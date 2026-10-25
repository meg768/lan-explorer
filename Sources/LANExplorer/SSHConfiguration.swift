import AppKit
import Foundation
import Security
import SwiftUI

struct SSHCredentials: Codable {
    let name: String
    let privateKey: Data
    let passphrase: String
}

enum SSHConfiguration {
    private static let service = "se.egelberg.lan-explorer.ssh"

    static var usernames: [String] {
        parseUsernames(UserDefaults.standard.string(forKey: "sshUsernames") ?? "pi")
    }

    static func parseUsernames(_ text: String) -> [String] {
        var seen = Set<String>()
        return text.split { $0 == "," || $0.isWhitespace }.map(String.init).filter {
            $0.range(of: #"^[a-zA-Z0-9_][a-zA-Z0-9_.-]*$"#, options: .regularExpression) != nil
                && seen.insert($0).inserted
        }
    }

    static func load() throws -> SSHCredentials? {
        var query = keychainQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        try check(status)
        guard let data = item as? Data else { throw ConfigurationError.invalidKey }
        return try JSONDecoder().decode(SSHCredentials.self, from: data)
    }

    static func save(_ credentials: SSHCredentials, usernames: String) throws {
        let data = try JSONEncoder().encode(credentials)
        let attributes = [kSecValueData as String: data]
        let status = SecItemUpdate(keychainQuery as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var query = keychainQuery
            query[kSecValueData as String] = data
            query[kSecAttrLabel as String] = "LAN Explorer SSH key"
            try check(SecItemAdd(query as CFDictionary, nil))
        } else {
            try check(status)
        }
        UserDefaults.standard.set(parseUsernames(usernames).joined(separator: ", "), forKey: "sshUsernames")
        NotificationCenter.default.post(name: .sshConfigurationChanged, object: nil)
    }

    static func remove() throws {
        let status = SecItemDelete(keychainQuery as CFDictionary)
        if status != errSecItemNotFound { try check(status) }
        NotificationCenter.default.post(name: .sshConfigurationChanged, object: nil)
    }

    static func importedKey(at url: URL) throws -> Data {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        guard size > 0, size <= 65_536 else { throw ConfigurationError.invalidKey }
        let data = try Data(contentsOf: url)
        guard let text = String(data: data, encoding: .utf8),
              ["OPENSSH PRIVATE KEY", "RSA PRIVATE KEY", "EC PRIVATE KEY", "PRIVATE KEY"].contains(where: {
                  text.hasPrefix("-----BEGIN \($0)-----")
              }) else { throw ConfigurationError.invalidKey }
        return data
    }

    private static var keychainQuery: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: service,
         kSecAttrAccount as String: "private-key",
         kSecAttrSynchronizable as String: false]
    }

    private static func check(_ status: OSStatus) throws {
        guard status == errSecSuccess else {
            throw ConfigurationError.keychain(SecCopyErrorMessageString(status, nil) as String? ?? "Keychain error \(status)")
        }
    }

    enum ConfigurationError: LocalizedError {
        case invalidKey
        case keychain(String)

        var errorDescription: String? {
            switch self {
            case .invalidKey: return "Choose a private SSH key in OpenSSH or PEM format, not a .pub file."
            case .keychain(let message): return message
            }
        }
    }
}

extension Notification.Name {
    static let sshConfigurationChanged = Notification.Name("SSHConfigurationChanged")
}

// OpenSSH inherits access to the app container, but not a file-picker grant.
// Materialize the key only for the duration of an inspection in a private folder.
final class SSHSession {
    let directory: URL
    let keyURL: URL
    let knownHostsURL: URL
    let environment: [String: String]
    let hasPassphrase: Bool

    init(credentials: SSHCredentials) throws {
        let manager = FileManager.default
        let cache = try manager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        directory = cache.appendingPathComponent("LANExplorerSSH", isDirectory: true).appendingPathComponent(UUID().uuidString, isDirectory: true)
        keyURL = directory.appendingPathComponent("identity")
        let support = try manager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("LANExplorer/SSH", isDirectory: true)
        try manager.createDirectory(at: support, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        knownHostsURL = support.appendingPathComponent("known_hosts")
        hasPassphrase = !credentials.passphrase.isEmpty
        #if SWIFT_PACKAGE
        let resourceBundle = Bundle.module
        #else
        let resourceBundle = Bundle.main
        #endif
        environment = [
            "SSH_ASKPASS": resourceBundle.url(forResource: "ssh-askpass", withExtension: "sh")?.path ?? "",
            "SSH_ASKPASS_REQUIRE": "force",
            "DISPLAY": "LANExplorer",
            "LAN_EXPLORER_PASSPHRASE_FILE": directory.appendingPathComponent("passphrase").path
        ]
        do {
            try manager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
            try credentials.privateKey.write(to: keyURL, options: .atomic)
            try manager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: keyURL.path)
            if hasPassphrase {
                let url = directory.appendingPathComponent("passphrase")
                try Data((credentials.passphrase + "\n").utf8).write(to: url, options: .atomic)
                try manager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
            }
        } catch {
            try? manager.removeItem(at: directory)
            throw error
        }
    }

    deinit { try? FileManager.default.removeItem(at: directory) }

    func arguments(user: String, host: String) -> [String] {
        ["-F", "/dev/null", "-i", keyURL.path,
         "-o", "BatchMode=\(hasPassphrase ? "no" : "yes")",
         "-o", "IdentitiesOnly=yes", "-o", "IdentityAgent=none",
         "-o", "UserKnownHostsFile=\(knownHostsURL.path)",
         "-o", "PreferredAuthentications=publickey", "-o", "PasswordAuthentication=no",
         "-o", "KbdInteractiveAuthentication=no", "-o", "NumberOfPasswordPrompts=1",
         "-o", "ConnectTimeout=4", "-o", "StrictHostKeyChecking=accept-new",
         "\(user)@\(host)"]
    }
}

struct SSHSettingsView: View {
    @State private var usernames = UserDefaults.standard.string(forKey: "sshUsernames") ?? "pi"
    @State private var credentials: SSHCredentials?
    @State private var pendingKey: Data?
    @State private var keyName = "No key selected"
    @State private var passphrase = ""
    @State private var testHost = ""
    @State private var message = ""
    @State private var isTesting = false
    @State private var isError = false

    var body: some View {
        Form {
            Section("SSH access") {
                Text("Use one SSH key across your devices. Device information is read using the usernames below.")
                    .foregroundStyle(.secondary)
                TextField("Usernames", text: $usernames, prompt: Text("pi, magnus"))
                LabeledContent("Private key") {
                    Text(keyName).lineLimit(1).truncationMode(.middle)
                    Button("Choose key…", action: chooseKey)
                }
                SecureField("Key passphrase", text: $passphrase,
                            prompt: Text(credentials == nil || pendingKey != nil ? "Optional" : "Leave blank to keep saved passphrase"))
                Text("The key and any passphrase are saved in this Mac’s Keychain. Remove the saved key to revoke access. Keys are never uploaded by LAN Explorer.")
                    .font(.caption).foregroundStyle(.secondary)
                HStack {
                    Button("Remove saved key", action: remove).disabled(credentials == nil || isTesting)
                    Spacer()
                    Button("Save", action: save).disabled(isTesting || SSHConfiguration.parseUsernames(usernames).isEmpty || (credentials == nil && pendingKey == nil))
                }
            }
            Section("Test connection") {
                TextField("Device address", text: $testHost, prompt: Text("Hostname or IP address"))
                    .onSubmit(test)
                HStack {
                    Button("Test connection", action: test).disabled(isTesting || testHost.trimmingCharacters(in: .whitespaces).isEmpty)
                    if isTesting { ProgressView().controlSize(.small) }
                }
                if !message.isEmpty {
                    Text(message).foregroundStyle(isError ? Color.red : Color.secondary).textSelection(.enabled)
                }
            }
        }
        .formStyle(.grouped)
        .buttonStyle(.bordered)
        .frame(width: 560, height: 540)
        .onAppear(perform: load)
    }

    private func load() {
        do {
            credentials = try SSHConfiguration.load()
            keyName = credentials?.name ?? "No key selected"
        } catch { show(error.localizedDescription, error: true) }
    }

    private func chooseKey() {
        let panel = NSOpenPanel()
        panel.title = "Choose a private SSH key"
        panel.message = "Select the private key, not the matching .pub file. A copy will be saved in this Mac’s Keychain when you click Save."
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.showsHiddenFiles = true
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            pendingKey = try SSHConfiguration.importedKey(at: url)
            keyName = url.lastPathComponent
            passphrase = ""
            show("Key selected. Click Save to use it across your devices.")
        } catch { show(error.localizedDescription, error: true) }
    }

    private func save() {
        guard let key = pendingKey ?? credentials?.privateKey else { return }
        let saved = SSHCredentials(name: keyName, privateKey: key,
                                   passphrase: pendingKey != nil ? passphrase : (passphrase.isEmpty ? credentials?.passphrase ?? "" : passphrase))
        do {
            try SSHConfiguration.save(saved, usernames: usernames)
            credentials = saved
            pendingKey = nil
            passphrase = ""
            show("SSH settings saved for all devices.")
        } catch { show(error.localizedDescription, error: true) }
    }

    private func remove() {
        do {
            try SSHConfiguration.remove()
            credentials = nil
            pendingKey = nil
            passphrase = ""
            keyName = "No key selected"
            show("Saved SSH key removed.")
        } catch { show(error.localizedDescription, error: true) }
    }

    private func test() {
        let host = testHost.trimmingCharacters(in: .whitespacesAndNewlines)
        guard host.range(of: #"^[a-zA-Z0-9][a-zA-Z0-9.:%_-]*$"#, options: .regularExpression) != nil else {
            show("Enter a hostname or IP address without a username or URL.", error: true)
            return
        }
        save()
        if isError { return }
        isTesting = true
        show("Testing SSH connection…")
        Task {
            let result = await NetworkScanner().testSSH(host: host)
            isTesting = false
            show(result.message, error: !result.succeeded)
        }
    }

    private func show(_ text: String, error: Bool = false) {
        message = text
        isError = error
    }
}

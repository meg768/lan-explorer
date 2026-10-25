import Foundation
import XCTest
@testable import LANExplorer

final class SSHConfigurationTests: XCTestCase {
    func testUsernamesRejectOptionsAndDeduplicate() {
        XCTAssertEqual(SSHConfiguration.parseUsernames(" pi, magnus\npi root -oProxyCommand=x bad@name "),
                       ["pi", "magnus", "root"])
    }

    func testPublicKeyCannotBeImportedAsPrivateKey() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: url) }
        try Data("ssh-ed25519 AAAA not-a-private-key\n".utf8).write(to: url)
        XCTAssertThrowsError(try SSHConfiguration.importedKey(at: url))
    }

    func testOversizedKeyCannotBeImported() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: url) }
        try Data(repeating: 65, count: 65_537).write(to: url)
        XCTAssertThrowsError(try SSHConfiguration.importedKey(at: url))
    }

    func testSessionProtectsAndRemovesTemporaryCredentials() throws {
        let fixture = Data("test fixture, not a private key".utf8)
        var session: SSHSession? = try SSHSession(credentials: SSHCredentials(name: "fixture", privateKey: fixture, passphrase: "test-passphrase"))
        let directory = try XCTUnwrap(session?.directory)
        let keyURL = try XCTUnwrap(session?.keyURL)
        let passphraseURL = directory.appendingPathComponent("passphrase")
        XCTAssertEqual(try Data(contentsOf: keyURL), fixture)
        for (url, permissions) in [(directory, 0o700), (keyURL, 0o600), (passphraseURL, 0o600)] {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            XCTAssertEqual((attributes[.posixPermissions] as? NSNumber)?.intValue, permissions)
        }
        XCTAssertFalse(try XCTUnwrap(session?.environment).values.contains("test-passphrase"))
        session = nil
        XCTAssertFalse(FileManager.default.fileExists(atPath: directory.path))
    }

    func testSSHIsIsolatedFromDefaultKeysAndPreservesHostVerification() throws {
        let session = try SSHSession(credentials: SSHCredentials(name: "fixture", privateKey: Data(), passphrase: ""))
        let arguments = session.arguments(user: "pi", host: "192.168.86.41")
        XCTAssertEqual(Array(arguments.prefix(2)), ["-F", "/dev/null"])
        XCTAssertTrue(arguments.contains("IdentitiesOnly=yes"))
        XCTAssertTrue(arguments.contains("IdentityAgent=none"))
        XCTAssertTrue(arguments.contains("StrictHostKeyChecking=accept-new"))
        XCTAssertTrue(arguments.contains("PasswordAuthentication=no"))
        XCTAssertTrue(arguments.contains("BatchMode=yes"))
        XCTAssertTrue(arguments.contains("UserKnownHostsFile=\(session.knownHostsURL.path)"))
        XCTAssertEqual(arguments.last, "pi@192.168.86.41")
    }
}

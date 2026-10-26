import Foundation
import XCTest
@testable import NetworkExplorer

final class SSHConfigurationTests: XCTestCase {
    func testAutomaticAccessKeepsMacAndOriginalDeviceAccounts() {
        XCTAssertEqual(SSHConfiguration.connectionUsers, [nil, "pi", "root"])
    }

    func testOpenSSHConfigSuppliesUserPortKeysAgentAndHostDatabase() throws {
        let configuration = try effectiveConfiguration(user: nil)
        XCTAssertEqual(configuration["user"], "device-account")
        XCTAssertEqual(configuration["hostname"], "127.0.0.1")
        XCTAssertEqual(configuration["port"], "2222")
        XCTAssertEqual(configuration["identityfile"], "/tmp/network-explorer-fixture-key")
        XCTAssertEqual(configuration["identityagent"], "/tmp/network-explorer-fixture-agent")
        XCTAssertEqual(configuration["userknownhostsfile"], "/tmp/network-explorer-fixture-known-hosts")
    }

    func testExplicitFallbackChangesOnlyTheAccount() throws {
        let configuration = try effectiveConfiguration(user: "another-account")
        XCTAssertEqual(configuration["user"], "another-account")
        XCTAssertEqual(configuration["port"], "2222")
        XCTAssertEqual(configuration["identityfile"], "/tmp/network-explorer-fixture-key")
    }

    func testBackgroundInspectionKeepsHostChecksWithoutInteractiveOrForwardingSideEffects() throws {
        let configuration = try effectiveConfiguration(user: nil)
        XCTAssertEqual(configuration["batchmode"], "yes")
        XCTAssertEqual(configuration["stricthostkeychecking"], "accept-new")
        XCTAssertEqual(configuration["clearallforwardings"], "yes")
        XCTAssertEqual(configuration["forwardagent"], "no")
        XCTAssertEqual(configuration["forwardx11"], "no")
        XCTAssertEqual(configuration["permitlocalcommand"], "no")
        XCTAssertEqual(configuration["requesttty"], "false")
        XCTAssertNil(configuration["localforward"])
    }

    private func effectiveConfiguration(user: String?) throws -> [String: String] {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let config = directory.appendingPathComponent("config")
        try """
        Host fixture-device
            HostName 127.0.0.1
            User device-account
            Port 2222
            IdentityFile /tmp/network-explorer-fixture-key
            IdentityAgent /tmp/network-explorer-fixture-agent
            UserKnownHostsFile /tmp/network-explorer-fixture-known-hosts
            ForwardAgent yes
            ForwardX11 yes
            PermitLocalCommand yes
            RequestTTY force
            LocalForward 127.0.0.1:12345 example.invalid:22
        """.write(to: config, atomically: true, encoding: .utf8)
        let process = Process()
        let output = Pipe()
        let errors = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/ssh")
        process.arguments = ["-G", "-F", config.path] + SSHConfiguration.arguments(user: user, host: "fixture-device")
        process.standardOutput = output
        process.standardError = errors
        try process.run()
        let data = output.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        XCTAssertEqual(process.terminationStatus, 0)
        var values: [String: String] = [:]
        for line in String(decoding: data, as: UTF8.self).split(separator: "\n") {
            let parts = line.split(separator: " ", maxSplits: 1)
            if parts.count == 2 { values[String(parts[0])] = String(parts[1]) }
        }
        return values
    }
}

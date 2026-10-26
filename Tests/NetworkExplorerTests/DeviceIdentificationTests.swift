import Foundation
import XCTest
@testable import NetworkExplorer

final class DeviceIdentificationTests: XCTestCase {
    func testObservedTeslaIsIdentifiedWithoutOpenServices() {
        let device = makeDevice(hostname: "tesla_model_3", mac: "4c:fc:aa:00:00:01")
        XCTAssertEqual(device.vendor, "Tesla")
        XCTAssertEqual(device.deviceType, "Tesla Model 3 / electric vehicle candidate")
        XCTAssertTrue(device.services.isEmpty)
    }

    func testModelCanComeFromDNSWithoutAVendorMatch() {
        var device = makeDevice(hostname: nil, mac: "02:00:00:00:00:01")
        device.dnsName = "Tesla-Model-Y.local"
        XCTAssertNil(device.vendor)
        XCTAssertEqual(device.deviceType, "Tesla Model Y / electric vehicle candidate")
    }

    func testTeslaVendorAloneDoesNotImplyACarOrModel() {
        let device = makeDevice(hostname: "powerwall", mac: "4C:FC:AA:00:00:01")
        XCTAssertEqual(device.vendor, "Tesla")
        XCTAssertEqual(device.deviceType, "Tesla device")
    }

    func testSimilarNamesDoNotMatchVehicleModels() {
        for name in ["teslamate", "not-tesla-model-3", "tesla_model_30", "tesla_model_server"] {
            XCTAssertEqual(makeDevice(hostname: name, mac: "00:00:00:00:00:01").deviceType, "", name)
        }
    }

    func testExistingMacAndRaspberryPiHintsRemainAvailable() {
        XCTAssertTrue(makeDevice(hostname: "MacBook-Air", mac: "f4:5c:89:00:00:01").deviceType.contains("Mac / macOS candidate"))
        XCTAssertTrue(makeDevice(hostname: "pi-kato", mac: "b8:27:eb:00:00:01").deviceType.contains("Raspberry Pi"))
    }

    private func makeDevice(hostname: String?, mac: String) -> NetworkDevice {
        NetworkDevice(ipAddress: "192.0.2.22", hostname: hostname, dnsName: nil,
                      macAddress: mac, vendor: NetworkScanner.vendorName(for: mac),
                      responseTimeMS: nil, services: [], lastSeen: Date())
    }
}

import Foundation
import Combine

@MainActor
final class ScannerStore: ObservableObject {
    @Published var devices: [NetworkDevice] = []
    @Published var localNetwork = NetworkScanner.localNetwork()
    @Published var status: ScanStatus = .idle
    @Published var isScanning = false
    @Published var isBusy = false
    @Published var scanProgress = 0.0
    @Published private(set) var inspections: [String: DeviceInspection] = [:]
    @Published private(set) var inspectingDeviceIDs: Set<String> = []

    private let scanner = NetworkScanner()
    private var autoScanTask: Task<Void, Never>?
    private let autoScanIntervalSeconds = 30.0
    private var inspectionGeneration = 0

    func refreshLocalNetwork() {
        localNetwork = NetworkScanner.localNetwork()
    }

    func scan() {
        Task {
            await scanOnce()
        }
    }

    func startAutoScan() {
        guard autoScanTask == nil else {
            return
        }

        refreshLocalNetwork()
        autoScanTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                guard let self else {
                    return
                }

                await self.scanOnce()
                do {
                    try await Task.sleep(for: .seconds(self.autoScanIntervalSeconds))
                } catch {
                    return
                }
            }
        }
    }

    func stopAutoScan() {
        autoScanTask?.cancel()
        autoScanTask = nil
    }

    func inspect(_ device: NetworkDevice) {
        guard inspections[device.id] == nil || inspections[device.id]?.accessDenied == true else { return }
        guard !inspectingDeviceIDs.contains(device.id) else { return }
        inspectingDeviceIDs.insert(device.id)
        let generation = inspectionGeneration
        Task {
            let result = await scanner.inspect(device: device)
            inspectingDeviceIDs.remove(device.id)
            guard generation == inspectionGeneration else {
                inspect(device)
                return
            }
            inspections[device.id] = result
        }
    }

    func resetInspections() {
        inspectionGeneration += 1
        inspections.removeAll()
    }

    private func scanOnce() async {
        guard !isBusy else {
            return
        }

        isBusy = true
        isScanning = true
        scanProgress = 0
        status = .scanning("Scanning local network...")
        refreshLocalNetwork()

        do {
            let foundDevices = try await scanner.scan { completed, total in
                Task { @MainActor in
                    self.scanProgress = total > 0 ? Double(completed) / Double(total) : 0
                    self.status = .scanning("Scanned \(completed) of \(total) addresses...")
                }
            }

            mergeDevices(foundDevices)
            isScanning = false
            scanProgress = 0
            status = .complete("Scan complete")
            isBusy = false
        } catch {
            status = .failed(error.localizedDescription)
            isScanning = false
            scanProgress = 0
            isBusy = false
        }
    }

    private func mergeDevices(_ incomingDevices: [NetworkDevice]) {
        var merged = Dictionary(uniqueKeysWithValues: devices.map { ($0.ipAddress, $0) })

        for incomingDevice in incomingDevices {
            if let currentDevice = merged[incomingDevice.ipAddress] {
                merged[incomingDevice.ipAddress] = mergedDevice(currentDevice, with: incomingDevice)
            } else {
                merged[incomingDevice.ipAddress] = incomingDevice
            }
        }

        devices = merged.values.sorted { $0.tableIPSortKey < $1.tableIPSortKey }
    }

    private func mergedDevice(_ currentDevice: NetworkDevice, with incomingDevice: NetworkDevice) -> NetworkDevice {
        var nextDevice = incomingDevice
        nextDevice.hostname = incomingDevice.hostname ?? currentDevice.hostname
        nextDevice.dnsName = incomingDevice.dnsName ?? currentDevice.dnsName
        nextDevice.macAddress = incomingDevice.macAddress ?? currentDevice.macAddress
        nextDevice.vendor = incomingDevice.vendor ?? currentDevice.vendor
        nextDevice.responseTimeMS = incomingDevice.responseTimeMS ?? currentDevice.responseTimeMS
        return nextDevice
    }
}


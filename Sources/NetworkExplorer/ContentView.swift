import AppKit
import SwiftUI

struct ContentView: View {
    @StateObject private var store = ScannerStore()
    @State private var searchText = ""
    @State private var selectedDeviceID: NetworkDevice.ID?
    @State private var sortOrder = [KeyPathComparator(\NetworkDevice.displayName, comparator: .localizedStandard)]

    private var selectedDevice: NetworkDevice? {
        store.devices.first { $0.id == selectedDeviceID }
    }

    private var filteredDevices: [NetworkDevice] {
        store.devices.filter { device in
            searchText.isEmpty || [device.ipAddress, device.hostname, device.dnsName,
                                   device.macAddress, device.vendor, device.deviceType]
                .compactMap { $0 }
                .joined(separator: " ")
                .localizedCaseInsensitiveContains(searchText)
        }.sorted { lhs, rhs in
            for comparator in sortOrder {
                let result = comparator.compare(lhs, rhs)
                if result != .orderedSame { return result == .orderedAscending }
            }
            return lhs.tableIPSortKey < rhs.tableIPSortKey
        }
    }

    // Table may clear a selection when filtering hides its row. Keep the logical
    // selection so the details and the row are restored when the filter clears.
    private var tableSelection: Binding<NetworkDevice.ID?> {
        Binding {
            selectedDeviceID
        } set: { value in
            if value != nil || filteredDevices.contains(where: { $0.id == selectedDeviceID }) {
                selectedDeviceID = value
            }
        }
    }

    private var deviceTable: some View {
        Table(filteredDevices, selection: tableSelection, sortOrder: $sortOrder) {
            TableColumn("Address", value: \.tableIPSortKey) { device in
                Text(device.ipAddress).monospacedDigit()
            }
            .width(min: 110, ideal: 130)
            TableColumn("Name", value: \.displayName)
                .width(min: 150, ideal: 220)
            TableColumn("Vendor", value: \.tableVendor) { device in
                Text(device.vendor ?? "—")
            }
            .width(min: 120, ideal: 180)
            TableColumn("Device Type", value: \.deviceType) { device in
                Text(device.deviceType.isEmpty ? "—" : device.deviceType)
                    .lineLimit(1)
                    .help(device.deviceType.isEmpty ? "Unknown device type" : device.deviceType)
            }
            .width(min: 140, ideal: 220)

        }
    }

    var body: some View {
        VStack(spacing: 0) {
            workspace
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("Network Explorer")
        .navigationSubtitle(store.localNetwork?.displayName ?? "No local IPv4 network")
        .toolbar {
            ToolbarItem {
                Button(action: store.scan) {
                    Label("Scan Network", systemImage: "arrow.clockwise")
                }
                .keyboardShortcut("r", modifiers: .command)
                .disabled(store.isBusy)
                .help("Scan network (⌘R)")
            }

        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                Divider()
                HStack {
                    if store.isScanning {
                        ProgressView(value: store.scanProgress)
                            .frame(width: 80)
                            .accessibilityLabel("Network scan progress")
                    }
                    Text(store.status.text)
                    Spacer()
                    Text(store.devices.count == 1 ? "1 device" : "\(store.devices.count) devices")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(.bar)
        }
        .onChange(of: selectedDeviceID) { _, _ in
            if let selectedDevice { store.inspect(selectedDevice) }
        }
        .onAppear {
            store.startAutoScan()
        }
        .onDisappear { store.stopAutoScan() }
    }

    private var workspace: some View {
        DeviceWorkspace() {
            deviceTable
                .searchable(text: $searchText, placement: .toolbar, prompt: "Filter devices")
        } details: {
            DeviceDetails(
                device: selectedDevice,
                inspection: selectedDeviceID.flatMap { store.inspections[$0] },
                isInspecting: selectedDeviceID.map { store.inspectingDeviceIDs.contains($0) } ?? false
            )
        }
    }

}

// Only the content is divided; the window toolbar remains a single system toolbar.
private struct DeviceWorkspace<TableContent: View, Details: View>: View {
    @ViewBuilder let table: TableContent
    @ViewBuilder let details: Details
    @State private var preferredDetailsWidth: CGFloat = 340

    private let minimumTableWidth: CGFloat = 520
    private let minimumDetailsWidth: CGFloat = 300
    private let dividerWidth: CGFloat = 10

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let detailsWidth = clampedDetailsWidth(preferredDetailsWidth, availableWidth: width)

            HStack(spacing: 0) {
                table
                    .frame(width: width - detailsWidth - dividerWidth)
                    .frame(maxHeight: .infinity)
                ZStack {
                    Rectangle().fill(Color.clear)
                    HStack(spacing: 0) { Divider() }
                }
                    .frame(width: dividerWidth)
                    .frame(maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onHover { hovering in
                        (hovering ? NSCursor.resizeLeftRight : NSCursor.arrow).set()
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .named("DeviceWorkspace"))
                            .onChanged { value in
                                preferredDetailsWidth = clampedDetailsWidth(
                                    width - value.location.x - dividerWidth / 2,
                                    availableWidth: width
                                )
                            }
                    )
                    .accessibilityLabel("Device details width")
                    .accessibilityValue("\(Int(detailsWidth)) points")
                    .accessibilityAdjustableAction { direction in
                        switch direction {
                        case .increment:
                            preferredDetailsWidth = clampedDetailsWidth(detailsWidth + 20, availableWidth: width)
                        case .decrement:
                            preferredDetailsWidth = clampedDetailsWidth(detailsWidth - 20, availableWidth: width)
                        @unknown default:
                            break
                        }
                    }
                details
                    .frame(width: detailsWidth)
                    .frame(maxHeight: .infinity)
            }
            .coordinateSpace(name: "DeviceWorkspace")
        }
        .frame(minWidth: minimumTableWidth + minimumDetailsWidth + dividerWidth)
    }

    private func clampedDetailsWidth(_ width: CGFloat, availableWidth: CGFloat) -> CGFloat {
        min(max(width, minimumDetailsWidth), max(minimumDetailsWidth, availableWidth - minimumTableWidth - dividerWidth))
    }
}

private struct DeviceDetails: View {
    let device: NetworkDevice?
    let inspection: DeviceInspection?
    let isInspecting: Bool

    private var findings: [DeviceInspectionItem] {
        inspection?.systemFindings.filter {
            !["Last seen", "Ping response", "DNS name"].contains($0.name)
        } ?? []
    }

    var body: some View {
        Group {
            if let device {
                Form {
                    Section(device.displayName) {
                        LabeledContent("IP address", value: device.ipAddress)
                        LabeledContent("MAC address", value: device.macAddress ?? "Unknown")
                        LabeledContent("Vendor", value: device.vendor ?? "Unknown")
                        if let dnsName = device.dnsName {
                            LabeledContent("DNS name", value: dnsName)
                        }
                    }
                    Section("Activity") {
                        LabeledContent("Ping", value: device.pingText)
                        LabeledContent("Last seen") {
                            Text(device.lastSeen, format: .dateTime.hour().minute().second())
                        }
                    }
                    if let inspection {
                        if inspection.accessDenied {
                            Section {
                                Text(ScannerError.localNetworkDenied.localizedDescription)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            if !inspection.likelyTypes.isEmpty {
                                Section("Device type") {
                                    ForEach(inspection.likelyTypes, id: \.self) { Text($0) }
                                }
                            }
                            Section("Services") {
                                if inspection.openServices.isEmpty {
                                    Text("No services found").foregroundStyle(.secondary)
                                } else {
                                    ForEach(inspection.openServices) { item in
                                        InspectionRow(item: item, sshURL: item.port == 22
                                            ? (inspection.systemFindings.compactMap(\.sshURL).first
                                                ?? SSHConfiguration.terminalURL(user: nil, host: device.ipAddress))
                                            : nil)
                                    }
                                }
                            }
                            Section("System information") {
                                if findings.isEmpty {
                                    Text("No system information found").foregroundStyle(.secondary)
                                } else {
                                    ForEach(findings) { item in
                                        InspectionRow(item: item)
                                    }
                                }
                            }
                            if !inspection.notes.isEmpty {
                                Section("Notes") {
                                    ForEach(inspection.notes, id: \.self) { Text($0) }
                                }
                            }
                        }
                    } else if isInspecting {
                        Section {
                            HStack {
                                ProgressView().controlSize(.small)
                                Text("Inspecting device…").foregroundStyle(.secondary)
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }
                }
                .formStyle(.grouped)
            } else {
                ContentUnavailableView("Select a Device", systemImage: "network",
                    description: Text("Select a device to explore its services and system information."))
            }
        }
        .textSelection(.enabled)
    }

}

private struct InspectionRow: View {
    let item: DeviceInspectionItem
    var sshURL: URL? = nil
    @State private var terminalError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(item.name, systemImage: item.systemImage)
            Text(item.port.map { "Port \($0) · \(item.detail)" } ?? item.detail)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if let progress = item.progress {
                ProgressView(value: progress)
            }
            if let sshURL {
                Button {
                    openTerminal(sshURL)
                } label: {
                    Label("Open in Terminal", systemImage: "terminal")
                }
                .buttonStyle(.bordered)
                .help("Connect to \(sshURL.user.map { "\($0)@" } ?? "")\(sshURL.host ?? "") using SSH")
                .padding(.top, 8)
                .padding(.bottom, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
                if let terminalError {
                    Text(terminalError).font(.caption).foregroundStyle(.red)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }

    private func openTerminal(_ url: URL) {
        terminalError = nil
        guard let terminal = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal") else {
            terminalError = "Terminal could not be found."
            return
        }
        Task { @MainActor in
            do {
                try await NSWorkspace.shared.open([url], withApplicationAt: terminal,
                                                  configuration: NSWorkspace.OpenConfiguration())
            } catch {
                terminalError = "Could not open Terminal: \(error.localizedDescription)"
            }
        }
    }
}

import AppKit
import SwiftUI

struct ContentView: View {
    @StateObject private var store = ScannerStore()
    @State private var searchText = ""
    @State private var showDetails = true
    @State private var detailPath: [DetailPage] = []
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
            TableColumn("Last Seen", value: \.lastSeen) { device in
                Text(device.lastSeen, format: .dateTime.hour().minute().second())
                    .monospacedDigit()
            }
            .width(min: 85, ideal: 100)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            workspace
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("LAN Scanner")
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
            ToolbarItem {
                Button {
                    showDetails.toggle()
                } label: {
                    Label(showDetails ? "Hide Details" : "Show Details", systemImage: "sidebar.right")
                }
                .help(showDetails ? "Hide device details" : "Show device details")
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
            detailPath.removeAll()
            if let selectedDevice { store.inspect(selectedDevice) }
        }
        .onAppear { store.startAutoScan() }
        .onDisappear { store.stopAutoScan() }
    }

    private var workspace: some View {
        DeviceWorkspace(showDetails: showDetails) {
            deviceTable
                .searchable(text: $searchText, placement: .toolbar, prompt: "Filter devices")
        } details: {
            DeviceDetails(
                path: $detailPath,
                device: selectedDevice,
                inspection: selectedDeviceID.flatMap { store.inspections[$0] },
                isInspecting: selectedDeviceID.map { store.inspectingDeviceIDs.contains($0) } ?? false
            )
        }
    }
}

// Only the content is divided; the window toolbar remains a single system toolbar.
private struct DeviceWorkspace<TableContent: View, Details: View>: View {
    let showDetails: Bool
    @ViewBuilder let table: TableContent
    @ViewBuilder let details: Details
    @State private var preferredDetailsWidth: CGFloat = 340

    private let minimumTableWidth: CGFloat = 300
    private let minimumDetailsWidth: CGFloat = 280
    private let dividerWidth: CGFloat = 10

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let detailsWidth = clampedDetailsWidth(preferredDetailsWidth, availableWidth: width)

            HStack(spacing: 0) {
                table
                    .frame(width: showDetails ? width - detailsWidth - dividerWidth : width)
                    .frame(maxHeight: .infinity)
                if showDetails {
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
            }
            .coordinateSpace(name: "DeviceWorkspace")
        }
        .frame(minWidth: showDetails ? minimumTableWidth + minimumDetailsWidth + dividerWidth : minimumTableWidth)
    }

    private func clampedDetailsWidth(_ width: CGFloat, availableWidth: CGFloat) -> CGFloat {
        min(max(width, minimumDetailsWidth), max(minimumDetailsWidth, availableWidth - minimumTableWidth - dividerWidth))
    }
}

private enum DetailPage: Hashable {
    case services
    case system
    case finding(String)
}

private struct DeviceDetails: View {
    @Binding var path: [DetailPage]
    let device: NetworkDevice?
    let inspection: DeviceInspection?
    let isInspecting: Bool

    private var findings: [DeviceInspectionItem] {
        inspection?.systemFindings.filter {
            !["Last seen", "Ping response", "DNS name"].contains($0.name)
        } ?? []
    }

    var body: some View {
        NavigationStack(path: $path) {
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
                            if !inspection.likelyTypes.isEmpty {
                                Section("Device type") {
                                    ForEach(inspection.likelyTypes, id: \.self) { Text($0) }
                                }
                            }
                            Section("Explore") {
                                NavigationLink(value: DetailPage.services) {
                                    LabeledContent {
                                        Text(inspection.openServices.count, format: .number)
                                    } label: {
                                        Label("Services", systemImage: "network")
                                    }
                                }
                                NavigationLink(value: DetailPage.system) {
                                    LabeledContent {
                                        Text(findings.count, format: .number)
                                    } label: {
                                        Label("System information", systemImage: "desktopcomputer")
                                    }
                                }
                            }
                            if !inspection.notes.isEmpty {
                                Section("Notes") {
                                    ForEach(inspection.notes, id: \.self) { Text($0) }
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
            .navigationDestination(for: DetailPage.self) { page in
                switch page {
                case .services:
                    findingsList(inspection?.openServices ?? [], title: "Services")
                case .system:
                    findingsList(findings, title: "System information")
                case .finding(let id):
                    if let item = ((inspection?.openServices ?? []) + findings).first(where: { $0.id == id }) {
                        Form {
                            Section(item.name) {
                                if let port = item.port {
                                    LabeledContent("Port", value: String(port))
                                }
                                Text(item.detail)
                                if let progress = item.progress {
                                    ProgressView(value: progress)
                                }
                            }
                        }
                        .formStyle(.grouped)
                    }
                }
            }
        }
        .textSelection(.enabled)
    }

    private func findingsList(_ items: [DeviceInspectionItem], title: String) -> some View {
        List {
            Section(title) {
                ForEach(items) { item in
                    NavigationLink(value: DetailPage.finding(item.id)) {
                        InspectionRow(item: item)
                    }
                }
            }
        }
        .overlay {
            if items.isEmpty {
                ContentUnavailableView("No findings", systemImage: "magnifyingglass",
                    description: Text("No additional information was found for this device."))
            }
        }
    }
}

private struct InspectionRow: View {
    let item: DeviceInspectionItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(item.name, systemImage: item.systemImage)
            Text(item.port.map { "Port \($0) · \(item.detail)" } ?? item.detail)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            if let progress = item.progress {
                ProgressView(value: progress)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
}

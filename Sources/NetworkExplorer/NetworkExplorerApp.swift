import AppKit
import SwiftUI

@main
struct NetworkExplorerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 1000, height: 650)
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Network Explorer") {
                    let info = Bundle.main.infoDictionary ?? [:]
                    let version = info["CFBundleShortVersionString"] as? String ?? "1.0"
                    let timestamp = info["ExplorerBuildTimestamp"] as? String ?? ""
                    NSApp.orderFrontStandardAboutPanel(options: [
                        .applicationVersion: "Version \(version)\nBuild \(timestamp)",
                        .version: "",
                    ])
                }
            }
            CommandGroup(replacing: .help) {
                Button("Network Explorer Help") {
                    guard let url = URL(string: "https://meg768.github.io/network-explorer/") else { return }
                    NSWorkspace.shared.open(url)
                }
                .keyboardShortcut("?", modifiers: .command)
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    // An off-menu help menu suppresses AppKit's automatic Spotlight Search field.
    private let spotlightHelpMenu = NSMenu()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.helpMenu = spotlightHelpMenu
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationDidUpdate(_ notification: Notification) {
        if NSApp.helpMenu !== spotlightHelpMenu {
            NSApp.helpMenu = spotlightHelpMenu
        }
    }
}

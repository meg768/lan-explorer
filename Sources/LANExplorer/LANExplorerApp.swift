import AppKit
import SwiftUI

@main
struct LANExplorerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 1000, height: 650)
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About LAN Explorer") {
                    let info = Bundle.main.infoDictionary ?? [:]
                    let version = info["CFBundleShortVersionString"] as? String ?? "1.0"
                    let timestamp = info["ExplorerBuildTimestamp"] as? String ?? ""
                    NSApp.orderFrontStandardAboutPanel(options: [
                        .applicationVersion: "Version \(version)\nBuild \(timestamp)",
                        .version: "",
                    ])
                }
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

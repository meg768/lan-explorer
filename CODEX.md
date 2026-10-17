# LAN Explorer project context

## Identity and repository

- Repository: https://github.com/meg768/lan-explorer
- Local path: `/Users/magnus/Documents/GitHub/lan-explorer`
- App: **LAN Explorer**, bundle identifier `se.egelberg.lan-explorer`.
- Swift package, executable, target, module and Xcode-generated scheme: `LANExplorer`.
- Minimum platform: macOS 14; entry point: `Sources/LANExplorer/LANExplorerApp.swift`.
- This is a Swift package, not a checked-in `.xcodeproj`. Open `Package.swift` in Xcode.
- LAN Explorer is a separate application. Never modify or overwrite the original LAN Scanner project or `/Applications/LAN Scanner.app`, and do not migrate its preferences.
- There are currently no explicit UserDefaults/AppStorage preferences. macOS-managed preferences and window state use the new app identity.

## Build and installation

- `swift build` and `swift build -c release` build the `LANExplorer` executable.
- `xcodebuild -list` lists the generated scheme; `xcodebuild -scheme LANExplorer -configuration Release -destination 'platform=macOS' -derivedDataPath /tmp/lan-explorer-xcode-build build` verifies the Xcode build.
- `Scripts/build-app.sh [release|debug]` assembles and ad-hoc signs `dist/LAN Explorer.app`.
- Install only as `/Applications/LAN Explorer.app`.
- `Scripts/build-dmg.sh` creates `dist/lan-explorer.dmg`; do not build a DMG or publish unless requested.
- Ad-hoc signing is for local use. External distribution requires appropriate Developer ID signing and notarization.
- Finder/File Provider extended attributes can invalidate ad-hoc signing under Documents. If necessary, assemble/sign outside Documents, copy with `ditto --norsrc --noextattr`, and verify the final destination with `codesign --verify --deep --strict`.

## Preserve functionality and GUI

- `NetworkScanner.swift` contains the existing networking actor: active private IPv4 `/24` discovery, ping, ARP, names, service-port inspection, HTTP fingerprints and passwordless SSH inspection.
- `ScannerStore.swift` owns scans, per-IP inspection cache and retained device data. Automatic scans pause 30 seconds after completion. Retaining older devices/ping and IP identity are intentional behavior.
- `ContentView.swift` owns stable selection, filtering, sorting, optional details and detail navigation. Resolve selection against the full device collection when filtering hides a row.
- The native Table columns are Address / Name / Vendor / Device Type / Last Seen. Ping stays in details. Search uses `.searchable` directly on the permanent Table with `.toolbar` placement.
- Keep the approved `DeviceWorkspace`: GeometryReader + HStack, a thin Divider in a 10-point drag target, and optional details. Details default to 340 points, minimum 280; table minimum 300. Widths clamp to available space and survive visibility changes during the session.
- The shared system toolbar must remain continuous. HSplitView and native split-container alternatives extended the divider into the toolbar. Toolbar style/background changes were not reliable after navigation and hiding/showing details; do not reintroduce those attempts.
- Detail NavigationStack stays confined to the right pane. Its path survives automatic updates and hiding/showing details, and clears only when the selected IP changes.
- Follow system appearance. No obsolete themes, F3/F6 shortcuts or empty Settings window.
- Icon consists of the blue signal symbol on transparency; preserve it when renaming resources.
- CUA mouse-gesture verification requires an active app: focus the search field before testing drag events.

## Rename verification

2026-10-17: Renamed app identity, Swift package/product/target, app entry point,
networking type/file, icon resources, packaging scripts and current documentation.
No scanning, selection, sorting, filtering, refresh or detail-navigation behavior was changed.
The `Before-Mac-Look` tag remains a historical pre-modernization checkpoint.

Verified Debug and Release Swift builds, the generated Xcode scheme/target and
Xcode Release build, plist/script validation, strict bundle signing, and identical
installed/staged bundle file hashes. Installed `/Applications/LAN Explorer.app`
and verified 49 discovered devices, search, numeric sorting, selection, successful
SSH/system inspection, detail navigation and hide/show across an automatic scan.
Normalized comparison against the pre-rename Swift files confirmed naming-only changes.
`/Applications/LAN Scanner.app` and the old `lan-scanner` checkout were already absent
when this work began; neither was removed, modified or recreated.

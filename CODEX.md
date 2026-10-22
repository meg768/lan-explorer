# LAN Explorer project context

## Identity and repository

- Repository: https://github.com/meg768/lan-explorer
- Local path: `/Users/magnus/Documents/GitHub/lan-explorer`
- App: **LAN Explorer**, bundle identifier `se.egelberg.lan-explorer`.
- Swift package, executable and module: `LANExplorer`. Native Xcode target and shared scheme: `lan-explorer`.
- Minimum platform: macOS 14; entry point: `Sources/LANExplorer/LANExplorerApp.swift`.
- Open `lan-explorer.xcodeproj` in Xcode for the native macOS app target and shared `lan-explorer` scheme. The Swift package remains available for local CLI builds.
- LAN Explorer is a separate application. Never modify or overwrite the original LAN Scanner project or `/Applications/LAN Scanner.app`, and do not migrate its preferences.
- There are currently no explicit UserDefaults/AppStorage preferences. macOS-managed preferences and window state use the new app identity.

## Build and installation

- `swift build` and `swift build -c release` build the `LANExplorer` executable.
- `xcodebuild -project lan-explorer.xcodeproj -scheme lan-explorer -configuration Debug -destination 'platform=macOS' build` builds the native app.
- Product > Archive, or `xcodebuild -project lan-explorer.xcodeproj -scheme lan-explorer -configuration Release -destination 'generic/platform=macOS' -archivePath /tmp/LANExplorer.xcarchive archive`, produces a native app archive.
- Xcode uses the existing team `52A6FA9VB5`, original bundle identifier and version `1.0 (3)`. Icons are copied from the existing ICNS into `Xcode/Assets.xcassets`.
- App Sandbox is disabled again on the user's instruction: sandboxing prevented existing SSH authentication and removed memory/disk/CPU information, which is core functionality. Preserve full SSH inspection. Do not re-enable sandbox or prepare another Store build until feature parity is demonstrated and the user approves that tradeoff. The previously uploaded sandboxed build is not the restored local version.
- Distribution status and remaining steps are documented in `DISTRIBUTION.md`.
- Install only as `/Applications/LAN Explorer.app`.
- Finder/File Provider extended attributes can invalidate ad-hoc signing under Documents. If necessary, build/sign outside Documents, copy with `ditto --norsrc --noextattr`, and verify the final destination with `codesign --verify --deep --strict`.

## Preserve functionality and GUI

- `NetworkScanner.swift` contains the existing networking actor: active private IPv4 `/24` discovery, ping, ARP, names, service-port inspection, HTTP fingerprints and passwordless SSH inspection.
- `ScannerStore.swift` owns scans, per-IP inspection cache and retained device data. Automatic scans pause 30 seconds after completion. Retaining older devices/ping and IP identity are intentional behavior.
- `ContentView.swift` owns stable selection, filtering, sorting and permanent details. Resolve selection against the full device collection when filtering hides a row.
- The native Table columns are Address / Name / Vendor / Device Type. Ping and Last seen stay in details. Search uses `.searchable` with toolbar placement.
- Keep the existing resizable DeviceWorkspace and continuous toolbar. Services and system information are inline; both panels stay visible. Avoid unnecessary split-container rewrites.
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

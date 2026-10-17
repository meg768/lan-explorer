# Codex Context

## Project

`LAN Scanner` is a native macOS SwiftUI app for scanning Magnus' local LAN. It detects the active private IPv4 network, scans the `/24`, reads ARP data where available, resolves names, detects common service ports, and highlights likely Raspberry Pi / home automation devices.

The app is intentionally local-first and small. It is not a hosted service.

## Repository

- Local path: `/Users/magnus/Documents/GitHub/lan-scanner`
- Swift package product: `LANScanner`
- Minimum platform: macOS 14
- App bundle output: `dist/LAN Scanner.app`
- DMG output: `dist/lan-scanner.dmg`

## Build

Useful commands:

```bash
swift build
Scripts/build-app.sh
Scripts/build-app.sh debug
Scripts/build-dmg.sh
```

`Scripts/build-app.sh` builds the Swift package, assembles `dist/LAN Scanner.app`, removes extended attributes, ad-hoc-signs the app, and verifies it with `codesign --verify --deep --strict`.

`Scripts/build-dmg.sh` builds the release app, creates a writable APFS DMG, copies the app into it, adds an `/Applications` symlink, clears extended attributes inside the mounted volume, ad-hoc-signs/verifies the app inside the volume, converts the DMG to compressed read-only `UDZO`, and verifies the DMG.

## Distribution Notes

2026-06-30: Downloading `lan-scanner.dmg` from `https://server.egelberg.se/lan-scanner.dmg` works, and the app can be made `codesign`-valid with ad-hoc signing. This is not enough for a frictionless double-click install from Safari on another Mac.

For a normal friend-facing web download, Apple Gatekeeper requires Developer ID signing and notarization. Without that, macOS may show warnings such as:

- "Apple could not verify that LAN Scanner is free from malware"
- "LAN Scanner is damaged and can't be opened" when the signature or extended attributes are wrong

Do not present `xattr -dr com.apple.quarantine` as an acceptable non-technical user solution unless Magnus explicitly asks for a workaround. It works technically, but it is not the simple installation experience he wants.

When checked on 2026-06-30, `security find-identity -v -p codesigning` returned `0 valid identities found`, so this Mac could not produce a real Developer ID-notarized release.

## Native macOS UI — 2026-10-16

- Table columns: Address / Name / Vendor / Device Type / Last Seen. Ping remains in the inspector. Device types reuse the inspector’s existing heuristic hints without triggering inspections. Automatic scans pause 30 seconds after completion.

- Replaced custom table, split panels, header, scan ring and surface themes with SwiftUI `Table`, toolbar search and standard progress (macOS 14 minimum retained).
- System appearance is automatic; F3/F6 theme controls and theme settings were removed. No Settings window is needed.
- `ScannerStore.swift` owns scanning and the per-IP inspection cache; `ContentView.swift` owns selection, filtering, sort order and native split-view presentation.
- Selection resolves against the complete device collection, including when filtering hides its row. Automatic updates retain per-IP IDs and do not recreate the view hierarchy or rerun cached inspections.
- Networking in `LANScanner.swift` is unchanged. Existing /24 discovery, retained historical devices/ping values and IP identity remain intentional scope limits for this GUI change.
- LAN Scanner is a private local utility. Earlier distribution notes below are historical; do not build DMGs or prepare publication unless requested.
- `Before-Mac-Look` marks the pre-modernization version (`2867114`).

## Gotchas

- `dmgbuild` and simple `hdiutil create -srcfolder` flows caused Finder metadata / extended attributes on the `.app` inside the DMG, which broke strict code-sign verification with errors like `resource fork, Finder information, or similar detritus not allowed`.
- The current `build-dmg.sh` flow exists to avoid that by signing the app after it has been copied into the mounted writable DMG.
- If the DMG or build process changes, verify the app after mounting the final DMG:

```bash
hdiutil attach -nobrowse -readonly dist/lan-scanner.dmg
codesign --verify --deep --strict --verbose=4 "/Volumes/LAN Scanner Installer/LAN Scanner.app"
spctl -a -vvv -t exec "/Volumes/LAN Scanner Installer/LAN Scanner.app"
```

`codesign_status=0` means the bundle is structurally signed correctly. `spctl` rejection still means the app is not Developer ID-notarized.

## Related Infrastructure

`server.egelberg.se` is served by Apache on `pi-kato` from `/var/www/html`. The public DMG path used during testing was:

```text
https://server.egelberg.se/lan-scanner.dmg
```

That hosting fact also lives in the global context at `/Users/magnus/Documents/GitHub/codex-chat/CONTEXT.md`.

- 2026-10-16: Magnus requested removing the icon background entirely. SVG/ICNS now contain only the existing blue signal symbol on transparency in all ten representations. This supersedes the earlier opaque-square correction.

- 2026-10-16: Search uses `.toolbar` rather than `.toolbarPrincipal`; the standard trailing search field adapts at narrow window widths without overlapping the inspector divider. Verified at 650-point minimum width with inspector open/closed.

- 2026-10-16: On Magnus’ explicit request, replaced `.inspector` with a standard two-column `NavigationSplitView`: Table in the sidebar, reused device information Form in detail. SidebarCommands/system sidebar toggle replace InspectorCommands/custom inspector toggle. No split-width calculations, explicit split widths or custom toolbar sizing. Table uses native horizontal scrolling when its columns exceed available width. Search, sort, selection, cached inspections and 30-second automatic scan pause remain unchanged.

- 2026-10-16: Supersedes the NavigationSplitView structure above: standard `HSplitView` now keeps Table permanently present; `showDetails` defaults to true and a regular toolbar button conditionally shows/hides the reused DeviceDetails view. When hidden, Table fills the window. Removed SidebarCommands. Native divider and flexible SwiftUI frames with readable minimum sizes (table 300, details 280 with ideal 340); no split-width calculations or custom positions. Selection, search, sort and inspection cache stay outside the conditional details view.

- 2026-10-17: GUI preview adds a NavigationStack confined to the optional HSplitView detail pane. Overview links to Services and System information, then individual findings show full selectable text. Navigation path lives in ContentView, survives detail visibility changes and automatic updates, and clears only when selected IP changes. Scanning/model logic unchanged. Built debug/release and visually checked search, numeric IP sorting, navigation, cached inspection, auto updates and panel visibility. Separate bundle ID `se.meg768.lan-scanner.preview`; do not replace /Applications until Magnus approves appearance.

- 2026-10-17: Investigated stopping the HSplitView divider below the shared toolbar while retaining the detail NavigationStack. `.windowToolbarStyle(.unified)` and `.toolbarBackground(.visible, for: .windowToolbar)` (at root and navigation stack) appeared successful in some initial states but failed after pushing navigation or hiding/showing details. `.expanded` also changed titlebar appearance and did not fully confine the divider. Reverted all trials; approved GUI remains unchanged. Do not claim these modifiers solve the issue based on a single screenshot. No AppKit manipulation, clipping, geometry or masks introduced.

- 2026-10-17: Magnus explicitly approved a small custom split container after comparison with broker-explorer. Replaced HSplitView with DeviceWorkspace (GeometryReader + HStack + a thin Divider in a 10-point drag target). Details default to 340 points with minimum 280, table minimum 300; widths clamp to the available content area. Preferred details width survives hiding and window resizing in the current session. The system toolbar remains continuous because there is no native split view extending its divider into the titlebar. Searchable is attached directly to the permanent Table so it stays in the window toolbar independently of the optional detail NavigationStack. Existing detail navigation, store, selection/filter/sort behavior and all network logic retained. Root uses system window background. Divider supports drag, resize cursor and accessibility increment/decrement. GUI preview only; no installation over /Applications.

- Final custom-container preview verification: Debug and Release builds passed and preview signature verified. Real LAN scan and subsequent automatic update retained filtered/sorted selection and open System information destination. Verified mouse drag from 340 to 390 points, accessibility adjustment, smaller/larger window, filtering the selected row out and back, and hiding/showing details with restored navigation and width. Toolbar search remained present and divider began below the shared toolbar. Preview: `/Users/magnus/Builds/lan-scanner-preview-_iovh3ec/LAN Scanner Preview.app`. For CUA gesture checks, first focus the app via its search field; inactive-window drags may deliver no SwiftUI gesture events.

- 2026-10-17: Magnus approved building and copying the custom-container version to `/Applications/LAN Scanner.app`. Release build passed; installed bundle passed strict signature verification and file hashes matched the signed staged bundle. Closed the preview and launched the installed app; verified the normal bundle identity, toolbar search, optional details and active network scanning. Previous installed bundle saved at `/var/folders/3t/lrgc1m3n52l350gm_r34yk1w0000gn/T/lan-scanner-install-rcffqz0e/Previous LAN Scanner.app`.

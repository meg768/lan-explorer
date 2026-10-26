# Network Explorer project context

## Identity and repository

- Repository: https://github.com/meg768/network-explorer
- Local path: `/Users/magnus/GitHub/network-explorer`
- App: **Network Explorer**, bundle identifier `se.egelberg.network-explorer`.
- Swift package, executable and module: `NetworkExplorer`. Native Xcode target and shared scheme: `network-explorer`.
- Minimum platform: macOS 14; entry point: `Sources/NetworkExplorer/NetworkExplorerApp.swift`.
- Open `network-explorer.xcodeproj` in Xcode for the native macOS app target and shared `network-explorer` scheme. The Swift package remains available for local CLI builds.
- Network Explorer is a separate application. Never modify or overwrite the original LAN Scanner project or `/Applications/LAN Scanner.app`, and do not migrate its preferences.
- Local SSH uses macOS OpenSSH with the user's existing keys, SSH agent, ~/.ssh/config and normal known-hosts files. There are no app-specific SSH preferences or setup dialogs. Do not import or copy private keys.

## No SSH dialog — 2026-10-26

Magnus explicitly rejected the SSH settings dialog. Keep SSH automatic, without
any Settings scene, toolbar key button, configuration links, key import, username
form or test dialog. Keep Network Explorer's name, ID, approved icon and the
working Mac discovery. Discovery, Mac identification and Bonjour lookup were
compared with origin/main (220e9a3) and remain unchanged apart from identity.
Do not reintroduce SSH configuration UI without an explicit request.
Verified in the installed build: no Settings menu entry or SSH toolbar button;
Mac-Mini-2026, MacBook-Air and MacBook-Air-2025 appear in the device table.
Release build, four OpenSSH regression tests and strict signing passed.

## Current local SSH behavior — 2026-10-26

Magnus put App Store publication on hold and explicitly requested full local SSH.
App Sandbox is disabled in Debug and Release; hardened runtime remains enabled.
Use the normal macOS SSH setup directly, with the configured/default account
first, then the original pi and root device accounts as fallbacks. Keep
noninteractive execution and reject changed host keys. No app-owned key import,
passphrase storage, askpass helper or temporary credential files remain.
Preserve the Network Explorer name, new bundle ID, approved icon and GUI.
The older sandbox/distribution records below are historical and superseded by
this instruction for current local builds.

Current local verification: universal Release build and strict installed-app
signature passed; seven SSH tests passed. The native app discovered 49 devices,
connected automatically to pi-kato as pi without imported credentials, and
returned disk, memory, temperature, software and process information. The
installed version and historical artifact distinctions are in DISTRIBUTION.md.

## Build and installation

- `swift build` and `swift build -c release` build the `NetworkExplorer` executable.
- `xcodebuild -project network-explorer.xcodeproj -scheme network-explorer -configuration Debug -destination 'platform=macOS' build` builds the native app.
- Product > Archive, or `xcodebuild -project network-explorer.xcodeproj -scheme network-explorer -configuration Release -destination 'generic/platform=macOS' -archivePath /tmp/NetworkExplorer.xcarchive archive`, produces a native app archive.
- Xcode uses team `52A6FA9VB5`, bundle identifier `se.egelberg.network-explorer`, marketing version `1.0`, and a date-based build number. Icon sources are in `Xcode/IconSources`; the asset catalog contains the macOS icon sizes and `Resources/NetworkExplorerIcon.icns` supports standalone packaging.
- 2026-10-25: The user authorized sandbox adaptation for App Store distribution. App Sandbox is enabled. Global SSH settings import a user-selected key into the local Keychain, with optional passphrase and configurable usernames. OpenSSH uses temporary owner-only credential files inside the app container and a persistent app-owned known-hosts file. Preserve full SSH inspection. Verified sandbox SSH on 14 Raspberry Pi devices and Mac mini, including an encrypted key; pi-kato disk, memory and system information were verified in the GUI. Earlier runtime checks and uploaded builds used the previous LAN Explorer identity; they do not establish App Store Connect validation for the new bundle ID.
- Distribution status and remaining steps are documented in `DISTRIBUTION.md`.
- Install only as `/Applications/Network Explorer.app`.
- Finder/File Provider extended attributes can invalidate ad-hoc signing under Documents. If necessary, build/sign outside Documents, copy with `ditto --norsrc --noextattr`, and verify the final destination with `codesign --verify --deep --strict`.

## Preserve functionality and GUI

- `NetworkScanner.swift` contains the existing networking actor: active private IPv4 `/24` discovery, ping, ARP, names, service-port inspection, HTTP fingerprints and passwordless SSH inspection.
- `ScannerStore.swift` owns scans, per-IP inspection cache and retained device data. Automatic scans pause 30 seconds after completion. Retaining older devices/ping and IP identity are intentional behavior.
- `ContentView.swift` owns stable selection, filtering, sorting and permanent details. Resolve selection against the full device collection when filtering hides a row.
- The native Table columns are Address / Name / Vendor / Device Type. Ping and Last seen stay in details. Search uses `.searchable` with toolbar placement.
- Keep the existing resizable DeviceWorkspace and continuous toolbar. Services and system information are inline; both panels stay visible. Avoid unnecessary split-container rewrites.
- Follow system appearance. No obsolete themes, F3/F6 shortcuts or empty Settings window.
- Approved icon: sapphire tile, ivory/turquoise Wi-Fi arcs, amber dot, and three discovered-device symbols. Preserve the selected design; use the simplified companion for the smallest icon sizes.
- CUA mouse-gesture verification requires an active app: focus the search field before testing drag events.

## Network Explorer rename — 2026-10-25

Magnus authorized a full identity change from LAN Explorer, including bundle ID,
Xcode project/scheme, Swift package/module, source/test folders, app executable,
SSH service names, current documentation, and the approved new app icon.
GitHub repository and origin remote were renamed to network-explorer on
2026-10-26. The help URL is https://meg768.github.io/network-explorer/ and current
repository/support links use the new name. The local checkout directory was
renamed to /Users/magnus/GitHub/network-explorer on 2026-10-26.

At the rename, the new identity had its own sandbox, preferences, SSH Keychain
service and known-hosts file. The local-SSH change above supersedes that storage
model. Do not migrate the old imported credentials implicitly.
Historical archive paths and upload records below refer to LAN Explorer.

Verified after the rename: Xcode Debug build, universal Release archive, six
Swift tests, strict installed-app signing, and App Store export for the new ID.
GUI verification found 48 devices and confirmed the name, production icon,
About panel, and Help menu without Search. See DISTRIBUTION.md for artifact paths.
No Git commit/tag/push or Apple upload was performed for this rename.

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

# LAN Explorer

A small native macOS app for scanning the local LAN and spotting devices such as Raspberry Pi, Homebridge, MQTT brokers, Home Assistant, and Node-RED.

## Current version

- Detects the active private IPv4 network.
- Scans the `/24` subnet with ping.
- Reads MAC addresses from ARP when available.
- Shows hostname, IP, MAC/vendor, response time, and last seen time.
- Detects common services on ports `22`, `80`, `443`, `1883`, `8581`, `1880`, and `8123`.
- Highlights likely Raspberry Pi devices by hostname, MAC prefix, or vendor.
- Native macOS table with Address, Name, Vendor, Device Type and Last Seen columns, keyboard selection, sortable/resizable columns, and toolbar search.
- Always-visible native device table and optional device details with independent navigation, including port, HTTP, and passwordless SSH information. A resizable content divider leaves the window toolbar continuous.
- Automatically scans again after a 30-second pause; preserves selection, filtering, and sorting.
- Follows the system light/dark appearance. Use Command-R to scan and the toolbar details button to show/hide device information; the table remains visible.

## Application identity

LAN Explorer is a separate app with bundle identifier `se.egelberg.lan-explorer`.
It does not migrate preferences from or replace LAN Scanner.

## Build

Open `Package.swift` in Xcode and select the generated `LANExplorer` scheme,
or build from the command line. The package, executable product, target, and
Swift module are all named `LANExplorer`; no separate Xcode project is required.


```bash
swift build
Scripts/build-app.sh
Scripts/build-dmg.sh
```

The app bundle is created at:

```text
dist/LAN Explorer.app
```

The DMG installer is created at:

```text
dist/lan-explorer.dmg
```

## Distribution

The local build scripts create an ad-hoc-signed app bundle and DMG. For a frictionless web download on another Mac, the app must be signed with an Apple Developer ID certificate and notarized by Apple.

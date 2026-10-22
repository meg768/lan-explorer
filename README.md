# LAN Explorer

A small native macOS app for scanning the local LAN and spotting devices such as Raspberry Pi, Homebridge, MQTT brokers, Home Assistant, and Node-RED.

## Current version

- Detects the active private IPv4 network.
- Scans the `/24` subnet with ping.
- Reads MAC addresses from ARP when available.
- Shows hostname, IP, MAC/vendor, response time, and last seen time.
- Detects common services on ports `22`, `80`, `443`, `1883`, `8581`, `1880`, and `8123`.
- Highlights likely Raspberry Pi devices by hostname, MAC prefix, or vendor.
- Native macOS table with Address, Name, Vendor and Device Type columns, keyboard selection, sortable/resizable columns, and toolbar search.
- Always-visible native device table and device details, including inline port, HTTP, and passwordless SSH information. A resizable content divider leaves the window toolbar continuous.
- Automatically scans again after a 30-second pause; preserves selection, filtering, and sorting.
- Follows the system light/dark appearance. Use Command-R to scan; both panels remain visible.

## Application identity

LAN Explorer is a separate app with bundle identifier `se.egelberg.lan-explorer`.
It does not migrate preferences from or replace LAN Scanner.

## Build

Open **`lan-explorer.xcodeproj`** in Xcode and select **lan-explorer → My Mac**.
Use **Product → Run** to run the app or **Product → Archive** to create an app
archive in Organizer. Signing uses Magnus's existing development team and the
bundle identifier remains `se.egelberg.lan-explorer`.

```bash
xcodebuild -project lan-explorer.xcodeproj -scheme lan-explorer \
  -configuration Debug -destination 'platform=macOS' build
xcodebuild -project lan-explorer.xcodeproj -scheme lan-explorer \
  -configuration Release -destination 'generic/platform=macOS' \
  -archivePath /tmp/LANExplorer.xcarchive archive
```

## Distribution

Build and archive the application through Xcode. Export archives through Organizer.

### Mac App Store distribution

The current local Xcode build has App Sandbox disabled to preserve SSH inspection
using the user's existing SSH configuration and keys. Memory, disk, CPU and other
remote system details require successful SSH authentication. The sandboxed Store
build lost that access and is not functionally equivalent to this local build.
Do not use the previously uploaded build for release until this is resolved.
See [DISTRIBUTION.md](DISTRIBUTION.md) for verification and history.

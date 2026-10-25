# LAN Explorer

A small native macOS app for scanning the local LAN and spotting devices such as Raspberry Pi, Homebridge, MQTT brokers, Home Assistant, and Node-RED.

## Current version

- Detects the active private IPv4 network.
- Scans the `/24` subnet with ping.
- Reads MAC addresses from ARP when available.
- Prefers Bonjour/mDNS hostnames, with router DNS as a fallback.
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

App Sandbox is enabled. Configure SSH once in **LAN Explorer > Settings > SSH**:
select a private key, enter usernames such as `pi, magnus`, save, and test a device.
The app stores the key and optional passphrase in the local macOS Keychain. SSH
uses an app-owned known-hosts file; changes to a previously trusted host key are
rejected. Temporary key material is owner-only and removed after each inspection.
The original `~/.ssh` files and SSH agent are not used by the Store configuration.

The same saved key is reused across devices that already authorize it. Network
and Bonjour discovery work without configuring SSH; detailed system information
requires successful SSH authentication. See [DISTRIBUTION.md](DISTRIBUTION.md).

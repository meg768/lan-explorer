# Network Explorer

<img src="docs/images/app-icon.png" alt="Network Explorer icon" width="96" height="96">

A native macOS app for discovering Macs, Raspberry Pi computers and other devices on your local network, over Wi-Fi or Ethernet. Select a device to inspect its services and, when SSH access is available, read its system information automatically.

[Help](https://meg768.github.io/network-explorer/) · [Support](https://meg768.github.io/network-explorer/support.html) · [Privacy](https://meg768.github.io/network-explorer/privacy.html)

## Features

- Discovers devices in the selected private IPv4 `/24` range using ping and ARP.
- Resolves device names through Bonjour/mDNS, with DNS as a fallback.
- Shows addresses, available MAC/vendor information, likely device types, ping and last-seen times.
- Finds common services, including SSH, web interfaces, file sharing, printers, MQTT, Home Assistant, Homebridge, Node-RED, media servers and databases.
- Reads supported system information through SSH: operating system, disk usage, memory, temperature, installed software, running services and processes.
- Keeps the device table and details visible together, with sortable and resizable columns, keyboard selection and toolbar filtering.
- Automatically starts another scan after a 30-second pause following completion, preserving filtering, sorting and selection.
- Follows the system's light or dark appearance.

## Getting started

Requires **macOS 14 or later**.

1. Connect your Mac to the network you want to explore.
2. Open Network Explorer and allow local-network access if macOS requests it. Scanning starts automatically.
3. Filter the list by name, address, vendor or device type, then select a device to inspect it.
4. Use **Scan Network** or **Command-R** to scan again when the app is ready.

Mac and device discovery works without SSH or Remote Login being enabled. There is no SSH settings dialog or key-import step in the app.

## Automatic SSH

Network Explorer runs macOS OpenSSH using your existing private keys, SSH agent, `~/.ssh/config` and normal known-hosts files. It first tries the configured account, or your Mac's account name when no user is configured, then the device accounts `pi` and `root`. It uses the first account that connects successfully.

The remote device must already offer SSH on port **22** and authorize a key available on your Mac. Automatic inspection connects to the discovered IP address, so any per-device SSH configuration rules must match that address.

Connections run without password prompts. Encrypted keys must already be available through your SSH agent or existing macOS SSH Keychain setup. OpenSSH records new host keys in its normal host database and rejects changed keys. Background inspections do not enable port forwarding, agent forwarding or local SSH commands.

The app does not import or copy private keys, store passphrases, or create temporary credential files. See the [SSH guide](https://meg768.github.io/network-explorer/ssh.html) for details.

## Build and test

Open **`network-explorer.xcodeproj`** in Xcode and select **network-explorer → My Mac**, then choose **Product → Run**. The project is configured for Magnus's development team; select your own signing team when building elsewhere.

Build the native application from the command line:

```bash
xcodebuild -project network-explorer.xcodeproj -scheme network-explorer \
  -configuration Debug -destination 'platform=macOS' build

xcodebuild -project network-explorer.xcodeproj -scheme network-explorer \
  -configuration Release -destination 'generic/platform=macOS' build
```

Create a Release archive through **Product → Archive**, or:

```bash
xcodebuild -project network-explorer.xcodeproj -scheme network-explorer \
  -configuration Release -destination 'generic/platform=macOS' \
  -archivePath /tmp/NetworkExplorer.xcarchive archive
```

Run the Swift package tests:

```bash
swift test
```

The native app is **Network Explorer.app**, the Swift package/module is **NetworkExplorer**, and the bundle identifier is **`se.egelberg.network-explorer`**.

## Scope and local use

- Discovery checks addresses `.1` through `.254` in the selected IPv4 `/24` range. It does not scan other subnets or discover IPv6-only devices.
- Results depend on device reachability, local-network permissions, ARP information and network isolation. Vendor and device-type labels are hints.
- Previously discovered devices and some earlier values are retained during the app session. A listed device is not proof that it is currently online.
- Service inspection probes selected common TCP ports, rather than every possible port. Available SSH information depends on the remote operating system, tools and account permissions.

The current build is intended for local use. App Sandbox is disabled so OpenSSH can use your existing SSH setup; hardened runtime remains enabled. App Store publication is on hold. Historical build and distribution records are in [DISTRIBUTION.md](DISTRIBUTION.md).

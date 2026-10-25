---
title: Getting Started
---

# Getting Started

## 1. Connect to your network

Connect your Mac to the Wi-Fi or Ethernet network containing the devices you want to find. LAN Explorer requires a private IPv4 address and automatically chooses a network interface. The window subtitle shows the selected network and interface.

The current scanner checks addresses **.1 through .254 in the same /24 range** as your Mac. For example, a Mac at `192.168.1.42` scans `192.168.1.1` through `192.168.1.254`. It does not scan every subnet on a larger network or discover IPv6-only devices.

## 2. Allow local-network access

Open LAN Explorer and allow access when macOS asks to find devices on your local network.

If access was denied, open **System Settings → Privacy & Security → Local Network** and enable LAN Explorer, where that setting is available. Return to the app and scan again. See [Troubleshooting](troubleshooting.html) if access remains unavailable.

## 3. Scan

A scan starts automatically when the main window opens. Use **Scan Network** in the toolbar or press **Command-R** to run another scan when the app is ready. The status bar shows progress and the device count.

Automatic scanning waits 30 seconds after a scan finishes before starting the next one while the main window is open.

## 4. Select a device

Select a row to inspect it. The details panel shows its address, activity, reachable services, system information when available, and explanatory notes. Inspection can take a little time.

Use **Filter devices** to search by address, hostname, DNS name, MAC address, vendor, or device type. Click a column heading to change the sort order. Resize columns or drag the divider to adjust the details panel.

Names and device types depend on the information the device exposes. A missing name or ping response does not necessarily mean a device is offline. See [Devices and Services](devices.html).

## 5. Add SSH access if needed

You can discover devices and inspect service ports without a private key. To read supported system information from devices offering SSH, follow [SSH Access](ssh.html). First launch has no preset usernames or keys.

[Back to LAN Explorer Help](index.html)

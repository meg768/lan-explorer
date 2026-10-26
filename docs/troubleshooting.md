---
title: Troubleshooting
---

# Troubleshooting

## No local IPv4 network

Check that your Mac is connected to Wi-Fi or Ethernet and has an address in a private IPv4 range: `10.x.x.x`, `172.16.x.x` through `172.31.x.x`, or `192.168.x.x`.

Network Explorer automatically selects an interface and prefers `en0` when it is available. Check the network and interface shown in the window subtitle, especially when Ethernet, Wi-Fi, or a VPN is active. The app currently has no manual interface or scan-range selector.

## Local-network access denied

Where available, open **System Settings → Privacy & Security → Local Network** and enable Network Explorer. Return to the app and use **Scan Network** or **Command-R**. If needed, quit and reopen the app after changing the permission.

An access-denied message is different from a successful scan with no devices. Keep the exact message when reporting a problem.

## A device is missing

- Check that it is powered on and connected to the same local network.
- Check the scan range in the window subtitle. Only the selected IPv4 /24 range is scanned, even if your actual network is larger.
- Guest Wi-Fi, client isolation, separate VLANs, firewalls, and VPN routing can prevent devices from reaching one another.
- Wake sleeping devices and run another scan. Some devices do not respond to ping or appear in the Mac's ARP information.
- IPv6-only devices and devices on other subnets are outside the current discovery scope.

The result is a practical view of discoverable devices, not a guaranteed inventory of everything connected to your router.

## A device remains after it disconnects

The app deliberately retains previous discoveries during the current session. The Mac's ARP cache can also retain an entry after a device disconnects. Earlier names and ping values may remain visible. See [Devices and Services](devices.html) for how to interpret these results.

## Names or vendors are missing or incorrect

A device may not publish a name through Bonjour/mDNS or DNS. Router DNS can be stale, and private MAC addresses can hide the hardware vendor. Use the IP and MAC information alongside your router or device settings to identify it.

## No services or system information

Only selected common service ports are checked. A service on a different port, a firewall, or a sleeping device may produce no result. Port labels and inferred device types are not definitive identification.

Detailed system information usually requires SSH. Follow [SSH Access](ssh.html), check that SSH is enabled on the device, and use an account authorized for the selected key. Inspection results are cached for the current session; quit and reopen the app if you need to recheck them after changing the remote device.

## SSH does not sign in automatically

Check that SSH is enabled on the device and that it authorizes a key available
through your normal Mac SSH setup. The app tries the configured/default account,
then `pi` and `root`. There is no separate app configuration.

Automatic inspection connects to the discovered IP address when port 22 responds.
SSH configuration rules for that device must match its IP address. If a key is
encrypted, make it available through your existing SSH agent or macOS SSH
Keychain setup. Background connections do not show password prompts.

Changed host keys are rejected. Verify the device before updating its matching
known-hosts entry using your normal SSH tools.

[Back to Network Explorer Help](index.html)

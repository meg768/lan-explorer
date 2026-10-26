---
title: Privacy Policy
---

# Privacy Policy

Last updated: 26 October 2026

Network Explorer is developed by Magnus Egelberg. This policy describes how the app handles information.

## Network discovery and inspection

Network Explorer scans the selected local IPv4 /24 range and reads information such as IP and MAC addresses, hostnames, vendor hints, response times, service ports, and supported system details. It sends discovery and inspection traffic to devices and uses system networking services for name resolution. Devices and network infrastructure may record these requests under their own settings.

Results are processed on your Mac and kept in the running app's memory. Network Explorer does not send your device inventory or inspection results to the developer and does not provide a developer-operated cloud account or inventory service.

## SSH access

The local app uses macOS OpenSSH to read system information from reachable
devices. OpenSSH uses your normal SSH configuration, private-key files, SSH agent
and host-key database. Network Explorer does not import private keys or passphrases
into its own storage and does not create temporary credential files.

Your existing SSH setup may use macOS Keychain to unlock encrypted keys. This is
handled by OpenSSH and your existing configuration. Network Explorer does not
upload keys or passphrases to the developer.

Private-key and configuration files are not modified by the app. OpenSSH can
record new host keys in the normal known-hosts file; changed host keys are
rejected. Remote devices may record connections in their own SSH logs.

Earlier sandboxed builds offered an app-owned key import. Those imported
credentials are not used by the current automatic SSH implementation.

## Analytics and tracking

Network Explorer does not include developer-operated analytics, advertising, or tracking services. Apple may separately process App Store purchase information and diagnostics according to your Apple account and system settings.

## Help website and support

This help website is hosted on GitHub Pages, and support requests are hosted in GitHub Issues. GitHub handles web requests and submitted information under [GitHub's privacy statement](https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement).

Information you submit in a support issue is public and is used to respond to that issue. Do not include private keys, passphrases, passwords, or sensitive network details. For questions about this policy, see [Support](support.html).

[Back to Network Explorer Help](index.html)

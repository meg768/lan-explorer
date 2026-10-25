---
title: Privacy Policy
---

# Privacy Policy

Last updated: 25 October 2026

LAN Explorer is developed by Magnus Egelberg. This policy describes how the app handles information.

## Network discovery and inspection

LAN Explorer scans the selected local IPv4 /24 range and reads information such as IP and MAC addresses, hostnames, vendor hints, response times, service ports, and supported system details. It sends discovery and inspection traffic to devices and uses system networking services for name resolution. Devices and network infrastructure may record these requests under their own settings.

Results are processed on your Mac and kept in the running app's memory. LAN Explorer does not send your device inventory or inspection results to the developer and does not provide a developer-operated cloud account or inventory service.

## Optional SSH access

If you configure SSH, LAN Explorer stores the private key you select and its optional passphrase in the local macOS Keychain. Configured usernames are stored in the app's local preferences. The selected key is used to authenticate connections to your devices; LAN Explorer does not upload it to the developer.

For SSH sessions, the app creates temporary private-key and, when needed, passphrase files inside its app container with permissions restricted to your user. It removes these files when the session ends. The app also stores its own known-hosts file for checking device identity on later connections.

The app does not automatically read your original SSH keys, SSH configuration, or SSH agent. Importing a key stores a separate copy; it does not alter the original file.

**Remove SSH settings** in Settings deletes the saved Keychain credential and username preference. It does not remove the original key, change remote authorized keys, or delete the app's separate known-hosts file.

## Analytics and tracking

LAN Explorer does not include developer-operated analytics, advertising, or tracking services. Apple may separately process App Store purchase information and diagnostics according to your Apple account and system settings.

## Help website and support

This help website is hosted on GitHub Pages, and support requests are hosted in GitHub Issues. GitHub handles web requests and submitted information under [GitHub's privacy statement](https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement).

Information you submit in a support issue is public and is used to respond to that issue. Do not include private keys, passphrases, passwords, or sensitive network details. For questions about this policy, see [Support](support.html).

[Back to LAN Explorer Help](index.html)

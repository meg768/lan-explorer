---
title: SSH Access
---

# SSH Access

Select a device with SSH available to read disk usage, memory, temperature,
software and other system information. Network Explorer uses your Mac's existing
SSH setup automatically. There is no settings dialog, key import or setup step.

## Automatic sign-in

Connections run through macOS OpenSSH with your normal keys, SSH agent,
`~/.ssh/config` and known-hosts files. The configured account is tried first;
without a matching user rule, OpenSSH uses your Mac's account name. The original
device accounts `pi` and `root` are then tried as fallbacks. The app uses the
first successful account.

The device must already allow SSH and authorize a key available on your Mac.
The app does not create accounts, install keys or ask for login passwords.
Encrypted keys need to be available through your existing SSH agent or macOS
SSH Keychain configuration.

Automatic inspection uses the discovered IP address and starts when SSH port 22
responds. Per-device SSH configuration rules must match that address.
If access is unavailable, network discovery and service inspection still work.

## Host verification

OpenSSH verifies host identity with your normal known-hosts files. New host keys
are accepted and recorded; changed keys are rejected. Resolve identity warnings
using your normal SSH tools after verifying the device.

Network Explorer does not import or copy private keys or passphrases and does
not create temporary credential files. Your private-key and configuration files
are not modified by the app.

For help, see [Troubleshooting](troubleshooting.html), [Support](support.html),
or the [Privacy Policy](privacy.html).

[Back to Network Explorer Help](index.html)

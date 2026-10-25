---
title: SSH Access
---

# SSH Access

SSH access lets LAN Explorer read supported system information from your devices. It is optional: network discovery and service-port inspection work without it.

## Before you start

The device must offer SSH on port 22, and the account you want to use must already authorize the public key matching your private key. LAN Explorer does not create remote accounts or install public keys on devices.

The app uses public-key authentication. The **Key passphrase** unlocks an encrypted private key; it is not the remote account's login password. Interactive password and keyboard-interactive authentication are not used.

## Configure once

1. Open **LAN Explorer → Settings…**, or click **SSH Settings** in the main toolbar. A device offering SSH can also show **Configure SSH…** in its details.
2. Enter one or more **Usernames**, separated by commas or whitespace. Use account names that exist on your devices.
3. Click **Choose key…** and select your private SSH key in OpenSSH or PEM format. Choose the private key, not the matching `.pub` file.
4. If the key is encrypted, enter its **Key passphrase**.
5. Click **Save**.
6. Enter a hostname or IP address under **Test connection**, then click **Test connection**. Enter only the address, without a username or URL scheme. Testing also saves the current settings.

One saved key is reused for devices that authorize its matching public key. The app tries the configured usernames when connecting. First launch starts without usernames, a key, a passphrase, or a test address.

## Inspect a device

Select a device with SSH available. The app reads the system information it can obtain with the configured account. Missing utilities, insufficient account permissions, or a different operating system can limit the results.

If a key works in Terminal but not in LAN Explorer, verify the selected key and usernames. The sandboxed app does not use your SSH agent or automatically read your original `~/.ssh` keys and configuration.

## Key storage and host verification

The saved private key and optional passphrase are stored in the local macOS Keychain. For each SSH session, the app creates temporary credential files with access restricted to your user inside its app container and removes them when the session ends.

The app maintains its own known-hosts file. A first connection accepts a new host key; a later connection with a changed key is rejected. This can happen after reinstalling a device or reusing its IP address, and it can also indicate that a different device is answering. Verify the device's identity before resolving a host-key warning. LAN Explorer does not change your original `~/.ssh/known_hosts` file.

## Change or remove settings

To replace the key, choose another key, enter its passphrase if needed, and save. When keeping the current key, leaving the passphrase field blank preserves its saved passphrase.

**Remove SSH settings** deletes the saved Keychain credential and username preference from LAN Explorer. It does not remove the public key from remote devices, modify your original SSH files, or clear the app's separate known-hosts file.

For connection errors, see [Troubleshooting](troubleshooting.html). For data handling, see the [Privacy Policy](privacy.html).

[Back to LAN Explorer Help](index.html)

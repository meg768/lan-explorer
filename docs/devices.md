---
title: Devices and Services
---

# Devices and Services

## Read the device table

| Column | Meaning |
| --- | --- |
| Address | The device's IPv4 address. |
| Name | A discovered hostname, or the IP address when no hostname is available. |
| Vendor | A vendor hint based on known MAC-address prefixes, when available. |
| Device Type | Likely device types inferred from the hostname, vendor, and MAC address. |

Network Explorer prefers names obtained directly through Bonjour/mDNS, with DNS as a fallback. Devices do not always publish a usable name, and router DNS can return outdated or shared names.

Vendor and device-type labels are hints. Private or randomized MAC addresses, shared hardware, and incomplete network information can make these labels unavailable or inaccurate.

Tesla model names such as `tesla_model_3` are shown as electric-vehicle candidates.
The model is inferred from the network name; a Tesla vendor match alone is shown
as a Tesla device. Identification does not read vehicle telemetry.

## Activity and retained results

The details panel shows the MAC address, DNS name when available, ping response, and **Last seen** time. Discovery combines ping probes with the Mac's ARP information, so results depend on what is reachable and present in the local neighbor cache.

The app keeps previously found devices during later scans. It can also retain an earlier name, vendor, or ping response when a later scan provides no replacement. A listed device, recent ARP entry, or retained ping value is not proof that the device is currently online.

Use the activity information and inspection results together. If you need a fresh session after changing networks, quit and reopen the app.

## Services

Selecting a device checks a set of common TCP ports. Examples include:

| Service | Port |
| --- | --- |
| SSH | 22 |
| HTTP / HTTPS | 80 / 443 |
| SMB file sharing | 445 |
| MQTT | 1883 |
| Node-RED | 1880 |
| Home Assistant | 8123 |
| Homebridge | 8581 |
| MySQL / MariaDB | 3306 |
| PostgreSQL | 5432 |
| VNC | 5900 |

Inspection also checks other common printer, media, smart-home, and database ports. This is a selected set of probes rather than a scan of all possible ports.

A responding port suggests a service; it does not prove which application is listening. HTTP inspection can add information from a web response. **No services found** means none of the inspected ports responded, not that the device has no services.

## System information

Basic findings can come from the network and HTTP responses. More detailed information, such as operating system, disk usage, memory, temperature, software, or processes, requires successful [SSH access](ssh.html) and suitable tools and permissions on the remote device. The available information varies by device and operating system.

Inspection results are cached during the current app session. Repeated network scans do not refresh every service or system detail. Quit and reopen the app to start a new session and inspect devices again.

[Back to Network Explorer Help](index.html)

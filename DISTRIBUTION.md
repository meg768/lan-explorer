# Current status — local functionality restored, Store work paused

The user rejected the sandbox-induced loss of SSH system information.
App Sandbox is disabled in Debug and Release again. This local build is not
Mac App Store eligible in its current configuration. Existing uploaded build
202610172235 is unchanged and must not be submitted as a feature-equivalent release.
No review submission or publication has been performed by this agent.

# LAN Explorer distribution status — 2026-10-17

## Build

- Native project/scheme: `lan-explorer.xcodeproj` / `lan-explorer`.
- Identity: `se.egelberg.lan-explorer`, team `52A6FA9VB5`.
- Version/build: **1.0 (3)**; deployment target macOS 14.
- Release archive: `/Users/magnus/Library/Developer/Xcode/Archives/2026-10-17/LANExplorer-1.0-3-ready.xcarchive`.
- Release archive succeeded; arm64 and x86_64 slices verified; strict bundle signature verification passed.
- App Sandbox and hardened runtime enabled. Archive entitlements are sandbox, network client and network server only; no debug entitlement.
- Network server entitlement is needed for the existing ping/DNS tools inside the sandbox, not a new listening feature.
- App icon and local-network usage description included. Privacy manifest declares no tracking, collected data or required-reason API use; source inspection found no explicit required-reason API use.
- Standard local export options: `Distribution/ExportOptions.plist`; export does not upload or change the build number.

## Runtime verification

Tested a signed sandboxed Release build on this Apple Silicon Mac:

- Discovery with local-network access enabled: 48 devices found.
- Raspberry Pi inspection: SSH 22, HTTP 80 and HTTPS 443; web fingerprints displayed.
- Local-network access disabled: explicit unavailable-access error instead of misleading empty findings.
- Local-network access restored: discovery works again. Permission left enabled; test app quit.
- SSH configuration advice removed. Sandboxed SSH normally cannot use keys from the user's ~/.ssh directory; system details are limited to what the app can actually obtain.

Not verified: runtime on Intel/macOS 14, discovery with an initially empty ARP cache, successful passwordless SSH in the sandbox, and retrying an individual denied inspection after access is restored. No promise of SSH authentication or complete discovery is made. Existing scanner scope remains a private IPv4 /24.

## App Store Connect

Xcode's Validate App flow stopped before creating an app record: no LAN Explorer app record exists. No app record, upload, review submission or publication was performed.

App record proposal shown by Xcode: name LAN Explorer, bundle ID se.egelberg.lan-explorer, SKU se.egelberg.lan-explorer, primary language Swedish. Primary language requires a deliberate choice because the current UI is English.

Initial local App Store export failed because a distribution provisioning profile was missing. Retrying with standard Xcode automatic provisioning succeeded. Exported package signature verified: 3rd Party Mac Developer Installer, team 52A6FA9VB5. This is a local export, not App Store Connect validation.

Exported package: `/Users/magnus/Documents/GitHub/codex-chat/sandbox/lan-distribution-20261017/export/LAN Explorer.pkg`.

Next steps after approval: create the app record, complete validation, upload the unchanged 1.0 (3) build, and verify Apple's processing. Prepare store description, screenshots, support/privacy URLs, privacy answers, age rating, price/availability and review notes. Review notes should explain local-network permission and that results depend on devices reachable on the reviewer's network. Do not submit for review or publish without authorization.

## Date-based builds — 2026-10-17

Subsequent Xcode builds use the same scheme as PanoWizard: a build phase generates
CFBundleVersion as YYYYMMDDHHmm and ExplorerBuildTimestamp as YYYY-MM-DD HH:mm
using the build Mac's local time. The standard About panel displays Version and
Build on separate lines. Info.plist preprocessing embeds both values before signing.
No source files are rewritten by the build. Export options keep automatic version
management disabled. In Organizer, also disable Manage version and build number.
Archive once and export/upload that archive to preserve its identity. Two builds
in the same minute have the same number; wait until the next minute before a new
upload candidate. Keep the Mac clock correct. Existing archives/uploads are unchanged.
Date-based builds have been built locally; Apple validation/upload must be done
for the new archive, not inferred from the earlier build 3 validation.

## Date build upload — 2026-10-17

User authorized build, validation and upload. Native universal Release archive
1.0 (202610172235) succeeded; strict signature verification passed. Xcode's
distribution upload flow completed Apple's package/SPI analysis and uploaded
successfully at 22:36:32 Europe/Stockholm. Automatic version management disabled.
Archive: /Users/magnus/Library/Developer/Xcode/Archives/2026-10-17/LANExplorer-1.0-202610172235.xcarchive.
No source changes, review submission or publication performed during this upload.
Apple processing completed; TestFlight build 202610172235 verified as Ready to Submit.
Encryption question answered None of the algorithms mentioned above: LAN Explorer
uses Apple system networking/tools, without bundled third-party cryptography.
No review submission or publication performed.

## Local SSH restoration verified — 2026-10-17

Disabled App Sandbox in both native target configurations and removed its
network capability settings. Built universal Release and replaced only
/Applications/LAN Explorer.app, keeping a backup. Strict signature check passed;
installed entitlements contain no App Sandbox. No scanning/SSH code or GUI
changes were needed. Runtime verification in the installed app: 50 devices;
pi-kato passwordless SSH succeeded as pi; root disk 13G of 29G (45%),
memory 889Mi of 7.9Gi (11%), CPU/memory process data, uptime, temperature,
kernel and installed software appeared again. Previous Store archive untouched.

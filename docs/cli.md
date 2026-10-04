# CLI

| Script | Purpose |
| --- | --- |
| `scripts/install-quest.sh` | Build patched open-source APK + install + launch email login UI |
| `scripts/launch-quest.sh` | Start phone `MainActivity` (email path) |
| `scripts/e2e-quest.sh` | Device checks + assert email login UI (fails on QR-only) |
| `scripts/quest-enter-password.sh` | ADB-type password into focused field (avoids Horizon keyboard mangling) |
| `scripts/configure-quest-hardening.sh` | Always-on VPN + lockdown kill switch + boot auto-connect |
| `scripts/e2e-kill-switch.sh` | Prove lockdown filtering rules + blocked outbound TCP while VPN down |
| `scripts/e2e-boot-autoconnect.sh` | Prove `AutoConnectBootReceiver` + always-on + preferred reconnect path |
| `scripts/e2e-real-reboot.sh` | Reboot Quest and verify always-on/lockdown + launch after headset unlock |
| `scripts/build-from-source.sh` | Apply Quest patch + Gradle assemble |
| `scripts/apply-quest-patch.sh` | Apply `patches/0001-meta-quest-phone-email-auth.patch` |
| `scripts/build-quest-launcher.sh` | Build companion library APK |
| `scripts/install-quest-launcher.sh` | Install companion |
| `scripts/download-official-apk.sh` | Download Proton GitHub release APK (TV/QR only) |
| `scripts/verify-apk.sh` | Verify official APK signing certificate |
| `scripts/quest-device.sh` | Resolve Quest ADB serial |

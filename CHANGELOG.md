# Changelog

## 1.3.0 — 2026-10-04

### Added
- Quest product flavor: `applicationIdSuffix` `.quest` → package `ch.protonvpn.android.quest` (Pass-style); Gradle `productionVanillaQuestDebug` (`6feb7cd`)
- Patch `0002-meta-quest-product-flavor.patch`; install/e2e/hardening scripts prefer `.quest` with legacy `ch.protonvpn.android` fallback (`6feb7cd`)
- Companion launcher resolves `.quest` first; CI checks both Quest patches via `tests/test_scripts.sh` (`6feb7cd`)
- `scripts/resolve-android-sdk.sh` — pick a writable Android SDK (`$HOME/Android/Sdk` over non-writable `/opt/android-sdk`) for Gradle builds (`116b695`)

### Changed
- Build scripts (`build-from-source.sh`, `build-quest-launcher.sh`, `fetch-android-app.sh`) source the SDK resolver and write `local.properties` accordingly (`116b695`)

### Fixed
- Quest companion launcher assemble/install failing when `ANDROID_HOME` pointed at a non-writable system SDK (`116b695`)

## 1.2.0 — 2026-10-03

- Reboot auto-start: force Quest `tvAutoConnectOnBoot`, enable `AutoConnectBootReceiver` (+ `USER_UNLOCKED`), reconnect via preferred/quick-connect intent
- Real kill switch: Android Always-on VPN + lockdown; e2e proves Lockdown filtering rules and blocked outbound TCP while tunnel is down
- Fix corrupt always-on DataStore JSON from hardening script (was crashing Proton VPN on start)
- Add `configure-quest-hardening.sh`, `e2e-kill-switch.sh`, `e2e-boot-autoconnect.sh`, `e2e-real-reboot.sh`
- Real-reboot e2e waits up to ~15 minutes for Quest CE unlock so Proton VPN can launch and Preferred/Quick connect + ProtonTunnel can reconnect

## 1.1.0 — 2026-10-03

- Switch Quest primary path from TV/QR to phone email/password auth (Proton Pass model)
- Reverse `IsTvCheck` so Meta Quest never forces `TvMainActivity` / `TvQrLoginActivity`
- Enable exported `MainActivity` + `com.oculus.supportedDevices` (Horizon OS alias fix)
- Landscape / `adjustResize` on core auth activities for Quest keyboard
- Update `quest-launcher`, launch/e2e/install scripts, and docs — stop advertising QR as primary

## 1.0.0 — 2026-10-03

- Initial Quest packaging for Proton VPN Android (GPL-3.0 upstream)
- Verified sideload of Proton `production-vanilla-direct-release` APK
- TV UI launcher path + Quest library companion (superseded for standalone Quest in 1.1.0)
- Meta Quest detection patch for `IsTvCheck`
- Real-device e2e script for Meta Quest 3 (`eureka`)

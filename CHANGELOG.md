# Changelog

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

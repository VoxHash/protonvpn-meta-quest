# Roadmap

Unofficial Meta Quest packaging for Proton VPN Android (GPL). Keep milestones small, shippable, and contributor-useful — no store-scale bloat.

## Done

- Phone / email login path on Quest 3 (Pass-style)
- Horizon `MainActivity` launcher enablement + `com.oculus.supportedDevices`
- Quest companion launcher + e2e asserting email UI (not QR)
- Reboot auto-connect to preferred/quick-connect (`AutoConnectBootReceiver` + Always-on)
- Real kill switch via Always-on VPN lockdown (UID filtering + blocked outbound TCP)
- Documentation kit (README, docs/, issue & PR templates, SECURITY/SUPPORT)
- Quest product flavor / `applicationIdSuffix` `.quest` (`ch.protonvpn.android.quest`, Pass-style) + script/launcher updates
- Companion launcher prefers `.quest` package; clearer missing-app message
- CI script job checks auth + flavor patches (`tests/test_scripts.sh`)
- Writable Android SDK resolver (`scripts/resolve-android-sdk.sh`) for Gradle / quest-launcher builds

## Next

1. **SSO on Horizon** — document browser handoff / deep-link edge cases (email path works; SSO often needs PC assist)
2. **Upstream notes** — short CONTRIBUTING/docs blurb for ProtonVPN `IsTvCheck` Quest carve-out (what to upstream vs keep patched)
3. **Install demo** — short GIF or linked video: sideload → email login → `configure-quest-hardening.sh`
4. **Contributor UX** — point CONTRIBUTING at issue templates (Quest device, adb log, flavor/APK)
5. **F-Droid honesty** — note that this is GPL sideload packaging, not an F-Droid listing (unless/until one exists)
6. **CI APK artifacts** — optional upload of Quest APK when CI can assemble (heavy; needs SDK + JDK 17 cache; local release assets remain the primary download path)
7. **Community link** — Matrix/Discord only when a real channel exists (no placeholder invite)

## Out of scope (for now)

- Play Store / App Lab distribution
- Closed-source or non-GPL VPN cores
- Full upstream product ownership (this stays a packaging + Quest patch project)
- Device-farm e2e in GitHub Actions (no Quest farm access; keep local `e2e-*.sh`)

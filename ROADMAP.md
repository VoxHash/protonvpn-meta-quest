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

## Next

1. **SSO on Horizon** — document browser handoff / deep-link edge cases (email path works; SSO often needs PC assist)
2. **Upstream notes** — short CONTRIBUTING/docs blurb for ProtonVPN `IsTvCheck` Quest carve-out (what to upstream vs keep patched)
3. **CI APK artifacts** — optional upload of Quest APK when CI can assemble (heavy; needs SDK cache)
4. **Install demo** — short GIF or linked video: sideload → email login → `configure-quest-hardening.sh`
5. **Contributor UX** — point CONTRIBUTING at issue templates (Quest device, adb log, flavor/APK)
6. **F-Droid honesty** — note that this is GPL sideload packaging, not an F-Droid listing (unless/until one exists)
7. **Community link** — Matrix/Discord only when a real channel exists (no placeholder invite)
8. **Device-farm e2e in CI** — wire `e2e-*.sh` to a Quest farm runner only if access is available; keep local scripts otherwise

## Out of scope (for now)

- Play Store / App Lab distribution
- Closed-source or non-GPL VPN cores
- Full upstream product ownership (this stays a packaging + Quest patch project)

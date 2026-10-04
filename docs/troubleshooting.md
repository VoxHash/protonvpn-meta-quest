# Troubleshooting

| Symptom | Fix |
| --- | --- |
| Launch rejected / no panel (official APK) | Official Proton APK disables `MainActivity`; Horizon rejects the alias. Use `./scripts/install-quest.sh` (patched open-source build). |
| Lands on `TvQrLoginActivity` | Sticky TV prefs or old TV launcher. Reinstall patched build; e2e asserts email UI. |
| `Activity class ... MainActivity does not exist` | Unpatched APK (`enabled=false`). Rebuild with Quest patch. |
| VPN permission denied | Disable other VPNs / Always-on VPN; retry Connect |
| Signature verify fail (official download) | Re-download from ProtonVPN GitHub Releases only |
| Black screencap | Headset asleep or VR compositor; wake with `KEYCODE_WAKEUP` and re-pull |
| From-source build fails | Need JDK 17, NDK, cmake; OpenVPN path may need `swig` |

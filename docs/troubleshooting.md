# Troubleshooting

| Symptom | Fix |
| --- | --- |
| Launch rejected / no panel (official APK) | Official Proton APK disables `MainActivity`; Horizon rejects the alias. Use `./scripts/install-quest.sh` (patched open-source build). |
| Lands on `TvQrLoginActivity` | Sticky TV prefs or old TV launcher. Reinstall patched build; e2e asserts email UI. |
| `Activity class ... MainActivity does not exist` | Unpatched APK (`enabled=false`). Rebuild with Quest patch. |
| **Incorrect login credentials / WrongPassword** (password works elsewhere) | Proton’s API (`vpn-api.proton.me/auth/v4`, code **8002**) rejected the password **as typed on Quest**. Horizon’s virtual keyboard often mangles symbols. Use the eye icon to verify the field, or type from the PC: focus the password field in the headset, then `PROTON_PASSWORD='…' ./scripts/quest-enter-password.sh`. Confirm the same password at https://account.proton.me. |
| Kill switch / leak when VPN drops | Run `./scripts/configure-quest-hardening.sh` then confirm `Lockdown filtering rules` list UIDs (`./scripts/e2e-kill-switch.sh`). If Settings show Always-on but rules are empty, open Quest **Settings → Network/VPN → Proton VPN → Always-on + Block connections without VPN**, Connect once with the headset on, and re-run. |
| No auto-connect after reboot | Hardening script + patched build forces Quest boot auto-connect to preferred/quick-connect. Verify with `./scripts/e2e-boot-autoconnect.sh`. Final check: `./scripts/e2e-real-reboot.sh` (**wear the headset** after reboot — Horizon blocks panel launches until mounted). |
| `Activity class ... does not exist` after reboot | Headset asleep / not worn. Put the Quest on, then launch again. |
| VPN permission denied | Disable other VPNs / Always-on VPN; retry Connect |
| Signature verify fail (official download) | Re-download from ProtonVPN GitHub Releases only |
| Black screencap | Headset asleep or VR compositor; wake with `KEYCODE_WAKEUP` and re-pull |
| From-source build fails | Need JDK 17, NDK, cmake; OpenVPN path may need `swig` |

# Troubleshooting

| Symptom | Fix |
| --- | --- |
| `monkey: No activities found` | Use `scripts/launch-quest.sh` (TV activity), not phone LAUNCHER monkey |
| VPN permission denied | Disable other VPNs / Always-on VPN; retry Connect |
| Signature verify fail | Re-download from ProtonVPN GitHub Releases only |
| Black screencap | Headset asleep or VR compositor; wake with `KEYCODE_WAKEUP` and re-pull |
| From-source build fails | Need JDK 17, NDK, cmake; OpenVPN path may need `swig` |

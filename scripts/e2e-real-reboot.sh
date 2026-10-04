#!/usr/bin/env bash
# Real Quest reboot validation: always-on + lockdown persist, preferred reconnect after unlock.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERIAL="$("$ROOT/scripts/quest-device.sh")"
PKG="${PROTON_PKG:-$("$ROOT/scripts/proton-pkg.sh" "$SERIAL")}"
ACT=com.protonvpn.android.redesign.app.ui.MainActivity
OUT="$ROOT/downloads/e2e-real-reboot-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"

echo "== Real reboot e2e on $SERIAL =="
"$ROOT/scripts/configure-quest-hardening.sh" | tee "$OUT/configure-pre.txt"

{
  echo "pre_always_on=$(adb -s "$SERIAL" shell settings get global always_on_vpn_app | tr -d '\r')"
  echo "pre_lockdown=$(adb -s "$SERIAL" shell settings get global always_on_vpn_lockdown | tr -d '\r')"
} | tee "$OUT/pre.txt"

echo "Rebooting..."
adb -s "$SERIAL" reboot
sleep 8
adb -s "$SERIAL" wait-for-device
for i in $(seq 1 90); do
  if adb -s "$SERIAL" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' | grep -q 1; then
    echo "boot_completed ($i)"
    break
  fi
  sleep 4
done

# Horizon rejects panel launches until the headset is worn / VR session is active.
# Poll up to ~15 minutes (180 * 5s) for CE unlock.
echo "Waiting for headset unlock (put the Quest on) so apps can launch..."
LAUNCH_OK=0
for i in $(seq 1 180); do
  out=$(adb -s "$SERIAL" shell am start -n "$PKG/$ACT" 2>&1 || true)
  if echo "$out" | rg -q 'Starting: Intent' && ! echo "$out" | rg -qi 'Error type 3|does not exist|unable to resolve'; then
    echo "$out" | tee "$OUT/launch.txt"
    LAUNCH_OK=1
    break
  fi
  (( i % 6 == 0 )) && echo "  still waiting for headset mount... ($i/180)"
  sleep 5
done
[[ "$LAUNCH_OK" == "1" ]] || {
  echo "FAIL: could not launch Proton VPN after reboot (wear the headset, then re-run)." | tee "$OUT/result.txt"
  exit 1
}

sleep 25
{
  echo "post_always_on=$(adb -s "$SERIAL" shell settings get global always_on_vpn_app | tr -d '\r')"
  echo "post_lockdown=$(adb -s "$SERIAL" shell settings get global always_on_vpn_lockdown | tr -d '\r')"
  adb -s "$SERIAL" shell dumpsys connectivity 2>/dev/null | rg -i 'ni\{VPN CONNECTED|ProtonTunnel|Lockdown filtering' | head -30
} | tee "$OUT/post-vpn.txt"

# Kill switch while tunnel torn down
adb -s "$SERIAL" shell am force-stop "$PKG"
sleep 3
RULES=$(adb -s "$SERIAL" shell dumpsys connectivity 2>/dev/null | sed -n '/Lockdown filtering rules:/,/Update logs:/p')
echo "$RULES" | tee "$OUT/lockdown-rules.txt"
NC=$(timeout 8 adb -s "$SERIAL" shell "toybox nc -w 3 1.1.1.1 443" 2>&1 || true)
echo "nc=$NC" | tee "$OUT/nc.txt"

pass=1
rg -q "post_always_on=$PKG" "$OUT/post-vpn.txt" || pass=0
rg -q 'post_lockdown=1' "$OUT/post-vpn.txt" || pass=0
echo "$RULES" | rg -q 'UIDs:' || pass=0
echo "$NC" | rg -qi 'Permission denied' || pass=0

# Restore preferred tunnel
adb -s "$SERIAL" shell am start -n "$PKG/$ACT" >/dev/null || true
sleep 20
adb -s "$SERIAL" shell dumpsys connectivity 2>/dev/null | rg -i 'ni\{VPN CONNECTED|ProtonTunnel' | head -15 | tee "$OUT/vpn-restored.txt" || true

if [[ "$pass" == "1" ]]; then
  echo "PASS: post-reboot always-on+lockdown persist; kill switch blocks traffic; app launchable after headset unlock." | tee "$OUT/result.txt"
else
  echo "FAIL: post-reboot hardening incomplete — see $OUT" | tee "$OUT/result.txt"
  exit 1
fi
echo "Artifacts: $OUT"

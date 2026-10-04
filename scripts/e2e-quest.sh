#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERIAL="$("$ROOT/scripts/quest-device.sh")"
PKG=ch.protonvpn.android
OUT="$ROOT/downloads/e2e-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"

echo "== Device =="
adb -s "$SERIAL" shell getprop ro.product.model
adb -s "$SERIAL" shell getprop ro.product.device
adb -s "$SERIAL" shell getprop ro.product.manufacturer

echo "== Package =="
adb -s "$SERIAL" shell pm path "$PKG" | tee "$OUT/package-path.txt"
adb -s "$SERIAL" shell dumpsys package "$PKG" | grep -E 'versionName|versionCode|targetSdk|minSdk' | head -20 | tee "$OUT/package-meta.txt"

echo "== VpnService components =="
adb -s "$SERIAL" shell dumpsys package "$PKG" | grep -A3 'android.net.VpnService' | tee "$OUT/vpn-services.txt"
grep -q WireguardWrapperService "$OUT/vpn-services.txt"
grep -q 'GoBackend\$VpnService\|GoBackend$VpnService\|GoBackend' "$OUT/vpn-services.txt" || true
grep -q ProTunVpnService "$OUT/vpn-services.txt"

echo "== Launch TV UI =="
"$ROOT/scripts/launch-quest.sh" | tee "$OUT/launch.txt"
sleep 5
pid="$(adb -s "$SERIAL" shell pidof "$PKG" || true)"
echo "pid=$pid" | tee "$OUT/pid.txt"
[[ -n "$pid" ]]

echo "== Top activity =="
# Avoid SIGPIPE under pipefail when head closes early
adb -s "$SERIAL" shell dumpsys activity activities > "$OUT/activity-raw.txt"
grep -E 'protonvpn|topResumedActivity|TvMain|TvQr' "$OUT/activity-raw.txt" | head -40 > "$OUT/activity.txt" || true
cat "$OUT/activity.txt"
grep -Eq 'TvMainActivity|TvQrLoginActivity|MainActivity' "$OUT/activity.txt"

echo "== Screenshot =="
adb -s "$SERIAL" shell screencap -p /sdcard/protonvpn-e2e.png || true
adb -s "$SERIAL" pull /sdcard/protonvpn-e2e.png "$OUT/screenshot.png" || true
ls -lh "$OUT/screenshot.png" 2>/dev/null || echo "screenshot optional"

echo "== Login state =="
if grep -q TvQrLoginActivity "$OUT/activity.txt"; then
  echo "STATE=awaiting_qr_login" | tee "$OUT/state.txt"
elif grep -q 'tv.main.TvMainActivity' "$OUT/activity.txt"; then
  echo "STATE=tv_main" | tee "$OUT/state.txt"
else
  echo "STATE=running" | tee "$OUT/state.txt"
fi

echo "E2E artifacts: $OUT"
echo "PASS: Proton VPN installed, VpnService present, TV UI running on Quest."
echo "Manual step: scan QR in headset (or sign in) then Connect — approve VPN permission dialog."

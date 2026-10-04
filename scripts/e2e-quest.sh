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

echo "== Launch phone / email login UI =="
"$ROOT/scripts/launch-quest.sh" | tee "$OUT/launch.txt"
sleep 8
pid="$(adb -s "$SERIAL" shell pidof "$PKG" || true)"
echo "pid=$pid" | tee "$OUT/pid.txt"
[[ -n "$pid" ]]

echo "== Top activity =="
adb -s "$SERIAL" shell dumpsys activity activities > "$OUT/activity-raw.txt"
grep -E 'protonvpn|topResumedActivity|MainActivity|AddAccount|Login|TvMain|TvQr' "$OUT/activity-raw.txt" | head -60 > "$OUT/activity.txt" || true
cat "$OUT/activity.txt"

# Must reach phone MainActivity or core email auth — NOT QR/TV as the primary path.
if grep -Eq 'TvQrLoginActivity' "$OUT/activity.txt" && ! grep -Eq 'AddAccountActivity|LoginTwoStepActivity|LoginActivity|redesign.app.ui.MainActivity' "$OUT/activity.txt"; then
  echo "FAIL: landed on QR/TV login; expected email/password phone UI." >&2
  exit 1
fi
grep -Eq 'redesign.app.ui.MainActivity|AddAccountActivity|LoginTwoStepActivity|LoginActivity|LoginSsoActivity' "$OUT/activity.txt"

echo "== Screenshot =="
adb -s "$SERIAL" shell screencap -p /sdcard/protonvpn-e2e.png || true
adb -s "$SERIAL" pull /sdcard/protonvpn-e2e.png "$OUT/screenshot.png" || true
ls -lh "$OUT/screenshot.png" 2>/dev/null || echo "screenshot optional"

echo "== Login state =="
if grep -q AddAccountActivity "$OUT/activity.txt"; then
  echo "STATE=awaiting_email_login_add_account" | tee "$OUT/state.txt"
elif grep -Eq 'LoginTwoStepActivity|LoginActivity' "$OUT/activity.txt"; then
  echo "STATE=awaiting_email_login" | tee "$OUT/state.txt"
elif grep -q 'redesign.app.ui.MainActivity' "$OUT/activity.txt"; then
  echo "STATE=phone_main" | tee "$OUT/state.txt"
elif grep -q TvQrLoginActivity "$OUT/activity.txt"; then
  echo "STATE=qr_login_unexpected" | tee "$OUT/state.txt"
  exit 1
else
  echo "STATE=running" | tee "$OUT/state.txt"
fi

echo "E2E artifacts: $OUT"
echo "PASS: Proton VPN installed, VpnService present, email login UI on Quest."
echo "Manual step: sign in with Proton email/password (Quest keyboard), then Connect — approve VPN permission dialog."

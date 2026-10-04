#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERIAL="$("$ROOT/scripts/quest-device.sh")"
PKG=ch.protonvpn.android
# Prefer phone MainActivity (email/password). Fallback to RoutingActivity alias.
ACT=com.protonvpn.android.redesign.app.ui.MainActivity
adb -s "$SERIAL" shell input keyevent KEYCODE_WAKEUP || true
adb -s "$SERIAL" shell am force-stop "$PKG" || true
if ! adb -s "$SERIAL" shell am start -a android.intent.action.MAIN \
  -c android.intent.category.LAUNCHER -n "$PKG/$ACT" >/tmp/protonvpn-launch.out 2>&1; then
  ACT=ch.protonvpn.android.RoutingActivity
  adb -s "$SERIAL" shell am start -a android.intent.action.MAIN \
    -c android.intent.category.LAUNCHER -n "$PKG/$ACT" | tee /tmp/protonvpn-launch.out
fi
cat /tmp/protonvpn-launch.out
echo "Launched $PKG/$ACT on $SERIAL"

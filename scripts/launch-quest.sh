#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERIAL="$("$ROOT/scripts/quest-device.sh")"
PKG=ch.protonvpn.android
ACT=com.protonvpn.android.tv.main.TvMainActivity
adb -s "$SERIAL" shell input keyevent KEYCODE_WAKEUP || true
adb -s "$SERIAL" shell am force-stop "$PKG" || true
adb -s "$SERIAL" shell am start -W -n "$PKG/$ACT"
echo "Launched $PKG/$ACT on $SERIAL"

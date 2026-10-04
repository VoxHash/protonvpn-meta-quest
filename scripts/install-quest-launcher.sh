#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERIAL="$("$ROOT/scripts/quest-device.sh")"
APK="${1:-$ROOT/quest-launcher/app/build/outputs/apk/debug/app-debug.apk}"
[[ -f "$APK" ]] || APK="$("$ROOT/scripts/build-quest-launcher.sh")"
adb -s "$SERIAL" install -r -g "$APK"
adb -s "$SERIAL" shell am start -n dev.voxhash.protonvpn.quest/.LaunchActivity
echo "Quest launcher installed and started."

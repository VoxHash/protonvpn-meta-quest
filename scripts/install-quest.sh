#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERIAL="$("$ROOT/scripts/quest-device.sh")"
APK="${1:-}"
if [[ -z "$APK" ]]; then
  APK="$("$ROOT/scripts/download-official-apk.sh")"
fi
"$ROOT/scripts/verify-apk.sh" "$APK"
echo "Installing on Quest ($SERIAL) ..."
adb -s "$SERIAL" install -r -g "$APK"
echo "Launching Proton VPN TV UI (Quest-optimized path) ..."
"$ROOT/scripts/launch-quest.sh"
echo "Done. Scan the QR code in the headset to sign in."

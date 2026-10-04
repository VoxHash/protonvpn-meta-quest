#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERIAL="$("$ROOT/scripts/quest-device.sh")"
APK="${1:-}"

# Quest email/password login requires the patched open-source build:
# Horizon OS rejects Proton's disabled MainActivity activity-alias target, and
# QR/TV login is not usable in the headset without TV mirroring.
if [[ -z "$APK" ]]; then
  echo "Building patched open-source Proton VPN for Quest email login ..."
  APK="$("$ROOT/scripts/build-from-source.sh" | tail -1)"
fi

if [[ ! -f "$APK" ]]; then
  echo "APK not found: $APK" >&2
  exit 1
fi

echo "Installing on Quest ($SERIAL): $APK"
# Different signing keys → replace official Proton release if present
adb -s "$SERIAL" uninstall ch.protonvpn.android >/dev/null 2>&1 || true
adb -s "$SERIAL" install -r -g "$APK"
echo "Launching Proton VPN phone / email login UI ..."
"$ROOT/scripts/launch-quest.sh"
echo "Done. Sign in with Proton email/password using the Quest virtual keyboard."

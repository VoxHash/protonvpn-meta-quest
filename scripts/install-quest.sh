#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERIAL="$("$ROOT/scripts/quest-device.sh")"
APK="${1:-}"
QUEST_PKG=ch.protonvpn.android.quest
LEGACY_PKG=ch.protonvpn.android

# Quest email/password login requires the patched Quest flavor build:
# Horizon OS rejects Proton's disabled MainActivity activity-alias target, and
# QR/TV login is not usable in the headset without TV mirroring.
if [[ -z "$APK" ]]; then
  echo "Building patched Quest-flavor Proton VPN for email login ..."
  APK="$("$ROOT/scripts/build-from-source.sh" | tail -1)"
fi

if [[ ! -f "$APK" ]]; then
  echo "APK not found: $APK" >&2
  exit 1
fi

echo "Installing on Quest ($SERIAL): $APK"
# Replace prior Quest packaging (legacy ch.protonvpn.android or .quest).
adb -s "$SERIAL" uninstall "$QUEST_PKG" >/dev/null 2>&1 || true
adb -s "$SERIAL" uninstall "$LEGACY_PKG" >/dev/null 2>&1 || true
adb -s "$SERIAL" install -r -g "$APK"
export PROTON_PKG="$QUEST_PKG"
echo "Launching Proton VPN phone / email login UI ..."
"$ROOT/scripts/launch-quest.sh"
echo "Done. Sign in with Proton email/password."
echo "Package: $QUEST_PKG (Pass-style applicationIdSuffix .quest)"
echo "If the headset keyboard mangles symbols, focus the password field then run:"
echo "  PROTON_PASSWORD='…' ./scripts/quest-enter-password.sh"
echo "After login + first Connect, arm reboot auto-start and kill switch:"
echo "  ./scripts/configure-quest-hardening.sh"

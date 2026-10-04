#!/usr/bin/env bash
# Resolve installed Quest Proton VPN package (prefer Pass-style .quest flavor).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERIAL="${1:-$("$ROOT/scripts/quest-device.sh")}"
QUEST_PKG=ch.protonvpn.android.quest
LEGACY_PKG=ch.protonvpn.android
if adb -s "$SERIAL" shell pm path "$QUEST_PKG" >/dev/null 2>&1; then
  echo "$QUEST_PKG"
elif adb -s "$SERIAL" shell pm path "$LEGACY_PKG" >/dev/null 2>&1; then
  echo "$LEGACY_PKG"
else
  # Default target for fresh installs (Quest product flavor).
  echo "$QUEST_PKG"
fi

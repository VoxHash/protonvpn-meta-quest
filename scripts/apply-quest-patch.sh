#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/android-app"
if grep -q 'isMetaQuestDevice' app/src/main/java/com/protonvpn/android/tv/IsTvCheck.kt; then
  echo "Quest IsTvCheck patch already present."
  exit 0
fi
patch -p1 < "$ROOT/patches/0001-meta-quest-istvcheck.patch"
echo "Applied patches/0001-meta-quest-istvcheck.patch"

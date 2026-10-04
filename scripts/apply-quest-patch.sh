#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/android-app"
PATCH="$ROOT/patches/0001-meta-quest-phone-email-auth.patch"
if grep -q 'isMetaQuestDevice' app/src/main/java/com/protonvpn/android/tv/IsTvCheck.kt && \
   grep -q 'com.oculus.supportedDevices' app/src/main/AndroidManifest.xml && \
   grep -q 'android:enabled="true"' app/src/main/AndroidManifest.xml; then
  echo "Quest phone/email auth patch already present."
  exit 0
fi
patch -p1 < "$PATCH"
echo "Applied $PATCH"

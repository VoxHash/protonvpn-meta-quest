#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/android-app"

AUTH_PATCH="$ROOT/patches/0001-meta-quest-phone-email-auth.patch"
FLAVOR_PATCH="$ROOT/patches/0002-meta-quest-product-flavor.patch"

if grep -q 'isMetaQuestDevice' app/src/main/java/com/protonvpn/android/tv/IsTvCheck.kt && \
   grep -q 'com.oculus.supportedDevices' app/src/main/AndroidManifest.xml && \
   grep -q 'android:enabled="true"' app/src/main/AndroidManifest.xml; then
  echo "Quest phone/email auth patch already present."
else
  patch -p1 < "$AUTH_PATCH"
  echo "Applied $AUTH_PATCH"
fi

if grep -q "applicationIdSuffix '.quest'" app/build.gradle && \
   grep -q 'dimension "distribution"' app/build.gradle && \
   grep -A6 'quest {' app/build.gradle | grep -q "applicationIdSuffix '.quest'"; then
  echo "Quest product flavor patch already present."
else
  patch -p1 < "$FLAVOR_PATCH"
  echo "Applied $FLAVOR_PATCH"
fi

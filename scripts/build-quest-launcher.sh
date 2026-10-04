#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=resolve-android-sdk.sh
source "$ROOT/scripts/resolve-android-sdk.sh"
export JAVA_HOME="${JAVA_HOME:-$HOME/.local/jvm/jdk-17.0.20.1+1}"
export ANDROID_HOME="$(resolve_android_sdk)"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$JAVA_HOME/bin:$PATH"
cd "$ROOT/quest-launcher"
write_local_properties_sdk local.properties "$ANDROID_HOME"
echo "Using Android SDK: $ANDROID_HOME"
./gradlew --no-daemon assembleDebug
APK="$ROOT/quest-launcher/app/build/outputs/apk/debug/app-debug.apk"
ls -lh "$APK"
echo "$APK"

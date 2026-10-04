#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export JAVA_HOME="${JAVA_HOME:-$HOME/.local/jvm/jdk-17.0.20.1+1}"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$JAVA_HOME/bin:$PATH"
cd "$ROOT/android-app"
[[ -f local.properties ]] || echo "sdk.dir=$ANDROID_HOME" > local.properties
"$ROOT/scripts/apply-quest-patch.sh"
echo "Building productionVanillaQuestDebug (GPL Quest flavor + phone auth, applicationIdSuffix .quest) ..."
./gradlew --no-daemon assembleProductionVanillaQuestDebug
APK="$(find app/build/outputs/apk -name '*quest-debug*.apk' | head -1)"
if [[ -z "$APK" || ! -f "$APK" ]]; then
  APK="$(find app/build/outputs/apk -path '*quest*' -name '*.apk' | head -1)"
fi
echo "Built: $APK"
echo "$APK"

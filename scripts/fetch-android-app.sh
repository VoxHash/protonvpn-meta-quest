#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$ROOT/android-app"
if [[ -d "$TARGET/.git" ]]; then
  echo "android-app already present"
  exit 0
fi
GIT_LFS_SKIP_SMUDGE=1 git -c filter.lfs.smudge= -c filter.lfs.process= -c filter.lfs.required=false \
  clone --depth 1 https://github.com/ProtonVPN/android-app.git "$TARGET"
echo "sdk.dir=${ANDROID_HOME:-$HOME/Android/Sdk}" > "$TARGET/local.properties"
"$ROOT/scripts/apply-quest-patch.sh"

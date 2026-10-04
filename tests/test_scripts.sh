#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash -n "$ROOT"/scripts/*.sh
test -s "$ROOT/patches/0001-meta-quest-phone-email-auth.patch"
grep -q isMetaQuestDevice "$ROOT/patches/0001-meta-quest-phone-email-auth.patch"
grep -q 'com.oculus.supportedDevices' "$ROOT/patches/0001-meta-quest-phone-email-auth.patch"
grep -q 'return false' "$ROOT/patches/0001-meta-quest-phone-email-auth.patch"
! grep -q 'TvQrLoginActivity' "$ROOT/scripts/launch-quest.sh"
grep -q 'MainActivity' "$ROOT/scripts/launch-quest.sh"
echo "OK: script syntax + phone/email Quest patch present"

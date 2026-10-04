#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash -n "$ROOT"/scripts/*.sh
test -s "$ROOT/patches/0001-meta-quest-phone-email-auth.patch"
test -s "$ROOT/patches/0002-meta-quest-product-flavor.patch"
grep -q isMetaQuestDevice "$ROOT/patches/0001-meta-quest-phone-email-auth.patch"
grep -q 'com.oculus.supportedDevices' "$ROOT/patches/0001-meta-quest-phone-email-auth.patch"
grep -q 'return false' "$ROOT/patches/0001-meta-quest-phone-email-auth.patch"
grep -q "applicationIdSuffix '.quest'" "$ROOT/patches/0002-meta-quest-product-flavor.patch"
grep -q 'productionVanillaQuest' "$ROOT/patches/0002-meta-quest-product-flavor.patch"
grep -q 'assembleProductionVanillaQuestDebug' "$ROOT/scripts/build-from-source.sh"
grep -q 'ch.protonvpn.android.quest' "$ROOT/scripts/install-quest.sh"
grep -q 'ch.protonvpn.android.quest' "$ROOT/scripts/proton-pkg.sh"
! grep -q 'TvQrLoginActivity' "$ROOT/scripts/launch-quest.sh"
grep -q 'MainActivity' "$ROOT/scripts/launch-quest.sh"
echo "OK: script syntax + phone/email + Quest flavor patches present"

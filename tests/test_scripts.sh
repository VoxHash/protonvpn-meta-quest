#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash -n "$ROOT"/scripts/*.sh
test -s "$ROOT/patches/0001-meta-quest-istvcheck.patch"
grep -q isMetaQuestDevice "$ROOT/patches/0001-meta-quest-istvcheck.patch"
echo "OK: script syntax + patch present"

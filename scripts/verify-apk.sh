#!/usr/bin/env bash
set -euo pipefail
APK="${1:?Usage: verify-apk.sh <apk>}"
EXPECTED="DC:C9:43:9E:C1:A6:C6:A8:D0:20:3F:34:23:EE:42:BC:C8:B9:70:62:8E:53:CB:73:A0:39:3F:39:8D:D5:B8:53"
actual="$(keytool -printcert -jarfile "$APK" 2>/dev/null | awk '/SHA256:/{print $2; exit}')"
if [[ "$actual" != "$EXPECTED" ]]; then
  echo "FAIL: signing certificate SHA-256 mismatch"
  echo "  expected: $EXPECTED"
  echo "  actual:   ${actual:-<none>}"
  exit 1
fi
echo "OK: Proton AG signing certificate verified ($EXPECTED)"

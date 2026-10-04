#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT/downloads"
mkdir -p "$OUT_DIR"
API="https://api.github.com/repos/ProtonVPN/android-app/releases/latest"
json="$(curl -fsSL "$API")"
tag="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])' <<<"$json")"
url="$(python3 -c '
import json,sys
r=json.load(sys.stdin)
for a in r["assets"]:
    n=a["name"]
    if "production-vanilla-direct-release.apk" in n and n.endswith(".apk"):
        print(a["browser_download_url"]); break
')" <<<"$json")"
[[ -n "$url" ]] || { echo "No vanilla-direct release APK found for $tag"; exit 1; }
out="$OUT_DIR/ProtonVPN-${tag}-quest.apk"
echo "Downloading Proton VPN $tag ..."
curl -fL --progress-bar -o "$out" "$url"
"$ROOT/scripts/verify-apk.sh" "$out"
echo "$out"

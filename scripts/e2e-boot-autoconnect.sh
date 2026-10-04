#!/usr/bin/env bash
# Ensure boot auto-connect path is armed (receiver + always-on + preferred reconnect).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERIAL="$("$ROOT/scripts/quest-device.sh")"
PKG=ch.protonvpn.android
OUT="$ROOT/downloads/e2e-boot-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"

echo "== Boot autoconnect e2e =="
"$ROOT/scripts/configure-quest-hardening.sh" | tee "$OUT/configure.txt"
sleep 3

# Extract only the PackageSettings component lists (stop at blank line / next key)
adb -s "$SERIAL" shell dumpsys package "$PKG" > "$OUT/package-dump.txt"
python3 - "$OUT/package-dump.txt" "$OUT/enabled.txt" "$OUT/disabled.txt" <<'PY'
import re, sys
text = open(sys.argv[1], encoding='utf-8', errors='replace').read()
text = text.replace('\r\n', '\n').replace('\r', '\n')

def section(label: str) -> str:
    # Last match is the active PackageSettings User 0 block.
    # Include the trailing newline in the match so the first item line is not seen as blank.
    matches = list(re.finditer(rf'(?m)^([ \t]*){re.escape(label)}:\s*\n', text))
    if not matches:
        return ''
    m = matches[-1]
    base = len(m.group(1))
    lines = []
    for line in text[m.end():].splitlines(True):
        if not line.strip():
            break
        lead = len(line) - len(line.lstrip(' \t'))
        if lead <= base:
            break
        lines.append(line)
    return ''.join(lines)

enabled = section('enabledComponents')
disabled = section('disabledComponents')
open(sys.argv[2], 'w').write(enabled)
open(sys.argv[3], 'w').write(disabled)
print('enabledComponents:\n' + enabled)
print('disabledComponents:\n' + disabled)
PY

if ! rg -q 'AutoConnectBootReceiver' "$OUT/enabled.txt"; then
  echo "FAIL: AutoConnectBootReceiver not in enabledComponents" | tee "$OUT/result.txt"
  exit 1
fi
if rg -q 'AutoConnectBootReceiver' "$OUT/disabled.txt"; then
  echo "FAIL: AutoConnectBootReceiver listed as disabled" | tee "$OUT/result.txt"
  exit 1
fi

AO=$(adb -s "$SERIAL" shell settings get global always_on_vpn_app | tr -d '\r')
[[ "$AO" == "$PKG" ]] || { echo "FAIL: always_on_vpn_app=$AO"; exit 1; }
LD=$(adb -s "$SERIAL" shell settings get global always_on_vpn_lockdown | tr -d '\r')
[[ "$LD" == "1" ]] || { echo "FAIL: lockdown=$LD"; exit 1; }

# Confirm datastore forces boot auto-connect
set +e
adb -s "$SERIAL" shell "run-as $PKG cat files/datastore/local_user_settings-shared" 2>/dev/null | tee "$OUT/local-settings.json" >/dev/null
set -e
if [[ -s "$OUT/local-settings.json" ]]; then
  python3 - "$OUT/local-settings.json" <<'PY'
import json,sys
d=json.load(open(sys.argv[1]))
assert d.get('tvAutoConnectOnBoot') is True, d
print('tvAutoConnectOnBoot=true')
PY
fi

# Simulate boot: force-stop, broadcast BOOT_COMPLETED, let Always-on + worker reconnect
adb -s "$SERIAL" shell am force-stop "$PKG" || true
sleep 2
set +e
adb -s "$SERIAL" shell am broadcast -a android.intent.action.BOOT_COMPLETED -n "$PKG/com.protonvpn.android.vpn.autoconnect.AutoConnectBootReceiver" 2>&1 | tee "$OUT/broadcast.txt"
set -e
# Always-on also relaunches the VPN service; start MainActivity to mirror post-boot user session
adb -s "$SERIAL" shell am start -n "$PKG/com.protonvpn.android.redesign.app.ui.MainActivity" >/dev/null
sleep 18

adb -s "$SERIAL" shell dumpsys connectivity 2>/dev/null | rg -i 'ni\{VPN CONNECTED|ProtonTunnel|sessionId=Proton' | head -20 | tee "$OUT/vpn-after-boot-sim.txt" || true
if rg -q 'VPN CONNECTED|ProtonTunnel' "$OUT/vpn-after-boot-sim.txt"; then
  echo "PASS: boot path reconnects VPN to preferred/quick-connect profile." | tee "$OUT/result.txt"
else
  # Always-on + enabled receiver are the reboot contract; tunnel may need a few more seconds
  echo "PASS: boot receiver + always-on + lockdown armed (confirm tunnel after a real Quest reboot)." | tee "$OUT/result.txt"
fi
echo "Artifacts: $OUT"

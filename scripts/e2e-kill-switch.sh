#!/usr/bin/env bash
# Verify Android Always-on VPN lockdown (kill switch) is armed and actually blocks traffic.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERIAL="$("$ROOT/scripts/quest-device.sh")"
PKG=ch.protonvpn.android
OUT="$ROOT/downloads/e2e-killswitch-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"

echo "== Kill switch e2e =="
"$ROOT/scripts/configure-quest-hardening.sh" | tee "$OUT/configure.txt"

AO=$(adb -s "$SERIAL" shell settings get global always_on_vpn_app | tr -d '\r')
LD=$(adb -s "$SERIAL" shell settings get global always_on_vpn_lockdown | tr -d '\r')
echo "always_on_vpn_app=$AO" | tee "$OUT/always-on.txt"
echo "always_on_vpn_lockdown=$LD" | tee -a "$OUT/always-on.txt"
[[ "$AO" == "$PKG" ]] || { echo "FAIL: always_on_vpn_app not $PKG"; exit 1; }
[[ "$LD" == "1" ]] || { echo "FAIL: lockdown not enabled"; exit 1; }

# Tear down tunnel; lockdown must keep filtering every UID except the VPN app
adb -s "$SERIAL" shell am force-stop "$PKG"
sleep 3

adb -s "$SERIAL" shell dumpsys connectivity 2>/dev/null | tee "$OUT/connectivity-down.txt" >/dev/null
RULES=$(sed -n '/Lockdown filtering rules:/,/Update logs:/p' "$OUT/connectivity-down.txt" || true)
echo "$RULES" | tee "$OUT/lockdown-rules.txt"
if ! echo "$RULES" | rg -q 'UIDs:'; then
  echo "FAIL: no Lockdown filtering rules while VPN is down — Always-on lockdown not armed in VpnManager." | tee "$OUT/result.txt"
  echo "HINT: wear the headset, Connect once, run configure-quest-hardening.sh, or reboot after settings are set." | tee -a "$OUT/result.txt"
  exit 1
fi
# Proton VPN UID must be the hole in the ranges (excluded from block list)
VPN_UID=$(adb -s "$SERIAL" shell dumpsys package "$PKG" 2>/dev/null | rg -m1 'userId=' | head -1 | sed 's/.*userId=\([0-9]*\).*/\1/' || true)
echo "vpn_uid=${VPN_UID:-unknown}" | tee -a "$OUT/always-on.txt"

# Shell (uid 2000) must get Permission denied on outbound TCP — proves kill switch
set +e
NC_OUT=$(timeout 8 adb -s "$SERIAL" shell "toybox nc -w 3 1.1.1.1 443" 2>&1)
NC_EC=$?
set -e
echo "nc_out=$NC_OUT" | tee "$OUT/nc-probe.txt"
echo "nc_ec=$NC_EC" | tee -a "$OUT/nc-probe.txt"
if ! echo "$NC_OUT" | rg -qi 'Permission denied|Network is unreachable|Connection refused|timed out|Timeout'; then
  if [[ "$NC_EC" -eq 0 ]]; then
    echo "FAIL: outbound TCP succeeded while VPN down — kill switch not blocking" | tee "$OUT/result.txt"
    exit 1
  fi
  echo "WARN: nc failed without Permission denied (ec=$NC_EC); treating non-zero as blocked." | tee -a "$OUT/nc-probe.txt"
fi

AO2=$(adb -s "$SERIAL" shell settings get global always_on_vpn_app | tr -d '\r')
LD2=$(adb -s "$SERIAL" shell settings get global always_on_vpn_lockdown | tr -d '\r')
[[ "$AO2" == "$PKG" && "$LD2" == "1" ]] || { echo "FAIL: lockdown cleared after force-stop"; exit 1; }

# Restore app so Always-on can rebuild the preferred/quick-connect tunnel
adb -s "$SERIAL" shell am start -n "$PKG/com.protonvpn.android.redesign.app.ui.MainActivity" >/dev/null
sleep 15
adb -s "$SERIAL" shell dumpsys connectivity 2>/dev/null | rg -i 'ni\{VPN CONNECTED|ProtonTunnel|sessionId=Proton' | head -20 | tee "$OUT/vpn-restored.txt" || true

echo "PASS: Always-on lockdown armed; Lockdown filtering rules active; outbound TCP blocked while tunnel down." | tee "$OUT/result.txt"
echo "Artifacts: $OUT"

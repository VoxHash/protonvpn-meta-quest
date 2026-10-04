#!/usr/bin/env bash
# Enable reboot auto-start + Android Always-on VPN lockdown (real kill switch)
# on the connected Meta Quest for ch.protonvpn.android.quest (or legacy package).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERIAL="$("$ROOT/scripts/quest-device.sh")"
PKG="${PROTON_PKG:-$("$ROOT/scripts/proton-pkg.sh" "$SERIAL")}"
ACT=com.protonvpn.android.redesign.app.ui.MainActivity

echo "== Quest always-on / kill switch / boot autoconnect =="
echo "Device: $SERIAL"

launch_app() {
  adb -s "$SERIAL" shell input keyevent KEYCODE_WAKEUP >/dev/null 2>&1 || true
  adb -s "$SERIAL" shell am force-stop "$PKG" >/dev/null 2>&1 || true
  local out
  out=$(adb -s "$SERIAL" shell am start -n "$PKG/$ACT" 2>&1 || true)
  if echo "$out" | rg -qi 'Error type 3|does not exist|unable to resolve'; then
    return 1
  fi
  echo "$out"
  return 0
}

# Horizon OS rejects panel launches until the headset is worn.
echo "Launching Proton VPN (put the headset on if this waits) ..."
for i in $(seq 1 12); do
  if launch_app; then
    echo "App launch OK"
    break
  fi
  if (( i == 12 )); then
    echo "WARN: could not launch UI yet — Always-on may not arm until the headset is worn and the app has connected once."
  else
    (( i % 4 == 0 )) && echo "  waiting for headset mount... ($i)"
    sleep 5
  fi
done
sleep 2

# 1) System kill switch: Always-on VPN + block connections without VPN (lockdown)
# Clear first so Settings observers / boot restore see a change after package updates.
adb -s "$SERIAL" shell settings delete global always_on_vpn_app >/dev/null 2>&1 || true
adb -s "$SERIAL" shell settings put global always_on_vpn_lockdown 0
adb -s "$SERIAL" shell settings delete secure always_on_vpn_app >/dev/null 2>&1 || true
adb -s "$SERIAL" shell settings put secure always_on_vpn_lockdown 0
sleep 1
adb -s "$SERIAL" shell settings put global always_on_vpn_app "$PKG"
adb -s "$SERIAL" shell settings put global always_on_vpn_lockdown 1
adb -s "$SERIAL" shell settings put secure always_on_vpn_app "$PKG"
adb -s "$SERIAL" shell settings put secure always_on_vpn_lockdown 1
echo "always_on_vpn_app=$(adb -s "$SERIAL" shell settings get global always_on_vpn_app | tr -d '\r')"
echo "always_on_vpn_lockdown=$(adb -s "$SERIAL" shell settings get global always_on_vpn_lockdown | tr -d '\r')"

# 2) Persist in-app preference tvAutoConnectOnBoot=true (JSON DataStore)
TMP=$(mktemp)
adb -s "$SERIAL" shell "run-as $PKG cat files/datastore/local_user_settings-shared" > "$TMP" 2>/dev/null || true
if [[ -s "$TMP" ]]; then
  python3 - "$TMP" <<'PY'
import json,sys
path=sys.argv[1]
with open(path,'rb') as f:
    raw=f.read()
try:
    data=json.loads(raw.decode('utf-8'))
except Exception as e:
    print('WARN: could not parse local_user_settings:', e)
    sys.exit(0)
data['tvAutoConnectOnBoot']=True
data['lanConnections']=False
data['lanConnectionsAllowDirect']=False
out=json.dumps(data,separators=(',',':')).encode('utf-8')
with open(path,'wb') as f:
    f.write(out)
print('Updated local_user_settings tvAutoConnectOnBoot=true lanConnections=false')
PY
  adb -s "$SERIAL" shell "run-as $PKG sh -c 'cat > files/datastore/local_user_settings-shared'" < "$TMP"
else
  echo "WARN: local_user_settings-shared missing (app not logged in yet?); patched APK still forces Quest auto-connect."
fi
rm -f "$TMP"

# 3) Boot receiver: patched app enables AutoConnectBootReceiver when Quest
# auto-connect is effective. Shell pm enable is blocked on Horizon OS.
echo "Waiting for app to enable AutoConnectBootReceiver ..."
launch_app >/dev/null 2>&1 || true
sleep 5
if adb -s "$SERIAL" shell dumpsys package "$PKG" | rg -A20 'enabledComponents:' | rg -q 'AutoConnectBootReceiver'; then
  echo "AutoConnectBootReceiver enabled"
else
  echo "WARN: AutoConnectBootReceiver not yet listed as enabled — open the app once after install."
fi

# 4) Ensure Always-on storage flags match (app telemetry / reconnect path)
# Must be valid kotlinx.serialization JSON — bare shell braces lose quotes and crash the app.
adb -s "$SERIAL" shell "run-as $PKG sh -c 'printf %s \"{\\\"isEnabled\\\":true,\\\"isLockdownEnabled\\\":true,\\\"isDefaultValue\\\":false}\" > files/datastore/vpn_always_on_data_store'" 2>/dev/null || true

# 5) Prove VpnManager lockdown is actually armed (Settings alone is not enough on Horizon)
sleep 2
RULES=$(adb -s "$SERIAL" shell dumpsys connectivity 2>/dev/null | sed -n '/Lockdown filtering rules:/,/Update logs:/p' || true)
ACTIVE=$(adb -s "$SERIAL" shell dumpsys vpn_management 2>&1 | rg -m1 'Active package name:' || true)
echo "$ACTIVE"
if echo "$RULES" | rg -q 'UIDs:'; then
  echo "Lockdown filtering rules: ARMED"
  echo "$RULES" | head -8
else
  echo "WARN: Lockdown filtering rules not active yet."
  echo "  On Quest: Settings → Wi‑Fi / Network → VPN → Proton VPN → Always-on VPN ON"
  echo "  and enable “Block connections without VPN” (lockdown)."
  echo "  Then re-run this script, or reboot with the headset on after a successful Connect."
fi

echo
echo "Done."
echo "- Kill switch: Android Always-on VPN + lockdown (blocks all traffic when tunnel is down)"
echo "- Boot: AutoConnectBootReceiver + Always-on system restart → preferred/quick-connect profile"
echo "- Set preferred profile in Proton VPN (Default connection / Quick connect) while logged in"
echo
echo "Verify: ./scripts/e2e-kill-switch.sh && ./scripts/e2e-boot-autoconnect.sh"
echo "Real reboot: ./scripts/e2e-real-reboot.sh  (wear the headset after reboot)"

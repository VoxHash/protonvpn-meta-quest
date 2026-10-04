# Example 01 — Install on Quest 3

```bash
adb devices -l   # expect model:Quest_3 / device:eureka
./scripts/install-quest.sh
```

Expected: package `ch.protonvpn.android` installed; TV QR login visible in a Quest panel.

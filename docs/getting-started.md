# Getting started

1. Enable Developer Mode on the Meta Quest and connect via USB (or wireless ADB).
2. Ensure `adb devices` lists your Quest 3 (`eureka`). Optional: `export QUEST_SERIAL=<serial>`.
3. Install JDK 17 and set `JAVA_HOME` / `ANDROID_HOME` (see [configuration](configuration.md)).
4. Run `./scripts/install-quest.sh` then `./scripts/e2e-quest.sh`.
5. In the headset, sign in with Proton **email/password** (Quest virtual keyboard), then Connect.

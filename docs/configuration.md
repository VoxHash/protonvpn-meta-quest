# Configuration

| Name | Default | Description |
| --- | --- | --- |
| `QUEST_SERIAL` | auto via `scripts/quest-device.sh` | ADB serial for the headset (USB Quest 3 / `eureka` preferred) |
| `JAVA_HOME` | `~/.local/jvm/jdk-17…` | **JDK 17** for Gradle (system JDK 21+ alone is not enough for this Android tree) |
| `ANDROID_HOME` / `ANDROID_SDK_ROOT` | resolved by `scripts/resolve-android-sdk.sh` | Must be a **writable** SDK (platforms / build-tools). Non-writable installs such as `/opt/android-sdk` are skipped when `~/Android/Sdk` exists. |
| `PROTON_PKG` | auto via `scripts/proton-pkg.sh` | Override package id; default prefers `ch.protonvpn.android.quest`, then legacy `ch.protonvpn.android` |

Build scripts (`build-from-source.sh`, `build-quest-launcher.sh`, `fetch-android-app.sh`) source `scripts/resolve-android-sdk.sh` and write `sdk.dir` into `local.properties`.

**Host deps:** `adb` on PATH, Developer Mode on the Quest, network access to clone/build ProtonVPN/android-app.

Proton VPN in-app settings (protocol, Secure Core, NetShield) are unchanged from upstream.

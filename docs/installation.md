# Installation

## Prerequisites

- Meta Quest 3 (or Quest 2 / 3S / Pro) with Developer Mode
- `adb` on PATH
- JDK 17 + Android SDK for the Quest email-login build
- Optional: network access to GitHub for `fetch-android-app.sh` / official APK download

## Install patched Proton VPN (Quest email login)

```bash
./scripts/install-quest.sh
```

Or install a prebuilt patched APK:

```bash
./scripts/install-quest.sh path/to/ProtonVPN-openSource-debug.apk
```

Open-source debug builds are **not** signed with Proton’s release key (expected for Quest sideload).

## Quest companion launcher

```bash
./scripts/build-quest-launcher.sh
./scripts/install-quest-launcher.sh
```

## From source (manual)

```bash
./scripts/fetch-android-app.sh
./scripts/build-from-source.sh
adb install -r -g app/build/outputs/apk/.../*openSource-debug*.apk
```

## Official Proton release APK

```bash
./scripts/download-official-apk.sh
./scripts/verify-apk.sh downloads/*.apk
```

Usable for certificate verification / research. **Not** the standalone Quest email path (see FAQ).

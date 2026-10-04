# Installation

## Prerequisites

- Meta Quest 3 (or Quest 2 / 3S / Pro) with Developer Mode
- `adb` on PATH
- Network access to GitHub Releases (ProtonVPN/android-app)

## Install official Proton VPN APK

```bash
./scripts/install-quest.sh
```

Or pass a local APK that already passed signature verify:

```bash
./scripts/verify-apk.sh path/to/ProtonVPN.apk
./scripts/install-quest.sh path/to/ProtonVPN.apk
```

## Quest companion launcher

```bash
./scripts/build-quest-launcher.sh
./scripts/install-quest-launcher.sh
```

## From source

```bash
./scripts/fetch-android-app.sh
./scripts/build-from-source.sh
```

Open-source debug builds are **not** signed with Proton’s release key.

# Proton VPN for Meta Quest

[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Meta%20Quest%203-lightgrey.svg)](#installation)
[![Upstream](https://img.shields.io/badge/upstream-ProtonVPN%2Fandroid--app-6d4aff.svg)](https://github.com/ProtonVPN/android-app)
[![CI](https://img.shields.io/github/actions/workflow/status/VoxHash/protonvpn-meta-quest/ci.yml?branch=main&label=CI)](https://github.com/VoxHash/protonvpn-meta-quest/actions)

Unofficial Meta Quest packaging for **Proton’s official open-source Android VPN app** ([ProtonVPN/android-app](https://github.com/ProtonVPN/android-app), GPL-3.0). Quest has no Play Store Proton VPN listing; this project verifies Proton’s GitHub APK, sideloads it, and always launches the **Android TV / QR login** path that works as a 2D panel on Horizon OS.

Not affiliated with Proton AG or Meta Platforms. Proton VPN is a trademark of Proton AG.

## Features

- Downloads the official `production-vanilla-direct-release` APK from ProtonVPN GitHub Releases
- Verifies the published signing certificate SHA-256 before install
- Sideloads to a connected Meta Quest (USB or wireless ADB)
- Forces Proton’s TV UI (`TvMainActivity` → `TvQrLoginActivity`) — the working Quest path
- Optional Quest library launcher (`dev.voxhash.protonvpn.quest`) that opens TV UI in one click
- Optional from-source build with a Meta Quest `IsTvCheck` patch so the phone launcher also routes to TV UI
- Real-device e2e script against connected Quest 3

## Quick start

```bash
# Developer Mode enabled on Quest; adb devices shows Quest 3
./scripts/install-quest.sh
./scripts/e2e-quest.sh
```

In the headset: scan the QR code to sign in, then Connect and approve the VPN permission dialog.

## Installation

### One-shot (recommended)

```bash
./scripts/install-quest.sh
```

This downloads the latest official Proton VPN Android APK, verifies Proton AG’s signing certificate (`DC:C9:43:9E:…:B8:53`), installs `ch.protonvpn.android`, and launches the TV UI.

### Optional Quest launcher icon

```bash
./scripts/build-quest-launcher.sh
./scripts/install-quest-launcher.sh
```

### From-source (GPL fork + Quest patch)

```bash
./scripts/fetch-android-app.sh   # if android-app/ missing
./scripts/build-from-source.sh
# then adb install the generated open-source debug APK (resigns; not Proton-signed)
```

Requires JDK 17, Android SDK/NDK, and (for full OpenVPN native bits) `swig` / `cmake`.

## How it works (architecture)

Proton VPN Android core (unchanged):

1. **Auth** — Proton account / TV QR session fork
2. **VpnConnectionManager** — connects via protocol backends
3. **WireguardBackend** / **OpenVPN** / **ProTun** — Android `VpnService` tunnels
4. **ServerManager** — live Proton VPN server list

Quest adaptation:

| Horizon OS fact | Adaptation |
| --- | --- |
| No `FEATURE_LEANBACK` | Launch `TvMainActivity` explicitly; patch `IsTvCheck` for Oculus/Quest |
| 2D Android panels | TV / leanback layouts fit Quest panels better than phone redesign |
| Sideload only | Official GitHub APK + ADB install scripts |
| VpnService supported | WireGuard + ProTun services register and run on Quest 3 (API 34) |

## Configuration

| Variable / flag | Meaning |
| --- | --- |
| `QUEST_SERIAL` | Force ADB serial (otherwise auto-detects `eureka` / Quest 3) |
| `JAVA_HOME` | JDK 17 for from-source / launcher builds |
| `ANDROID_HOME` | Android SDK root (default `~/Android/Sdk`) |

## Examples

- [Install and launch on Quest 3](docs/examples/example-01.md)
- [E2E checklist with VPN permission](docs/examples/example-02.md)

## Roadmap

See [ROADMAP.md](ROADMAP.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

GPL-3.0-or-later — same as [ProtonVPN/android-app](https://github.com/ProtonVPN/android-app). See [LICENSE](LICENSE).

# Proton VPN for Meta Quest

[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Meta%20Quest%203-lightgrey.svg)](#installation)
[![Upstream](https://img.shields.io/badge/upstream-ProtonVPN%2Fandroid--app-6d4aff.svg)](https://github.com/ProtonVPN/android-app)
[![CI](https://img.shields.io/github/actions/workflow/status/VoxHash/protonvpn-meta-quest/ci.yml?branch=main&label=CI)](https://github.com/VoxHash/protonvpn-meta-quest/actions)

Unofficial Meta Quest packaging for **Proton’s official open-source Android VPN app** ([ProtonVPN/android-app](https://github.com/ProtonVPN/android-app), GPL-3.0). Quest has no Play Store Proton VPN listing; this project applies a small Meta Quest patch so the app opens the **phone email/password (and SSO) sign-in** flow — the same approach [Proton Pass](https://github.com/protonpass/android-pass) uses on Horizon OS (`proton.android.pass.quest`).

Not affiliated with Proton AG or Meta Platforms. Proton VPN is a trademark of Proton AG.

## Features

- Builds Proton VPN from source (GPL) with a Meta Quest patch
- Forces **phone MainActivity + email login** on Quest (never QR/TV as the primary path)
- Declares `com.oculus.supportedDevices` and enables a real `MainActivity` entry (Horizon OS rejects Proton’s disabled activity-alias launcher)
- Optional Quest library companion (`dev.voxhash.protonvpn.quest`)
- Real-device e2e script against connected Quest 3
- Reboot auto-start to the logged-in account’s preferred/quick-connect profile
- Real kill switch via Android Always-on VPN **lockdown** (blocks all non-VPN traffic when the tunnel is down)
- Optional download/verify of Proton’s official GitHub APK (TV/QR only — not the Quest email path)

## Quick start

```bash
# Developer Mode enabled on Quest; adb devices shows Quest 3
# Requires JDK 17 + Android SDK (see Configuration)
./scripts/install-quest.sh
./scripts/e2e-quest.sh
```

In the headset: sign in with Proton **email and password**. If you get “incorrect password” despite a known-good account, Horizon’s keyboard likely mangled symbols — focus the password field and run `PROTON_PASSWORD='…' ./scripts/quest-enter-password.sh` from this PC, then Connect and approve VPN permission.

Arm reboot auto-connect + kill switch:

```bash
./scripts/configure-quest-hardening.sh
./scripts/e2e-kill-switch.sh && ./scripts/e2e-boot-autoconnect.sh
```

## Installation

### One-shot (recommended — patched open-source build)

```bash
./scripts/install-quest.sh
```

This applies `patches/0001-meta-quest-phone-email-auth.patch`, builds `productionVanillaOpenSourceDebug`, installs `ch.protonvpn.android` on the Quest, and launches phone `MainActivity` → email auth (`AddAccountActivity` / `LoginTwoStepActivity`).

### Optional Quest launcher icon

```bash
./scripts/build-quest-launcher.sh
./scripts/install-quest-launcher.sh
```

### Official Proton APK (not for standalone Quest email login)

```bash
./scripts/download-official-apk.sh
./scripts/verify-apk.sh downloads/*.apk
```

The official release keeps `MainActivity` disabled behind an activity-alias. Horizon OS `ShellSpatialWindowManagerService` rejects that launch path. Its TV UI (`TvQrLoginActivity`) only works when the headset is mirrored to a display a phone can scan.

## How it works (architecture)

Proton VPN Android core (unchanged logic):

1. **Auth** — Proton account email/password + SSO via `me.proton.core.auth` (same stack as Pass)
2. **VpnConnectionManager** — connects via protocol backends
3. **WireguardBackend** / **OpenVPN** / **ProTun** — Android `VpnService` tunnels
4. **ServerManager** — live Proton VPN server list

Quest adaptation (modeled on Proton Pass `quest` flavor):

| Horizon OS fact | Adaptation |
| --- | --- |
| QR unusable without TV mirror | `IsTvCheck` returns **false** on Quest → phone UI |
| Activity-alias + disabled `MainActivity` rejected | Enable/export real `MainActivity` launcher |
| Pass ships `com.oculus.supportedDevices` | Same metadata: `quest2\|questpro\|quest3\|quest3s` |
| Auth panels need landscape keyboard | Landscape + `adjustResize` on core auth activities |
| VpnService supported | WireGuard + ProTun register and run on Quest 3 |
| Reboot must reconnect | `AutoConnectBootReceiver` + Always-on VPN → preferred/quick-connect |
| Kill switch required | Always-on VPN **lockdown** (system UID filters; no traffic without tunnel) |

## Configuration

| Variable / flag | Meaning |
| --- | --- |
| `QUEST_SERIAL` | Force ADB serial (otherwise auto-detects `eureka` / Quest 3) |
| `JAVA_HOME` | JDK 17 for from-source / launcher builds (default `~/.local/jvm/jdk-17.0.20.1+1`) |
| `ANDROID_HOME` | Android SDK root (default `~/Android/Sdk`) |

## Examples

- [Install and launch email login on Quest 3](docs/examples/example-01.md)
- [E2E checklist with VPN permission](docs/examples/example-02.md)

## Roadmap

See [ROADMAP.md](ROADMAP.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

GPL-3.0-or-later — same as [ProtonVPN/android-app](https://github.com/ProtonVPN/android-app). See [LICENSE](LICENSE).

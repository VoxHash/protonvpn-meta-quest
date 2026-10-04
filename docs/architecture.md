# Architecture

Modeled on Proton Pass for Meta Quest (`proton.android.pass.quest`): phone `MainActivity` + core email/SSO auth activities — not Android TV / QR.

```
Quest library / adb
        │
        ▼
┌───────────────────────┐     Intent (LAUNCHER)      ┌──────────────────────────┐
│ Quest companion       │ ─────────────────────────► │ Proton VPN (patched)      │
│ (optional)            │                            │ MainActivity (phone)      │
└───────────────────────┘                            │  └─ AddAccount / Login* │
                                                     │ VpnConnectionManager      │
                                                     │  ├─ WireguardBackend      │
                                                     │  ├─ OpenVpnBackend        │
                                                     │  └─ ProTunVpnService      │
                                                     │ Android VpnService TUN    │
                                                     └──────────────────────────┘
```

Quest patches:

1. `patches/0001-meta-quest-phone-email-auth.patch` — `IsTvCheck` returns **false** on Quest; enable/export `MainActivity`; `com.oculus.supportedDevices`; landscape auth; boot/Always-on reconnect helpers.
2. `patches/0002-meta-quest-product-flavor.patch` — distribution flavor `quest` with `applicationIdSuffix '.quest'` (Pass-style `ch.protonvpn.android.quest`); Gradle target `productionVanillaQuestDebug`.

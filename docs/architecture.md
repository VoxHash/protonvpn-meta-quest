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

Quest patch (`patches/0001-meta-quest-phone-email-auth.patch`):

1. `IsTvCheck` — Meta Quest devices always return **false** (clear sticky TV prefs); never force `TvMainActivity` / `TvQrLoginActivity`.
2. Manifest — enable/export `MainActivity`, add `com.oculus.supportedDevices`, landscape auth activities (Pass-style).

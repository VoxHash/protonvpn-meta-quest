# Architecture

```
Quest library / adb
        │
        ▼
┌───────────────────────┐     Intent (LEANBACK)      ┌──────────────────────────┐
│ Quest companion       │ ─────────────────────────► │ Proton VPN Android        │
│ (optional)            │                            │ TvMainActivity            │
└───────────────────────┘                            │  └─ TvQrLoginActivity     │
                                                     │ VpnConnectionManager      │
                                                     │  ├─ WireguardBackend      │
                                                     │  ├─ OpenVpnBackend        │
                                                     │  └─ ProTunVpnService      │
                                                     │ Android VpnService TUN    │
                                                     └──────────────────────────┘
```

Quest patch: `IsTvCheck.isMetaQuestDevice()` treats Oculus / Quest / `standalone_vr` as TV so phone `MainActivity` forwards to TV UI when building from source.

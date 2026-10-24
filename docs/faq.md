# FAQ

**Why email login instead of QR?**  
Standalone Quest cannot scan the TV QR with a phone. Proton Pass on Quest uses email/password (+ SSO) with the virtual keyboard; this project mirrors that. QR only works if the headset is mirrored to a TV.

**Why a from-source build?**  
Official Proton APK disables `MainActivity` and exposes a `RoutingActivity` alias. Horizon OS rejects that alias target. The Quest patch enables a real `MainActivity` and forces `IsTvCheck` false on Oculus/Quest. The packaging flavor installs as `ch.protonvpn.android.quest` (not the Play Store id).

**Same Proton account?**  
Yes — email/password or SSO for your Proton VPN account.

**Does SSO work on Quest?**  
Partially. Email/password is the reliable path. Org SSO uses the same `LoginSsoActivity` as phone Android, but Custom Tabs / WebView IdP handoff and the `protonvpn://…/sso/login` deep-link return often fail or need Quest Link + keyboard assist. Details: [sso-horizon.md](sso-horizon.md).

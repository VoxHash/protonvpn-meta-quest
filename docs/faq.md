# FAQ

**Why email login instead of QR?**  
Standalone Quest cannot scan the TV QR with a phone. Proton Pass on Quest uses email/password (+ SSO) with the virtual keyboard; this project mirrors that. QR only works if the headset is mirrored to a TV.

**Why a from-source build?**  
Official Proton APK disables `MainActivity` and exposes a `RoutingActivity` alias. Horizon OS rejects that alias target. The Quest patch enables a real `MainActivity` and forces `IsTvCheck` false on Oculus/Quest.

**Same Proton account?**  
Yes — email/password or SSO for your Proton VPN account.

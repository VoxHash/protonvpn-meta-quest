# Usage

1. Launch Proton VPN from the Quest library (or the optional `Proton VPN (Quest)` companion).
2. Sign in with Proton **email/password** (or SSO). Expected activities: `MainActivity` → `AddAccountActivity` / `LoginTwoStepActivity` — **not** `TvQrLoginActivity`.
   - Use the eye icon to confirm the password. Horizon’s keyboard often mangles symbols; Proton then returns “Incorrect login credentials” (API `8002` / `WrongPassword`) even when the same password works elsewhere.
   - Prefer PC entry: focus the password field in the headset, then `PROTON_PASSWORD='…' ./scripts/quest-enter-password.sh`.
3. After login, tap Connect and accept the Android VPN permission dialog.
4. In Proton VPN, set your **preferred / Quick connect** profile (Default connection). Boot auto-connect uses that same intent.
5. Arm reboot auto-start + kill switch (once per install / after factory reset):

```bash
./scripts/configure-quest-hardening.sh
./scripts/e2e-kill-switch.sh
./scripts/e2e-boot-autoconnect.sh
```

6. Traffic for apps that use the system VPN route goes through Proton VPN. With lockdown armed, non-VPN apps get **no** internet while the tunnel is down.

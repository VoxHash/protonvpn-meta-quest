# Usage

1. Launch Proton VPN (or the Quest companion).
2. Sign in via QR (`TvQrLoginActivity`) using a phone browser / Proton account.
3. When Connect is pressed, Horizon OS shows the Android VPN permission dialog — allow it.
4. Traffic from the headset routes through Proton’s WireGuard / ProTun / OpenVPN backend.

Do not run a second always-on VPN concurrently; Quest may deny a new `VpnService`.

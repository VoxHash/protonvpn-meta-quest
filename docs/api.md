# API / entry points

Phone entry activity (Quest primary): `com.protonvpn.android.redesign.app.ui.MainActivity`

Email auth (Proton Core, same as Pass):

- `me.proton.core.auth.presentation.ui.AddAccountActivity`
- `me.proton.core.auth.presentation.ui.LoginTwoStepActivity`
- `me.proton.core.auth.presentation.ui.LoginActivity`
- `me.proton.core.auth.presentation.ui.LoginSsoActivity`

TV/QR (not the Quest primary path): `com.protonvpn.android.tv.main.TvMainActivity` → `TvQrLoginActivity`

Quest VPN package: `ch.protonvpn.android.quest` (`applicationIdSuffix` `.quest`)

Companion package: `dev.voxhash.protonvpn.quest`

# API / entry points

Phone entry activity (Quest primary): `com.protonvpn.android.redesign.app.ui.MainActivity`

Email auth (Proton Core, same as Pass):

- `me.proton.core.auth.presentation.ui.AddAccountActivity`
- `me.proton.core.auth.presentation.ui.LoginTwoStepActivity`
- `me.proton.core.auth.presentation.ui.LoginActivity`
- `me.proton.core.auth.presentation.ui.LoginSsoActivity`

TV/QR (not the Quest primary path): `com.protonvpn.android.tv.main.TvMainActivity` → `TvQrLoginActivity`

Companion package: `dev.voxhash.protonvpn.quest`

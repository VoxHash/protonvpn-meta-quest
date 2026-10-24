# SSO on Meta Quest (Horizon OS)

Email/password sign-in on Quest is the **supported primary path**. Organization **SSO** (SAML via Proton VPN for Business) uses the same Proton Core `LoginSsoActivity` as phone Android, but Horizon often breaks the **browser handoff** and **deep-link return**. Prefer email/password when the account has one; treat in-headset SSO as best-effort and plan on **PC assist** when it stalls.

Proton’s product guide: [How to use SSO with Proton VPN for Business](https://proton.me/support/sso) (VPN Professional / Enterprise + IdP such as Okta or Google).

## What works on Quest today

| Path | On Quest 3 |
| --- | --- |
| Email + password (`LoginTwoStepActivity` / `LoginActivity`) | Works — use the virtual keyboard or `./scripts/quest-enter-password.sh` |
| Sign in with SSO (`LoginSsoActivity`) | UI opens; IdP handoff / callback often needs PC assist |
| TV QR / session-fork (`TvQrLoginActivity`, `protonvpn://session-fork`, `https://account.proton.me/vpn/tv/code/…`) | Not the Quest primary path — do not use these for SSO |

Package under test: `ch.protonvpn.android.quest` (legacy fallback `ch.protonvpn.android`). The auth deep-link **scheme** is still `protonvpn` (`core_app_scheme`); the `.quest` suffix does not change it.

## How Proton SSO handoff works (phone Android)

Upstream Proton Core (`LoginSsoActivity`):

1. User enters org email → app starts an SSO session against Proton’s API (`…/auth/sso/{token}`).
2. The app opens the IdP either in **Chrome Custom Tabs** (when `IsSsoCustomTabEnabled` and a Custom Tabs provider exist) or in **`ProtonWebViewActivity`**.
3. Redirect base is `FinalRedirectBaseUrl=<scheme>://<api-host>` with `scheme` = `protonvpn`.
4. After the IdP succeeds, the browser/WebView navigates to a custom URI such as:

   `protonvpn://<api-host>/sso/login` (plus login token / error fragment handled by Core).

5. `LoginSsoActivity` / `LoginTwoStepActivity` declare a `BROWSABLE` filter for `protonvpn` + path `/sso/login` (`launchMode=singleInstance`) and finish account setup when that intent arrives (`onNewIntent` for Custom Tabs).

## Horizon edge cases

### 1. Custom Tabs missing or unused

Quest may have **no** usable `CustomTabsService` (no Chrome / incomplete browser). Core then falls back to the in-app WebView. That is expected — SSO can still succeed if the WebView completes the IdP and hits the success URL regex (`login#token`). If the WebView cannot load the IdP (TLS pinning, “unsupported browser”, corporate Conditional Access), SSO stops here.

### 2. Deep-link return never reaches the app

After IdP success you may stay in Horizon Browser / a WebView panel while Proton VPN never resumes. Common causes:

- `protonvpn://…/sso/login` is not delivered to `ch.protonvpn.android.quest` (panel focus, browser swallows the custom scheme, or user closed the auth activity).
- Confusing TV **session-fork** links with SSO — those are a different flow (`SessionForkConfirmationActivity`).

Check from a PC with the headset connected:

```bash
# Who owns the SSO callback?
adb shell cmd package resolve-activity -a android.intent.action.VIEW \
  -d 'protonvpn://vpn-api.proton.me/sso/login'

# Optional: watch for the callback while retrying SSO in the headset
adb logcat -d | grep -E 'LoginSso|sso/login|protonvpn://|CustomTab|ProtonWebView' | tail -n 50
```

If resolve-activity does not point at Proton VPN Quest, reinstall with `./scripts/install-quest.sh` and retry. Manually opening the library icon after a browser success **without** the token intent will not finish SSO.

### 3. IdP UX (2FA, device trust, approved browsers)

Many IdPs assume a phone or desktop: authenticator apps, push approve, hardware keys, or “managed browser only”. Horizon’s keyboard and browser panels make these painful or impossible. **PC assist** means:

1. Keep the Quest worn (or awake) so the Proton panel stays alive.
2. Use **Quest Link / casting** plus a real keyboard to complete the IdP screens shown in the headset WebView/Custom Tab, **or**
3. If the org IdP blocks Quest entirely, use email/password on Quest when policy allows a Proton password, or complete VPN login on a supported Android/desktop client for that account — this packaging cannot bypass IdP Conditional Access.

### 4. Wrong activity after “Sign in with SSO”

Expected: `me.proton.core.auth.presentation.ui.LoginSsoActivity` (email field + SSO continue). If you land on `TvQrLoginActivity`, the build is not the Quest email path — reinstall the patched Quest flavor.

```bash
./scripts/e2e-quest.sh   # asserts MainActivity / AddAccount / Login* / LoginSso — not TV QR
```

## Recommended order for contributors / users

1. **Email/password** on Quest (documented in [usage.md](usage.md)) whenever the account has a Proton password.
2. Try **SSO in-headset** once; if the IdP page or callback fails, stop and use PC assist (Link/cast + keyboard) rather than retrying blindly.
3. Capture `resolve-activity` + logcat snippets above when filing a bug (see issue templates).
4. Do not file SSO deep-link bugs against the TV QR / `session-fork` URLs — wrong code path.

## Out of scope

This project does not ship a custom SSO browser, rewrite Proton Core auth, or guarantee every corporate IdP on Horizon. Patches only ensure Quest opens phone email/SSO activities (`LoginSsoActivity` landscape + keyboard) instead of TV QR.

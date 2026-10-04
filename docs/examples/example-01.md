# Example 01 — Install and launch on Quest 3

```bash
export JAVA_HOME="${JAVA_HOME:-$HOME/.local/jvm/jdk-17.0.20.1+1}"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
./scripts/install-quest.sh
./scripts/launch-quest.sh
```

Expected: package `ch.protonvpn.android` installed; phone `MainActivity` / `AddAccountActivity` or `LoginTwoStepActivity` visible in a Quest panel (email login — not QR).

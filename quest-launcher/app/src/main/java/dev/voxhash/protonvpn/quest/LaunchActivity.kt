package dev.voxhash.protonvpn.quest

import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

/**
 * Thin Quest entrypoint that opens Proton VPN's phone MainActivity so users
 * can sign in with email/password (and SSO) via the Quest virtual keyboard —
 * the same auth approach Proton Pass uses on Meta Quest.
 *
 * Prefer the Quest product flavor package (`ch.protonvpn.android.quest`), then
 * fall back to the legacy sideload id. Do not route to TvMainActivity /
 * TvQrLoginActivity: QR login is not usable in the headset without TV mirroring.
 */
class LaunchActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val packages = listOf(PROTON_PACKAGE_QUEST, PROTON_PACKAGE_LEGACY)
        var launched = false
        for (pkg in packages) {
            if (tryLaunch(pkg, MAIN_ACTIVITY) || tryLaunch(pkg, ROUTING_ACTIVITY)) {
                launched = true
                break
            }
        }
        if (!launched) {
            Toast.makeText(this, R.string.missing_proton, Toast.LENGTH_LONG).show()
        }
        finish()
    }

    private fun tryLaunch(pkg: String, activity: String): Boolean {
        val intent = Intent().apply {
            component = ComponentName(pkg, activity)
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        return try {
            startActivity(intent)
            true
        } catch (_: ActivityNotFoundException) {
            false
        }
    }

    companion object {
        const val PROTON_PACKAGE_QUEST = "ch.protonvpn.android.quest"
        const val PROTON_PACKAGE_LEGACY = "ch.protonvpn.android"
        const val MAIN_ACTIVITY = "com.protonvpn.android.redesign.app.ui.MainActivity"
        const val ROUTING_ACTIVITY = "ch.protonvpn.android.RoutingActivity"
    }
}

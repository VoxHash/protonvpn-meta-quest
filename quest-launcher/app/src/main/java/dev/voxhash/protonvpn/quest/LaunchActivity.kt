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
 * Do not route to TvMainActivity / TvQrLoginActivity: QR login is not usable
 * in the headset without TV mirroring.
 */
class LaunchActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val intent = Intent().apply {
            component = ComponentName(
                PROTON_PACKAGE,
                MAIN_ACTIVITY,
            )
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        try {
            startActivity(intent)
        } catch (_: ActivityNotFoundException) {
            // Fallback for builds that still expose only the RoutingActivity alias.
            try {
                startActivity(
                    Intent().apply {
                        component = ComponentName(PROTON_PACKAGE, ROUTING_ACTIVITY)
                        action = Intent.ACTION_MAIN
                        addCategory(Intent.CATEGORY_LAUNCHER)
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    },
                )
            } catch (_: ActivityNotFoundException) {
                Toast.makeText(this, R.string.missing_proton, Toast.LENGTH_LONG).show()
            }
        }
        finish()
    }

    companion object {
        const val PROTON_PACKAGE = "ch.protonvpn.android"
        const val MAIN_ACTIVITY = "com.protonvpn.android.redesign.app.ui.MainActivity"
        const val ROUTING_ACTIVITY = "ch.protonvpn.android.RoutingActivity"
    }
}

package dev.voxhash.protonvpn.quest

import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

/**
 * Thin Quest entrypoint that always opens Proton VPN's TV UI
 * (TvMainActivity → QR login / connect), which is the supported path on
 * Horizon OS. Core VPN stack remains the official GPL ProtonVPN Android app.
 */
class LaunchActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val intent = Intent().apply {
            component = ComponentName(
                PROTON_PACKAGE,
                TV_MAIN_ACTIVITY,
            )
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            addCategory(Intent.CATEGORY_LEANBACK_LAUNCHER)
        }
        try {
            startActivity(intent)
        } catch (_: ActivityNotFoundException) {
            Toast.makeText(this, R.string.missing_proton, Toast.LENGTH_LONG).show()
        }
        finish()
    }

    companion object {
        const val PROTON_PACKAGE = "ch.protonvpn.android"
        const val TV_MAIN_ACTIVITY = "com.protonvpn.android.tv.main.TvMainActivity"
    }
}

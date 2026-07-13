package com.ludotcc.boussole

import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.view.View
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        applySystemBars()
    }

    private fun applySystemBars() {
        val navigationBarColor = Color.rgb(31, 41, 55)

        window.statusBarColor = Color.BLACK
        window.navigationBarColor = navigationBarColor

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            window.navigationBarDividerColor = navigationBarColor
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val systemUiFlags = window.decorView.systemUiVisibility
            window.decorView.systemUiVisibility =
                systemUiFlags and View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR.inv()
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            window.isNavigationBarContrastEnforced = false
        }
    }
}

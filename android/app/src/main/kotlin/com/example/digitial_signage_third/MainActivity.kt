package com.example.motionreach

import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.math.roundToInt
import kotlin.system.exitProcess

class MainActivity : FlutterActivity() {
    private val channelName = "com.motionreach/device_controls"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setBrightness" -> {
                        val value = (call.arguments as? Number)?.toDouble() ?: 0.0
                        setWindowBrightness(value)
                        result.success(null)
                    }
                    "getBrightness" -> {
                        result.success(getWindowBrightness())
                    }
                    "setVolume" -> {
                        val value = (call.arguments as? Number)?.toDouble() ?: 0.0
                        setStreamVolume(value)
                        result.success(null)
                    }
                    "getVolume" -> {
                        result.success(getStreamVolume())
                    }
                    "restartApp" -> {
                        // Reply first, then schedule the restart so the
                        // MethodChannel response is actually delivered.
                        result.success(null)
                        Handler(Looper.getMainLooper()).postDelayed({
                            restartApp()
                        }, 150)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Closes the current task stack and launches the app again. This is a
     * user-level "restart" (not an OS reboot) — sufficient for a consumer
     * APK without device-admin privileges.
     */
    private fun restartApp() {
        val pm = baseContext.packageManager
        val launchIntent = pm.getLaunchIntentForPackage(baseContext.packageName)
        if (launchIntent != null) {
            launchIntent.addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            )
            startActivity(launchIntent)
        }
        finishAffinity()
        exitProcess(0)
    }

    private fun setWindowBrightness(value: Double) {
        // Enforce a small minimum so the screen dims to near-black without
        // triggering Android's "reset to system default" behavior which
        // happens when screenBrightness is set to 0 or negative values.
        val clamped = value.coerceIn(0.01, 1.0).toFloat()
        val params = window.attributes
        params.screenBrightness = clamped
        window.attributes = params
    }

    private fun getWindowBrightness(): Double {
        val params = window.attributes
        val current = params.screenBrightness
        if (current >= 0f) return current.toDouble()
        return try {
            val sys = Settings.System.getInt(contentResolver, Settings.System.SCREEN_BRIGHTNESS)
            sys / 255.0
        } catch (_: Exception) {
            1.0
        }
    }

    private fun setStreamVolume(value: Double) {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val max = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        val clamped = value.coerceIn(0.0, 1.0)
        val target = (clamped * max).roundToInt().coerceIn(0, max)
        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, target, 0)
    }

    private fun getStreamVolume(): Double {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val max = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        if (max == 0) return 0.0
        val current = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
        return current.toDouble() / max.toDouble()
    }
}

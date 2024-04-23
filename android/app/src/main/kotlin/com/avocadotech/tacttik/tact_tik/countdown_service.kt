package com.avocadotech.tacttik.tact_tik
import com.avocadotech.tacttik.tact_tik.CountdownService
import android.os.Bundle
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class CountdownService : Service() {
    private val NOTIFICATION_ID = 12345
    private val COUNTDOWN_INTERVAL = 1000L // 1 second
    private val COUNTDOWN_DURATION = 300L // 5 minutes
    private var remainingTime = COUNTDOWN_DURATION
    private var isCountdownRunning = false
    private lateinit var countdownHandler: Handler
    private lateinit var countdownRunnable: Runnable

    companion object {
        private var flutterEngine: FlutterEngine? = null
        private const val CHANNEL = "com.avocadotech.tacttik.tact_tik/countdown_service"

        fun setFlutterEngine(engine: FlutterEngine) {
            flutterEngine = engine
        }
    }

    override fun onCreate() {
        super.onCreate()

        if (flutterEngine != null) {
            Log.d("CountdownService", "FlutterEngine is not null")
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
               
                if (call.method == "startCountdown") {
                    startCountdown()
                    result.success(null)
                } else if (call.method == "stopCountdown") {
                    stopCountdown()
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
        } else {
            Log.e("CountdownService", "FlutterEngine is null")
        }

        startForeground(NOTIFICATION_ID, createNotification())
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startCountdown()
        return START_STICKY
    }

    private fun startCountdown() {
        if (!isCountdownRunning) {
            isCountdownRunning = true
            countdownHandler = Handler(Looper.getMainLooper())
            countdownRunnable = Runnable {
                if (remainingTime > 0) {
                    remainingTime--
                    sendCountdownUpdate(remainingTime)
                    countdownHandler.postDelayed(countdownRunnable, COUNTDOWN_INTERVAL)
                } else {
                    stopSelf()
                }
            }
            countdownHandler.postDelayed(countdownRunnable, COUNTDOWN_INTERVAL)
        }
    }

    private fun sendCountdownUpdate(remainingTime: Long) {
        val intent = Intent("countdown_update")
        intent.putExtra("remainingTime", remainingTime)
        sendBroadcast(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        isCountdownRunning = false
        countdownHandler.removeCallbacks(countdownRunnable)
    }

    private fun createNotification(): Notification {
        val channelId =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                createNotificationChannel()
            } else {
                ""
            }

        val notificationBuilder = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Countdown")
            .setContentText("Countdown in progress")
            .setSmallIcon(R.drawable.icon)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)

        return notificationBuilder.build()
    }

    private fun createNotificationChannel(): String {
        val channelId = "countdown_channel"
        val channelName = "Countdown"
        val importance = NotificationManager.IMPORTANCE_DEFAULT
        val channel = NotificationChannel(channelId, channelName, importance)
        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.createNotificationChannel(channel)
        return channelId
    }

    private fun stopCountdown() {
    if (isCountdownRunning) {
        isCountdownRunning = false
        countdownHandler.removeCallbacks(countdownRunnable)
        remainingTime = COUNTDOWN_DURATION // Reset remaining time
    }
}
}

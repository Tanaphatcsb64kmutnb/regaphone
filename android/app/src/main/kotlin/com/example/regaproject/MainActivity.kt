package com.example.regaproject

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.Activity
import android.os.Bundle
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.graphics.BitmapFactory
import androidx.core.app.NotificationCompat
import java.net.HttpURLConnection
import java.net.URL
import android.graphics.Bitmap
import com.google.firebase.auth.FirebaseAuth  // เพิ่มบรรทัดนี้

class MainActivity : FlutterActivity() {
    // Existing channels
    private val CAMERA_CHANNEL = "live_camera_view"
    private val NOTIFICATION_CHANNEL = "com.example.regaproject/notification"
    private val VIDEO_REQUEST_CODE = 1001
    private lateinit var cameraMethodChannel: MethodChannel
    private lateinit var notificationMethodChannel: MethodChannel

    override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    
    if (intent?.getBooleanExtra("show_notification_details", false) == true) {
        val notificationTitle = intent.getStringExtra("notification_title") ?: ""
        val notificationBody = intent.getStringExtra("notification_body") ?: ""
        
        notificationMethodChannel.invokeMethod("showNotificationDetails", mapOf(
            "title" to notificationTitle,
            "body" to notificationBody,
            "timestamp" to System.currentTimeMillis()
        ))
    }
}

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup camera channel
        cameraMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CAMERA_CHANNEL)
        
        // Setup notification channel
        notificationMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFICATION_CHANNEL)

        // Register camera view factory
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "live_camera_view",
                LiveCameraViewFactory(cameraMethodChannel)
            )

        // Setup camera method handler
        cameraMethodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "switchCamera" -> {
                    val isFrontCamera = call.argument<Boolean>("camera") ?: true
                    result.success(null)
                }
                "playRestVideo" -> {
                    playRestVideo()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // Setup notification method handler
        notificationMethodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "showNotificationWithImage" -> {
                    val title = call.argument<String>("title") ?: ""
                    val body = call.argument<String>("body") ?: ""
                    val imageUrl = call.argument<String>("imageUrl")
                    val payload = call.argument<String>("payload")
                    
                    showNotificationWithImage(title, body, imageUrl, payload)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun playRestVideo() {
        val intent = Intent(this, VideoActivity::class.java)
        startActivityForResult(intent, VIDEO_REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == VIDEO_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            cameraMethodChannel.invokeMethod("videoCompleted", null)
        }
    }

    override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    handleIntent(intent)
}

private fun handleIntent(intent: Intent) {
    if (intent.getBooleanExtra("show_notification", false)) {
        val notificationData = intent.getBundleExtra("notification_data")
        if (notificationData != null) {
            notificationMethodChannel.invokeMethod(
                "showNotificationDetails",
                mapOf(
                    "title" to notificationData.getString("title"),
                    "body" to notificationData.getString("body"),
                    "timestamp" to notificationData.getLong("timestamp")
                )
            )
        }
    }
}


private fun showNotificationWithImage(title: String, body: String, imageUrl: String?, payload: String?) {
    Thread {
        try {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            var bitmap: Bitmap? = null

            // Download image if URL is provided
            if (!imageUrl.isNullOrEmpty()) {
                try {
                    val connection = URL(imageUrl).openConnection() as HttpURLConnection
                    connection.doInput = true
                    connection.connect()
                    bitmap = BitmapFactory.decodeStream(connection.inputStream)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }

            val intent = Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtra("show_notification_details", true)
                putExtra("notification_title", title)
                putExtra("notification_body", body)
                if (payload != null) {
                    putExtra("payload", payload)
                }
            }

            val pendingIntent = PendingIntent.getActivity(
                this, 
                System.currentTimeMillis().toInt(), 
                intent,
                PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
            )

            val channelId = "high_importance_channel"
            val builder = NotificationCompat.Builder(this, channelId)
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setContentTitle(title)
                .setContentText(body)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)
                .setContentIntent(pendingIntent)

            if (bitmap != null) {
                builder.setStyle(NotificationCompat.BigPictureStyle()
                    .bigPicture(bitmap))
            }

            notificationManager.notify(System.currentTimeMillis().toInt(), builder.build())

        } catch (e: Exception) {
            e.printStackTrace()
        }
    }.start()
}

}
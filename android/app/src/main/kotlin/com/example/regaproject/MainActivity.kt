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
        
        // ตรวจสอบข้อมูลการแจ้งเตือนเมื่อเปิดแอป
        handleNotificationIntent(intent)
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
        setIntent(intent)
        handleNotificationIntent(intent)
    }

   private fun handleNotificationIntent(intent: Intent) {
    intent.extras?.let { bundle ->
        try {
            // สร้าง Map เพื่อเก็บข้อมูลที่จะส่งไป Flutter
            val notificationData = HashMap<String, Any>()
            
            // เพิ่มข้อมูลจาก bundle
            bundle.keySet()?.forEach { key ->
                bundle.get(key)?.let { value ->
                    notificationData[key] = value
                }
            }

            // ดึงข้อมูล title และ body จาก bundle
            val title = bundle.getString("gcm.notification.title") ?: ""
            val body = bundle.getString("gcm.notification.body") ?: ""
            
            // เพิ่มข้อมูลเพิ่มเติม
            notificationData["title"] = title
            notificationData["body"] = body
            notificationData["timestamp"] = System.currentTimeMillis()
            notificationData["requiresAuth"] = true  // เพิ่ม flag นี้

            // ส่งข้อมูลไปยัง Flutter โดยไม่ต้องเช็ค login
            notificationMethodChannel.invokeMethod(
                "notificationClicked",
                notificationData
            )
        } catch (e: Exception) {
            println("Error sending notification data to Flutter: ${e.message}")
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

                // Create notification intent
                val intent = Intent(this, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
                    if (payload != null) {
                        putExtra("payload", payload)
                    }
                }

                val pendingIntent = PendingIntent.getActivity(
                    this, 
                    0, 
                    intent,
                    PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
                )

                // Build notification
                val channelId = "high_importance_channel"
                val builder = NotificationCompat.Builder(this, channelId)
                    .setSmallIcon(android.R.drawable.ic_dialog_info)
                    .setContentTitle(title)
                    .setContentText(body)
                    .setPriority(NotificationCompat.PRIORITY_HIGH)
                    .setAutoCancel(true)
                    .setContentIntent(pendingIntent)

                // Add image if downloaded successfully
                if (bitmap != null) {
                    val bigPictureStyle = NotificationCompat.BigPictureStyle()
                        .bigPicture(bitmap)
                        .setBigContentTitle(title)
                        .setSummaryText(body)
                    
                    builder.setStyle(bigPictureStyle)
                        .setLargeIcon(bitmap)
                } else {
                    builder.setStyle(NotificationCompat.BigTextStyle()
                        .bigText(body))
                }

                // Show notification
                notificationManager.notify(System.currentTimeMillis().toInt(), builder.build())

            } catch (e: Exception) {
                e.printStackTrace()
            }
        }.start()
    }
}
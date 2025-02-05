package com.example.regaproject

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import android.content.Context
import android.app.NotificationManager
import android.app.NotificationChannel
import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.media.RingtoneManager
import androidx.core.app.NotificationCompat
import android.util.Log
import com.google.firebase.auth.FirebaseAuth


class MyFirebaseMessagingService : FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        
        // ตรวจสอบสถานะการ login ก่อนแสดงการแจ้งเตือน
        val currentUser = FirebaseAuth.getInstance().currentUser
        if (currentUser == null) {
            Log.d("FCM", "User not logged in, skipping notification")
            return
        }
        
        Log.d("FCM", "From: ${remoteMessage.from}")

        remoteMessage.notification?.let {
            Log.d("FCM", "Message Notification Body: ${it.body}")
            sendNotification(it.title ?: "", it.body ?: "", remoteMessage.data)
        }
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d("FCM", "Refreshed token: $token")
    }

    private fun sendNotification(title: String, messageBody: String, data: Map<String, String>) {
        // ตรวจสอบอีกครั้งก่อนส่งการแจ้งเตือน
        val currentUser = FirebaseAuth.getInstance().currentUser
        if (currentUser == null) {
            return
        }

        val intent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            data?.forEach { (key, value) ->
                putExtra(key, value)
            }
        }

        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
        )

        val channelId = "high_importance_channel"
        val defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)

        val notificationBuilder = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(messageBody)
            .setAutoCancel(true)
            .setSound(defaultSoundUri)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "High Importance Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "This channel is used for important notifications."
                enableLights(true)
                enableVibration(true)
            }
            notificationManager.createNotificationChannel(channel)
        }

        notificationManager.notify(0, notificationBuilder.build())
    }
}
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
import android.os.Bundle

class MyFirebaseMessagingService : FirebaseMessagingService() {

   override fun onMessageReceived(remoteMessage: RemoteMessage) {
       super.onMessageReceived(remoteMessage)
       
       Log.d("FCM", "From: ${remoteMessage.from}")

       remoteMessage.notification?.let {
           Log.d("FCM", "Message Notification Body: ${it.body}")
           
           // สร้าง Bundle สำหรับเก็บข้อมูลการแจ้งเตือน
           val notificationData = Bundle().apply {
               putString("title", it.title)
               putString("body", it.body)
               putLong("timestamp", System.currentTimeMillis())
               // เพิ่มข้อมูลเพิ่มเติมจาก data payload ถ้ามี
               remoteMessage.data.forEach { (key, value) ->
                   putString(key, value)
               }
           }

           // สร้าง Intent สำหรับเปิดแอพ
           val intent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
               flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
               putExtra("notification_data", notificationData)
               putExtra("show_notification", true)
           }

           val pendingIntent = PendingIntent.getActivity(
               this,
               System.currentTimeMillis().toInt(),
               intent,
               PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
           )

           val channelId = "high_importance_channel"
           val defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)

           val notificationBuilder = NotificationCompat.Builder(this, channelId)
               .setSmallIcon(android.R.drawable.ic_dialog_info)
               .setContentTitle(it.title)
               .setContentText(it.body)
               .setAutoCancel(true)
               .setSound(defaultSoundUri)
               .setPriority(NotificationCompat.PRIORITY_HIGH)
               .setContentIntent(pendingIntent)

           val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

           // ตั้งค่า notification channel สำหรับ Android 8.0 (API level 26) ขึ้นไป
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

           // แสดงการแจ้งเตือน
           notificationManager.notify(System.currentTimeMillis().toInt(), notificationBuilder.build())
       }
   }

   override fun onNewToken(token: String) {
       super.onNewToken(token)
       Log.d("FCM", "Refreshed token: $token")
       // ส่ง token ใหม่ไปเก็บที่เซิร์ฟเวอร์ถ้าต้องการ
   }
}
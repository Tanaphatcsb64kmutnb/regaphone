// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'dart:io';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static const platform = MethodChannel('com.example.app/notification');

//   static ValueNotifier<RemoteMessage?> currentMessage =
//       ValueNotifier<RemoteMessage?>(null);

//   // Initialize notification service
//   static Future<void> showNotification({
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     // ปิดการแสดง notification จาก Flutter เมื่อแอพอยู่ใน background
//     if (!isAppForeground()) {
//       return;
//     }

//     // แสดง notification เฉพาะเมื่อแอพอยู่ใน foreground
//     try {
//       final NotificationDetails platformChannelSpecifics = NotificationDetails(
//         android: AndroidNotificationDetails(
//           'high_importance_channel',
//           'High Importance Notifications',
//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//       );

//       await _notificationsPlugin.show(
//         DateTime.now().millisecond,
//         title,
//         body,
//         platformChannelSpecifics,
//         payload: payload,
//       );
//     } catch (e) {
//       print('Error showing notification: $e');
//     }
//   }

// // เช็คว่าแอพอยู่ใน foreground หรือไม่
//   static bool isAppForeground() {
//     return WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
//   }
// }

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

// สร้างไฟล์ใหม่ services/notification_manager.dart
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationManager {
  // รับการแจ้งเตือนทั้งหมด
  static Future<List<NotificationModel>> getAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('notifications') ?? '[]';
    final notifications = List<Map<String, dynamic>>.from(
        jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

    return notifications
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }

  // รับการแจ้งเตือนที่ยังไม่ได้อ่าน
  static Future<List<NotificationModel>> getUnreadNotifications() async {
    final notifications = await getAllNotifications();
    return notifications.where((notification) => !notification.isRead).toList();
  }

  // บันทึกการแจ้งเตือนใหม่
  static Future<void> saveNotification(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('notifications') ?? '[]';
    final notifications = List<Map<String, dynamic>>.from(
        jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

    // สร้าง unique ID
    final notificationId = DateTime.now().millisecondsSinceEpoch.toString();

    // เพิ่มการแจ้งเตือนใหม่
    notifications.insert(0, {
      'id': notificationId,
      'title': message.notification?.title,
      'body': message.notification?.body,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': message.data,
      'isRead': false,
      'category': message.data['category'] ?? 'general',
      'priority': message.data['priority'] ?? 'normal',
    });

    // ถ้ามีการแจ้งเตือนมากเกินไป ให้ลบเก่าออก
    if (notifications.length > 100) {
      notifications.removeRange(100, notifications.length);
    }

    // บันทึกกลับ
    await prefs.setString('notifications', jsonEncode(notifications));
  }

  // ทำเครื่องหมายว่าอ่านแล้ว
  static Future<void> markAsRead(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('notifications') ?? '[]';
    final notifications = List<Map<String, dynamic>>.from(
        jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

    for (var i = 0; i < notifications.length; i++) {
      if (notifications[i]['id'] == notificationId) {
        notifications[i]['isRead'] = true;
        break;
      }
    }

    await prefs.setString('notifications', jsonEncode(notifications));
  }

  // ทำเครื่องหมายว่าอ่านทั้งหมด
  static Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('notifications') ?? '[]';
    final notifications = List<Map<String, dynamic>>.from(
        jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

    for (var i = 0; i < notifications.length; i++) {
      notifications[i]['isRead'] = true;
    }

    await prefs.setString('notifications', jsonEncode(notifications));
  }

  // ลบการแจ้งเตือน
  static Future<void> deleteNotification(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('notifications') ?? '[]';
    final notifications = List<Map<String, dynamic>>.from(
        jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

    notifications
        .removeWhere((notification) => notification['id'] == notificationId);

    await prefs.setString('notifications', jsonEncode(notifications));
  }

  // ลบการแจ้งเตือนทั้งหมด
  static Future<void> deleteAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notifications', '[]');
  }
}

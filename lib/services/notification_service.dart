import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const platform = MethodChannel('com.example.app/notification');

  static ValueNotifier<RemoteMessage?> currentMessage =
      ValueNotifier<RemoteMessage?>(null);

  // Initialize notification service
  static Future<void> initialize() async {
    try {
      print('Initializing notification service...');

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          print('Notification response received: ${details.payload}');
          // Handle notification tap here if needed
        },
      );

      final status = await _requestPermissions();
      print('Notification permissions status: $status');

      print('Notification service initialized successfully');
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  // Request notification permissions
  static Future<bool> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          announcement: true,
          badge: true,
          carPlay: true,
          criticalAlert: true,
          provisional: false,
          sound: true,
        );

        print(
            'Firebase Messaging permission status: ${settings.authorizationStatus}');

        final bool granted =
            settings.authorizationStatus == AuthorizationStatus.authorized;

        if (granted) {
          await FirebaseMessaging.instance
              .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
        }

        return granted;
      }
      return false;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  // Create notification channel
  static Future<void> createNotificationChannel() async {
    try {
      print('Creating notification channel...');

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        showBadge: true,
        enableLights: true,
      );

      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(channel);
        print('Notification channel created successfully');

        // Print existing channels for debugging
        final channels = await androidPlugin.getNotificationChannels();
        print('Available notification channels: ${channels?.length}');
        channels?.forEach((channel) {
          print('Channel ID: ${channel.id}');
          print('Channel Name: ${channel.name}');
        });
      }
    } catch (e) {
      print('Error creating notification channel: $e');
    }
  }

  // ฟังก์ชันใหม่สำหรับแสดงการแจ้งเตือนพร้อมรูปภาพ
  static Future<void> showNotificationWithImage({
    required String title,
    required String body,
    String? imageUrl,
    String? payload,
  }) async {
    try {
      print('Preparing to show notification with image...');
      print('Title: $title');
      print('Body: $body');
      print('Image URL: $imageUrl');

      // ส่งข้อมูลไปให้ Native Android ผ่าน Method Channel
      if (imageUrl != null) {
        await platform.invokeMethod('showNotificationWithImage', {
          'title': title,
          'body': body,
          'imageUrl': imageUrl,
          'payload': payload,
        });
        return;
      }

      // ถ้าไม่มีรูปภาพ ใช้การแสดงผลปกติ
      final StyleInformation styleInformation = BigTextStyleInformation(
        body,
        contentTitle: title,
        htmlFormatContent: true,
        htmlFormatTitle: true,
      );

      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        styleInformation: styleInformation,
        fullScreenIntent: true,
      );

      final NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _notificationsPlugin.show(
        DateTime.now().millisecond,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      print('Notification with image shown successfully');
    } catch (e) {
      print('Error showing notification with image: $e');
      print('Stack trace: ${e.toString()}');

      // Fallback to normal notification if showing with image fails
      await showNotification(
        title: title,
        body: body,
        payload: payload,
      );
    }
  }

  // Original showNotification function remains unchanged
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      print('Preparing to show notification...');
      print('Title: $title');
      print('Body: $body');

      final StyleInformation styleInformation = BigTextStyleInformation(
        body,
        contentTitle: title,
        htmlFormatContent: true,
        htmlFormatTitle: true,
      );

      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        enableLights: true,
        color: Colors.blue,
        ledColor: Colors.blue,
        ledOnMs: 1000,
        ledOffMs: 500,
        channelShowBadge: true,
        autoCancel: true,
        styleInformation: styleInformation,
        visibility: NotificationVisibility.public,
      );

      final NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _notificationsPlugin.show(
        DateTime.now().millisecond,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      print('Notification shown successfully');
    } catch (e) {
      print('Error showing notification: $e');
      print('Stack trace: ${e.toString()}');
    }
  }

  // Show test notification
  static Future<void> showTestNotification() async {
    try {
      print('Attempting to show test notification...');

      await showNotification(
        title: 'Test Notification',
        body: 'This is a test notification. Time: ${DateTime.now()}',
      );

      print('Test notification sent successfully');
    } catch (e) {
      print('Error showing test notification: $e');
    }
  }

  // Get FCM token
  static Future<String?> getFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      print('Notification $id cancelled successfully');
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      print('All notifications cancelled successfully');
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }
}

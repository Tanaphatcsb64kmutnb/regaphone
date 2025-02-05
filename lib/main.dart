// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart'; // Import Firebase core
// import 'firebase_options.dart'; // Import generated firebase_options.dart
// import 'package:regaproject/Home/Home.dart';
// import 'Sign-In/SignIn.dart';
// import 'Sign-Up/SignUp.dart';

// void main() async {
//   WidgetsFlutterBinding
//       .ensureInitialized(); // Ensure widgets binding is initialized
//   await Firebase.initializeApp(
//     // Initialize Firebase
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(
//     const MaterialApp(
//       home: SignInPage(),
//       debugShowCheckedModeBanner: false, // ปิด Debug Banner
//     ),
//   );
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'firebase_options.dart';
// import 'package:regaproject/Home/Home.dart';
// import 'Sign-In/SignIn.dart';
// import 'Sign-Up/SignUp.dart';
// import 'services/notification_service.dart';
// import 'package:regaproject/services/in_app_message_dialog.dart';

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   print('Handling a background message: ${message.messageId}');

//   if (message.notification != null) {
//     await NotificationService.showNotification(
//       title: message.notification?.title ?? '',
//       body: message.notification?.body ?? '',
//     );
//   }
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต
//   var connectivityResult = await Connectivity().checkConnectivity();
//   if (connectivityResult == ConnectivityResult.none) {
//     print('No internet connection');
//     return;
//   }

//   // Initialize Firebase
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   // Initialize NotificationService
//   await NotificationService.initialize();

//   // ตั้งค่า background message handler
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   // ขอสิทธิ์การแจ้งเตือน
//   NotificationSettings settings =
//       await FirebaseMessaging.instance.requestPermission(
//     alert: true,
//     badge: true,
//     sound: true,
//     provisional: false,
//     announcement: true,
//     carPlay: true,
//     criticalAlert: true,
//   );

//   print('User granted permission: ${settings.authorizationStatus}');

//   // ตั้งค่าการแสดงการแจ้งเตือนเมื่อแอพทำงานอยู่
//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );

//   // สร้าง notification channel
//   await NotificationService.createNotificationChannel();

//   // แก้ไขส่วนการรับฟังเมื่อคลิกที่การแจ้งเตือนขณะแอพอยู่ในพื้นหลัง
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     print('Message clicked! ${message.data}');

//     // แสดง dialog เมื่อกดที่การแจ้งเตือน
//     Navigator.of(GlobalKey<NavigatorState>().currentContext!).push(
//       MaterialPageRoute(
//         builder: (context) => InAppMessageDialog(message: message),
//       ),
//     );
//   });

//   // รับฟังเมื่อคลิกที่การแจ้งเตือนขณะแอพอยู่ในพื้นหลัง
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     print('Message clicked! ${message.data}');
//   });

//   // แก้ไขส่วนตรวจสอบการคลิกการแจ้งเตือนที่เปิดแอพ
//   FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
//     if (message != null) {
//       print(
//           'App opened from terminated state by notification! ${message.data}');

//       // แสดง dialog เมื่อเปิดแอพจากการแจ้งเตือน
//       Future.delayed(const Duration(milliseconds: 1000), () {
//         Navigator.of(GlobalKey<NavigatorState>().currentContext!).push(
//           MaterialPageRoute(
//             builder: (context) => InAppMessageDialog(message: message),
//           ),
//         );
//       });
//     }
//   });

//   // ดึง FCM token
//   String? token = await NotificationService.getFCMToken();
//   print('FCM Token: $token');

//   runApp(
//     const MaterialApp(
//       home: SignInPage(),
//       debugShowCheckedModeBanner: false,
//     ),
//   );
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:regaproject/Home/Home.dart';
import 'Sign-In/SignIn.dart';
import 'services/notification_service.dart';
import 'services/in_app_message_dialog.dart';

// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationHandler {
  static const platform = MethodChannel('com.example.regaproject/notification');

  static void initialize() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'notificationClicked':
          print('Notification clicked with data: ${call.arguments}');
          // แปลง Bundle string เป็น Map
          final Map<String, dynamic> notificationData =
              _parseNotificationData(call.arguments);
          handleNotificationClick(notificationData);
          break;
      }
    });
  }

  static Map<String, dynamic> _parseNotificationData(String bundleStr) {
    try {
      // แยกข้อมูลจาก Bundle string
      String dataStr = bundleStr.replaceAll('Bundle[', '').replaceAll(']', '');
      Map<String, dynamic> data = {};

      // แยก payload
      if (dataStr.contains('payload=')) {
        final payloadStart = dataStr.indexOf('payload=') + 8;
        final payloadStr = dataStr.substring(payloadStart);

        // ถ้า payload เป็น Map
        if (payloadStr.startsWith('{') && payloadStr.endsWith('}')) {
          // แปลง String เป็น Map
          final payloadMap = Map<String, dynamic>.from(Uri.splitQueryString(
              payloadStr.substring(1, payloadStr.length - 1)));
          data.addAll(payloadMap);
        } else {
          data['message'] = payloadStr;
        }
      }

      return data;
    } catch (e) {
      print('Error parsing notification data: $e');
      return {'message': bundleStr};
    }
  }

  static void handleNotificationClick(Map<String, dynamic> data) {
    if (navigatorKey.currentContext != null) {
      try {
        final RemoteMessage message = RemoteMessage(
          data: data,
          notification: RemoteNotification(
              title: data['title'] ?? 'การแจ้งเตือน',
              body: data['body'] ?? data['message'] ?? 'คุณมีการแจ้งเตือนใหม่'),
          messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        );

        // แสดงการแจ้งเตือนในแอป
        showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => InAppMessageDialog(
            message: message,
            isFullScreen: true,
          ),
        );
      } catch (e) {
        print('Error showing notification dialog: $e');
        // แสดง dialog แบบพื้นฐานถ้าเกิดข้อผิดพลาด
        showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: const Text('การแจ้งเตือน'),
            content: Text(data['message'] ?? 'คุณมีการแจ้งเตือนใหม่'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ปิด'),
              ),
            ],
          ),
        );
      }
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('Handling a background message: ${message.messageId}');
  if (message.notification != null) {
    await NotificationService.showNotification(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification handler
  NotificationHandler.initialize();

  // Check internet connection
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    print('No internet connection');
    return;
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notification service
  await NotificationService.initialize();

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Create notification channel
  await NotificationService.createNotificationChannel();

  // Set up foreground message handling
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('Got a message in foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message notification:');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');

      await NotificationService.showNotification(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        payload: message.data.toString(),
      );
    }
  });

  // Handle notification click when app is in background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Message clicked when app in background! ${message.data}');
    if (navigatorKey.currentContext != null) {
      Navigator.push(
        navigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (context) => InAppMessageDialog(
            message: message,
            isFullScreen: true,
          ),
        ),
      );
    }
  });

  // Handle notification click when app is terminated
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      print(
          'App opened from terminated state by notification! ${message.data}');
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (navigatorKey.currentContext != null) {
          Navigator.push(
            navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (context) => InAppMessageDialog(
                message: message,
                isFullScreen: true,
              ),
            ),
          );
        }
      });
    }
  });

  // Get FCM token
  String? token = await NotificationService.getFCMToken();
  print('FCM Token: $token');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const SignInPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}





























// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'firebase_options.dart';
// import 'Sign-In/SignIn.dart';
// import 'services/notification_service.dart';
// import 'services/in_app_message_dialog.dart';

// // Global navigator key
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// // ตัวแปรเพื่อเก็บ messageId ของการแจ้งเตือนที่จัดการไปแล้ว
// String? lastHandledMessageId;

// void handleNotificationClick(RemoteMessage message) {
//   // ตรวจสอบว่าข้อความนี้ได้ถูกจัดการไปแล้วหรือไม่
//   if (message.messageId != null && message.messageId == lastHandledMessageId) {
//     print('ตรวจจับการแจ้งเตือนซ้ำแล้ว ไม่ดำเนินการต่อ');
//     return;
//   }
//   lastHandledMessageId = message.messageId;

//   if (navigatorKey.currentContext != null) {
//     Navigator.push(
//       navigatorKey.currentContext!,
//       MaterialPageRoute(
//         builder: (context) => InAppMessageDialog(
//           message: message,
//           isFullScreen: true,
//         ),
//       ),
//     );
//   }
// }

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   print('Handling a background message: ${message.messageId}');
//   if (message.notification != null) {
//     await NotificationService.showNotification(
//       title: message.notification?.title ?? '',
//       body: message.notification?.body ?? '',
//     );
//   }
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต
//   var connectivityResult = await Connectivity().checkConnectivity();
//   if (connectivityResult == ConnectivityResult.none) {
//     print('ไม่มีการเชื่อมต่ออินเทอร์เน็ต');
//     return;
//   }

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   // เริ่มต้น NotificationService
//   await NotificationService.initialize();

//   // ตั้งค่า background message handler
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   // สร้างช่องการแจ้งเตือน
//   await NotificationService.createNotificationChannel();

//   // จัดการข้อความแจ้งเตือนในขณะที่แอปอยู่ใน foreground
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//     print('ได้รับข้อความใน foreground!');
//     print('ข้อมูลของข้อความ: ${message.data}');

//     if (message.notification != null) {
//       print('รายละเอียดแจ้งเตือน:');
//       print('Title: ${message.notification?.title}');
//       print('Body: ${message.notification?.body}');

//       await NotificationService.showNotification(
//         title: message.notification?.title ?? '',
//         body: message.notification?.body ?? '',
//         payload: message.data.toString(),
//       );
//     }
//   });

//   // จัดการการคลิกแจ้งเตือนเมื่อแอปอยู่ใน background
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     print('คลิกแจ้งเตือนเมื่อแอปอยู่ใน background! ${message.data}');
//     handleNotificationClick(message);
//   });

//   // จัดการการคลิกแจ้งเตือนเมื่อแอปถูกเปิดจาก terminated state
//   FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
//     if (message != null) {
//       print('แอปถูกเปิดจากสถานะ terminated โดยแจ้งเตือน! ${message.data}');
//       Future.delayed(const Duration(milliseconds: 1000), () {
//         handleNotificationClick(message);
//       });
//     }
//   });

//   // รับ FCM Token
//   String? token = await NotificationService.getFCMToken();
//   print('FCM Token: $token');

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       home: const SignInPage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

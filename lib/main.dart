// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'firebase_options.dart';
// import 'Sign-In/SignIn.dart';
// import 'services/in_app_message_dialog.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   print('Handling a background message: ${message.messageId}');
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//     print('Got a message in foreground!');
//     print('Message data: ${message.data}');
//   });

//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     if (navigatorKey.currentContext != null) {
//       Navigator.push(
//         navigatorKey.currentContext!,
//         MaterialPageRoute(
//           builder: (context) => InAppMessageDialog(
//             message: message,
//             isFullScreen: true,
//           ),
//         ),
//       );
//     }
//   });

//   String? token = await FirebaseMessaging.instance.getToken();
//   print('FCM Token: $token');

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       home: const SignInPage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'firebase_options.dart';
import 'Sign-In/SignIn.dart';
import 'Home/Home.dart';
import 'services/in_app_message_dialog.dart';
import 'services/session_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('Got a message in foreground!');
    print('Message data: ${message.data}');
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
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

  String? token = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $token');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const AuthenticationWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SessionService.isSessionValid(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ถ้ามี session ที่ยังใช้งานได้ ไปที่ HomePage
        if (snapshot.hasData && snapshot.data == true) {
          return const HomePage();
        }

        // ถ้าไม่มี session หรือ session หมดอายุ ไปที่ SignInPage
        return const SignInPage();
      },
    );
  }
}

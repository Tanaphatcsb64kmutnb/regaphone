import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission handler
import 'firebase_options.dart';
import 'Sign-In/SignIn.dart';
import 'Home/Home.dart';
import 'services/in_app_message_dialog.dart';
import 'services/session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase already initialized in background: $e');
  }
  print('Handling a background message: ${message.messageId}');
}

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase is already initialized: $e');
  }
}

Future<void> requestPermissionsOnFirstRun() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isFirstRun = prefs.getBool('first_run');

  if (isFirstRun == null || isFirstRun) {
    // Request permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.notification
    ].request();

    // Check if all permissions are granted
    if (statuses[Permission.camera]!.isGranted &&
        statuses[Permission.microphone]!.isGranted &&
        statuses[Permission.storage]!.isGranted &&
        statuses[Permission.notification]!.isGranted) {
      print("✅ All permissions granted!");
    } else {
      print("⚠️ Some permissions were denied!");
    }

    // Set first run flag to false
    await prefs.setBool('first_run', false);
  }
}

/// 📌 Request Notification Permission Separately for iOS
Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('✅ User granted permission for notifications');
  } else {
    print('⚠️ User denied notification permissions');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await initializeFirebase();

  // Request permissions on first app launch
  await requestPermissionsOnFirstRun();

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

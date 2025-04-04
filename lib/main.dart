import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart'; // เพิ่ม package สำหรับจัดการสิทธิ์
import 'package:shared_preferences/shared_preferences.dart'; // เพิ่ม package สำหรับเก็บข้อมูล
import 'firebase_options.dart';
import 'Sign-In/SignIn.dart';
import 'Home/Home.dart';
import 'services/in_app_message_dialog.dart';
import 'services/session_service.dart';
import 'services/connectivity_service.dart'; // เพิ่มบรรทัดนี้
import 'widgets/no_internet_dialog.dart'; // เพิ่มบรรทัดนี้
import 'widgets/no_internet_banner.dart'; // เพิ่มบรรทัดนี้

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized in background handler');
  } catch (e) {
    print('Firebase already initialized in background: $e');
  }
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // เริ่มต้น ConnectivityService ก่อน
  ConnectivityService().initialize();

  // ตรวจสอบการเชื่อมต่อก่อนเริ่มแอป
  final hasConnection = await ConnectivityService().checkConnection();

  try {
    // เริ่มต้น Firebase ทุกกรณี แม้ไม่มีอินเทอร์เน็ต
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ เริ่มต้น Firebase สำเร็จ');

    if (!hasConnection) {
      print(
          '⚠️ ไม่มีการเชื่อมต่ออินเทอร์เน็ต Firebase จะทำงานแบบ offline mode');
    }
  } catch (e) {
    print('⚠️ Firebase เริ่มต้นไปแล้ว หรือเกิดข้อผิดพลาด: $e');
  }

  // ขอสิทธิ์เมื่อเปิดแอปครั้งแรก
  await checkFirstRunAndRequestPermissions();

  // เริ่มต้นบริการ Firebase
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // รับข้อความในเฟอร์กราวนด์เฉพาะเมื่อมีการเชื่อมต่อ
  if (hasConnection) {
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

    try {
      String? token = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $token');
    } catch (e) {
      print('ไม่สามารถรับ FCM Token ได้: $e');
    }
  }

  runApp(const MyApp());
}

// ฟังก์ชันสำหรับตรวจสอบและขอสิทธิ์การเข้าถึงเมื่อเปิดแอปครั้งแรก
Future<void> checkFirstRunAndRequestPermissions() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isFirstRun = prefs.getBool('first_run');

  if (isFirstRun == null || isFirstRun) {
    // ขอสิทธิ์การเข้าถึงต่างๆ
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.notification
    ].request();

    // ตรวจสอบผลลัพธ์
    if (statuses[Permission.camera]!.isGranted &&
        statuses[Permission.microphone]!.isGranted &&
        statuses[Permission.storage]!.isGranted &&
        statuses[Permission.notification]!.isGranted) {
      print("✅ ได้รับอนุญาตทั้งหมดแล้ว!");
    } else {
      print("⚠️ บางสิทธิ์ถูกปฏิเสธ!");
    }

    // ขอสิทธิ์การแจ้งเตือนสำหรับ iOS เพิ่มเติม
    await requestNotificationPermissionForIOS();

    // บันทึกว่าไม่ใช่การเปิดครั้งแรกแล้ว
    await prefs.setBool('first_run', false);
  }
}

// ขอสิทธิ์การแจ้งเตือนแยกสำหรับ iOS
Future<void> requestNotificationPermissionForIOS() async {
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
    print('✅ ผู้ใช้อนุญาตการแจ้งเตือน');
  } else {
    print('⚠️ ผู้ใช้ปฏิเสธการแจ้งเตือน');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const NetworkWrapper(child: AuthenticationWrapper()),
      debugShowCheckedModeBanner: false,
    );
  }
}

// เพิ่ม Widget ใหม่เพื่อตรวจสอบการเชื่อมต่อก่อนที่จะไปยัง AuthenticationWrapper
class NetworkWrapper extends StatefulWidget {
  final Widget child;

  const NetworkWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<NetworkWrapper> createState() => _NetworkWrapperState();
}

class _NetworkWrapperState extends State<NetworkWrapper> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isConnected = true; // เริ่มต้นเป็น true เพื่อไม่ให้แสดงแบนเนอร์ทันที

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivityService.isConnected.listen(_handleConnectivityChange);
  }

  Future<void> _checkConnectivity() async {
    final isConnected = await _connectivityService.checkConnection();
    if (mounted) {
      setState(() {
        _isConnected = isConnected;
      });
    }
  }

  void _handleConnectivityChange(bool isConnected) {
    if (mounted) {
      setState(() {
        _isConnected = isConnected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // แสดง child widget เสมอ แต่ถ้าไม่มีอินเทอร์เน็ตให้แสดงแบนเนอร์ข้างบน
    return Scaffold(
      body: Column(
        children: [
          // แบนเนอร์แจ้งเตือนไม่มีอินเทอร์เน็ต
          if (!_isConnected)
            Container(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'ไม่มีการเชื่อมต่ออินเทอร์เน็ต',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _checkConnectivity,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'ลองอีกครั้ง',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // แสดง widget หลัก
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  @override
  void initState() {
    super.initState();
    // ถ้าอยากให้แสดง dialog ถามผู้ใช้ก่อนขอสิทธิ์
    // สามารถทำที่นี่ได้ โดยใช้ context ที่พร้อมแล้ว
  }

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

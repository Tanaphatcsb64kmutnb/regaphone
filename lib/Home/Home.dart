import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Sign-In/SignIn.dart';
import '../CameraMediapipe/cameramediapipe.dart';
import '../yogaprogrampose/YogaListPage.dart';
import '../history/HistoryPage.dart';
import '../Favorite/FavoritePage.dart';
import '../Notification/NotificationsPage.dart';
import './notification_dialog.dart';
import '../services/notification_service.dart';
import '../services/in_app_message_dialog.dart';
import 'package:flutter/services.dart'; // สำหรับ MethodChannel
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert'; // สำหรับ jsonEncode, jsonDecode
import 'package:shared_preferences/shared_preferences.dart';
import '../services/session_service.dart';
import '../settings/setting.dart';
import '../AboutUs/about_us.dart';
import '../ContactUs/contact_us.dart';
import '../services/connectivity_service.dart';
import '../widgets/no_internet_banner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = 'User';
  // เป็นนี้:
  Stream<RemoteMessage> _notificationsStream = Stream.empty();
  bool _isFirstNotification = true;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _isConnected = true; // เพิ่มตัวแปรสำหรับเก็บสถานะการเชื่อมต่อ

// เพิ่มฟังก์ชันใหม่สำหรับจัดการการแจ้งเตือนตามสถานะ login
  Future<void> _subscribeToNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firebaseMessaging.subscribeToTopic('user_${user.uid}');
      await _firebaseMessaging.subscribeToTopic('general_notifications');

      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> _unsubscribeFromNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firebaseMessaging.unsubscribeFromTopic('user_${user.uid}');
      await _firebaseMessaging.unsubscribeFromTopic('general_notifications');
    }
  }

  Future<void> _checkSession() async {
    final isValid = await SessionService.isSessionValid();
    if (!isValid) {
      await FirebaseAuth.instance.signOut();
      await SessionService.clearSession();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignInPage()),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('notifications') ?? '[]';
    return List<Map<String, dynamic>>.from(
        jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));
  }

  @override
  void initState() {
    super.initState();
    _checkSession(); // เพิ่มบรรทัดนี้
    _fetchUserData();
    // _setupNotifications(); // เพิ่มบรรทัดนี้
    initializeNotifications(); // เพิ่มบรรทัดนี้
    // _initializeFirebaseMessaging();
    _setupNotificationListeners(); // เพิ่มบรรทัดนี้
    _checkAuthAndInitialize();

    // เพิ่มการตรวจสอบการเชื่อมต่อ
    _checkConnectivity();
    ConnectivityService().isConnected.listen(_updateConnectionStatus);

    // ทำงานพื้นฐานที่ไม่ต้องใช้อินเทอร์เน็ต
    _fetchUserData();

    // ทำงานที่ต้องใช้อินเทอร์เน็ตแบบมีเงื่อนไข
    _initializeOnlineFeatures();
  }

// 2. เพิ่มฟังก์ชันใหม่สำหรับเริ่มต้นฟีเจอร์ที่ต้องใช้อินเทอร์เน็ต
  void _initializeOnlineFeatures() {
    if (_isConnected) {
      _checkSession();
      initializeNotifications();
      _setupNotificationListeners();
      _checkAuthAndInitialize();
    }
  }

  void _checkAuthAndInitialize() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        // เมื่อ Login สำเร็จ
        initializeNotifications();
        // _initializeFirebaseMessaging();
        await _subscribeToNotifications();
      } else {
        // เมื่อ Logout หรือยังไม่ได้ login
        await _unsubscribeFromNotifications();
        if (mounted) {
          setState(() {
            _notificationsStream = Stream.empty(); // ล้าง stream การแจ้งเตือน
          });
        }
      }
    });
  }

  void _setupNotificationListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (mounted && message.notification != null) {
        _saveNotificationToLocalStorage(message);

        // แสดงป๊อปอัพการแจ้งเตือน
        showDialog(
          context: context,
          builder: (context) => NotificationDialog(
            notificationData: {
              'title': message.notification?.title,
              'body': message.notification?.body,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
              ...message.data
            },
          ),
        );
      }
    });

    // เพิ่มการรับฟังเหตุการณ์อื่นๆ ตามต้องการ
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _saveNotificationToLocalStorage(message);
    });

    // ตรวจสอบการเปิดแอปจากการแจ้งเตือน
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        _saveNotificationToLocalStorage(message);
      }
    });
  }

  // ใน _HomePageState class เพิ่มฟังก์ชัน
  // ใน Home.dart
  void _saveNotificationToLocalStorage(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();

    // โหลดข้อมูลเดิม
    final notificationsJson = prefs.getString('notifications') ?? '[]';
    final notifications = List<Map<String, dynamic>>.from(
        jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

    // เพิ่มการแจ้งเตือนใหม่
    notifications.insert(0, {
      'title': message.notification?.title,
      'body': message.notification?.body,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': message.data,
      'isRead': false,
    });

    // บันทึกกลับ
    await prefs.setString('notifications', jsonEncode(notifications));
  }

// // แก้ไขใน _initializeFirebaseMessaging()
//   void _initializeFirebaseMessaging() {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       _notificationsStream = FirebaseMessaging.onMessage;

//       _notificationsStream.listen((RemoteMessage message) {
//         if (mounted && message.notification != null) {
//           _saveNotificationToFirestore(message); // เพิ่มบรรทัดนี้

//           showDialog(
//             context: context,
//             builder: (context) => NotificationDialog(
//               notificationData: {
//                 'title': message.notification?.title,
//                 'body': message.notification?.body,
//                 'timestamp': DateTime.now().millisecondsSinceEpoch,
//                 ...message.data
//               },
//             ),
//           );
//         }
//       });
//     }
//   }

  void initializeNotifications() {
    const platform = MethodChannel('com.example.regaproject/notification');
    platform.setMethodCallHandler((call) async {
      if (call.method == 'notificationClicked') {
        final data = Map<String, dynamic>.from(call.arguments);
        final user = FirebaseAuth.instance.currentUser;

        if (mounted) {
          if (user != null) {
            // กรณี login แล้ว
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationDialog(
                  notificationData: data,
                ),
              ),
            );
          } else {
            // กรณียังไม่ได้ login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SignInPage(
                  pendingNotification: data,
                ),
              ),
            );
          }
        }
      }
    });
  }

  // 1. ฟังก์ชันเก็บข้อมูลแจ้งเตือน
  Future<void> _saveNotificationData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_notification', jsonEncode(data));
  }

// 2. ฟังก์ชันแสดงการแจ้งเตือนที่บันทึกไว้
  Future<void> _showSavedNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNotification = prefs.getString('pending_notification');

    if (savedNotification != null) {
      final data = jsonDecode(savedNotification) as Map<String, dynamic>;
      await prefs.remove('pending_notification'); // ลบข้อมูลที่บันทึกไว้

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NotificationDialog(
              notificationData: data,
            ),
          ),
        );
      }
    }
  }

  // 4. เพิ่มฟังก์ชันสำหรับตรวจสอบการเชื่อมต่อ
  Future<void> _checkConnectivity() async {
    final isConnected = await ConnectivityService().checkConnection();
    if (mounted) {
      setState(() {
        _isConnected = isConnected;
      });
    }
  }

// 3. แก้ไขฟังก์ชัน _updateConnectionStatus
  void _updateConnectionStatus(bool isConnected) {
    if (mounted) {
      setState(() {
        _isConnected = isConnected;
      });

      // เริ่มต้นฟีเจอร์ที่ต้องใช้อินเทอร์เน็ตเมื่อการเชื่อมต่อกลับมา
      if (isConnected) {
        _initializeOnlineFeatures();
      }
    }
  }

  void _showInAppMessage(RemoteMessage message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => InAppMessageDialog(message: message),
    );
  }

  // 4. แก้ไขฟังก์ชัน _fetchUserData เพื่อป้องกัน error เมื่อไม่มีอินเทอร์เน็ต
  void _fetchUserData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null && _isConnected) {
        final DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (mounted && userData.exists) {
          setState(() {
            username = userData['username'] ?? 'User';
          });
        }
      }
    } catch (e) {
      print('ไม่สามารถดึงข้อมูลผู้ใช้: $e');
      // ใช้ค่าเริ่มต้นหากไม่สามารถดึงข้อมูลได้
    }
  }
  // void _showLogoutConfirmation(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Confirm Logout'),
  //       content: const Text('Are you sure you want to logout?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () async {
  //             await SessionService.clearSession(); // เพิ่มบรรทัดนี้
  //             await FirebaseAuth.instance.signOut().then((_) {
  //               Navigator.pushReplacement(
  //                 context,
  //                 MaterialPageRoute(builder: (_) => const SignInPage()),
  //               );
  //             });
  //           },
  //           child: const Text('Logout'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: Colors.purple.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logout Icon
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.red.shade800.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red.shade400,
                  size: 34,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'ออกจากระบบ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Message
              const Text(
                'คุณต้องการออกจากระบบใช่หรือไม่?',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Logout Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Dialog(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'กำลังออกจากระบบ...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );

                        // ล้าง session ก่อนออกจากระบบ
                        await SessionService.clearSession();
                        // ออกจากระบบ Firebase
                        await FirebaseAuth.instance.signOut();

                        if (mounted) {
                          // Remove loading dialog
                          Navigator.pop(context);
                          // Remove logout confirm dialog
                          Navigator.pop(context);
                          // Navigate to sign in
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignInPage()),
                            (route) => false, // ล้าง stack ทั้งหมด
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'ออกจากระบบ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _testMediapipe(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraMediapipeApp()),
    );
  }

  void _contactUs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Us'),
        content: const Text('This is the contact us page.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsPage()),
    );
  }

  // เพิ่มต่อจากฟังก์ชันอื่นๆ ก่อน build
  void _checkCurrentSession() async {
    final session = await SessionService.getSession();
    if (session != null) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ข้อมูล Session ปัจจุบัน'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Username: ${session['username']}'),
                Text('Email: ${session['email']}'),
                Text('Login ล่าสุด: ${session['lastLogin']}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ปิด'),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ไม่พบ Session'),
            content: const Text('ไม่พบข้อมูล session ที่ใช้งานอยู่'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: FutureBuilder<List<Map<String, dynamic>>>(
          future: _getNotifications(),
          builder: (context, snapshot) {
            bool hasUnreadMessage = false;
            if (snapshot.hasData) {
              hasUnreadMessage =
                  snapshot.data!.any((item) => item['isRead'] == false);
            }

            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () => _openNotifications(context),
                ),
                if (hasUnreadMessage)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: const Text(
                        "1",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        title: const Text(
          'REGA',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                tooltip: 'เมนู',
              ),
            ),
          ),
        ],
      ),
      endDrawer: _buildDrawer(),
      body: Column(
        // เปลี่ยนจาก SafeArea เป็น Column
        children: [
          // เพิ่มแบนเนอร์แจ้งเตือนไม่มีอินเทอร์เน็ต
          if (!_isConnected)
            NoInternetBanner(
              onRetry: () async {
                // ตรวจสอบการเชื่อมต่ออีกครั้ง
                final isConnected =
                    await ConnectivityService().checkConnection();
                if (mounted) {
                  _updateConnectionStatus(isConnected);
                }
              },
            ),
          Expanded(
            // ครอบ SafeArea ด้วย Expanded
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      _buildMainCard(),
                      const SizedBox(height: 16),
                      _buildGridCards(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const YogaListPage()),
        );
      },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: const DecorationImage(
            image: AssetImage('assets/img/yoga1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'รายการโยคะทั้งหมด',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'เริ่มต้นการฝึกโยคะของคุณ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: [
        _buildCard(
          'รายการโปรด',
          'assets/img/yoga2.png',
          onTap: () {
            final currentUser = FirebaseAuth.instance.currentUser;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FavoritePage(userId: currentUser?.uid ?? ''),
              ),
            );
          },
        ),
        _buildCard(
          'ประวัติการใช้งาน',
          'assets/img/yoga3.png',
          onTap: () {
            // Navigate to history page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryPage()),
            );
          },
        ),
        _buildCard(
          'เกี่ยวกับเรา',
          'assets/img/yoga4.png',
          onTap: () {
            // Navigate to about page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutUsPage()),
            );
          },
        ),
        _buildCard(
          'ติดต่อเรา',
          'assets/img/yoga5.png',
          onTap: () {
            // Navigate to about page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactUsPage()),
            );
          },
        ),
        _buildCard(
          'ทดลอง Mediapipe',
          'assets/img/yoga1.png',
          onTap: () => _testMediapipe(context),
        ),
      ],
    );
  }

  Widget _buildCard(String title, String imagePath, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.black,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.grey[900]!,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white24,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'สวัสดี, $username',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              FirebaseAuth.instance.currentUser?.email ?? '',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showLogoutConfirmation(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      minimumSize: const Size(double.infinity, 0),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.logout, size: 20),
                    label: const Text(
                      'ออกจากระบบ',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 8),
                  _buildDrawerItem(Icons.home, 'หน้าหลัก', () {
                    Navigator.pop(context);
                  }),
                  _buildDrawerItem(Icons.favorite, 'รายการโปรด', () {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FavoritePage(userId: currentUser?.uid ?? ''),
                      ),
                    );
                  }),
                  _buildDrawerItem(Icons.history, 'ประวัติ', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HistoryPage()),
                    );
                  }),
                  _buildDrawerItem(Icons.info, 'เกี่ยวกับเรา', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AboutUsPage()),
                    );
                  }),
                  _buildDrawerItem(Icons.contact_mail, 'ติดต่อเรา', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ContactUsPage()),
                    );
                  }),
                  _buildDrawerItem(Icons.settings, 'ตั้งค่า', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()),
                    );
                  }),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white24, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'REGA © 2025',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'เวอร์ชัน 1.0.0',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Also replace the _buildDrawerItem method with this improved version

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          highlightColor: Colors.white.withOpacity(0.05),
          splashColor: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 24),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _unsubscribeFromNotifications();
    super.dispose();
  }
}

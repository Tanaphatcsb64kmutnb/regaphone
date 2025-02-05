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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = 'User';
  // เป็น
  late Stream<RemoteMessage> _notificationsStream;
  bool _isFirstNotification = true;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

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

  @override
  void initState() {
    super.initState();

    _fetchUserData();
    // _setupNotifications(); // เพิ่มบรรทัดนี้
    initializeNotifications(); // เพิ่มบรรทัดนี้
    _initializeFirebaseMessaging();
    _checkAuthAndInitialize();
  }

  void _checkAuthAndInitialize() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        // เมื่อ Login สำเร็จ
        initializeNotifications();
        _initializeFirebaseMessaging();
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

  // ใน _HomePageState class เพิ่มฟังก์ชัน
  void _saveNotificationToFirestore(RemoteMessage message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': user.uid,
      'title': message.notification?.title,
      'body': message.notification?.body,
      'timestamp': FieldValue.serverTimestamp(),
      'imageUrl': message.data['imageUrl'],
      'additionalData': message.data,
      'isRead': false,
    });
  }

// แก้ไขใน _initializeFirebaseMessaging()
  void _initializeFirebaseMessaging() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _notificationsStream = FirebaseMessaging.onMessage;

      _notificationsStream.listen((RemoteMessage message) {
        if (mounted && message.notification != null) {
          _saveNotificationToFirestore(message); // เพิ่มบรรทัดนี้

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
    }
  }

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

  void _showInAppMessage(RemoteMessage message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => InAppMessageDialog(message: message),
    );
  }

  void _fetchUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        username = userData['username'] ?? 'User';
      });
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut().then((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInPage()),
                );
              });
            },
            child: const Text('Logout'),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: StreamBuilder<RemoteMessage>(
          // เปลี่ยนจาก QuerySnapshot เป็น RemoteMessage
          stream: _notificationsStream,
          builder: (context, snapshot) {
            // ปรับการตรวจสอบข้อมูล
            bool hasUnreadMessage = false;
            if (snapshot.hasData && snapshot.data != null) {
              hasUnreadMessage = true; // หรือตามลอจิกที่ต้องการ
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
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: _buildDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              MaterialPageRoute(builder: (context) => const YogaListPage()),
            );
          },
        ),
        _buildCard(
          'ติดต่อเรา',
          'assets/img/yoga5.png',
          onTap: () => _contactUs(context),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black,
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
                  Text(
                    'สวัสดี, $username',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showLogoutConfirmation(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('ออกจากระบบ'),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, 'หน้าหลัก', () {
              Navigator.pop(context);
            }),
            // 2. ในส่วน _buildDrawerItem
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
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            }),
            _buildDrawerItem(Icons.info, 'เกี่ยวกับเรา', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const YogaListPage()),
              );
            }),
            _buildDrawerItem(Icons.contact_mail, 'ติดต่อเรา', () {
              Navigator.pop(context);
              _contactUs(context);
            }),
            _buildDrawerItem(Icons.settings, 'ตั้งค่า', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const YogaListPage()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  void dispose() {
    _unsubscribeFromNotifications();
    super.dispose();
  }
}

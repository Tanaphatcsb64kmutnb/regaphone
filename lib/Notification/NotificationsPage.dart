// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import './notification_detail.dart';
// import 'package:intl/intl.dart';

// class NotificationsPage extends StatefulWidget {
//   const NotificationsPage({Key? key}) : super(key: key);

//   @override
//   _NotificationsPageState createState() => _NotificationsPageState();
// }

// class _NotificationsPageState extends State<NotificationsPage> {
//   final List<RemoteMessage> notifications = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadNotifications();
//   }

//   Future<void> _loadNotifications() async {
//     // เรียกดูประวัติการแจ้งเตือนที่ยังไม่ได้อ่าน
//     final unreadMessages = await FirebaseMessaging.instance.getInitialMessage();
//     if (unreadMessages != null) {
//       setState(() {
//         notifications.add(unreadMessages);
//       });
//     }

//     // ฟังก์ชันรับการแจ้งเตือนใหม่
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       setState(() {
//         notifications.add(message);
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title:
//             const Text('การแจ้งเตือน', style: TextStyle(color: Colors.white)),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: notifications.isEmpty
//           ? const Center(
//               child: Text(
//                 'ไม่มีการแจ้งเตือน',
//                 style: TextStyle(color: Colors.white),
//               ),
//             )
//           : ListView.builder(
//               itemCount: notifications.length,
//               itemBuilder: (context, index) {
//                 final notification = notifications[index];
//                 final timestamp = notification.sentTime ?? DateTime.now();
//                 final formattedDate =
//                     DateFormat('dd/MM/yyyy HH:mm').format(timestamp);

//                 return GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => NotificationDetailPage(
//                           title: notification.notification?.title ?? '',
//                           body: notification.notification?.body ?? '',
//                           timestamp: timestamp,
//                           additionalData: notification.data,
//                         ),
//                       ),
//                     );
//                   },
//                   child: Container(
//                     margin:
//                         const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[900],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           notification.notification?.title ?? '',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           notification.notification?.body ?? '',
//                           style: TextStyle(
//                             color: Colors.grey[400],
//                             fontSize: 14,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           formattedDate,
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// ใน NotificationsPage.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import './notification_detail.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // ใช้ SharedPreferences เพื่อเก็บประวัติการแจ้งเตือน
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('notifications') ?? '[]';

    setState(() {
      notifications = List<Map<String, dynamic>>.from(
          jsonDecode(notificationsJson)
              .map((x) => Map<String, dynamic>.from(x)));
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
            const Text('การแจ้งเตือน', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(
                  child: Text('ไม่มีการแจ้งเตือน',
                      style: TextStyle(color: Colors.white)),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final timestamp = DateTime.fromMillisecondsSinceEpoch(
                        notification['timestamp'] ??
                            DateTime.now().millisecondsSinceEpoch);
                    final formattedDate =
                        DateFormat('dd/MM/yyyy HH:mm').format(timestamp);

                    return GestureDetector(
                      onTap: () async {
                        // อัพเดทสถานะเป็นอ่านแล้ว
                        setState(() {
                          notifications[index]['isRead'] = true;
                        });

                        // บันทึกกลับไปที่ SharedPreferences
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(
                            'notifications', jsonEncode(notifications));

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationDetailPage(
                              title: notification['title'] ?? '',
                              body: notification['body'] ?? '',
                              timestamp: timestamp,
                              additionalData: notification['data'] ?? {},
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: notification['isRead'] == true
                              ? Colors.grey[900]
                              : Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                          border: notification['isRead'] == true
                              ? null
                              : Border.all(
                                  color: Colors.blue.shade300, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification['title'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notification['body'] ?? '',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

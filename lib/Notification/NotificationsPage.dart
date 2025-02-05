// import 'package:flutter/material.dart';

// class NotificationsPage extends StatelessWidget {
//   const NotificationsPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // ตัวอย่างข้อมูลแจ้งเตือน (Dummy)
//     final List<Map<String, String>> notifications = [
//       {
//         'title': 'ท่าโยคะใหม่!',
//         'message': 'ลองเล่นท่าใหม่เพื่อบรรเทาปวดหลังได้แล้ววันนี้',
//         'time': '2 ชม.ที่แล้ว',
//       },
//       {
//         'title': 'โปรโมชั่นพิเศษ',
//         'message': 'รับส่วนลด 20% สำหรับการสมัครสมาชิก Premium',
//         'time': 'เมื่อวานนี้',
//       },
//       {
//         'title': 'อัปเดตแอป',
//         'message': 'มีฟีเจอร์ใหม่ให้ลอง เช่น ระบบวัดการเคลื่อนไหว',
//         'time': '3 วันก่อน',
//       },
//     ];

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         // พื้นหลัง AppBar สีดำ
//         backgroundColor: Colors.black,
//         centerTitle: true,

//         // ตั้งค่าให้ไอคอน (ปุ่ม Back) เป็นสีขาว
//         iconTheme: const IconThemeData(color: Colors.white),

//         // ตั้งค่า Title เป็นสีขาว
//         titleTextStyle: const TextStyle(
//           color: Colors.white,
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),

//         title: const Text('การแจ้งเตือน'),
//       ),
//       body: SafeArea(
//         child: ListView.builder(
//           itemCount: notifications.length,
//           itemBuilder: (context, index) {
//             final item = notifications[index];
//             final title = item['title'] ?? 'No title';
//             final message = item['message'] ?? 'No message';
//             final time = item['time'] ?? 'No time';

//             return Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade900.withOpacity(0.5),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     message,
//                     style: const TextStyle(
//                       color: Colors.white70,
//                       fontSize: 14,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     time,
//                     style: const TextStyle(
//                       color: Colors.grey,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class NotificationsPage extends StatelessWidget {
//   const NotificationsPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//         titleTextStyle: const TextStyle(
//           color: Colors.white,
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//         title: const Text('การแจ้งเตือน'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('notifications')
//             .orderBy('createdAt', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return const Center(
//                 child: Text('เกิดข้อผิดพลาด',
//                     style: TextStyle(color: Colors.white)));
//           }

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(
//               child: Text('ไม่มีการแจ้งเตือน',
//                   style: TextStyle(color: Colors.white)),
//             );
//           }

//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               final notification = snapshot.data!.docs[index];
//               final data = notification.data() as Map<String, dynamic>;

//               return Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade900.withOpacity(0.5),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       data['title'] ?? '',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       data['message'] ?? '',
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       data['createdAt'] != null
//                           ? timeago.format(
//                               (data['createdAt'] as Timestamp).toDate(),
//                               locale: 'th',
//                             )
//                           : '',
//                       style: TextStyle(
//                         color: Colors.grey.shade400,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// // lib/pages/NotificationsPage.dart
// import 'package:flutter/material.dart';

// class NotificationsPage extends StatelessWidget {
//   final String? notificationData;

//   const NotificationsPage({Key? key, this.notificationData}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('การแจ้งเตือน'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (notificationData != null) ...[
//               Text(
//                 'ข้อความการแจ้งเตือน:',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//               const SizedBox(height: 8),
//               Text(notificationData!),
//             ] else
//               const Text('ไม่มีการแจ้งเตือน'),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import './notification_detail.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<RemoteMessage> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // เรียกดูประวัติการแจ้งเตือนที่ยังไม่ได้อ่าน
    final unreadMessages = await FirebaseMessaging.instance.getInitialMessage();
    if (unreadMessages != null) {
      setState(() {
        notifications.add(unreadMessages);
      });
    }

    // ฟังก์ชันรับการแจ้งเตือนใหม่
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        notifications.add(message);
      });
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
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                'ไม่มีการแจ้งเตือน',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final timestamp = notification.sentTime ?? DateTime.now();
                final formattedDate =
                    DateFormat('dd/MM/yyyy HH:mm').format(timestamp);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationDetailPage(
                          title: notification.notification?.title ?? '',
                          body: notification.notification?.body ?? '',
                          timestamp: timestamp,
                          additionalData: notification.data,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.notification?.title ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notification.notification?.body ?? '',
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

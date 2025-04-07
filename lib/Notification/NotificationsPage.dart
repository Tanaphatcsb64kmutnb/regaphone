// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../Home/notification_dialog.dart';
// import '../models/notification_model.dart';
// import '../services/notification_manager.dart';

// class NotificationsPage extends StatefulWidget {
//   const NotificationsPage({Key? key}) : super(key: key);

//   @override
//   State<NotificationsPage> createState() => _NotificationsPageState();
// }

// class _NotificationsPageState extends State<NotificationsPage> {
//   String _selectedCategory = 'all'; // ตัวกรองหมวดหมู่
//   String _sortBy = 'newest'; // ตัวเรียงลำดับ

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3, // แบ่งเป็น 3 แท็บ: ทั้งหมด, ยังไม่อ่าน, อ่านแล้ว
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         appBar: AppBar(
//           backgroundColor: Colors.black,
//           elevation: 0,
//           title: const Text(
//             'การแจ้งเตือน',
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           bottom: TabBar(
//             indicatorColor: Colors.white,
//             labelColor: Colors.white,
//             unselectedLabelColor: Colors.white60,
//             tabs: const [
//               Tab(text: 'ทั้งหมด'),
//               Tab(text: 'ยังไม่อ่าน'),
//               Tab(text: 'อ่านแล้ว'),
//             ],
//           ),
//           actions: [
//             // ปุ่มสำหรับการกรอง
//             IconButton(
//               icon: const Icon(Icons.filter_list, color: Colors.white),
//               onPressed: _showFilterOptions,
//             ),
//             // ปุ่มสำหรับทำเครื่องหมายว่าอ่านทั้งหมด
//             IconButton(
//               icon: const Icon(Icons.done_all, color: Colors.white),
//               onPressed: _markAllAsRead,
//             ),
//             // ปุ่มสำหรับสร้างการแจ้งเตือนทดสอบ
//             IconButton(
//               icon: const Icon(Icons.add_alert, color: Colors.white),
//               onPressed: _createTestNotification,
//             ),
//             // ปุ่มลบการแจ้งเตือนทั้งหมด
//             IconButton(
//               icon: const Icon(Icons.delete_sweep, color: Colors.white),
//               onPressed: _resetNotifications,
//             ),
//           ],
//         ),
//         body: TabBarView(
//           children: [
//             _buildNotificationList(null), // ทั้งหมด
//             _buildNotificationList(false), // ยังไม่อ่าน
//             _buildNotificationList(true), // อ่านแล้ว
//           ],
//         ),
//       ),
//     );
//   }

//   // สร้างการแจ้งเตือนทดสอบ
//   void _createTestNotification() async {
//     try {
//       await NotificationManager.saveCustomNotification(
//         title: "การแจ้งเตือนทดสอบ",
//         body:
//             "นี่คือการแจ้งเตือนทดสอบที่สร้างเมื่อ ${DateTime.now().toString()}",
//         category: "test",
//         priority: "high",
//       );

//       setState(() {}); // รีเฟรชหน้าจอ
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('สร้างการแจ้งเตือนทดสอบสำเร็จ'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     } catch (e) {
//       print('❌ เกิดข้อผิดพลาดในการสร้างการแจ้งเตือนทดสอบ: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('เกิดข้อผิดพลาด: $e'),
//           backgroundColor: Colors.red,
//           duration: Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   // ลบการแจ้งเตือนทั้งหมด
//   Future<void> _resetNotifications() async {
//     try {
//       await NotificationManager.deleteAllNotifications();
//       setState(() {});
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('ล้างข้อมูลการแจ้งเตือนทั้งหมดแล้ว'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     } catch (e) {
//       print('❌ เกิดข้อผิดพลาดในการลบการแจ้งเตือนทั้งหมด: $e');
//     }
//   }

//   // แสดงตัวเลือกในการกรอง
//   void _showFilterOptions() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.grey[900],
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'กรองและเรียงลำดับ',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   // หมวดหมู่
//                   const Text(
//                     'หมวดหมู่',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Wrap(
//                     spacing: 8,
//                     children: [
//                       _filterChip('ทั้งหมด', 'all', setState),
//                       _filterChip('ทั่วไป', 'general', setState),
//                       _filterChip('อัปเดต', 'update', setState),
//                       _filterChip('ข่าวสาร', 'news', setState),
//                       _filterChip('ทดสอบ', 'test', setState),
//                     ],
//                   ),
//                   const SizedBox(height: 16),

//                   // เรียงลำดับ
//                   const Text(
//                     'เรียงลำดับ',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Wrap(
//                     spacing: 8,
//                     children: [
//                       _sortChip('ล่าสุด', 'newest', setState),
//                       _sortChip('เก่าสุด', 'oldest', setState),
//                     ],
//                   ),
//                   const SizedBox(height: 24),

//                   // ปุ่มนำไปใช้
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       onPressed: () {
//                         Navigator.pop(context);
//                         // refresh UI
//                         this.setState(() {});
//                       },
//                       child: const Text(
//                         'นำไปใช้',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     ).then((_) {
//       // รีเฟรชหน้าจอเมื่อปิดการกรอง
//       setState(() {});
//     });
//   }

//   // สร้าง Chip สำหรับกรอง
//   Widget _filterChip(String label, String value, StateSetter setState) {
//     return FilterChip(
//       label: Text(
//         label,
//         style: TextStyle(
//           color: _selectedCategory == value ? Colors.white : Colors.white70,
//         ),
//       ),
//       selected: _selectedCategory == value,
//       selectedColor: Colors.blue,
//       backgroundColor: Colors.grey[800],
//       checkmarkColor: Colors.white,
//       onSelected: (selected) {
//         setState(() {
//           _selectedCategory = value;
//         });
//         this.setState(() {});
//       },
//     );
//   }

//   // สร้าง Chip สำหรับเรียงลำดับ
//   Widget _sortChip(String label, String value, StateSetter setState) {
//     return FilterChip(
//       label: Text(
//         label,
//         style: TextStyle(
//           color: _sortBy == value ? Colors.white : Colors.white70,
//         ),
//       ),
//       selected: _sortBy == value,
//       selectedColor: Colors.blue,
//       backgroundColor: Colors.grey[800],
//       checkmarkColor: Colors.white,
//       onSelected: (selected) {
//         setState(() {
//           _sortBy = value;
//         });
//         this.setState(() {});
//       },
//     );
//   }

//   // ทำเครื่องหมายว่าอ่านทั้งหมด
//   Future<void> _markAllAsRead() async {
//     try {
//       await NotificationManager.markAllAsRead();
//       setState(() {});
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('ทำเครื่องหมายการแจ้งเตือนทั้งหมดว่าอ่านแล้ว'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     } catch (e) {
//       print('❌ เกิดข้อผิดพลาดในการทำเครื่องหมายว่าอ่านทั้งหมด: $e');
//     }
//   }

//   // ลบการแจ้งเตือน
//   Future<void> _deleteNotification(String id) async {
//     try {
//       await NotificationManager.deleteNotification(id);
//       setState(() {});
//     } catch (e) {
//       print('❌ เกิดข้อผิดพลาดในการลบการแจ้งเตือน: $e');
//     }
//   }

//   // รับการแจ้งเตือนจาก SharedPreferences และ Firestore
//   Future<List<NotificationModel>> _getNotifications() async {
//     // ลองดึงข้อมูลจาก Firestore ก่อน
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         print('📩 กำลังดึงข้อมูลการแจ้งเตือนจาก Firestore...');
//         var firebaseNotifications =
//             await NotificationManager.getAllNotificationsFromFirestore();

//         if (firebaseNotifications.isNotEmpty) {
//           print(
//               '✅ ดึงข้อมูลจาก Firestore สำเร็จ: ${firebaseNotifications.length} รายการ');

//           // กรองตามหมวดหมู่
//           if (_selectedCategory != 'all') {
//             firebaseNotifications = firebaseNotifications
//                 .where((notification) =>
//                     notification.category == _selectedCategory)
//                 .toList();
//           }

//           // เรียงลำดับ
//           if (_sortBy == 'newest') {
//             firebaseNotifications
//                 .sort((a, b) => b.timestamp.compareTo(a.timestamp));
//           } else {
//             firebaseNotifications
//                 .sort((a, b) => a.timestamp.compareTo(b.timestamp));
//           }

//           return firebaseNotifications;
//         }
//       }
//     } catch (e) {
//       print('❌ เกิดข้อผิดพลาดในการดึงข้อมูลจาก Firestore: $e');
//     }

//     // ถ้าดึงจาก Firestore ไม่สำเร็จ ให้ใช้ข้อมูลจาก SharedPreferences
//     print('📩 กำลังดึงข้อมูลการแจ้งเตือนจาก SharedPreferences...');
//     var notifications = await NotificationManager.getAllNotifications();
//     print(
//         '✅ ดึงข้อมูลจาก SharedPreferences สำเร็จ: ${notifications.length} รายการ');

//     // กรองตามหมวดหมู่
//     if (_selectedCategory != 'all') {
//       notifications = notifications
//           .where((notification) => notification.category == _selectedCategory)
//           .toList();
//     }

//     // เรียงลำดับ
//     if (_sortBy == 'newest') {
//       notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
//     } else {
//       notifications.sort((a, b) => a.timestamp.compareTo(b.timestamp));
//     }

//     return notifications;
//   }

//   // สร้าง Widget สำหรับแสดงรายการแจ้งเตือน
//   Widget _buildNotificationList(bool? isRead) {
//     return FutureBuilder<List<NotificationModel>>(
//       future: _getNotifications(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//             ),
//           );
//         }

//         if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return const Center(
//             child: Text(
//               'ไม่มีการแจ้งเตือน',
//               style: TextStyle(color: Colors.white70),
//             ),
//           );
//         }

//         // กรองข้อมูลตาม isRead ถ้ามีการกำหนด
//         final notifications = isRead == null
//             ? snapshot.data!
//             : snapshot.data!.where((item) => item.isRead == isRead).toList();

//         if (notifications.isEmpty) {
//           return Center(
//             child: Text(
//               isRead == true
//                   ? 'ไม่มีการแจ้งเตือนที่อ่านแล้ว'
//                   : 'ไม่มีการแจ้งเตือนที่ยังไม่ได้อ่าน',
//               style: const TextStyle(color: Colors.white70),
//             ),
//           );
//         }

//         // จัดกลุ่มตามวันที่
//         final Map<String, List<NotificationModel>> groupedNotifications = {};
//         for (var notification in notifications) {
//           final date =
//               DateTime.fromMillisecondsSinceEpoch(notification.timestamp);
//           final dateString = DateFormat('dd/MM/yyyy').format(date);

//           if (!groupedNotifications.containsKey(dateString)) {
//             groupedNotifications[dateString] = [];
//           }
//           groupedNotifications[dateString]!.add(notification);
//         }

//         // เรียงลำดับวันที่จากใหม่ไปเก่า
//         final sortedDates = groupedNotifications.keys.toList();
//         if (_sortBy == 'newest') {
//           sortedDates.sort((a, b) => b.compareTo(a));
//         } else {
//           sortedDates.sort((a, b) => a.compareTo(b));
//         }

//         // สร้าง ListView แบบมีส่วนหัว
//         return ListView.builder(
//           itemCount: sortedDates.length,
//           itemBuilder: (context, groupIndex) {
//             final dateString = sortedDates[groupIndex];
//             final notificationsForDate = groupedNotifications[dateString]!;

//             return Column(
//               key: Key('date_group_$dateString'),
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   color: Colors.grey[900],
//                   child: Text(
//                     dateString,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                       color: Colors.white70,
//                     ),
//                   ),
//                 ),
//                 ...notificationsForDate.asMap().entries.map((entry) {
//                   int index = entry.key;
//                   NotificationModel notification = entry.value;
//                   return _buildNotificationItem(notification, index);
//                 }).toList(),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   // สร้าง Widget สำหรับแสดงรายการแจ้งเตือนแต่ละรายการ
//   Widget _buildNotificationItem(NotificationModel notification, int index) {
//     return Dismissible(
//       key: Key('notification_${notification.id}_$index'),
//       background: Container(
//         color: Colors.red,
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: 20),
//         child: const Icon(
//           Icons.delete,
//           color: Colors.white,
//         ),
//       ),
//       direction: DismissDirection.endToStart,
//       onDismissed: (direction) {
//         _deleteNotification(notification.id);
//       },
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => NotificationDialog(
//                 notificationData: {
//                   'id': notification.id,
//                   'title': notification.title,
//                   'body': notification.body,
//                   'timestamp': notification.timestamp,
//                   'data': notification.data,
//                 },
//               ),
//             ),
//           ).then((_) {
//             // อัปเดตสถานะหลังจากดูรายละเอียด
//             setState(() {});
//           });
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             color: notification.isRead
//                 ? Colors.transparent
//                 : Colors.blue.withOpacity(0.1),
//             border: Border(
//               bottom: BorderSide(
//                 color: Colors.grey.withOpacity(0.2),
//                 width: 0.5,
//               ),
//             ),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ไอคอนสถานะการอ่าน
//               Container(
//                 width: 12,
//                 height: 12,
//                 margin: const EdgeInsets.only(top: 4, right: 12),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: notification.isRead ? Colors.transparent : Colors.blue,
//                   border: Border.all(
//                     color: notification.isRead ? Colors.grey : Colors.blue,
//                     width: notification.isRead ? 1 : 0,
//                   ),
//                 ),
//               ),

//               // เนื้อหาการแจ้งเตือน
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       notification.title ?? 'ไม่มีหัวข้อ',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: notification.isRead
//                             ? FontWeight.normal
//                             : FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     if (notification.body != null &&
//                         notification.body!.isNotEmpty) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         notification.body!,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.white70,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                     const SizedBox(height: 4),
//                     Text(
//                       _formatTime(notification.timestamp),
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.white38,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // ป้ายหมวดหมู่ (ถ้ามี)
//               if (notification.category != 'general')
//                 Container(
//                   margin: const EdgeInsets.only(left: 8),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: _getCategoryColor(notification.category),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     _getCategoryLabel(notification.category),
//                     style: const TextStyle(
//                       fontSize: 10,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // แปลงเวลาเป็นรูปแบบที่อ่านง่าย
//   String _formatTime(int timestamp) {
//     final now = DateTime.now();
//     final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
//     final difference = now.difference(dateTime);

//     if (difference.inDays == 0) {
//       if (difference.inHours == 0) {
//         if (difference.inMinutes == 0) {
//           return 'เมื่อสักครู่';
//         }
//         return '${difference.inMinutes} นาทีที่แล้ว';
//       }
//       return '${difference.inHours} ชั่วโมงที่แล้ว';
//     } else if (difference.inDays == 1) {
//       return 'เมื่อวาน';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays} วันที่แล้ว';
//     }

//     return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
//   }

//   // รับสีตามหมวดหมู่
//   Color _getCategoryColor(String category) {
//     switch (category) {
//       case 'update':
//         return Colors.green;
//       case 'news':
//         return Colors.orange;
//       case 'promotion':
//         return Colors.purple;
//       case 'alert':
//         return Colors.red;
//       case 'test':
//         return Colors.blue;
//       default:
//         return Colors.grey;
//     }
//   }

//   // รับชื่อหมวดหมู่ภาษาไทย
//   String _getCategoryLabel(String category) {
//     switch (category) {
//       case 'update':
//         return 'อัปเดต';
//       case 'news':
//         return 'ข่าวสาร';
//       case 'promotion':
//         return 'โปรโมชัน';
//       case 'alert':
//         return 'แจ้งเตือน';
//       case 'test':
//         return 'ทดสอบ';
//       default:
//         return 'ทั่วไป';
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Home/notification_dialog.dart';
import '../models/notification_model.dart';
import '../services/notification_manager.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'all'; // ตัวกรองหมวดหมู่
  String _sortBy = 'newest'; // ตัวเรียงลำดับ
  bool _isLoading = false;
  String? _errorMessage;

  // แคชสำหรับการแจ้งเตือน
  List<NotificationModel>? _notificationsCache;

  // TabController สำหรับควบคุมแท็บ
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  // โหลดข้อมูลการแจ้งเตือน
  Future<void> _loadNotifications() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifications = await NotificationManager.getAllNotifications();

      if (mounted) {
        setState(() {
          _notificationsCache = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ เกิดข้อผิดพลาดในการโหลดการแจ้งเตือน: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'ไม่สามารถโหลดการแจ้งเตือนได้ กรุณาลองใหม่อีกครั้ง';
          _isLoading = false;
        });
      }
    }
  }

  // จัดการเมื่อมีการเปลี่ยนแท็บ
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      // เปลี่ยนแท็บเสร็จแล้ว ให้อัปเดต UI
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // แบ่งเป็น 3 แท็บ: ทั้งหมด, ยังไม่อ่าน, อ่านแล้ว
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            'การแจ้งเตือน',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(text: 'ทั้งหมด'),
              Tab(text: 'ยังไม่อ่าน'),
              Tab(text: 'อ่านแล้ว'),
            ],
          ),
          actions: [
            // ปุ่มรีเฟรช
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                // ล้างแคชและโหลดข้อมูลใหม่
                NotificationManager.clearCache();
                _loadNotifications();
              },
            ),
            // ปุ่มสำหรับการกรอง
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: _showFilterOptions,
            ),
            // ปุ่มสำหรับทำเครื่องหมายว่าอ่านทั้งหมด
            IconButton(
              icon: const Icon(Icons.done_all, color: Colors.white),
              onPressed: _markAllAsRead,
            ),
            // ปุ่มเมนูเพิ่มเติม
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'create_test') {
                  _createTestNotification();
                } else if (value == 'delete_all') {
                  _resetNotifications();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'create_test',
                  child: Row(
                    children: [
                      Icon(Icons.add_alert, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('สร้างการแจ้งเตือนทดสอบ'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, color: Colors.red),
                      SizedBox(width: 8),
                      Text('ลบการแจ้งเตือนทั้งหมด'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildNotificationList(null), // ทั้งหมด
            _buildNotificationList(false), // ยังไม่อ่าน
            _buildNotificationList(true), // อ่านแล้ว
          ],
        ),
      ),
    );
  }

  // สร้างการแจ้งเตือนทดสอบ
  void _createTestNotification() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await NotificationManager.saveCustomNotification(
        title: "การแจ้งเตือนทดสอบ",
        body:
            "นี่คือการแจ้งเตือนทดสอบที่สร้างเมื่อ ${DateTime.now().toString()}",
        category: "test",
        priority: "high",
      );

      // รีเฟรชข้อมูล
      await _loadNotifications();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('สร้างการแจ้งเตือนทดสอบสำเร็จ'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ เกิดข้อผิดพลาดในการสร้างการแจ้งเตือนทดสอบ: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // ลบการแจ้งเตือนทั้งหมด
  Future<void> _resetNotifications() async {
    // แสดงไดอะล็อกยืนยัน
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
              'ยืนยันการลบ',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'คุณต้องการลบการแจ้งเตือนทั้งหมดใช่หรือไม่? การกระทำนี้ไม่สามารถย้อนกลับได้',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('ยกเลิก',
                    style: TextStyle(color: Colors.white70)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                ),
                child: const Text('ลบทั้งหมด'),
              ),
            ],
          ),
        ) ??
        false;

    // ถ้าผู้ใช้ยืนยัน ให้ดำเนินการลบ
    if (confirmed) {
      setState(() {
        _isLoading = true;
      });

      try {
        await NotificationManager.deleteAllNotifications();

        // รีเฟรชข้อมูล
        await _loadNotifications();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ล้างข้อมูลการแจ้งเตือนทั้งหมดแล้ว'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('❌ เกิดข้อผิดพลาดในการลบการแจ้งเตือนทั้งหมด: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'ไม่สามารถลบการแจ้งเตือนทั้งหมดได้';
          });
        }
      }
    }
  }

  // ทำเครื่องหมายว่าอ่านทั้งหมด
  Future<void> _markAllAsRead() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await NotificationManager.markAllAsRead();

      // รีเฟรชข้อมูล
      await _loadNotifications();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ทำเครื่องหมายการแจ้งเตือนทั้งหมดว่าอ่านแล้ว'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ เกิดข้อผิดพลาดในการทำเครื่องหมายว่าอ่านทั้งหมด: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'ไม่สามารถทำเครื่องหมายว่าอ่านทั้งหมดได้';
        });
      }
    }
  }

  // ลบการแจ้งเตือน
  Future<void> _deleteNotification(String id) async {
    try {
      // ลบการแจ้งเตือน
      await NotificationManager.deleteNotification(id);

      // อัปเดตแคชข้อมูล
      if (_notificationsCache != null) {
        setState(() {
          _notificationsCache!
              .removeWhere((notification) => notification.id == id);
        });
      }
    } catch (e) {
      print('❌ เกิดข้อผิดพลาดในการลบการแจ้งเตือน: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่สามารถลบการแจ้งเตือนได้: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // แสดงตัวเลือกในการกรอง
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'กรองและเรียงลำดับ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // หมวดหมู่
                  const Text(
                    'หมวดหมู่',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _filterChip('ทั้งหมด', 'all', setState),
                      _filterChip('ทั่วไป', 'general', setState),
                      _filterChip('อัปเดต', 'update', setState),
                      _filterChip('ข่าวสาร', 'news', setState),
                      _filterChip('ทดสอบ', 'test', setState),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // เรียงลำดับ
                  const Text(
                    'เรียงลำดับ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _sortChip('ล่าสุด', 'newest', setState),
                      _sortChip('เก่าสุด', 'oldest', setState),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ปุ่มนำไปใช้
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        // refresh UI
                        this.setState(() {});
                      },
                      child: const Text(
                        'นำไปใช้',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      // รีเฟรชหน้าจอเมื่อปิดการกรอง
      setState(() {});
    });
  }

  // สร้าง Chip สำหรับกรอง
  Widget _filterChip(String label, String value, StateSetter setState) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: _selectedCategory == value ? Colors.white : Colors.white70,
        ),
      ),
      selected: _selectedCategory == value,
      selectedColor: Colors.blue,
      backgroundColor: Colors.grey[800],
      checkmarkColor: Colors.white,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = value;
        });
        this.setState(() {});
      },
    );
  }

  // สร้าง Chip สำหรับเรียงลำดับ
  Widget _sortChip(String label, String value, StateSetter setState) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: _sortBy == value ? Colors.white : Colors.white70,
        ),
      ),
      selected: _sortBy == value,
      selectedColor: Colors.blue,
      backgroundColor: Colors.grey[800],
      checkmarkColor: Colors.white,
      onSelected: (selected) {
        setState(() {
          _sortBy = value;
        });
        this.setState(() {});
      },
    );
  }

  // กรองและเรียงลำดับรายการแจ้งเตือน
  List<NotificationModel> _filterAndSortNotifications(
      List<NotificationModel> notifications, bool? isRead) {
    // 1. กรองตามสถานะการอ่าน
    var filtered = isRead == null
        ? notifications
        : notifications.where((item) => item.isRead == isRead).toList();

    // 2. กรองตามหมวดหมู่
    if (_selectedCategory != 'all') {
      filtered =
          filtered.where((item) => item.category == _selectedCategory).toList();
    }

    // 3. เรียงลำดับ
    if (_sortBy == 'newest') {
      filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } else {
      filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }

    return filtered;
  }

  // สร้าง Widget สำหรับแสดงรายการแจ้งเตือน
  Widget _buildNotificationList(bool? isRead) {
    if (_isLoading && _notificationsCache == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_errorMessage != null && _notificationsCache == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }

    // ใช้ข้อมูลจากแคช
    final notifications = _notificationsCache ?? [];
    final filteredNotifications =
        _filterAndSortNotifications(notifications, isRead);

    if (filteredNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isRead == null
                  ? Icons.notifications_off_outlined
                  : isRead
                      ? Icons.mark_email_read_outlined
                      : Icons.mark_email_unread_outlined,
              color: Colors.white54,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              isRead == null
                  ? 'ไม่มีการแจ้งเตือน'
                  : isRead
                      ? 'ไม่มีการแจ้งเตือนที่อ่านแล้ว'
                      : 'ไม่มีการแจ้งเตือนที่ยังไม่ได้อ่าน',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            if (_selectedCategory != 'all') ...[
              const SizedBox(height: 8),
              Text(
                'กำลังกรองตามหมวดหมู่: ${_getCategoryLabel(_selectedCategory)}',
                style: const TextStyle(color: Colors.white38, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _showFilterOptions,
                icon: const Icon(Icons.filter_alt_off, size: 16),
                label: const Text('ล้างตัวกรอง'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
              ),
            ],
          ],
        ),
      );
    }

    // จัดกลุ่มตามวันที่
    final Map<String, List<NotificationModel>> groupedNotifications = {};
    for (var notification in filteredNotifications) {
      final date = DateTime.fromMillisecondsSinceEpoch(notification.timestamp);
      final dateString = DateFormat('dd/MM/yyyy').format(date);

      if (!groupedNotifications.containsKey(dateString)) {
        groupedNotifications[dateString] = [];
      }
      groupedNotifications[dateString]!.add(notification);
    }

    // เรียงลำดับวันที่
    final sortedDates = groupedNotifications.keys.toList();
    if (_sortBy == 'newest') {
      sortedDates.sort((a, b) => b.compareTo(a));
    } else {
      sortedDates.sort((a, b) => a.compareTo(b));
    }

    // แสดงผลในรูปแบบ ListView
    return RefreshIndicator(
      onRefresh: () async {
        // ล้างแคชและโหลดข้อมูลใหม่
        NotificationManager.clearCache();
        await _loadNotifications();
      },
      color: Colors.blue,
      backgroundColor: Colors.grey[900],
      child: Stack(
        children: [
          ListView.builder(
            itemCount: sortedDates.length,
            padding: const EdgeInsets.only(bottom: 32),
            itemBuilder: (context, groupIndex) {
              final dateString = sortedDates[groupIndex];
              final notificationsForDate = groupedNotifications[dateString]!;

              return Column(
                key: Key('date_group_$dateString'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.grey[900],
                    child: Text(
                      dateString,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  ...notificationsForDate.asMap().entries.map((entry) {
                    int index = entry.key;
                    NotificationModel notification = entry.value;
                    return _buildNotificationItem(notification, index);
                  }).toList(),
                ],
              );
            },
          ),
          if (_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                child: const LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // สร้าง Widget สำหรับแสดงรายการแจ้งเตือนแต่ละรายการ
  Widget _buildNotificationItem(NotificationModel notification, int index) {
    return Dismissible(
      key: Key('notification_${notification.id}_$index'),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(notification.id);
      },
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationDialog(
                notificationData: {
                  'id': notification.id,
                  'title': notification.title,
                  'body': notification.body,
                  'timestamp': notification.timestamp,
                  'data': notification.data,
                },
              ),
            ),
          ).then((_) {
            // อัปเดตสถานะหลังจากดูรายละเอียด
            _loadNotifications();
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.transparent
                : Colors.blue.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 0.5,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ไอคอนสถานะการอ่าน
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 4, right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: notification.isRead ? Colors.transparent : Colors.blue,
                  border: Border.all(
                    color: notification.isRead ? Colors.grey : Colors.blue,
                    width: notification.isRead ? 1 : 0,
                  ),
                ),
              ),

              // เนื้อหาการแจ้งเตือน
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title ?? 'ไม่มีหัวข้อ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (notification.body != null &&
                        notification.body!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        notification.body!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(notification.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),

              // ป้ายหมวดหมู่ (ถ้ามี)
              if (notification.category != 'general')
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(notification.category),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getCategoryLabel(notification.category),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // รับชื่อหมวดหมู่ภาษาไทย
  String _getCategoryLabel(String category) {
    switch (category) {
      case 'update':
        return 'อัปเดต';
      case 'news':
        return 'ข่าวสาร';
      case 'promotion':
        return 'โปรโมชัน';
      case 'alert':
        return 'แจ้งเตือน';
      case 'test':
        return 'ทดสอบ';
      default:
        return 'ทั่วไป';
    }
  }

// รับสีตามหมวดหมู่
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'update':
        return Colors.green;
      case 'news':
        return Colors.orange;
      case 'promotion':
        return Colors.purple;
      case 'alert':
        return Colors.red;
      case 'test':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // แปลงเวลาเป็นรูปแบบที่อ่านง่าย
  String _formatTime(int timestamp) {
    final now = DateTime.now();
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'เมื่อสักครู่';
        }
        return '${difference.inMinutes} นาทีที่แล้ว';
      }
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inDays == 1) {
      return 'เมื่อวาน';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} วันที่แล้ว';
    }

    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
}

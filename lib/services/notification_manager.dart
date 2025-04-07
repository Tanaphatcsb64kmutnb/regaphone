// // import 'dart:convert';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../models/notification_model.dart';

// // class NotificationManager {
// //   // รับการแจ้งเตือนทั้งหมด
// //   static Future<List<NotificationModel>> getAllNotifications() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final notificationsJson = prefs.getString('notifications') ?? '[]';
// //     final notifications = List<Map<String, dynamic>>.from(
// //         jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

// //     return notifications
// //         .map((json) => NotificationModel.fromJson(json))
// //         .toList();
// //   }

// //   // รับการแจ้งเตือนที่ยังไม่ได้อ่าน
// //   static Future<List<NotificationModel>> getUnreadNotifications() async {
// //     final notifications = await getAllNotifications();
// //     return notifications.where((notification) => !notification.isRead).toList();
// //   }

// //   // รับจำนวนการแจ้งเตือนที่ยังไม่ได้อ่าน
// //   static Future<int> getUnreadCount() async {
// //     final unreadNotifications = await getUnreadNotifications();
// //     return unreadNotifications.length;
// //   }

// //   // บันทึกการแจ้งเตือนใหม่
// //   static Future<void> saveNotification(RemoteMessage message) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final notificationsJson = prefs.getString('notifications') ?? '[]';
// //     final notifications = List<Map<String, dynamic>>.from(
// //         jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

// //     // สร้าง unique ID
// //     final notificationId = DateTime.now().millisecondsSinceEpoch.toString();

// //     // เพิ่มการแจ้งเตือนใหม่
// //     notifications.insert(0, {
// //       'id': notificationId,
// //       'title': message.notification?.title,
// //       'body': message.notification?.body,
// //       'timestamp': DateTime.now().millisecondsSinceEpoch,
// //       'data': message.data,
// //       'isRead': false,
// //       'category': message.data['category'] ?? 'general',
// //       'priority': message.data['priority'] ?? 'normal',
// //     });

// //     // ถ้ามีการแจ้งเตือนมากเกินไป ให้ลบเก่าออก
// //     if (notifications.length > 100) {
// //       notifications.removeRange(100, notifications.length);
// //     }

// //     // บันทึกกลับ
// //     await prefs.setString('notifications', jsonEncode(notifications));
// //   }

// //   // ทำเครื่องหมายว่าอ่านแล้ว
// //   static Future<void> markAsRead(String notificationId) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final notificationsJson = prefs.getString('notifications') ?? '[]';
// //     final notifications = List<Map<String, dynamic>>.from(
// //         jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

// //     bool updated = false;
// //     for (var i = 0; i < notifications.length; i++) {
// //       if (notifications[i]['id'] == notificationId) {
// //         notifications[i]['isRead'] = true;
// //         updated = true;
// //         break;
// //       }
// //     }

// //     if (updated) {
// //       await prefs.setString('notifications', jsonEncode(notifications));
// //     }
// //   }

// //   // ทำเครื่องหมายว่าอ่านทั้งหมด
// //   static Future<void> markAllAsRead() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final notificationsJson = prefs.getString('notifications') ?? '[]';
// //     final notifications = List<Map<String, dynamic>>.from(
// //         jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

// //     bool hasUpdates = false;
// //     for (var i = 0; i < notifications.length; i++) {
// //       if (notifications[i]['isRead'] == false) {
// //         notifications[i]['isRead'] = true;
// //         hasUpdates = true;
// //       }
// //     }

// //     if (hasUpdates) {
// //       await prefs.setString('notifications', jsonEncode(notifications));
// //     }
// //   }

// //   // ลบการแจ้งเตือน
// //   static Future<void> deleteNotification(String notificationId) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final notificationsJson = prefs.getString('notifications') ?? '[]';
// //     final notifications = List<Map<String, dynamic>>.from(
// //         jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

// //     notifications
// //         .removeWhere((notification) => notification['id'] == notificationId);

// //     await prefs.setString('notifications', jsonEncode(notifications));
// //   }

// //   // ลบการแจ้งเตือนทั้งหมด
// //   static Future<void> deleteAllNotifications() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     await prefs.setString('notifications', '[]');
// //   }

// //   // อัปเดตการแจ้งเตือนที่มีอยู่ในรายการแล้ว
// //   static Future<void> updateNotification(NotificationModel notification) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final notificationsJson = prefs.getString('notifications') ?? '[]';
// //     final notifications = List<Map<String, dynamic>>.from(
// //         jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

// //     bool updated = false;
// //     for (var i = 0; i < notifications.length; i++) {
// //       if (notifications[i]['id'] == notification.id) {
// //         notifications[i] = notification.toJson();
// //         updated = true;
// //         break;
// //       }
// //     }

// //     if (updated) {
// //       await prefs.setString('notifications', jsonEncode(notifications));
// //     }
// //   }

// //   // บันทึกข้อมูลการแจ้งเตือนใหม่แบบกำหนดค่าเอง
// //   static Future<void> saveCustomNotification({
// //     required String title,
// //     required String body,
// //     String category = 'general',
// //     String priority = 'normal',
// //     Map<String, dynamic>? additionalData,
// //   }) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final notificationsJson = prefs.getString('notifications') ?? '[]';
// //     final notifications = List<Map<String, dynamic>>.from(
// //         jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

// //     // สร้าง unique ID
// //     final notificationId = DateTime.now().millisecondsSinceEpoch.toString();

// //     // เพิ่มการแจ้งเตือนใหม่
// //     notifications.insert(0, {
// //       'id': notificationId,
// //       'title': title,
// //       'body': body,
// //       'timestamp': DateTime.now().millisecondsSinceEpoch,
// //       'data': additionalData ?? {},
// //       'isRead': false,
// //       'category': category,
// //       'priority': priority,
// //     });

// //     // ถ้ามีการแจ้งเตือนมากเกินไป ให้ลบเก่าออก
// //     if (notifications.length > 100) {
// //       notifications.removeRange(100, notifications.length);
// //     }

// //     // บันทึกกลับ
// //     await prefs.setString('notifications', jsonEncode(notifications));
// //   }
// // }

// import 'dart:convert';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/notification_model.dart';

// class NotificationManager {
//   // รับการแจ้งเตือนทั้งหมดจาก SharedPreferences
//   static Future<List<NotificationModel>> getAllNotifications() async {
//     final prefs = await SharedPreferences.getInstance();
//     final notificationsJson = prefs.getString('notifications') ?? '[]';
//     final notifications = List<Map<String, dynamic>>.from(
//         jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

//     return notifications
//         .map((json) => NotificationModel.fromJson(json))
//         .toList();
//   }

//   // รับการแจ้งเตือนทั้งหมดจาก Firestore
//   static Future<List<NotificationModel>>
//       getAllNotificationsFromFirestore() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return []; // ต้องล็อกอินก่อน

//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('notifications')
//           .orderBy('timestamp', descending: true)
//           .get();

//       return querySnapshot.docs.map((doc) {
//         final data = doc.data();
//         // แปลง timestamp จาก Firestore เป็น int
//         if (data['timestamp'] is Timestamp) {
//           data['timestamp'] =
//               (data['timestamp'] as Timestamp).millisecondsSinceEpoch;
//         }
//         return NotificationModel.fromJson(data);
//       }).toList();
//     } catch (e) {
//       print('❌ เกิดข้อผิดพลาดในการดึงข้อมูลจาก Firestore: $e');
//       return [];
//     }
//   }

//   // รับการแจ้งเตือนที่ยังไม่ได้อ่าน
//   static Future<List<NotificationModel>> getUnreadNotifications() async {
//     final notifications = await getAllNotifications();
//     return notifications.where((notification) => !notification.isRead).toList();
//   }

//   // รับจำนวนการแจ้งเตือนที่ยังไม่ได้อ่าน
//   static Future<int> getUnreadCount() async {
//     final unreadNotifications = await getUnreadNotifications();
//     return unreadNotifications.length;
//   }

//   // แก้ไขใน notification_manager.dart
//   static Future<void> saveNotification(RemoteMessage message) async {
//     try {
//       print('🔔 เริ่มบันทึกการแจ้งเตือน: ${message.notification?.title}');

//       // สร้าง unique ID
//       final notificationId = DateTime.now().millisecondsSinceEpoch.toString();

//       // บันทึกลง SharedPreferences
//       await _saveToLocalStorage(message, notificationId);

//       // บันทึกลง Firestore
//       await saveNotificationToFirestore(message, notificationId);

//       print('✅ บันทึกการแจ้งเตือนสำเร็จทั้ง Local และ Firestore');
//     } catch (e) {
//       print('❌ เกิดข้อผิดพลาดในการบันทึกการแจ้งเตือน: $e');
//     }
//   }

// // แก้ไข _saveToLocalStorage รับ notificationId เพิ่ม
//   static Future<void> _saveToLocalStorage(
//       RemoteMessage message, String notificationId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final notificationsJson = prefs.getString('notifications') ?? '[]';
//     final notifications = List<Map<String, dynamic>>.from(
//         jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

//     // เพิ่มการแจ้งเตือนใหม่
//     notifications.insert(0, {
//       'id': notificationId,
//       'title': message.notification?.title,
//       'body': message.notification?.body,
//       'timestamp': DateTime.now().millisecondsSinceEpoch,
//       'data': message.data,
//       'isRead': false,
//       'category': message.data['category'] ?? 'general',
//       'priority': message.data['priority'] ?? 'normal',
//     });

//     // ถ้ามีการแจ้งเตือนมากเกินไป ให้ลบเก่าออก
//     if (notifications.length > 100) {
//       notifications.removeRange(100, notifications.length);
//     }

//     // บันทึกกลับ
//     await prefs.setString('notifications', jsonEncode(notifications));
//     print('✅ บันทึกการแจ้งเตือนลง SharedPreferences สำเร็จ');
//   }

// // แก้ไข saveNotificationToFirestore รับ notificationId เพิ่ม
//   static Future<void> saveNotificationToFirestore(
//       RemoteMessage message, String notificationId) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         print('⚠️ ไม่สามารถบันทึกการแจ้งเตือนลง Firestore: ไม่พบข้อมูลผู้ใช้');
//         return;
//       }

//       // สร้างข้อมูลการแจ้งเตือน
//       final notificationData = {
//         'id': notificationId,
//         'title': message.notification?.title,
//         'body': message.notification?.body,
//         'timestamp': FieldValue.serverTimestamp(),
//         'data': message.data,
//         'isRead': false,
//         'category': message.data['category'] ?? 'general',
//         'priority': message.data['priority'] ?? 'normal',
//         'deviceId': await _getDeviceId(),
//       };

//       // ใช้ document ID เป็น notificationId
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('notifications')
//           .doc(notificationId)
//           .set(notificationData);

//       print('✅ บันทึกการแจ้งเตือนลง Firestore สำเร็จ');
//     } catch (e) {
//       print('❌ เกิดข้อผิดพลาดในการบันทึกการแจ้งเตือนลง Firestore: $e');
//     }
//   }

//   // ดึงหรือสร้าง Device ID
//   static Future<String> _getDeviceId() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? deviceId = prefs.getString('device_id');

//     if (deviceId == null) {
//       deviceId = DateTime.now().millisecondsSinceEpoch.toString();
//       await prefs.setString('device_id', deviceId);
//     }

//     return deviceId;
//   }

//   // ทำเครื่องหมายว่าอ่านแล้ว
//   static Future<void> markAsRead(String notificationId) async {
//     try {
//       // อัปเดตใน SharedPreferences
//       await _markAsReadInLocalStorage(notificationId);

//       // อัปเดตใน Firestore
//       await _markAsReadInFirestore(notificationId);
//     } catch (e) {
//       print('❌ เกิดข้อผิดพลาดในการทำเครื่องหมายว่าอ่านแล้ว: $e');
//     }
//   }

//   // ทำเครื่องหมายว่าอ่านแล้วใน SharedPreferences
//   static Future<void> _markAsReadInLocalStorage(String notificationId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final notificationsJson = prefs.getString('notifications') ?? '[]';
//     final notifications = List<Map<String, dynamic>>.from(
//         jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

//     bool updated = false;
//     for (var i = 0; i < notifications.length; i++) {
//       if (notifications[i]['id'] == notificationId) {
//         notifications[i]['isRead'] = true;
//         updated = true;
//         break;
//       }
//     }

//     if (updated) {
//       await prefs.setString('notifications', jsonEncode(notifications));
//       print('✅ ทำเครื่องหมายว่าอ่านแล้วใน SharedPreferences สำเร็จ');
//     }
//   }

//   // ทำเครื่องหมายว่าอ่านแล้วใน Firestore
//   static Future<void> _markAsReadInFirestore(String notificationId) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;

//       // ค้นหา document ที่มี id ตรงกัน
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('notifications')
//           .where('id', isEqualTo: notificationId)
//           .limit(1)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         final docId = querySnapshot.docs.first.id;
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .collection('notifications')
//             .doc(docId)
//             .update({'isRead': true});

//         print('✅ ทำเครื่องหมายว่าอ่านแล้วใน Firestore สำเร็จ');
//       }
//     } catch (e) {
//       print('❌ เกิดข้อผิดพลาดในการทำเครื่องหมายว่าอ่านแล้วใน Firestore: $e');
//     }
//   }

//   // ทำเครื่องหมายว่าอ่านทั้งหมด
//   static Future<void> markAllAsRead() async {
//     try {
//       // อัปเดตใน SharedPreferences
//       await _markAllAsReadInLocalStorage();

//       // อัปเดตใน Firestore
//       await _markAllAsReadInFirestore();
//     } catch (e) {
//       print('❌ เกิดข้อผิดพลาดในการทำเครื่องหมายว่าอ่านทั้งหมด: $e');
//     }
//   }

//   // ทำเครื่องหมายว่าอ่านทั้งหมดใน SharedPreferences
//   static Future<void> _markAllAsReadInLocalStorage() async {
//     final prefs = await SharedPreferences.getInstance();
//     final notificationsJson = prefs.getString('notifications') ?? '[]';
//     final notifications = List<Map<String, dynamic>>.from(
//         jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

//     bool hasUpdates = false;
//     for (var i = 0; i < notifications.length; i++) {
//       if (notifications[i]['isRead'] == false) {
//         notifications[i]['isRead'] = true;
//         hasUpdates = true;
//       }
//     }

//     if (hasUpdates) {
//       await prefs.setString('notifications', jsonEncode(notifications));
//       print('✅ ทำเครื่องหมายว่าอ่านทั้งหมดใน SharedPreferences สำเร็จ');
//     }
//   }

//   // ทำเครื่องหมายว่าอ่านทั้งหมดใน Firestore
//   static Future<void> _markAllAsReadInFirestore() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;

//       // ดึงข้อมูลการแจ้งเตือนที่ยังไม่ได้อ่าน
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('notifications')
//           .where('isRead', isEqualTo: false)
//           .get();

//       // อัปเดตแต่ละรายการเป็นอ่านแล้ว
//       final batch = FirebaseFirestore.instance.batch();
//       for (var doc in querySnapshot.docs) {
//         batch.update(doc.reference, {'isRead': true});
//       }

//       // ทำการอัปเดตพร้อมกัน
//       if (querySnapshot.docs.isNotEmpty) {
//         await batch.commit();
//         print('✅ ทำเครื่องหมายว่าอ่านทั้งหมดใน Firestore สำเร็จ');
//       }
//     } catch (e) {
//       print('❌ เกิดข้อผิดพลาดในการทำเครื่องหมายว่าอ่านทั้งหมดใน Firestore: $e');
//     }
//   }

//   // ลบการแจ้งเตือน
//   static Future<void> deleteNotification(String notificationId) async {
//     try {
//       // ลบจาก SharedPreferences
//       await _deleteNotificationFromLocalStorage(notificationId);

//       // ลบจาก Firestore
//       await _deleteNotificationFromFirestore(notificationId);
//     } catch (e) {
//       print('❌ เกิดข้อผิดพลาดในการลบการแจ้งเตือน: $e');
//     }
//   }

//   // ลบการแจ้งเตือนจาก SharedPreferences
//   static Future<void> _deleteNotificationFromLocalStorage(
//       String notificationId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final notificationsJson = prefs.getString('notifications') ?? '[]';
//     final notifications = List<Map<String, dynamic>>.from(
//         jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

//     final initialLength = notifications.length;
//     notifications
//         .removeWhere((notification) => notification['id'] == notificationId);

//     if (notifications.length < initialLength) {
//       await prefs.setString('notifications', jsonEncode(notifications));
//       print('✅ ลบการแจ้งเตือนจาก SharedPreferences สำเร็จ');
//     }
//   }

//   // ลบการแจ้งเตือนจาก Firestore
//   static Future<void> _deleteNotificationFromFirestore(
//       String notificationId) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;

//       // ค้นหา document ที่มี id ตรงกัน
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('notifications')
//           .where('id', isEqualTo: notificationId)
//           .limit(1)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         final docId = querySnapshot.docs.first.id;
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .collection('notifications')
//             .doc(docId)
//             .delete();

//         print('✅ ลบการแจ้งเตือนจาก Firestore สำเร็จ');
//       }
//     } catch (e) {
//       print('❌ เกิดข้อผิดพลาดในการลบการแจ้งเตือนจาก Firestore: $e');
//     }
//   }

//   // ลบการแจ้งเตือนทั้งหมด
//   static Future<void> deleteAllNotifications() async {
//     try {
//       // ลบจาก SharedPreferences
//       await _deleteAllNotificationsFromLocalStorage();

//       // ลบจาก Firestore
//       await _deleteAllNotificationsFromFirestore();
//     } catch (e) {
//       print('❌ เกิดข้อผิดพลาดในการลบการแจ้งเตือนทั้งหมด: $e');
//     }
//   }

//   // ลบการแจ้งเตือนทั้งหมดจาก SharedPreferences
//   static Future<void> _deleteAllNotificationsFromLocalStorage() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('notifications', '[]');
//     print('✅ ลบการแจ้งเตือนทั้งหมดจาก SharedPreferences สำเร็จ');
//   }

//   // ลบการแจ้งเตือนทั้งหมดจาก Firestore
//   static Future<void> _deleteAllNotificationsFromFirestore() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;

//       // ดึงข้อมูลการแจ้งเตือนทั้งหมด
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('notifications')
//           .get();

//       // ลบแต่ละรายการ
//       final batch = FirebaseFirestore.instance.batch();
//       for (var doc in querySnapshot.docs) {
//         batch.delete(doc.reference);
//       }

//       // ทำการลบพร้อมกัน
//       if (querySnapshot.docs.isNotEmpty) {
//         await batch.commit();
//         print('✅ ลบการแจ้งเตือนทั้งหมดจาก Firestore สำเร็จ');
//       }
//     } catch (e) {
//       print('❌ เกิดข้อผิดพลาดในการลบการแจ้งเตือนทั้งหมดจาก Firestore: $e');
//     }
//   }

//   // อัปเดตการแจ้งเตือน
//   static Future<void> updateNotification(NotificationModel notification) async {
//     try {
//       // อัปเดตใน SharedPreferences
//       await _updateNotificationInLocalStorage(notification);

//       // อัปเดตใน Firestore
//       await _updateNotificationInFirestore(notification);
//     } catch (e) {
//       print('❌ เกิดข้อผิดพลาดในการอัปเดตการแจ้งเตือน: $e');
//     }
//   }

//   // อัปเดตการแจ้งเตือนใน SharedPreferences
//   static Future<void> _updateNotificationInLocalStorage(
//       NotificationModel notification) async {
//     final prefs = await SharedPreferences.getInstance();
//     final notificationsJson = prefs.getString('notifications') ?? '[]';
//     final notifications = List<Map<String, dynamic>>.from(
//         jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

//     bool updated = false;
//     for (var i = 0; i < notifications.length; i++) {
//       if (notifications[i]['id'] == notification.id) {
//         notifications[i] = notification.toJson();
//         updated = true;
//         break;
//       }
//     }

//     if (updated) {
//       await prefs.setString('notifications', jsonEncode(notifications));
//       print('✅ อัปเดตการแจ้งเตือนใน SharedPreferences สำเร็จ');
//     }
//   }

//   // อัปเดตการแจ้งเตือนใน Firestore
//   static Future<void> _updateNotificationInFirestore(
//       NotificationModel notification) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;

//       // ค้นหา document ที่มี id ตรงกัน
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('notifications')
//           .where('id', isEqualTo: notification.id)
//           .limit(1)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         final docId = querySnapshot.docs.first.id;
//         final data = notification.toJson();

//         // ปรับค่า timestamp ให้เป็น Timestamp ของ Firestore
//         if (data['timestamp'] is int) {
//           data['timestamp'] =
//               Timestamp.fromMillisecondsSinceEpoch(data['timestamp']);
//         }

//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .collection('notifications')
//             .doc(docId)
//             .update(data);

//         print('✅ อัปเดตการแจ้งเตือนใน Firestore สำเร็จ');
//       }
//     } catch (e) {
//       print('❌ เกิดข้อผิดพลาดในการอัปเดตการแจ้งเตือนใน Firestore: $e');
//     }
//   }

//   // บันทึกข้อมูลการแจ้งเตือนใหม่แบบกำหนดค่าเอง
//   static Future<void> saveCustomNotification({
//     required String title,
//     required String body,
//     String category = 'general',
//     String priority = 'normal',
//     Map<String, dynamic>? additionalData,
//   }) async {
//     try {
//       // สร้าง unique ID
//       final notificationId = DateTime.now().millisecondsSinceEpoch.toString();
//       final timestamp = DateTime.now().millisecondsSinceEpoch;

//       // สร้างข้อมูล notification
//       final notification = NotificationModel(
//         id: notificationId,
//         title: title,
//         body: body,
//         timestamp: timestamp,
//         data: additionalData ?? {},
//         isRead: false,
//         category: category,
//         priority: priority,
//       );

//       // บันทึกลง SharedPreferences
//       await _saveCustomNotificationToLocalStorage(notification);

//       // บันทึกลง Firestore
//       await _saveCustomNotificationToFirestore(notification);
//     } catch (e) {
//       print('❌ เกิดข้อผิดพลาดในการบันทึกการแจ้งเตือนแบบกำหนดค่าเอง: $e');
//     }
//   }

//   // บันทึกข้อมูลการแจ้งเตือนแบบกำหนดค่าเองลง SharedPreferences
//   static Future<void> _saveCustomNotificationToLocalStorage(
//       NotificationModel notification) async {
//     final prefs = await SharedPreferences.getInstance();
//     final notificationsJson = prefs.getString('notifications') ?? '[]';
//     final notifications = List<Map<String, dynamic>>.from(
//         jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

//     // เพิ่มการแจ้งเตือนใหม่
//     notifications.insert(0, notification.toJson());

//     // ถ้ามีการแจ้งเตือนมากเกินไป ให้ลบเก่าออก
//     if (notifications.length > 100) {
//       notifications.removeRange(100, notifications.length);
//     }

//     // บันทึกกลับ
//     await prefs.setString('notifications', jsonEncode(notifications));
//     print('✅ บันทึกการแจ้งเตือนแบบกำหนดค่าเองลง SharedPreferences สำเร็จ');
//   }

//   // บันทึกข้อมูลการแจ้งเตือนแบบกำหนดค่าเองลง Firestore
//   static Future<void> _saveCustomNotificationToFirestore(
//       NotificationModel notification) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         print('⚠️ ไม่สามารถบันทึกการแจ้งเตือนลง Firestore: ไม่พบข้อมูลผู้ใช้');
//         return;
//       }

//       // สร้าง ID ที่ไม่ซ้ำกันสำหรับ Firestore
//       final firestoreId = FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('notifications')
//           .doc()
//           .id;

//       // แปลงข้อมูลเป็น Map
//       final data = notification.toJson();

//       // ปรับค่า timestamp ให้เป็น Timestamp ของ Firestore
//       data['timestamp'] =
//           Timestamp.fromMillisecondsSinceEpoch(notification.timestamp);
//       data['deviceId'] = await _getDeviceId(); // เพิ่ม ID อุปกรณ์

//       // บันทึกลง Firestore
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('notifications')
//           .doc(firestoreId)
//           .set(data);

//       print('✅ บันทึกการแจ้งเตือนแบบกำหนดค่าเองลง Firestore สำเร็จ');
//     } catch (e) {
//       print(
//           '❌ เกิดข้อผิดพลาดในการบันทึกการแจ้งเตือนแบบกำหนดค่าเองลง Firestore: $e');
//     }
//   }

//   // ซิงค์ข้อมูลการแจ้งเตือนระหว่าง SharedPreferences และ Firestore
//   static Future<void> syncNotifications() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;

//       // ดึงข้อมูลจาก Firestore
//       final firestoreNotifications = await getAllNotificationsFromFirestore();

//       // ดึงข้อมูลจาก SharedPreferences
//       final localNotifications = await getAllNotifications();

//       // สร้าง Map เพื่อเปรียบเทียบข้อมูล
//       final Map<String, NotificationModel> localMap = {};
//       for (var notification in localNotifications) {
//         localMap[notification.id] = notification;
//       }

//       final Map<String, NotificationModel> firestoreMap = {};
//       for (var notification in firestoreNotifications) {
//         firestoreMap[notification.id] = notification;
//       }

//       // รวมการแจ้งเตือนทั้งหมด
//       final allNotificationIds = <String>{
//         ...localMap.keys,
//         ...firestoreMap.keys,
//       };

//       final List<NotificationModel> mergedNotifications = [];

//       for (var id in allNotificationIds) {
//         if (firestoreMap.containsKey(id) && localMap.containsKey(id)) {
//           // มีข้อมูลทั้งสองที่ ใช้ข้อมูลล่าสุด (ตาม timestamp)
//           final firestoreTimestamp = firestoreMap[id]!.timestamp;
//           final localTimestamp = localMap[id]!.timestamp;

//           if (firestoreTimestamp > localTimestamp) {
//             mergedNotifications.add(firestoreMap[id]!);
//           } else {
//             mergedNotifications.add(localMap[id]!);
//           }
//         } else if (firestoreMap.containsKey(id)) {
//           // มีข้อมูลเฉพาะใน Firestore
//           mergedNotifications.add(firestoreMap[id]!);
//         } else {
//           // มีข้อมูลเฉพาะใน SharedPreferences
//           mergedNotifications.add(localMap[id]!);
//         }
//       }

//       // เรียงลำดับตาม timestamp
//       mergedNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

//       // บันทึกลง SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('notifications',
//           jsonEncode(mergedNotifications.map((n) => n.toJson()).toList()));

//       print(
//           '✅ ซิงค์ข้อมูลการแจ้งเตือนสำเร็จ รวมทั้งหมด ${mergedNotifications.length} รายการ');
//     } catch (e) {
//       print('❌ เกิดข้อผิดพลาดในการซิงค์ข้อมูลการแจ้งเตือน: $e');
//     }
//   }
// }

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_model.dart';

class NotificationManager {
  // คีย์สำหรับเก็บข้อมูลใน SharedPreferences
  static const String _notificationsKey = 'notifications';

  // แคชสำหรับเก็บการแจ้งเตือน
  static List<NotificationModel>? _cachedNotifications;
  static DateTime? _lastFetchTime;
  static const int _cacheExpirySeconds = 30; // แคชจะหมดอายุหลังจาก 30 วินาที

  // บันทึกการแจ้งเตือนลงใน SharedPreferences
  static Future<void> saveNotification(RemoteMessage message) async {
    try {
      // สร้าง ID ที่ไม่ซ้ำกัน
      final notificationId = DateTime.now().millisecondsSinceEpoch.toString();

      // สร้าง NotificationModel จากข้อมูลใน RemoteMessage
      final notification = NotificationModel(
        id: notificationId,
        title: message.notification?.title,
        body: message.notification?.body,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        data: message.data,
        isRead: false,
        category: message.data['category'] ?? 'general',
        priority: message.data['priority'] ?? 'normal',
      );

      // ดึงข้อมูลการแจ้งเตือนทั้งหมดที่มีอยู่
      final notifications = await getAllNotifications();

      // เพิ่มการแจ้งเตือนใหม่ไปยังรายการ
      notifications.insert(0, notification);

      // ถ้ามีการแจ้งเตือนมากกว่า 100 รายการ ให้ลบรายการเก่าออก
      if (notifications.length > 100) {
        notifications.removeRange(100, notifications.length);
      }

      // แปลงรายการเป็น JSON และบันทึกลงใน SharedPreferences
      await _saveNotificationsToStorage(notifications);

      // อัปเดตแคช
      _cachedNotifications = notifications;
      _lastFetchTime = DateTime.now();

      // บันทึกลง Firestore ถ้าผู้ใช้ล็อกอินอยู่
      _saveToFirestoreIfLoggedIn(notification);

      print('✅ บันทึกการแจ้งเตือนเรียบร้อย: ${notification.title}');
    } catch (e) {
      print('❌ เกิดข้อผิดพลาดในการบันทึกการแจ้งเตือน: $e');
    }
  }

  // บันทึกการแจ้งเตือนที่สร้างภายในแอปเอง
  static Future<void> saveCustomNotification({
    required String title,
    required String body,
    String category = 'general',
    String priority = 'normal',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // สร้าง ID ที่ไม่ซ้ำกัน
      final notificationId = DateTime.now().millisecondsSinceEpoch.toString();

      // สร้าง NotificationModel
      final notification = NotificationModel(
        id: notificationId,
        title: title,
        body: body,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        data: additionalData ?? {},
        isRead: false,
        category: category,
        priority: priority,
      );

      // ดึงข้อมูลการแจ้งเตือนทั้งหมดที่มีอยู่
      final notifications = await getAllNotifications();

      // เพิ่มการแจ้งเตือนใหม่ไปยังรายการ
      notifications.insert(0, notification);

      // ถ้ามีการแจ้งเตือนมากกว่า 100 รายการ ให้ลบรายการเก่าออก
      if (notifications.length > 100) {
        notifications.removeRange(100, notifications.length);
      }

      // แปลงรายการเป็น JSON และบันทึกลงใน SharedPreferences
      await _saveNotificationsToStorage(notifications);

      // อัปเดตแคช
      _cachedNotifications = notifications;
      _lastFetchTime = DateTime.now();

      // บันทึกลง Firestore ถ้าผู้ใช้ล็อกอินอยู่
      _saveToFirestoreIfLoggedIn(notification);

      print('✅ บันทึกการแจ้งเตือนที่สร้างเองเรียบร้อย: $title');
    } catch (e) {
      print('❌ เกิดข้อผิดพลาดในการบันทึกการแจ้งเตือนที่สร้างเอง: $e');
      throw e; // ส่งต่อข้อผิดพลาดเพื่อให้ผู้เรียกใช้จัดการได้
    }
  }

  // ดึงข้อมูลการแจ้งเตือนทั้งหมดจาก SharedPreferences
  static Future<List<NotificationModel>> getAllNotifications() async {
    try {
      // ตรวจสอบว่ามีแคชและยังไม่หมดอายุหรือไม่
      if (_cachedNotifications != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!).inSeconds <
              _cacheExpirySeconds) {
        print(
            '📋 ใช้ข้อมูลแจ้งเตือนจากแคช (${_cachedNotifications!.length} รายการ)');
        return List.from(_cachedNotifications!);
      }

      // ถ้าไม่มีแคชหรือหมดอายุแล้ว ดึงจาก SharedPreferences
      print('📩 กำลังดึงข้อมูลการแจ้งเตือนจาก SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey) ?? '[]';
      final List<dynamic> decoded = jsonDecode(notificationsJson);

      // แปลง JSON เป็น NotificationModel
      final notifications = decoded
          .map((item) =>
              NotificationModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      // อัปเดตแคช
      _cachedNotifications = notifications;
      _lastFetchTime = DateTime.now();

      print(
          '✅ ดึงข้อมูลจาก SharedPreferences สำเร็จ: ${notifications.length} รายการ');
      return notifications;
    } catch (e) {
      print('❌ เกิดข้อผิดพลาดในการดึงข้อมูลการแจ้งเตือน: $e');
      // ส่งคืนรายการว่างในกรณีที่เกิดข้อผิดพลาด
      return [];
    }
  }

  // ดึงข้อมูลการแจ้งเตือนจาก Firestore
  static Future<List<NotificationModel>>
      getAllNotificationsFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return [];
      }

      print('📩 กำลังดึงข้อมูลการแจ้งเตือนจาก Firestore...');

      // ดึงข้อมูลจาก Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      // แปลงข้อมูลจาก Firestore เป็น NotificationModel
      final notifications = snapshot.docs
          .map((doc) => NotificationModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      print('✅ ดึงข้อมูลจาก Firestore สำเร็จ: ${notifications.length} รายการ');

      // อัปเดตแคช
      _cachedNotifications = notifications;
      _lastFetchTime = DateTime.now();

      return notifications;
    } catch (e) {
      print('❌ เกิดข้อผิดพลาดในการดึงข้อมูลจาก Firestore: $e');
      throw e;
    }
  }

  // ทำเครื่องหมายการแจ้งเตือนว่าอ่านแล้ว
  static Future<void> markAsRead(String id) async {
    try {
      // ดึงข้อมูลการแจ้งเตือนทั้งหมด
      final notifications = await getAllNotifications();
      bool updated = false;

      // ค้นหาและอัปเดตการแจ้งเตือนที่ตรงกับ ID
      for (var i = 0; i < notifications.length; i++) {
        if (notifications[i].id == id && !notifications[i].isRead) {
          notifications[i].isRead = true;
          updated = true;

          // อัปเดตใน Firestore ด้วย
          _updateNotificationInFirestore(notifications[i]);
        }
      }

      // บันทึกการเปลี่ยนแปลงถ้ามีการอัปเดต
      if (updated) {
        await _saveNotificationsToStorage(notifications);

        // อัปเดตแคช
        _cachedNotifications = notifications;
      }
    } catch (e) {
      print('❌ เกิดข้อผิดพลาดในการทำเครื่องหมายว่าอ่านแล้ว: $e');
    }
  }

  // ทำเครื่องหมายการแจ้งเตือนทั้งหมดว่าอ่านแล้ว
  static Future<void> markAllAsRead() async {
    try {
      // ดึงข้อมูลการแจ้งเตือนทั้งหมด
      final notifications = await getAllNotifications();
      bool updated = false;

      // ทำเครื่องหมายว่าอ่านแล้วทั้งหมด
      for (var i = 0; i < notifications.length; i++) {
        if (!notifications[i].isRead) {
          notifications[i].isRead = true;
          updated = true;

          // อัปเดตใน Firestore ด้วย
          _updateNotificationInFirestore(notifications[i]);
        }
      }

      // บันทึกการเปลี่ยนแปลงถ้ามีการอัปเดต
      if (updated) {
        await _saveNotificationsToStorage(notifications);

        // อัปเดตแคช
        _cachedNotifications = notifications;
      }

      print('✅ ทำเครื่องหมายการแจ้งเตือนทั้งหมดว่าอ่านแล้ว');
    } catch (e) {
      print('❌ เกิดข้อผิดพลาดในการทำเครื่องหมายว่าอ่านทั้งหมด: $e');
      throw e;
    }
  }

  // ลบการแจ้งเตือน
  static Future<void> deleteNotification(String id) async {
    try {
      // ดึงข้อมูลการแจ้งเตือนทั้งหมด
      final notifications = await getAllNotifications();

      // ค้นหาและลบการแจ้งเตือนที่ตรงกับ ID
      notifications.removeWhere((notification) => notification.id == id);

      // บันทึกการเปลี่ยนแปลง
      await _saveNotificationsToStorage(notifications);

      // อัปเดตแคช
      _cachedNotifications = notifications;

      // ลบจาก Firestore ด้วย
      _deleteNotificationFromFirestore(id);

      print('✅ ลบการแจ้งเตือนเรียบร้อย: ID $id');
    } catch (e) {
      print('❌ เกิดข้อผิดพลาดในการลบการแจ้งเตือน: $e');
      throw e;
    }
  }

  // ลบการแจ้งเตือนทั้งหมด
  static Future<void> deleteAllNotifications() async {
    try {
      // บันทึกรายการว่างลงใน SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_notificationsKey, '[]');

      // ล้างแคช
      _cachedNotifications = [];
      _lastFetchTime = DateTime.now();

      // ลบจาก Firestore ด้วย
      _deleteAllNotificationsFromFirestore();

      print('✅ ลบการแจ้งเตือนทั้งหมดเรียบร้อย');
    } catch (e) {
      print('❌ เกิดข้อผิดพลาดในการลบการแจ้งเตือนทั้งหมด: $e');
      throw e;
    }
  }

  // ล้างแคชการแจ้งเตือน
  static void clearCache() {
    _cachedNotifications = null;
    _lastFetchTime = null;
    print('🧹 ล้างแคชการแจ้งเตือนเรียบร้อย');
  }

  // ตรวจสอบว่ามีการแจ้งเตือนที่ยังไม่ได้อ่านหรือไม่
  static Future<bool> hasUnreadNotifications() async {
    final notifications = await getAllNotifications();
    return notifications.any((notification) => !notification.isRead);
  }

  // นับจำนวนการแจ้งเตือนที่ยังไม่ได้อ่าน
  static Future<int> countUnreadNotifications() async {
    final notifications = await getAllNotifications();
    return notifications.where((notification) => !notification.isRead).length;
  }

  // ----- ฟังก์ชันภายใน -----

  // บันทึกรายการการแจ้งเตือนลงใน SharedPreferences
  static Future<void> _saveNotificationsToStorage(
      List<NotificationModel> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList =
        notifications.map((notification) => notification.toJson()).toList();
    await prefs.setString(_notificationsKey, jsonEncode(jsonList));
  }

  // บันทึกการแจ้งเตือนลง Firestore ถ้าผู้ใช้ล็อกอินอยู่
  static Future<void> _saveToFirestoreIfLoggedIn(
      NotificationModel notification) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc(notification.id)
            .set(notification.toJson());
      }
    } catch (e) {
      print('⚠️ ไม่สามารถบันทึกการแจ้งเตือนลง Firestore: $e');
      // ไม่ throw exception เพื่อให้แอปทำงานต่อไปได้แม้ Firestore จะมีปัญหา
    }
  }

  // อัปเดตการแจ้งเตือนใน Firestore
  static Future<void> _updateNotificationInFirestore(
      NotificationModel notification) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc(notification.id)
            .update({'isRead': notification.isRead});
      }
    } catch (e) {
      print('⚠️ ไม่สามารถอัปเดตการแจ้งเตือนใน Firestore: $e');
    }
  }

  // ลบการแจ้งเตือนจาก Firestore
  static Future<void> _deleteNotificationFromFirestore(String id) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc(id)
            .delete();
      }
    } catch (e) {
      print('⚠️ ไม่สามารถลบการแจ้งเตือนจาก Firestore: $e');
    }
  }

  // ลบการแจ้งเตือนทั้งหมดจาก Firestore
  static Future<void> _deleteAllNotificationsFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // ดึงเอกสารทั้งหมดในคอลเลกชัน notifications
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .limit(100) // จำกัดเพื่อป้องกันการโอเวอร์โหลด
            .get();

        // ลบเอกสารทีละรายการ
        final batch = FirebaseFirestore.instance.batch();
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (e) {
      print('⚠️ ไม่สามารถลบการแจ้งเตือนทั้งหมดจาก Firestore: $e');
    }
  }
}

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// class NotificationDialog extends StatefulWidget {
//   final Map<String, dynamic> notificationData;

//   const NotificationDialog({
//     Key? key,
//     required this.notificationData,
//   }) : super(key: key);

//   @override
//   State<NotificationDialog> createState() => _NotificationDialogState();
// }

// class _NotificationDialogState extends State<NotificationDialog> {
//   @override
//   void initState() {
//     super.initState();
//     // ทำการอัปเดตสถานะการอ่านทันทีที่เปิดหน้านี้
//     _markAsRead();
//   }

//   // ฟังก์ชันสำหรับอัปเดตสถานะการอ่าน
//   Future<void> _markAsRead() async {
//     final prefs = await SharedPreferences.getInstance();
//     final notificationsJson = prefs.getString('notifications') ?? '[]';
//     final notifications = List<Map<String, dynamic>>.from(
//         jsonDecode(notificationsJson).map((x) => Map<String, dynamic>.from(x)));

//     // ค้นหาและอัปเดตการแจ้งเตือนที่ตรงกับที่กำลังดูอยู่
//     bool updated = false;
//     for (var i = 0; i < notifications.length; i++) {
//       // ตรวจสอบว่าเป็นการแจ้งเตือนเดียวกันหรือไม่ (โดยใช้ timestamp เป็นตัวเปรียบเทียบ)
//       if (notifications[i]['timestamp'] ==
//           widget.notificationData['timestamp']) {
//         notifications[i]['isRead'] = true;
//         updated = true;
//       }
//     }

//     // บันทึกกลับถ้ามีการอัปเดต
//     if (updated) {
//       await prefs.setString('notifications', jsonEncode(notifications));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final title = widget.notificationData['title'] ?? 'การแจ้งเตือน';
//     final body = widget.notificationData['body'] ?? '';
//     final timestamp = DateTime.fromMillisecondsSinceEpoch(
//         widget.notificationData['timestamp'] ??
//             DateTime.now().millisecondsSinceEpoch);
//     final formattedDate = DateFormat('dd/MMM/yyyy hh:mm a').format(timestamp);

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.pink),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text(
//           'Notification',
//           style: TextStyle(color: Colors.pink),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'การแจ้งเตือน',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.1),
//                       spreadRadius: 1,
//                       blurRadius: 5,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     if (body.isNotEmpty) ...[
//                       const SizedBox(height: 8),
//                       Text(
//                         body,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                     const SizedBox(height: 8),
//                     Align(
//                       alignment: Alignment.bottomRight,
//                       child: Text(
//                         formattedDate,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/notification_manager.dart';

class NotificationDialog extends StatefulWidget {
  final Map<String, dynamic> notificationData;

  const NotificationDialog({
    Key? key,
    required this.notificationData,
  }) : super(key: key);

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ทำการอัปเดตสถานะการอ่านทันทีที่เปิดหน้านี้
    _markAsRead();
  }

  // ฟังก์ชันสำหรับอัปเดตสถานะการอ่าน
  Future<void> _markAsRead() async {
    if (widget.notificationData['id'] == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // ใช้ NotificationManager.markAsRead แทนการอัปเดตเองโดยตรง
      await NotificationManager.markAsRead(
          widget.notificationData['id'].toString());

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ เกิดข้อผิดพลาดในการทำเครื่องหมายว่าอ่านแล้ว: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.notificationData['title'] ?? 'การแจ้งเตือน';
    final body = widget.notificationData['body'] ?? '';
    final timestamp = DateTime.fromMillisecondsSinceEpoch(
        widget.notificationData['timestamp'] ??
            DateTime.now().millisecondsSinceEpoch);
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(timestamp);

    // ตรวจสอบว่ามีข้อมูลเพิ่มเติมหรือไม่
    final Map<String, dynamic> additionalData = {};
    if (widget.notificationData['data'] != null) {
      if (widget.notificationData['data'] is Map) {
        additionalData
            .addAll(Map<String, dynamic>.from(widget.notificationData['data']));
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.pink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'รายละเอียดการแจ้งเตือน',
          style: TextStyle(color: Colors.pink),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.pink),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // หัวข้อการแจ้งเตือน
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // เวลาการแจ้งเตือน
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // เนื้อหาการแจ้งเตือน
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      body,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),

                  // ข้อมูลเพิ่มเติม (ถ้ามี)
                  if (additionalData.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'ข้อมูลเพิ่มเติม',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: additionalData.entries
                            .where((entry) =>
                                entry.key != 'category' &&
                                entry.key != 'priority' &&
                                entry.key != 'click_action')
                            .map((entry) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_formatKeyName(entry.key)}: ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          _formatValue(entry.value),
                                          style: const TextStyle(
                                              color: Colors.black87),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                child: const LinearProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  // ยืนยันการลบการแจ้งเตือน
  void _confirmDelete() {
    if (widget.notificationData['id'] == null) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบการแจ้งเตือนนี้ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // ปิดไดอะล็อก

              try {
                await NotificationManager.deleteNotification(
                    widget.notificationData['id'].toString());

                // ปิดหน้ารายละเอียดการแจ้งเตือน
                if (mounted) {
                  Navigator.pop(context);

                  // แสดงการแจ้งเตือน
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ลบการแจ้งเตือนแล้ว'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('เกิดข้อผิดพลาด: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  // แปลงชื่อคีย์ให้อ่านง่ายขึ้น
  String _formatKeyName(String key) {
    // แปลงคีย์จาก snake_case หรือ camelCase เป็นข้อความที่อ่านง่าย
    final formattedKey = key.replaceAll('_', ' ').replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (Match m) => '${m.group(1)} ${m.group(2)}',
        );

    // ทำตัวอักษรแรกให้เป็นตัวพิมพ์ใหญ่
    return formattedKey.substring(0, 1).toUpperCase() +
        formattedKey.substring(1);
  }

  // แปลงค่าให้อ่านง่ายขึ้น
  String _formatValue(dynamic value) {
    if (value == null) return 'ไม่มีข้อมูล';

    if (value is Map || value is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(value);
      } catch (e) {
        return value.toString();
      }
    }

    // ตรวจสอบว่าเป็น timestamp หรือไม่
    if (value is int && value.toString().length > 10) {
      try {
        final date = DateTime.fromMillisecondsSinceEpoch(value);
        return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
      } catch (e) {
        return value.toString();
      }
    }

    return value.toString();
  }
}

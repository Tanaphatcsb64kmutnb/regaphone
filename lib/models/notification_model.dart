// เพิ่มบรรทัดนี้ที่ด้านบนของไฟล์ notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// สร้างไฟล์ใหม่ models/notification_model.dart
class NotificationModel {
  final String id;
  final String? title;
  final String? body;
  final int timestamp;
  final Map<String, dynamic> data;
  bool isRead;
  final String category;
  final String priority;

  NotificationModel({
    required this.id,
    this.title,
    this.body,
    required this.timestamp,
    required this.data,
    this.isRead = false,
    this.category = 'general',
    this.priority = 'normal',
  });

  // แปลงจาก JSON
  // ใน notification_model.dart
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // จัดการกรณีที่ timestamp อาจเป็นได้ทั้ง Timestamp หรือ int
    int timestamp;
    if (json['timestamp'] is int) {
      timestamp = json['timestamp'];
    } else if (json['timestamp'] is Timestamp) {
      timestamp = (json['timestamp'] as Timestamp).millisecondsSinceEpoch;
    } else {
      timestamp = DateTime.now().millisecondsSinceEpoch;
    }

    return NotificationModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'],
      body: json['body'],
      timestamp: timestamp,
      data: json['data'] ?? {},
      isRead: json['isRead'] ?? false,
      category: json['category'] ?? 'general',
      priority: json['priority'] ?? 'normal',
    );
  }

  // แปลงเป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp,
      'data': data,
      'isRead': isRead,
      'category': category,
      'priority': priority,
    };
  }
}

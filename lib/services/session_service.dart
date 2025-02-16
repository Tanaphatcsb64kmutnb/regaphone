// // lib/services/session_service.dart

// import 'package:shared_preferences.dart';
// import 'dart:convert';

// class SessionService {
//   static const String _keyUserSession = 'user_session';
//   static const String _keyLastLoginTime = 'last_login_time';

//   // บันทึกข้อมูล session
//   static Future<void> saveSession(Map<String, dynamic> userData) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_keyUserSession, jsonEncode(userData));
//     await prefs.setInt(
//         _keyLastLoginTime, DateTime.now().millisecondsSinceEpoch);
//   }

//   // ดึงข้อมูล session
//   static Future<Map<String, dynamic>?> getSession() async {
//     final prefs = await SharedPreferences.getInstance();
//     final sessionData = prefs.getString(_keyUserSession);
//     if (sessionData != null) {
//       return jsonDecode(sessionData) as Map<String, dynamic>;
//     }
//     return null;
//   }

//   // ตรวจสอบว่า session ยังใช้งานได้อยู่หรือไม่ (เช่น ยังไม่หมดอายุ)
//   static Future<bool> isSessionValid() async {
//     final prefs = await SharedPreferences.getInstance();
//     final lastLoginTime = prefs.getInt(_keyLastLoginTime);
//     if (lastLoginTime == null) return false;

//     final lastLogin = DateTime.fromMillisecondsSinceEpoch(lastLoginTime);
//     final now = DateTime.now();
//     // Session หมดอายุหลังจาก 30 วัน
//     return now.difference(lastLogin).inDays < 30;
//   }

//   // ล้างข้อมูล session
//   static Future<void> clearSession() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_keyUserSession);
//     await prefs.remove(_keyLastLoginTime);
//   }
// }

import 'package:shared_preferences/shared_preferences.dart'; // แก้จาก 'package:shared_preferences.dart'
import 'dart:convert';

class SessionService {
  static const String _keyUserSession = 'user_session';
  static const String _keyLastLoginTime = 'last_login_time';

  // บันทึกข้อมูล session
  static Future<void> saveSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserSession, jsonEncode(userData));
    await prefs.setInt(
        _keyLastLoginTime, DateTime.now().millisecondsSinceEpoch);
  }

  // ดึงข้อมูล session
  static Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = prefs.getString(_keyUserSession);
    if (sessionData != null) {
      return jsonDecode(sessionData) as Map<String, dynamic>;
    }
    return null;
  }

  // // ตรวจสอบว่า session ยังใช้งานได้อยู่หรือไม่
  static Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoginTime = prefs.getInt(_keyLastLoginTime);
    if (lastLoginTime == null) return false;

    final lastLogin = DateTime.fromMillisecondsSinceEpoch(lastLoginTime);
    final now = DateTime.now();
    return now.difference(lastLogin).inDays < 30;
  }

  // ล้างข้อมูล session
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserSession);
    await prefs.remove(_keyLastLoginTime);
  }
}

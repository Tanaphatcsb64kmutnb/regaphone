import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Service สำหรับจัดการการโหลดรูปภาพจาก Firebase Storage
/// ใช้ Singleton pattern เพื่อให้มีเพียงอินสแตนซ์เดียวทั้งแอป
/// และสามารถแชร์ cache ระหว่างหน้าต่างๆ ได้
class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Cache สำหรับเก็บ URL ที่เคยโหลดแล้ว
  final Map<String, String> _cachedImageUrls = {};

  // ตัวจับเวลาสำหรับบันทึก log เวลาที่ใช้ในการโหลด
  final Stopwatch _stopwatch = Stopwatch();

  /// ดึง URL ของรูปภาพจาก Firebase Storage
  /// โดยใช้ cache เพื่อป้องกันการเรียก getDownloadURL ซ้ำๆ
  Future<String> getImageUrl(String imageName,
      {String path = 'Yogapose/'}) async {
    _stopwatch.reset();
    _stopwatch.start();

    try {
      if (imageName.isEmpty) return '';

      final fullPath = '$path$imageName';

      // ตรวจสอบใน cache ก่อน
      if (_cachedImageUrls.containsKey(fullPath)) {
        _stopwatch.stop();
        debugPrint(
            '⚡ Retrieved from cache: $fullPath in ${_stopwatch.elapsedMilliseconds}ms');
        return _cachedImageUrls[fullPath]!;
      }

      // ถ้าไม่มีใน cache จึงโหลดจาก Firebase
      final ref = FirebaseStorage.instance.ref().child(fullPath);

      final url = await ref.getDownloadURL();

      // เก็บลงใน cache
      _cachedImageUrls[fullPath] = url;

      _stopwatch.stop();
      debugPrint(
          '🔄 Downloaded from Storage: $fullPath in ${_stopwatch.elapsedMilliseconds}ms');

      return url;
    } catch (e) {
      _stopwatch.stop();
      debugPrint(
          '❌ Error getting image URL for $imageName: $e (${_stopwatch.elapsedMilliseconds}ms)');
      return '';
    }
  }

  /// ล้าง cache ทั้งหมด (ใช้เมื่อต้องการโหลดรูปใหม่ทั้งหมด เช่น หลังจาก logout)
  void clearCache() {
    _cachedImageUrls.clear();
    debugPrint('🧹 Storage URL cache cleared');
  }

  /// ลบ URL บางรายการออกจาก cache (ใช้เมื่อมีการอัปเดตรูปภาพ)
  void removeFromCache(String imageName, {String path = 'Yogapose/'}) {
    final fullPath = '$path$imageName';
    _cachedImageUrls.remove(fullPath);
    debugPrint('🗑️ Removed from cache: $fullPath');
  }

  /// โหลดรูปภาพหลายรูปพร้อมกันล่วงหน้า
  Future<List<String>> preloadImages(List<String> imageNames,
      {String path = 'Yogapose/'}) async {
    final futures =
        imageNames.map((name) => getImageUrl(name, path: path)).toList();
    return await Future.wait(futures);
  }
}

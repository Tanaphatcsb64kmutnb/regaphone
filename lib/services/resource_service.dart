import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class ResourceService {
  static final ResourceService _instance = ResourceService._internal();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // สร้าง singleton
  factory ResourceService() {
    return _instance;
  }

  ResourceService._internal();

  // เก็บรายการไฟล์ที่ต้องการโหลด
  late List<String> _imagesList = [];
  late List<String> _videosList = [];

  // จำนวนไฟล์ที่โหลดสำเร็จ
  int _loadedImagesCount = 0;
  int _loadedVideosCount = 0;

  // สถานะการโหลด
  bool _isLoadingResources = false;

  // Stream controllers สำหรับแสดงความคืบหน้า
  final ValueNotifier<double> progressNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<String> currentFileNotifier = ValueNotifier<String>('');

  // เช็คว่าต้องโหลดทรัพยากรใหม่หรือไม่
  Future<bool> needToLoadResources() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? resourcesLoaded = prefs.getBool('resources_loaded');
    return resourcesLoaded == null || !resourcesLoaded;
  }

  // สร้างโฟลเดอร์สำหรับเก็บทรัพยากร
  Future<void> _createDirectories() async {
    final appDir = await getApplicationDocumentsDirectory();
    final picDir = Directory('${appDir.path}/pic');
    final videoDir = Directory('${appDir.path}/video');

    if (!await picDir.exists()) {
      await picDir.create(recursive: true);
    }

    if (!await videoDir.exists()) {
      await videoDir.create(recursive: true);
    }

    developer.log('✅ สร้างไดเรกทอรีสำเร็จ: ${picDir.path}, ${videoDir.path}');
  }

  // ดึงรายการไฟล์จาก Firebase Storage
  Future<void> _fetchFilesList() async {
    try {
      // ดึงรายการไฟล์รูปภาพ
      final imagesResult = await _storage.ref('/Yogapose').listAll();
      _imagesList = imagesResult.items.map((item) => item.fullPath).toList();

      // ดึงรายการไฟล์วิดีโอ
      final videosResult = await _storage.ref('/Yogavideo').listAll();
      _videosList = videosResult.items.map((item) => item.fullPath).toList();

      developer.log(
          '✅ ดึงรายการไฟล์สำเร็จ: ${_imagesList.length} รูปภาพ, ${_videosList.length} วิดีโอ');
    } catch (e) {
      developer.log('❌ ไม่สามารถดึงรายการไฟล์: $e');
      rethrow;
    }
  }

  // ดาวน์โหลดไฟล์และบันทึกลงใน local storage
  Future<void> _downloadFile(String filePath, String localDir) async {
    try {
      // อัปเดตชื่อไฟล์ปัจจุบันที่กำลังโหลด
      final fileName = filePath.split('/').last;
      currentFileNotifier.value = fileName;

      // เช็คว่าไฟล์มีอยู่แล้วหรือไม่
      final appDir = await getApplicationDocumentsDirectory();
      final localFilePath = '$appDir.path/$localDir/$fileName';
      final localFile = File(localFilePath);

      if (await localFile.exists()) {
        developer.log('⏩ ข้ามไฟล์ที่มีอยู่แล้ว: $fileName');
        return;
      }

      // ดาวน์โหลดไฟล์
      final ref = _storage.ref(filePath);
      await ref.writeToFile(localFile);

      developer.log('✅ ดาวน์โหลดไฟล์สำเร็จ: $fileName');
    } catch (e) {
      developer.log('❌ ไม่สามารถดาวน์โหลดไฟล์ $filePath: $e');
      // เราจะไม่ throw error เพื่อให้โหลดไฟล์อื่นต่อไป
    }
  }

  // โหลดทรัพยากรทั้งหมด
  Future<void> loadAllResources() async {
    if (_isLoadingResources) {
      developer.log('⚠️ กำลังโหลดทรัพยากรอยู่แล้ว');
      return;
    }

    _isLoadingResources = true;
    progressNotifier.value = 0.0;

    try {
      // ตรวจสอบการเชื่อมต่อ
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        developer.log('❌ ไม่มีการเชื่อมต่ออินเทอร์เน็ต');
        _isLoadingResources = false;
        throw Exception('ไม่มีการเชื่อมต่ออินเทอร์เน็ต กรุณาลองอีกครั้ง');
      }

      // สร้างไดเร็กทอรี
      await _createDirectories();

      // ดึงรายการไฟล์
      await _fetchFilesList();

      // รีเซ็ตตัวนับ
      _loadedImagesCount = 0;
      _loadedVideosCount = 0;

      // คำนวณจำนวนไฟล์ทั้งหมด
      final totalFiles = _imagesList.length + _videosList.length;

      // โหลดรูปภาพ
      for (var imagePath in _imagesList) {
        await _downloadFile(imagePath, 'pic');
        _loadedImagesCount++;

        // อัปเดตความคืบหน้า
        progressNotifier.value =
            (_loadedImagesCount + _loadedVideosCount) / totalFiles;
      }

      // โหลดวิดีโอ
      for (var videoPath in _videosList) {
        await _downloadFile(videoPath, 'video');
        _loadedVideosCount++;

        // อัปเดตความคืบหน้า
        progressNotifier.value =
            (_loadedImagesCount + _loadedVideosCount) / totalFiles;
      }

      // บันทึกสถานะการโหลด
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('resources_loaded', true);

      developer.log('✅ โหลดทรัพยากรทั้งหมดสำเร็จ');
    } catch (e) {
      developer.log('❌ เกิดข้อผิดพลาดในการโหลดทรัพยากร: $e');
      rethrow;
    } finally {
      _isLoadingResources = false;
      currentFileNotifier.value = '';
    }
  }

  // ลบทรัพยากรทั้งหมด (สำหรับการทดสอบหรือล้างข้อมูล)
  Future<void> clearAllResources() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final picDir = Directory('${appDir.path}/pic');
      final videoDir = Directory('${appDir.path}/video');

      if (await picDir.exists()) {
        await picDir.delete(recursive: true);
      }

      if (await videoDir.exists()) {
        await videoDir.delete(recursive: true);
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('resources_loaded', false);

      developer.log('✅ ลบทรัพยากรทั้งหมดสำเร็จ');
    } catch (e) {
      developer.log('❌ ไม่สามารถลบทรัพยากร: $e');
      rethrow;
    }
  }

  // ตรวจสอบว่าไฟล์มีอยู่ในระบบหรือไม่
  Future<bool> fileExists(String fileName, String type) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dir = type == 'image' ? 'pic' : 'video';
      final filePath = '${appDir.path}/$dir/$fileName';
      return await File(filePath).exists();
    } catch (e) {
      developer.log('❌ ไม่สามารถตรวจสอบไฟล์: $e');
      return false;
    }
  }

  // ดึงพาธของไฟล์ภาพจาก local storage
  Future<String> getLocalImagePath(String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/pic/$fileName';
  }

  // ดึงพาธของไฟล์วิดีโอจาก local storage
  Future<String> getLocalVideoPath(String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/video/$fileName';
  }
}

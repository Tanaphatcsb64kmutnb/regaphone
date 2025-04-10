import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PoseTracker {
  static const platform = MethodChannel('live_camera_view');

  // ข้อมูลการทำนายท่า
  final Map<String, List<double>> posePredictions = {};

  // Callbacks
  final Function(String, double) onPosePredicted;
  final Function() onVideoCompleted;

  PoseTracker({
    required this.onPosePredicted,
    required this.onVideoCompleted,
  });

  /// ตั้งค่า MethodChannel สำหรับการติดต่อกับ Native Code
  void setupMethodChannel() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'videoCompleted':
          onVideoCompleted();
          break;

        case 'onPosePredicted':
          final Map<String, dynamic> prediction =
              Map<String, dynamic>.from(call.arguments);

          final String pose = prediction['pose'] as String;
          double angleScore = prediction['score'] as double;
          double confidence = angleScore / 100; // แปลงค่า 0-100 เป็น 0-1

          onPosePredicted(pose, confidence);
          break;
      }
    });
  }

  /// ส่งรายชื่อท่าที่อนุญาตไปยัง native code
  Future<void> sendAllowedPoses(List<String> poseNames) async {
    try {
      debugPrint("Sending allowed poses: $poseNames");
      await platform.invokeMethod('setAllowedPoses', {'poseNames': poseNames});
    } catch (e) {
      debugPrint("Error sending allowed poses: $e");
    }
  }

  /// ส่งสถานะความถูกต้องของท่าไปยัง native code
  Future<void> setPoseCorrectness(bool isCorrect) async {
    try {
      await platform
          .invokeMethod('setPoseCorrectness', {'isCorrect': isCorrect});
    } catch (e) {
      debugPrint("Error setting pose correctness: $e");
    }
  }

  /// เล่นวิดีโอสอนท่า
  Future<void> playInstructionVideo(String videoFileName,
      {String? poseName}) async {
    try {
      await platform.invokeMethod('playRestVideo', {
        "videoFileName": videoFileName,
        "poseName": poseName ?? "โยคะ", // ส่งชื่อท่าไปแสดงในข้อความโหลด
      });
    } catch (e) {
      debugPrint("Failed to play instruction video: $e");
      rethrow;
    }
  }

  /// เล่นวิดีโอพัก
  Future<void> playRestVideo() async {
    try {
      await platform.invokeMethod('playRestVideo', {
        "videoFileName": "rest_video.mp4",
        "poseName": "พัก", // ใช้ชื่อ "พัก" สำหรับวิดีโอพัก
      });
    } catch (e) {
      debugPrint("Failed to play rest video: $e");
      rethrow;
    }
  }

  /// บันทึกข้อมูลการทำนายท่า
  void addPosePrediction(String poseId, double score) {
    if (!posePredictions.containsKey(poseId)) {
      posePredictions[poseId] = [];
    }
    posePredictions[poseId]!.add(score);
  }

  /// ดึงข้อมูลการทำนายท่าและล้างข้อมูลหลังใช้
  List<double> getPosePredictions(String poseId) {
    final predictions = posePredictions[poseId] ?? [];
    posePredictions.remove(poseId);
    return predictions;
  }
}

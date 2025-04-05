import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;
  final String programId;
  String? programHistoryId;

  // เก็บคะแนนของแต่ละท่า
  final Map<String, double> poseScores = {};

  HistoryService({
    required this.userId,
    required this.programId,
  });

  /// สร้างประวัติโปรแกรมใหม่
  Future<void> initializeProgramHistory() async {
    try {
      // สร้างเอกสาร YogaProgram History
      final docRef = await _firestore.collection('YogaProgramHistory').add({
        'Ovr_score': 0.0, // คะแนนเริ่มต้น
        'User': _firestore.doc('Users/$userId'),
        'Program_id': _firestore.doc('Yoga Program/$programId'),
        'Date': DateTime.now(),
        'Time': DateTime.now(),
      });

      programHistoryId = docRef.id;
    } catch (e) {
      debugPrint("Error initializing program history: $e");
    }
  }

  /// บันทึกคะแนนของท่าโยคะ
  Future<void> savePoseScore({
    required String poseId,
    required double score,
    required List<double> predictions,
    required String performance,
  }) async {
    if (programHistoryId == null) {
      debugPrint('Cannot save pose score: Missing history ID');
      return;
    }

    // คำนวณค่าเฉลี่ยจาก predictions (เก็บเพื่อข้อมูลเพิ่มเติม)
    final avgScore = predictions.isNotEmpty
        ? predictions.reduce((a, b) => a + b) / predictions.length
        : 0.0;

    try {
      final completer = Completer<void>();

      await _firestore.collection('YogaPoseHistory').add({
        'Pose_id': _firestore.doc('Yoga Pose/$poseId'),
        'Pose_score': score,
        'Avg_pose_score': avgScore,
        'Performance': performance,
        'Date': DateTime.now(),
        'Time': DateTime.now(),
        'User': _firestore.doc('Users/$userId'),
        'Program': _firestore.doc('Yoga Program/$programId'),
        'history_id': programHistoryId,
        'prediction_count': predictions.length,
        'predictions': predictions,
      }).then((_) {
        poseScores[poseId] = score;
        completer.complete();
      }).catchError((error) {
        debugPrint("Error saving pose score: $error");
        completer.completeError(error);
      });

      await completer.future;
    } catch (e) {
      debugPrint("Critical error saving pose score: $e");
    }
  }

  /// บันทึกคะแนนรวมของโปรแกรม
  Future<void> saveOverallScore() async {
    if (poseScores.isEmpty || programHistoryId == null) return;

    try {
      double totalScore = 0;
      poseScores.forEach((_, score) => totalScore += score);
      final averageScore = totalScore / poseScores.length;

      // อัปเดต YogaProgram History ด้วยคะแนนสุดท้าย
      await _firestore
          .collection('YogaProgramHistory')
          .doc(programHistoryId)
          .update({
        'Ovr_score': averageScore,
      });
    } catch (e) {
      debugPrint("Error updating program history: $e");
    }
  }
}

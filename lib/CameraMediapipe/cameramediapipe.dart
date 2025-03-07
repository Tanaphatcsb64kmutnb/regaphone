import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pose_result.dart';

class CameraMediapipeApp extends StatelessWidget {
  final String? programId;

  const CameraMediapipeApp({super.key, this.programId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Realtime Pose Detection Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CameraMediapipeScreen(programId: programId),
    );
  }
}

class CameraMediapipeScreen extends StatefulWidget {
  final String? programId;

  const CameraMediapipeScreen({super.key, this.programId});

  @override
  State<CameraMediapipeScreen> createState() => _CameraMediapipeScreenState();
}

class _CameraMediapipeScreenState extends State<CameraMediapipeScreen> {
  static const platform = MethodChannel('live_camera_view');

  int remainingTime = 0;
  int totalTime = 0;
  int currentPoseIndex = 0;
  Timer? countdownTimer;
  bool isResting = false;

  String currentPredictedPose = "Waiting...";
  double poseConfidence = 0.0;
  bool isConnected = true;

  String? currentUser;
  Map<String, double> poseScores = {};
  String? programHistoryId;

  // เพิ่มตัวแปรเหล่านี้ต่อจากตัวแปรอื่นๆ ที่มีอยู่แล้ว
  double cumulativeScore = 0.0; // คะแนนสะสมทั้งหมด
  double lastUpdateTime = 0.0; // เวลาล่าสุดที่อัพเดทคะแนน (เพื่อควบคุมความถี่)

  // อัตราการเพิ่มคะแนน (สามารถปรับได้ตามต้องการ)
  final double scoreMultiplier = 0.1; // ตัวคูณคะแนน - 100% = 10 คะแนน/ครั้ง

  // เพิ่มตัวแปรสำหรับแสดงผลเอฟเฟค
  bool showScoreEffect = false;
  double lastAddedScore = 0.0;

  // เพิ่มตัวแปรสำหรับเก็บค่า predictions
  Map<String, List<double>> posePredictions = {};
  Map<String, String> poseIdToName = {};

  List<Map<String, dynamic>> yogaPoses = [];

  @override
  void initState() {
    super.initState();
    _initializeUser();
    if (widget.programId != null) {
      _initializeProgramHistory().then((_) => fetchYogaPoses());
    }
    _setupMethodChannel();
  }

  Future<void> _initializeUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUser = user.uid;
      });
    }
  }

  Future<void> _initializeProgramHistory() async {
    if (currentUser == null) return;

    try {
      // Create YogaProgram History document first
      final docRef = await FirebaseFirestore.instance
          .collection('YogaProgramHistory')
          .add({
        'Ovr_score': 0.0, // Initial score
        'User': FirebaseFirestore.instance.doc('Users/$currentUser'),
        'Program_id':
            FirebaseFirestore.instance.doc('Yoga Program/${widget.programId}'),
        'Date': DateTime.now(),
        'Time': DateTime.now(),
      });

      setState(() {
        programHistoryId = docRef.id;
      });
    } catch (e) {
      debugPrint("Error initializing program history: $e");
    }
  }

  void _setupMethodChannel() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'videoCompleted':
          if (mounted) {
            if (currentPoseIndex < yogaPoses.length) {
              await savePoseScore();
            }

            setState(() {
              isResting = false;
              currentPoseIndex++;
            });

            if (currentPoseIndex >= yogaPoses.length) {
              await saveProgramHistory();
              if (mounted && programHistoryId != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PoseResultPage(
                      programId: widget.programId!,
                      programHistoryId: programHistoryId!,
                    ),
                  ),
                );
              }
            } else {
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  startPose();
                }
              });
            }
          }
          break;

        // case 'onPosePredicted':
        //   final Map<String, dynamic> prediction =
        //       Map<String, dynamic>.from(call.arguments);
        //   setState(() {
        //     currentPredictedPose = prediction['pose'] as String;
        //     double confidence = prediction['confidence'] as double;
        //     poseConfidence = confidence;
        //     isConnected = true;

        //     // เก็บค่า prediction ระหว่างเล่น
        //     if (currentPoseIndex < yogaPoses.length) {
        //       final currentPoseId = yogaPoses[currentPoseIndex]['id'];
        //       if (!posePredictions.containsKey(currentPoseId)) {
        //         posePredictions[currentPoseId] = [];
        //       }
        //       posePredictions[currentPoseId]!.add(confidence * 100);
        //       debugPrint(
        //           'Added prediction for pose $currentPoseId: ${confidence * 100}');
        //     }
        //   });
        //   break;

        // case 'onPredictionError':
        //   setState(() {
        //     isConnected = false;
        //   });
        //   break;
        case 'onPosePredicted':
          final Map<String, dynamic> prediction =
              Map<String, dynamic>.from(call.arguments);
          setState(() {
            currentPredictedPose = prediction['pose'] as String;

            // ใช้ค่า angle_similarity เป็นคะแนนหลัก
            double angleScore = prediction['score'] as double;
            poseConfidence = angleScore / 100; // แปลงค่า 0-100 เป็น 0-1

            isConnected = true;

            // บันทึกข้อมูลสำหรับวิเคราะห์ (ยังคงทำเสมอ)
            if (currentPoseIndex < yogaPoses.length) {
              final currentPoseId = yogaPoses[currentPoseIndex]['id'];
              if (!posePredictions.containsKey(currentPoseId)) {
                posePredictions[currentPoseId] = [];
              }
              posePredictions[currentPoseId]!.add(angleScore);

              // เพิ่มคะแนนเมื่อทำท่าถูกต้อง และไม่อยู่ในช่วงพัก
              if (!isResting && currentPoseIndex < yogaPoses.length) {
                // ตรวจสอบว่าท่าที่ทำนายได้ตรงกับท่าที่ล็อกไว้หรือไม่
                final expectedPoseName = yogaPoses[currentPoseIndex]['name'];

                if (currentPredictedPose == expectedPoseName) {
                  // คำนวณคะแนนเมื่อทำท่าถูกต้อง
                  double addedScore = angleScore * scoreMultiplier;

                  // ตรวจสอบไม่ให้คะแนนเกิน 100
                  if (cumulativeScore + addedScore > 100) {
                    addedScore = 100 - cumulativeScore; // เพิ่มแค่พอให้ครบ 100

                    if (addedScore <= 0) {
                      // กรณีคะแนนครบ 100 แล้ว ไม่เพิ่มคะแนนอีก
                      addedScore = 0;
                    }
                  }

                  cumulativeScore += addedScore;

                  // แสดงเอฟเฟคเมื่อได้คะแนน (เฉพาะถ้าได้คะแนนเพิ่ม)
                  if (addedScore > 0) {
                    lastAddedScore = addedScore;
                    showScoreEffect = true;
                    Future.delayed(const Duration(milliseconds: 800), () {
                      if (mounted) {
                        setState(() {
                          showScoreEffect = false;
                        });
                      }
                    });

                    debugPrint(
                        'Correct pose! Added ${addedScore.toStringAsFixed(1)} points. Total: ${cumulativeScore.toStringAsFixed(1)}/100');
                  }
                } else {
                  // ท่าไม่ตรงกับที่คาดหวัง - ไม่เพิ่มคะแนน
                  debugPrint(
                      'Incorrect pose: Expected $expectedPoseName but got $currentPredictedPose');
                }
              }
            }
          });
          break;
      }
    });
  }

  // Future<void> fetchYogaPoses() async {
  //   try {
  //     final querySnapshot = await FirebaseFirestore.instance
  //         .collection('Yoga Pose')
  //         .where('Program',
  //             isEqualTo: FirebaseFirestore.instance
  //                 .collection('Yoga Program')
  //                 .doc(widget.programId))
  //         .get();

  //     final fetchedPoses = querySnapshot.docs.map((doc) {
  //       return {
  //         "name": doc['Name'],
  //         "timeup": doc['Timeup'],
  //         "id": doc.id,
  //       };
  //     }).toList();

  //     setState(() {
  //       yogaPoses = fetchedPoses;
  //       if (yogaPoses.isNotEmpty) {
  //         startPose();
  //       }
  //     });
  //   } catch (e) {
  //     debugPrint("Error fetching yoga poses: $e");
  //   }
  // }

  // แก้ไขฟังก์ชัน fetchYogaPoses
  Future<void> fetchYogaPoses() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Yoga Pose')
          .where('Program',
              isEqualTo: FirebaseFirestore.instance
                  .collection('Yoga Program')
                  .doc(widget.programId))
          .get();

      final fetchedPoses = querySnapshot.docs.map((doc) {
        return {
          "name": doc['Name'],
          "timeup": doc['Timeup'],
          "id": doc.id,
        };
      }).toList();

      setState(() {
        yogaPoses = fetchedPoses;

        // สร้างการแมปปิ้งระหว่าง ID และชื่อท่า
        poseIdToName = {for (var pose in yogaPoses) pose["id"]: pose["name"]};

        if (yogaPoses.isNotEmpty) {
          // ส่งรายชื่อท่าที่อนุญาตไปยัง native code
          _sendAllowedPoses();

          startPose();
        }
      });
    } catch (e) {
      debugPrint("Error fetching yoga poses: $e");
    }
  }

  // เพิ่มฟังก์ชันส่งรายชื่อท่าที่อนุญาตไปยัง native code
  Future<void> _sendAllowedPoses() async {
    try {
      List<String> allowedPoseNames =
          yogaPoses.map((pose) => pose['name'] as String).toList();
      debugPrint("Sending allowed poses: $allowedPoseNames");

      await platform
          .invokeMethod('setAllowedPoses', {'poseNames': allowedPoseNames});
    } catch (e) {
      debugPrint("Error sending allowed poses: $e");
    }
  }
  // // อัปเดตฟังก์ชัน savePoseScore (ถ้าจำเป็น)
  // Future<void> savePoseScore() async {
  //   if (currentPoseIndex >= yogaPoses.length || programHistoryId == null) {
  //     debugPrint('Cannot save pose score: Invalid index or missing history ID');
  //     return;
  //   }

  //   final currentPose = yogaPoses[currentPoseIndex];
  //   final poseId = currentPose['id'];

  //   // รอให้มีการเก็บข้อมูลอย่างน้อย 3 วินาที
  //   await Future.delayed(const Duration(seconds: 3));

  //   // คำนวณค่าเฉลี่ยของ predictions ทั้งหมด
  //   final predictions = posePredictions[poseId] ?? [];
  //   if (predictions.isEmpty) {
  //     debugPrint('No predictions found for pose $poseId - Retrying...');
  //     // รอเพิ่มอีก 2 วินาทีแล้วลองอีกครั้ง
  //     await Future.delayed(const Duration(seconds: 2));
  //     if (posePredictions[poseId]?.isEmpty ?? true) {
  //       debugPrint(
  //           'Still no predictions after retry - Recording default score');
  //       predictions.add(0.0); // บันทึกคะแนน 0 ถ้าไม่มีข้อมูล
  //     }
  //   }

  //   final avgScore = predictions.isNotEmpty
  //       ? predictions.reduce((a, b) => a + b) / predictions.length
  //       : 0.0;

  //   debugPrint(
  //       'Average score for pose $poseId: $avgScore (from ${predictions.length} predictions)');

  //   try {
  //     // เพิ่ม CompleterFuture เพื่อติดตามการบันทึก
  //     final completer = Completer<void>();

  //     await FirebaseFirestore.instance.collection('YogaPoseHistory').add({
  //       'Pose_id': FirebaseFirestore.instance.doc('Yoga Pose/$poseId'),
  //       'Pose_score': avgScore,
  //       'Performance': _getPerformanceLevel(avgScore),
  //       'Date': DateTime.now(),
  //       'Time': DateTime.now(),
  //       'User': FirebaseFirestore.instance.doc('Users/$currentUser'),
  //       'Program':
  //           FirebaseFirestore.instance.doc('Yoga Program/${widget.programId}'),
  //       'history_id': programHistoryId,
  //       'prediction_count': predictions.length,
  //       'predictions': predictions,
  //     }).then((_) {
  //       poseScores[poseId] = avgScore;
  //       completer.complete();
  //     }).catchError((error) {
  //       debugPrint("Error saving pose score: $error");
  //       completer.completeError(error);
  //     });

  //     // รอให้การบันทึกเสร็จสมบูรณ์
  //     await completer.future;
  //   } catch (e) {
  //     debugPrint("Critical error saving pose score: $e");
  //   }

  //   // ล้างค่า predictions สำหรับท่าต่อไปหลังจากบันทึกเสร็จแล้ว
  //   posePredictions.remove(poseId);
  // }

  // แก้ไขฟังก์ชัน savePoseScore - บันทึกคะแนนสะสมแทนค่าเฉลี่ย
  Future<void> savePoseScore() async {
    if (currentPoseIndex >= yogaPoses.length || programHistoryId == null) {
      debugPrint('Cannot save pose score: Invalid index or missing history ID');
      return;
    }

    final currentPose = yogaPoses[currentPoseIndex];
    final poseId = currentPose['id'];

    // รอให้มีการเก็บข้อมูลอย่างน้อย 3 วินาที
    await Future.delayed(const Duration(seconds: 3));

    // คำนวณค่าเฉลี่ยของ predictions ทั้งหมด (ยังคงเก็บไว้เพื่อข้อมูลทางสถิติ)
    final predictions = posePredictions[poseId] ?? [];
    if (predictions.isEmpty) {
      debugPrint('No predictions found for pose $poseId - Retrying...');
      // รอเพิ่มอีก 2 วินาทีแล้วลองอีกครั้ง
      await Future.delayed(const Duration(seconds: 2));
      if (posePredictions[poseId]?.isEmpty ?? true) {
        debugPrint(
            'Still no predictions after retry - Recording default score');
        predictions.add(0.0); // บันทึกคะแนน 0 ถ้าไม่มีข้อมูล
      }
    }

    // คำนวณค่าเฉลี่ยจาก predictions (เก็บเพื่อข้อมูลเพิ่มเติม)
    final avgScore = predictions.isNotEmpty
        ? predictions.reduce((a, b) => a + b) / predictions.length
        : 0.0;

    debugPrint(
        'Average score for pose $poseId: $avgScore (from ${predictions.length} predictions)');
    debugPrint('Cumulative score for this pose: $cumulativeScore');

    try {
      final completer = Completer<void>();

      await FirebaseFirestore.instance.collection('YogaPoseHistory').add({
        'Pose_id': FirebaseFirestore.instance.doc('Yoga Pose/$poseId'),
        'Pose_score': cumulativeScore, // ใช้คะแนนสะสมแทนค่าเฉลี่ย
        'Avg_pose_score':
            avgScore, // เก็บค่าเฉลี่ยไว้ด้วย (อาจมีประโยชน์ในอนาคต)
        'Performance':
            _getPerformanceLevel(cumulativeScore), // ปรับการประเมินผล
        'Date': DateTime.now(),
        'Time': DateTime.now(),
        'User': FirebaseFirestore.instance.doc('Users/$currentUser'),
        'Program':
            FirebaseFirestore.instance.doc('Yoga Program/${widget.programId}'),
        'history_id': programHistoryId,
        'prediction_count': predictions.length,
        'predictions': predictions,
      }).then((_) {
        poseScores[poseId] = cumulativeScore;
        completer.complete();
      }).catchError((error) {
        debugPrint("Error saving pose score: $error");
        completer.completeError(error);
      });

      // รอให้การบันทึกเสร็จสมบูรณ์
      await completer.future;
    } catch (e) {
      debugPrint("Critical error saving pose score: $e");
    }

    // ล้างค่า predictions สำหรับท่าต่อไปหลังจากบันทึกเสร็จแล้ว
    posePredictions.remove(poseId);

    // รีเซ็ตคะแนนสะสมสำหรับท่าต่อไป
    setState(() {
      cumulativeScore = 0.0;
    });
  }

  String _getPerformanceLevel(double score) {
    if (score >= 75) return 'สุดยอดมาก';
    if (score >= 50) return 'ดี';
    if (score >= 25) return 'ปานกลาง';
    return 'พอใช้';
  }

  Future<void> saveProgramHistory() async {
    if (poseScores.isEmpty || programHistoryId == null) return;

    try {
      double totalScore = 0;
      poseScores.forEach((_, score) => totalScore += score);
      final averageScore = totalScore / poseScores.length;

      // Update the existing YogaProgram History with final score
      await FirebaseFirestore.instance
          .collection('YogaProgramHistory')
          .doc(programHistoryId)
          .update({
        'Ovr_score': averageScore,
      });
    } catch (e) {
      debugPrint("Error updating program history: $e");
    }
  }

  void startPose() {
    if (currentPoseIndex >= yogaPoses.length) {
      setState(() {
        remainingTime = 0;
      });
      return;
    }

    final currentPose = yogaPoses[currentPoseIndex];
    setState(() {
      remainingTime = currentPose['timeup'];
      totalTime = currentPose['timeup'];
    });

    startCountdown();
  }

  void startCountdown() {
    countdownTimer?.cancel();
    // ใน startCountdown()
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        debugPrint(
            "Timer: $remainingTime seconds left for pose ${currentPoseIndex}");
        if (isResting) {
          debugPrint("Currently resting - timer cancelled");
          timer.cancel();
          return;
        }

        setState(() {
          if (remainingTime > 0) {
            remainingTime--;
          } else {
            debugPrint("Time's up! Showing rest video");
            timer.cancel();
            if (!isResting) {
              showRestVideo();
            }
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> showRestVideo() async {
    setState(() {
      isResting = true;
    });

    countdownTimer?.cancel();

    try {
      await platform.invokeMethod('playRestVideo');
    } catch (e) {
      debugPrint("Failed to play rest video: $e");
      // ถ้าเกิด error ให้จำลองการจบวิดีโอเพื่อไปท่าถัดไป
      if (mounted) {
        debugPrint("Video error - simulating video completion");
        // เรียกใช้โดยตรงเพื่อข้ามไปท่าถัดไป
        await savePoseScore();
        setState(() {
          isResting = false;
          currentPoseIndex++;
        });

        if (currentPoseIndex >= yogaPoses.length) {
          await saveProgramHistory();
          if (mounted && programHistoryId != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PoseResultPage(
                  programId: widget.programId!,
                  programHistoryId: programHistoryId!,
                ),
              ),
            );
          }
        } else {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              startPose();
            }
          });
        }
      }
    }
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPose = currentPoseIndex < yogaPoses.length
        ? yogaPoses[currentPoseIndex]
        : null;

    double progressPercentage = totalTime > 0 ? remainingTime / totalTime : 0;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: AndroidView(
              viewType: 'live_camera_view',
              creationParams: {'camera': 'front'},
              creationParamsCodec: const StandardMessageCodec(),
            ),
          ),
          if (widget.programId != null && yogaPoses.isNotEmpty)
            Positioned(
              top: 30,
              left: 20,
              right: 20,
              child: Container(
                height: 35,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: (MediaQuery.of(context).size.width - 40) *
                          progressPercentage,
                      decoration: BoxDecoration(
                        color: _getProgressColor(progressPercentage),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Center(
                      child: Text(
                        '$remainingTime / $totalTime',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            top: 80,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Detected Pose: $currentPredictedPose',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Text(
                  //   'Confidence: ${(poseConfidence * 100).toStringAsFixed(1)}%',
                  //   style: TextStyle(
                  //     color: Colors.white.withOpacity(0.9),
                  //     fontSize: 16,
                  //   ),
                  // ),

                  // แสดงคะแนน
                  Text(
                    'Score: ${(poseConfidence * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  if (!isConnected)
                    const Text(
                      'Connection Error',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // เพิ่มส่วนแสดงคะแนนสะสม (ด้านบนขวา)
          Positioned(
            top: 30,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.stars,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${cumulativeScore.toStringAsFixed(0)}/100',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // เพิ่มเอฟเฟคแสดงคะแนนที่ได้รับ
          if (showScoreEffect)
            Positioned(
              top: 80,
              right: 30,
              child: AnimatedOpacity(
                opacity: showScoreEffect ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  '+${lastAddedScore.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black.withOpacity(0.7),
                        offset: const Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (widget.programId != null && yogaPoses.isNotEmpty)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: isResting
                      ? const Text(
                          "Resting...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : currentPose != null
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  currentPose['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (currentPredictedPose == currentPose['name'])
                                  const Text(
                                    'Correct Pose! 👍',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 18,
                                    ),
                                  )
                              ],
                            )
                          : const Text(
                              "Completed!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.7) return Colors.green;
    if (progress >= 0.3) {
      return Color.lerp(
        Colors.yellow,
        Colors.green,
        (progress - 0.3) / 0.4,
      )!;
    }
    return Color.lerp(
      Colors.red,
      Colors.yellow,
      progress / 0.3,
    )!;
  }
}

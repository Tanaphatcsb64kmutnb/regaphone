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

class _CameraMediapipeScreenState extends State<CameraMediapipeScreen>
    with SingleTickerProviderStateMixin {
  static const platform = MethodChannel('live_camera_view');

  bool isLoading = false;
  int countdownSeconds = 3;
  Timer? loadingTimer;
  double loadingProgress = 0.0;

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
  final double scoreMultiplier = 0.1; // เพิ่มจาก 0.1 เป็น 0.15

  // เพิ่มตัวแปรสำหรับแสดงผลเอฟเฟค
  bool showScoreEffect = false;
  double lastAddedScore = 0.0;

  // เพิ่มตัวแปรสำหรับเก็บค่า predictions
  Map<String, List<double>> posePredictions = {};
  Map<String, String> poseIdToName = {};

  // เพิ่มตัวแปรสำหรับฟีเจอร์แสดงฟีดแบ็ค
  String feedbackMessage = "";
  bool showFeedback = false;

  List<Map<String, dynamic>> yogaPoses = [];

  // เพิ่ม Animation Controller สำหรับ Score Effect
  late AnimationController _scoreAnimationController;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    if (widget.programId != null) {
      _initializeProgramHistory().then((_) => fetchYogaPoses());
    }
    _setupMethodChannel();

    // เพิ่ม Animation Controller
    _scoreAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  void _startLoadingCountdown() {
    setState(() {
      isLoading = true;
      countdownSeconds = 3;
      loadingProgress = 0.0;
    });

    // ยกเลิก timer เดิมถ้ามี
    loadingTimer?.cancel();

    // เริ่มนับถอยหลัง
    loadingTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (mounted) {
        setState(() {
          if (countdownSeconds > 0) {
            countdownSeconds--;
            // อัพเดทความคืบหน้าของแถบโหลด
            loadingProgress = 1.0 - (countdownSeconds / 3);
          } else {
            // เมื่อนับถอยหลังเสร็จ ปิดหน้าโหลด
            isLoading = false;
            timer.cancel();
          }
        });
      }
    });
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
            setState(() {
              isResting = false;
            });

            if (currentPoseIndex < yogaPoses.length) {
              // เริ่มต้นท่าโยคะหลังจากวิดีโอพักจบ
              startPose();
            } else {
              // ถ้าทำครบทุกท่าแล้ว ให้ไปหน้าผลลัพธ์
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
            }
          }
          break;

        // 2. แก้ไขส่วนของ case 'onPosePredicted': ในฟังก์ชัน _setupMethodChannel
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

                // เพิ่ม: ส่งสถานะความถูกต้องของท่าไปยัง native code
                bool isPoseCorrect = currentPredictedPose == expectedPoseName;
                setPoseCorrectness(isPoseCorrect);

                if (isPoseCorrect) {
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
                    _scoreAnimationController.forward(from: 0);
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

  // ปรับปรุงฟังก์ชัน fetchYogaPoses()
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
          "video": doc['Video'] ?? "rest_video.mp4", // เพิ่มฟิลด์ video
        };
      }).toList();

      setState(() {
        yogaPoses = fetchedPoses;

        // สร้างการแมปปิ้งระหว่าง ID และชื่อท่า
        poseIdToName = {for (var pose in yogaPoses) pose["id"]: pose["name"]};

        if (yogaPoses.isNotEmpty) {
          // ส่งรายชื่อท่าที่อนุญาตไปยัง native code
          _sendAllowedPoses();

          // เริ่มต้นด้วยวิดีโอสอนท่าแรก
          if (currentPoseIndex < yogaPoses.length) {
            showInstructionVideo(yogaPoses[currentPoseIndex]['video']);
          }
        }
      });
    } catch (e) {
      debugPrint("Error fetching yoga poses: $e");
    }
  }

  // ฟังก์ชัน showInstructionVideo เพื่อเพิ่มตัวแสดงการโหลด
  Future<void> showInstructionVideo(String videoFileName) async {
    setState(() {
      isResting = true;
      // รีเซ็ตและแสดงหน้าโหลดอีกครั้งเมื่อเปลี่ยนท่า
      isLoading = true;
      countdownSeconds = 3;
      loadingProgress = 0.0;
    });

    countdownTimer?.cancel();
    _startLoadingCountdown(); // เริ่มนับถอยหลังใหม่

    try {
      await platform
          .invokeMethod('playRestVideo', {"videoFileName": videoFileName});
    } catch (e) {
      debugPrint("Failed to play instruction video: $e");
      // ถ้าเกิด error ให้จำลองการจบวิดีโอเพื่อเริ่มท่า
      if (mounted) {
        debugPrint("Video error - simulating video completion");
        setState(() {
          isResting = false;
          isLoading = false; // ปิดหน้าโหลดในกรณีเกิดข้อผิดพลาด
        });
        startPose();
      }
    }
  }

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

  // 1. เพิ่มฟังก์ชัน setPoseCorrectness ในคลาส _CameraMediapipeScreenState
  Future<void> setPoseCorrectness(bool isCorrect) async {
    try {
      await platform
          .invokeMethod('setPoseCorrectness', {'isCorrect': isCorrect});
    } catch (e) {
      debugPrint("Error setting pose correctness: $e");
    }
  }

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
            debugPrint("Time's up! Moving to next pose");
            timer.cancel();

            // บันทึกคะแนนของท่าปัจจุบัน
            savePoseScore().then((_) {
              setState(() {
                currentPoseIndex++;
              });

              if (currentPoseIndex < yogaPoses.length) {
                // เล่นวิดีโอสอนของท่าถัดไป
                showInstructionVideo(yogaPoses[currentPoseIndex]['video']);
              } else {
                // ถ้าทำครบทุกท่าแล้ว ให้ไปหน้าผลลัพธ์
                saveProgramHistory().then((_) {
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
                });
              }
            });
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
    loadingTimer?.cancel(); // ยกเลิก timer เมื่อออกจากหน้าจอ
    _scoreAnimationController.dispose();
    super.dispose();
  }

  // 3. สร้างวิดเจ็ตสำหรับแสดงหน้าโหลด
  Widget _buildLoadingScreen() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'เริ่มต้นใน: $countdownSeconds',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'เตรียมพร้อม...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 40),
            // แถบแสดงความคืบหน้า
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(5),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: loadingProgress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.greenAccent,
                        Colors.green,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== เริ่มโค้ด UI ใหม่ =====

  // 1. สร้าง Widget สำหรับแถบเวลา (Timer Bar)
  Widget buildTimerBar(double progressPercentage) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // พื้นหลังหลัก
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF13121A),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          // พื้นหลังของแถบความคืบหน้า
          Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A2B3D),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          // แถบความคืบหน้า
          Padding(
            padding: const EdgeInsets.all(5),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width:
                  (MediaQuery.of(context).size.width - 50) * progressPercentage,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: progressPercentage > 0.5
                      ? [
                          const Color(0xFF4CAF50),
                          const Color(0xFF8BC34A),
                        ]
                      : [
                          const Color(0xFFFFA000),
                          const Color(0xFFFFD700),
                        ],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: (progressPercentage > 0.5
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFFFA000))
                        .withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: -2,
                  ),
                ],
              ),
            ),
          ),
          // Timer icon and text
          Row(
            children: [
              const SizedBox(width: 15),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2A2B3D),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(
                  Icons.timer,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$remainingTime / $totalTime',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // เพิ่มฟังก์ชันใหม่สำหรับนาฬิกาวงกลมแบบไม่มีแถบ
  Widget buildCircularTimer(double progressPercentage) {
    Color timerColor;
    if (progressPercentage > 0.7) {
      timerColor = Colors.green;
    } else if (progressPercentage > 0.3) {
      timerColor = const Color(0xFFFFA000);
    } else {
      timerColor = Colors.red;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13121A).withOpacity(0.85),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // วงกลมพื้นหลัง
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 5,
            backgroundColor: const Color(0xFF2A2B3D),
          ),
          // วงกลมแสดงความคืบหน้า
          CircularProgressIndicator(
            value: progressPercentage,
            strokeWidth: 5,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(timerColor),
          ),
          // แสดงเวลาที่เหลือ/เวลาทั้งหมด
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$remainingTime',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$totalTime',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. สร้าง Widget สำหรับแสดงคะแนน (Score Display)
  Widget buildScoreDisplay() {
    return Container(
      margin: const EdgeInsets.only(top: 0, right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF13121A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.stars,
            color: Color(0xFFFFD700),
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            '${cumulativeScore.toStringAsFixed(0)}/100',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // 3. สร้าง Widget สำหรับแสดงท่าที่ตรวจจับได้ (Detected Pose)
  Widget buildPoseDetectionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF13121A).withOpacity(0.85),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Detected Pose:',
                style: TextStyle(
                  color: Color(0xFF9FA4B4),
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isConnected
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isConnected ? Icons.wifi : Icons.wifi_off,
                      color: isConnected ? Colors.green : Colors.red,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isConnected ? 'Connected' : 'Disconnected',
                      style: TextStyle(
                        color: isConnected ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currentPredictedPose,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Score:',
                style: TextStyle(
                  color: Color(0xFF9FA4B4),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              buildConfidenceIndicator(poseConfidence),
            ],
          ),
        ],
      ),
    );
  }

  // 4. สร้าง Widget สำหรับแสดงระดับความมั่นใจ (Confidence Indicator)
  Widget buildConfidenceIndicator(double confidence) {
    Color indicatorColor;
    if (confidence > 0.7) {
      indicatorColor = Colors.green;
    } else if (confidence > 0.4) {
      indicatorColor = Colors.amber;
    } else {
      indicatorColor = Colors.red;
    }
    return Row(
      children: [
        Text(
          '${(confidence * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            color: indicatorColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 100,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: confidence,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    indicatorColor.withOpacity(0.7),
                    indicatorColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCurrentPoseDisplay() {
    if (currentPoseIndex >= yogaPoses.length) return Container();

    final currentPose = yogaPoses[currentPoseIndex];
    final bool isPoseCorrect = currentPredictedPose == currentPose['name'];
    final String poseName = currentPose['name'] as String;
    final bool isLongPoseName = poseName.length > 15;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF13121A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: isPoseCorrect
              ? const Color(0xFF4CAF50).withOpacity(0.5)
              : Colors.redAccent.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: isResting
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.self_improvement,
                  color: Colors.white70,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  "Resting...",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // For long pose names, use Expanded and handle overflow
                Expanded(
                  child: Center(
                    child: Text(
                      poseName,
                      style: TextStyle(
                        color: isPoseCorrect ? Colors.green : Colors.white,
                        fontSize: isLongPoseName
                            ? 18
                            : 22, // Smaller font for long names
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow:
                          TextOverflow.ellipsis, // Handle extra long names
                      maxLines: isLongPoseName
                          ? 2
                          : 1, // Allow 2 lines for long names
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPoseCorrect
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Icon(
                      isPoseCorrect ? Icons.check : Icons.close,
                      color: isPoseCorrect ? Colors.green : Colors.red,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // 6. สร้าง Widget สำหรับเอฟเฟคได้คะแนน (Score Effect)
  Widget buildScoreEffectAnimation() {
    return AnimatedBuilder(
      animation: _scoreAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: 1.0 - _scoreAnimationController.value,
          child: Transform.translate(
            offset: Offset(0, -30 * _scoreAnimationController.value),
            child: Text(
              '+${lastAddedScore.toStringAsFixed(1)}',
              style: TextStyle(
                color: const Color(0xFFFFD700),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 8.0,
                    color: Colors.black.withOpacity(0.7),
                    offset: const Offset(1.0, 1.0),
                  ),
                  Shadow(
                    blurRadius: 12.0,
                    color: const Color(0xFFFFD700).withOpacity(0.4),
                    offset: const Offset(0.0, 0.0),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // เพิ่มฟังก์ชันใหม่สำหรับแถบคะแนนแนวนอน
  Widget buildHorizontalScoreDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF13121A).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: Color(0xFFFFD700),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${cumulativeScore.toStringAsFixed(0)}/100',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 7. ปรับปรุง build method ของหน้าจอ
  @override
  Widget build(BuildContext context) {
    double progressPercentage = totalTime > 0 ? remainingTime / totalTime : 0;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Camera View (unchanged)
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: AndroidView(
              viewType: 'live_camera_view',
              creationParams: {'camera': 'front'},
              creationParamsCodec: const StandardMessageCodec(),
            ),
          ),

          // 2. Dark overlay at the top - helps with visibility
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. Detected Pose Card (updated)
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF13121A).withOpacity(0.85),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Detected Pose:',
                        style: TextStyle(
                          color: Color(0xFF9FA4B4),
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isConnected
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isConnected ? Icons.wifi : Icons.wifi_off,
                              color: isConnected ? Colors.green : Colors.red,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isConnected ? 'Connected' : 'Disconnected',
                              style: TextStyle(
                                color: isConnected ? Colors.green : Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentPredictedPose,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Score:',
                        style: TextStyle(
                          color: Color(0xFF9FA4B4),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(poseConfidence * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: poseConfidence > 0.7
                              ? Colors.green
                              : poseConfidence > 0.4
                                  ? const Color(0xFFFFA000)
                                  : Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: poseConfidence,
                            child: Container(
                              decoration: BoxDecoration(
                                color: poseConfidence > 0.7
                                    ? Colors.green
                                    : poseConfidence > 0.4
                                        ? const Color(0xFFFFA000)
                                        : Colors.red,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 4. Circular Timer (new design)
          Positioned(
            top: 160,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF13121A).withOpacity(0.85),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 5,
                    backgroundColor: const Color(0xFF2A2B3D),
                  ),
                  // Progress circle
                  CircularProgressIndicator(
                    value: progressPercentage,
                    strokeWidth: 5,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progressPercentage > 0.7
                          ? Colors.green
                          : progressPercentage > 0.3
                              ? const Color(0xFFFFA000)
                              : Colors.red,
                    ),
                  ),
                  // Time
                  Center(
                    child: Text(
                      '$remainingTime',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Score Display (new design)
          Positioned(
            top: 160,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF13121A).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.stars,
                    color: Color(0xFFFFD700),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${cumulativeScore.toStringAsFixed(0)}/100',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 6. Score Effect Animation (moved below score display)
          if (showScoreEffect)
            Positioned(
              top: 225,
              right: 60,
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: 1.0 - value,
                    child: Transform.translate(
                      offset: Offset(0, -10 * value),
                      child: Text(
                        '+${lastAddedScore.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: const Color(0xFFFFD700),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 8.0,
                              color: Colors.black.withOpacity(0.7),
                              offset: const Offset(1.0, 1.0),
                            ),
                            Shadow(
                              blurRadius: 12.0,
                              color: const Color(0xFFFFD700).withOpacity(0.4),
                              offset: const Offset(0.0, 0.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // 7. Current Pose Display (new design)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: widget.programId != null &&
                    yogaPoses.isNotEmpty &&
                    currentPoseIndex < yogaPoses.length
                ? buildCurrentPoseDisplay()
                : Container(),
          ),

          // 8. เพิ่มหน้าโหลดด้านบนสุด (จะแสดงเมื่อ isLoading เป็น true)
          if (isLoading) _buildLoadingScreen(),
        ],
      ),
    );
  }

// Add this method to handle pose display with improved long text support
}
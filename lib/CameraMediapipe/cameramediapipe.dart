// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'pose_result.dart';
// import 'models/yoga_pose.dart';
// import 'utils/score_calculator.dart';
// import 'utils/pose_tracker.dart';
// import 'services/history_service.dart';
// import 'widgets/loading_screen.dart';
// import 'widgets/timer_widgets.dart';
// import 'widgets/score_widgets.dart';
// import 'widgets/pose_widgets.dart';
// import '../services/connectivity_service.dart';
// import 'package:google_fonts/google_fonts.dart';

// class CameraMediapipeApp extends StatelessWidget {
//   final String? programId;

//   const CameraMediapipeApp({super.key, this.programId});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Realtime Pose Detection Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//         textTheme: GoogleFonts.kanitTextTheme(
//           Theme.of(context).textTheme,
//         ),
//         primaryTextTheme: GoogleFonts.kanitTextTheme(
//           Theme.of(context).primaryTextTheme,
//         ),
//       ),
//       debugShowCheckedModeBanner: false,
//       home: CameraMediapipeScreen(programId: programId),
//     );
//   }
// }

// class CameraMediapipeScreen extends StatefulWidget {
//   final String? programId;

//   const CameraMediapipeScreen({super.key, this.programId});

//   @override
//   State<CameraMediapipeScreen> createState() => _CameraMediapipeScreenState();
// }

// class _CameraMediapipeScreenState extends State<CameraMediapipeScreen>
//     with SingleTickerProviderStateMixin {
//   // Utility classes
//   late PoseTracker _poseTracker;
//   late ScoreCalculator _scoreCalculator;
//   HistoryService? _historyService;

//   // Loading state
//   bool isLoading = false;
//   int countdownSeconds = 3;
//   Timer? loadingTimer;
//   double loadingProgress = 0.0;

//   // Timer state
//   int remainingTime = 0;
//   int totalTime = 0;
//   int currentPoseIndex = 0;
//   Timer? countdownTimer;
//   bool isResting = false;

//   // Pose detection state
//   String currentPredictedPose = "Waiting...";
//   double poseConfidence = 0.0;
//   bool isConnected = true;

//   // User data
//   String? currentUser;

//   // Pose data
//   List<Map<String, dynamic>> yogaPoses = [];
//   Map<String, String> poseIdToName = {};

//   // Animation
//   bool showScoreEffect = false;
//   double lastAddedScore = 0.0;
//   late AnimationController _scoreAnimationController;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize ScoreCalculator
//     _scoreCalculator = ScoreCalculator(scoreMultiplier: 0.1);

//     // Initialize PoseTracker with callbacks
//     _poseTracker = PoseTracker(
//       onPosePredicted: _handlePosePrediction,
//       onVideoCompleted: _handleVideoCompleted,
//     );
//     _poseTracker.setupMethodChannel();

//     // Initialize user and program
//     _initializeUser();
//     if (widget.programId != null) {
//       _initializeProgramHistory().then((_) => _fetchYogaPoses());
//     }

//     // Initialize animation controller
//     _scoreAnimationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );

//     // Check connectivity
//     _checkConnectivity();
//     ConnectivityService().isConnected.listen((connected) {
//       if (mounted) {
//         setState(() {
//           isConnected = connected;
//         });
//       }
//     });
//   }

//   Future<void> _checkConnectivity() async {
//     final connected = await ConnectivityService().checkConnection();
//     if (mounted) {
//       setState(() {
//         isConnected = connected;
//       });
//     }
//   }

//   Future<void> _initializeUser() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       setState(() {
//         currentUser = user.uid;
//       });
//     }
//   }

//   Future<void> _initializeProgramHistory() async {
//     if (currentUser == null || widget.programId == null) return;

//     _historyService = HistoryService(
//       userId: currentUser!,
//       programId: widget.programId!,
//     );

//     await _historyService!.initializeProgramHistory();
//   }

//   Future<void> _fetchYogaPoses() async {
//     try {
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('Yoga Pose')
//           .where('Program',
//               isEqualTo: FirebaseFirestore.instance
//                   .collection('Yoga Program')
//                   .doc(widget.programId))
//           .get();

//       final fetchedPoses = querySnapshot.docs.map((doc) {
//         return {
//           "name": doc['Name'],
//           "timeup": doc['Timeup'],
//           "id": doc.id,
//           "video": doc['Video'] ?? "rest_video.mp4",
//         };
//       }).toList();

//       setState(() {
//         yogaPoses = fetchedPoses;
//         poseIdToName = {for (var pose in yogaPoses) pose["id"]: pose["name"]};

//         if (yogaPoses.isNotEmpty) {
//           // ส่งรายชื่อท่าที่อนุญาตไปยัง native code
//           List<String> allowedPoseNames =
//               yogaPoses.map((pose) => pose['name'] as String).toList();
//           _poseTracker.sendAllowedPoses(allowedPoseNames);

//           // เริ่มต้นด้วยวิดีโอสอนท่าแรก
//           if (currentPoseIndex < yogaPoses.length) {
//             _showInstructionVideo(yogaPoses[currentPoseIndex]['video']);
//           }
//         }
//       });
//     } catch (e) {
//       debugPrint("Error fetching yoga poses: $e");
//     }
//   }

//   void _handlePosePrediction(String pose, double confidence) {
//     setState(() {
//       currentPredictedPose = pose;
//       poseConfidence = confidence;
//       isConnected = true;

//       // ตรวจสอบว่าต้องบันทึกข้อมูลการตรวจจับหรือไม่
//       if (currentPoseIndex < yogaPoses.length) {
//         final currentPoseId = yogaPoses[currentPoseIndex]['id'];
//         _poseTracker.addPosePrediction(currentPoseId, confidence * 100);

//         // ถ้าไม่อยู่ในช่วงพัก ให้ตรวจสอบท่าและคำนวณคะแนน
//         if (!isResting) {
//           final expectedPoseName = yogaPoses[currentPoseIndex]['name'];
//           final isPoseCorrect = currentPredictedPose == expectedPoseName;

//           // แจ้ง native code ว่าท่าถูกต้องหรือไม่
//           _poseTracker.setPoseCorrectness(isPoseCorrect);

//           // คำนวณคะแนนเมื่อท่าถูกต้อง
//           if (isPoseCorrect) {
//             final hasAddedScore =
//                 _scoreCalculator.calculateScore(confidence * 100, true);

//             // แสดงเอฟเฟคเมื่อได้คะแนนเพิ่ม
//             if (hasAddedScore) {
//               _showScoreEffect();
//             }
//           }
//         }
//       }
//     });
//   }

//   void _handleVideoCompleted() {
//     if (mounted) {
//       setState(() {
//         isResting = false;
//       });

//       if (currentPoseIndex < yogaPoses.length) {
//         // เริ่มต้นท่าหลังวิดีโอจบ
//         _startPose();
//       } else {
//         // ถ้าทำครบทุกท่าแล้ว ไปหน้าผลลัพธ์
//         _finishProgram();
//       }
//     }
//   }

//   void _showScoreEffect() {
//     setState(() {
//       lastAddedScore = _scoreCalculator.lastAddedScore;
//       showScoreEffect = true;
//     });

//     _scoreAnimationController.forward(from: 0);

//     Future.delayed(const Duration(milliseconds: 800), () {
//       if (mounted) {
//         setState(() {
//           showScoreEffect = false;
//         });
//       }
//     });
//   }

//   Future<void> _finishProgram() async {
//     if (_historyService?.programHistoryId != null) {
//       await _historyService!.saveOverallScore();

//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => PoseResultPage(
//               programId: widget.programId!,
//               programHistoryId: _historyService!.programHistoryId!,
//             ),
//           ),
//         );
//       }
//     }
//   }

//   void _startLoadingCountdown() {
//     setState(() {
//       isLoading = true;
//       countdownSeconds = 3;
//       loadingProgress = 0.0;
//     });

//     // ยกเลิก timer เดิมถ้ามี
//     loadingTimer?.cancel();

//     // เริ่มนับถอยหลัง
//     loadingTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
//       if (mounted) {
//         setState(() {
//           if (countdownSeconds > 0) {
//             countdownSeconds--;
//             // อัพเดทความคืบหน้าของแถบโหลด
//             loadingProgress = 1.0 - (countdownSeconds / 3);
//           } else {
//             // เมื่อนับถอยหลังเสร็จ ปิดหน้าโหลด
//             isLoading = false;
//             timer.cancel();
//           }
//         });
//       }
//     });
//   }

//   Future<void> _showInstructionVideo(String videoFileName) async {
//     setState(() {
//       isResting = true;
//       isLoading = true;
//       countdownSeconds = 3;
//       loadingProgress = 0.0;
//     });

//     countdownTimer?.cancel();
//     _startLoadingCountdown();

//     try {
//       await _poseTracker.playInstructionVideo(videoFileName);
//     } catch (e) {
//       debugPrint("Failed to play instruction video: $e");
//       // ถ้าเกิด error ให้จำลองการจบวิดีโอเพื่อเริ่มท่า
//       if (mounted) {
//         debugPrint("Video error - simulating video completion");
//         setState(() {
//           isResting = false;
//           isLoading = false;
//         });
//         _startPose();
//       }
//     }
//   }

//   void _startPose() {
//     if (currentPoseIndex >= yogaPoses.length) {
//       setState(() {
//         remainingTime = 0;
//       });
//       return;
//     }

//     final currentPose = yogaPoses[currentPoseIndex];
//     setState(() {
//       remainingTime = currentPose['timeup'];
//       totalTime = currentPose['timeup'];
//     });

//     _startCountdown();
//   }

//   void _startCountdown() {
//     countdownTimer?.cancel();
//     countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (mounted) {
//         if (isResting) {
//           timer.cancel();
//           return;
//         }

//         setState(() {
//           if (remainingTime > 0) {
//             remainingTime--;
//           } else {
//             timer.cancel();
//             _savePoseScore().then((_) {
//               setState(() {
//                 currentPoseIndex++;
//               });

//               if (currentPoseIndex < yogaPoses.length) {
//                 // เล่นวิดีโอสอนของท่าถัดไป
//                 _showInstructionVideo(yogaPoses[currentPoseIndex]['video']);
//               } else {
//                 // ถ้าทำครบทุกท่าแล้ว ให้ไปหน้าผลลัพธ์
//                 _finishProgram();
//               }
//             });
//           }
//         });
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   Future<void> _savePoseScore() async {
//     if (currentPoseIndex >= yogaPoses.length || _historyService == null) {
//       return;
//     }

//     final currentPose = yogaPoses[currentPoseIndex];
//     final poseId = currentPose['id'];

//     // รอให้มีการเก็บข้อมูลอย่างน้อย 3 วินาที
//     await Future.delayed(const Duration(seconds: 3));

//     // ดึงข้อมูลการทำนายท่า
//     final predictions = _poseTracker.getPosePredictions(poseId);

//     // ตรวจสอบว่ามีการตรวจจับท่าหรือไม่
//     if (predictions.isEmpty) {
//       debugPrint('No predictions found for pose $poseId - Retrying...');
//       await Future.delayed(const Duration(seconds: 2));

//       // ลองอีกครั้งหลังรอเพิ่ม
//       final retryPredictions = _poseTracker.getPosePredictions(poseId);
//       if (retryPredictions.isEmpty) {
//         debugPrint(
//             'Still no predictions after retry - Recording default score');
//         predictions.add(0.0); // บันทึกคะแนน 0 ถ้าไม่มีข้อมูล
//       } else {
//         predictions.addAll(retryPredictions);
//       }
//     }

//     // บันทึกคะแนนไปยัง Firestore
//     await _historyService!.savePoseScore(
//       poseId: poseId,
//       score: _scoreCalculator.cumulativeScore,
//       predictions: predictions,
//       performance: _scoreCalculator.getPerformanceLevel(),
//     );

//     // รีเซ็ตคะแนนสำหรับท่าต่อไป
//     _scoreCalculator.resetScore();
//   }

//   @override
//   void dispose() {
//     countdownTimer?.cancel();
//     loadingTimer?.cancel();
//     _scoreAnimationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double progressPercentage = totalTime > 0 ? remainingTime / totalTime : 0;

//     return Scaffold(
//       body: Stack(
//         children: [
//           // 1. Camera View
//           SizedBox(
//             width: double.infinity,
//             height: double.infinity,
//             child: AndroidView(
//               viewType: 'live_camera_view',
//               creationParams: {'camera': 'front'},
//               creationParamsCodec: const StandardMessageCodec(),
//             ),
//           ),

//           // 2. Dark overlay at the top - helps with visibility
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             height: 150,
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.black.withOpacity(0.7),
//                     Colors.transparent,
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // 3. Detected Pose Card
//           Positioned(
//             top: 40,
//             left: 20,
//             right: 20,
//             child: PoseDetectionCardWidget(
//               currentPose: currentPredictedPose,
//               confidence: poseConfidence,
//               isConnected: isConnected,
//             ),
//           ),

//           // 4. Circular Timer
//           Positioned(
//             top: 200,
//             left: 20,
//             child: CircularTimerWidget(
//               progressPercentage: progressPercentage,
//               remainingTime: remainingTime,
//               totalTime: totalTime,
//             ),
//           ),

//           // 5. Score Display
//           Positioned(
//             top: 200,
//             right: 20,
//             child: ScoreDisplayWidget(
//               score: _scoreCalculator.cumulativeScore,
//             ),
//           ),

//           // 6. Score Effect Animation
//           if (showScoreEffect)
//             Positioned(
//               top: 265,
//               right: 60,
//               child: ScoreEffectWidget(
//                 addedScore: lastAddedScore,
//                 animation: _scoreAnimationController,
//               ),
//             ),

//           // 7. Current Pose Display
//           Positioned(
//             bottom: 40,
//             left: 20,
//             right: 20,
//             child: widget.programId != null &&
//                     yogaPoses.isNotEmpty &&
//                     currentPoseIndex < yogaPoses.length
//                 ? CurrentPoseDisplayWidget(
//                     poseName: yogaPoses[currentPoseIndex]['name'],
//                     detectedPose: currentPredictedPose,
//                     isResting: isResting,
//                   )
//                 : Container(),
//           ),

//           // 8. Loading Screen (shown when isLoading is true)
//           if (isLoading)
//             LoadingScreen(
//               countdownSeconds: countdownSeconds,
//               loadingProgress: loadingProgress,
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'pose_result.dart';
import 'models/yoga_pose.dart';
import 'utils/score_calculator.dart';
import 'utils/pose_tracker.dart';
import 'services/history_service.dart';
import 'widgets/loading_screen.dart';
import 'widgets/timer_widgets.dart';
import 'widgets/score_widgets.dart';
import 'widgets/pose_widgets.dart';
import 'widgets/no_internetplay_dialog.dart'; // เพิ่มการอิมพอร์ต
import '../Home/Home.dart';
import '../services/connectivity_service.dart';
import 'package:google_fonts/google_fonts.dart';

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
        textTheme: GoogleFonts.kanitTextTheme(
          Theme.of(context).textTheme,
        ),
        primaryTextTheme: GoogleFonts.kanitTextTheme(
          Theme.of(context).primaryTextTheme,
        ),
      ),
      debugShowCheckedModeBanner: false,
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
  // Utility classes
  late PoseTracker _poseTracker;
  late ScoreCalculator _scoreCalculator;
  HistoryService? _historyService;

  // Loading state
  bool isLoading = false;
  int countdownSeconds = 3;
  Timer? loadingTimer;
  double loadingProgress = 0.0;

  // Timer state
  int remainingTime = 0;
  int totalTime = 0;
  int currentPoseIndex = 0;
  Timer? countdownTimer;
  bool isResting = false;

  // Pose detection state
  String currentPredictedPose = "Waiting...";
  double poseConfidence = 0.0;
  bool isConnected = true;

  // Internet connection handling - ตัวแปรใหม่
  bool wasTimerRunning = false;
  bool showingNoInternetDialog = false;

  // User data
  String? currentUser;

  // Pose data
  List<Map<String, dynamic>> yogaPoses = [];
  Map<String, String> poseIdToName = {};

  // Animation
  bool showScoreEffect = false;
  double lastAddedScore = 0.0;
  late AnimationController _scoreAnimationController;

  @override
  void initState() {
    super.initState();

    // Initialize ScoreCalculator
    _scoreCalculator = ScoreCalculator(scoreMultiplier: 0.1);

    // Initialize PoseTracker with callbacks
    _poseTracker = PoseTracker(
      onPosePredicted: _handlePosePrediction,
      onVideoCompleted: _handleVideoCompleted,
    );
    _poseTracker.setupMethodChannel();

    // Initialize user and program
    _initializeUser();
    if (widget.programId != null) {
      _initializeProgramHistory().then((_) => _fetchYogaPoses());
    }

    // Initialize animation controller
    _scoreAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Check connectivity
    _checkConnectivity();

    // อัปเดตการติดตามสถานะการเชื่อมต่อ
    ConnectivityService().isConnected.listen((connected) {
      if (mounted) {
        setState(() {
          // ตรวจสอบว่าสถานะการเชื่อมต่อเปลี่ยนแปลงจริงหรือไม่
          if (isConnected != connected) {
            isConnected = connected;

            if (!isConnected) {
              // สถานะอินเทอร์เน็ตหลุด
              handleConnectionLost();
            } else if (showingNoInternetDialog) {
              // อินเทอร์เน็ตกลับมาใช้งานได้ขณะที่กำลังแสดงไดอะล็อก
              handleConnectionRestored();
            }
          }
        });
      }
    });
  }

  // เมธอดใหม่สำหรับจัดการเมื่อการเชื่อมต่อหลุด
  void handleConnectionLost() {
    // จำไว้ว่าไทม์เมอร์กำลังทำงานอยู่หรือไม่
    wasTimerRunning = countdownTimer?.isActive ?? false;

    // หยุดการทำงานของไทม์เมอร์
    countdownTimer?.cancel();

    // แสดงไดอะล็อกเตือนไม่มีอินเทอร์เน็ต (ถ้ายังไม่ได้แสดง)
    if (!showingNoInternetDialog && mounted) {
      showingNoInternetDialog = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => NoInternetDialog(
          onNavigateHome: () {
            // ปิดไดอะล็อก
            Navigator.of(context).pop();
            showingNoInternetDialog = false;

            // กลับไปที่หน้าหลัก (Home.dart)
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
              (route) => false, // ล้าง stack ทั้งหมด
            );
          },
        ),
      ).then((_) {
        // เมื่อไดอะล็อกถูกปิด
        showingNoInternetDialog = false;
      });
    }
  }

  // เมธอดใหม่สำหรับจัดการเมื่อการเชื่อมต่อกลับมา
  void handleConnectionRestored() {
    // เริ่มไทม์เมอร์ใหม่ถ้าก่อนหน้านี้กำลังทำงานอยู่
    if (wasTimerRunning && !isResting && remainingTime > 0) {
      _startCountdown();
    }

    // ปิดไดอะล็อกถ้ากำลังแสดงอยู่
    if (showingNoInternetDialog && mounted) {
      Navigator.of(context).pop();
      showingNoInternetDialog = false;
    }
  }

  Future<void> _checkConnectivity() async {
    final connected = await ConnectivityService().checkConnection();
    if (mounted) {
      setState(() {
        isConnected = connected;
      });
    }
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
    if (currentUser == null || widget.programId == null) return;

    _historyService = HistoryService(
      userId: currentUser!,
      programId: widget.programId!,
    );

    await _historyService!.initializeProgramHistory();
  }

  Future<void> _fetchYogaPoses() async {
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
          "video": doc['Video'] ?? "rest_video.mp4",
        };
      }).toList();

      setState(() {
        yogaPoses = fetchedPoses;
        poseIdToName = {for (var pose in yogaPoses) pose["id"]: pose["name"]};

        if (yogaPoses.isNotEmpty) {
          // ส่งรายชื่อท่าที่อนุญาตไปยัง native code
          List<String> allowedPoseNames =
              yogaPoses.map((pose) => pose['name'] as String).toList();
          _poseTracker.sendAllowedPoses(allowedPoseNames);

          // เริ่มต้นด้วยวิดีโอสอนท่าแรก
          if (currentPoseIndex < yogaPoses.length) {
            _showInstructionVideo(yogaPoses[currentPoseIndex]['video']);
          }
        }
      });
    } catch (e) {
      debugPrint("Error fetching yoga poses: $e");
    }
  }

  void _handlePosePrediction(String pose, double confidence) {
    setState(() {
      currentPredictedPose = pose;
      poseConfidence = confidence;
      isConnected = true;

      // ตรวจสอบว่าต้องบันทึกข้อมูลการตรวจจับหรือไม่
      if (currentPoseIndex < yogaPoses.length) {
        final currentPoseId = yogaPoses[currentPoseIndex]['id'];
        _poseTracker.addPosePrediction(currentPoseId, confidence * 100);

        // ถ้าไม่อยู่ในช่วงพัก ให้ตรวจสอบท่าและคำนวณคะแนน
        if (!isResting) {
          final expectedPoseName = yogaPoses[currentPoseIndex]['name'];
          final isPoseCorrect = currentPredictedPose == expectedPoseName;

          // แจ้ง native code ว่าท่าถูกต้องหรือไม่
          _poseTracker.setPoseCorrectness(isPoseCorrect);

          // คำนวณคะแนนเมื่อท่าถูกต้อง
          if (isPoseCorrect) {
            final hasAddedScore =
                _scoreCalculator.calculateScore(confidence * 100, true);

            // แสดงเอฟเฟคเมื่อได้คะแนนเพิ่ม
            if (hasAddedScore) {
              _showScoreEffect();
            }
          }
        }
      }
    });
  }

  void _handleVideoCompleted() {
    if (mounted) {
      setState(() {
        isResting = false;
      });

      if (currentPoseIndex < yogaPoses.length) {
        // เริ่มต้นท่าหลังวิดีโอจบ
        _startPose();
      } else {
        // ถ้าทำครบทุกท่าแล้ว ไปหน้าผลลัพธ์
        _finishProgram();
      }
    }
  }

  void _showScoreEffect() {
    setState(() {
      lastAddedScore = _scoreCalculator.lastAddedScore;
      showScoreEffect = true;
    });

    _scoreAnimationController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          showScoreEffect = false;
        });
      }
    });
  }

  Future<void> _finishProgram() async {
    if (_historyService?.programHistoryId != null) {
      await _historyService!.saveOverallScore();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PoseResultPage(
              programId: widget.programId!,
              programHistoryId: _historyService!.programHistoryId!,
            ),
          ),
        );
      }
    }
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

  Future<void> _showInstructionVideo(String videoFileName) async {
    setState(() {
      isResting = true;
      isLoading = true;
      countdownSeconds = 3;
      loadingProgress = 0.0;
    });

    countdownTimer?.cancel();
    _startLoadingCountdown();

    try {
      // ส่งชื่อท่าไปด้วย ไม่ใช่แค่ชื่อไฟล์
      await _poseTracker.playInstructionVideo(videoFileName,
          poseName: currentPoseIndex < yogaPoses.length
              ? yogaPoses[currentPoseIndex]['name']
              : "ท่าโยคะ");
    } catch (e) {
      debugPrint("Failed to play instruction video: $e");
      // ถ้าเกิด error ให้จำลองการจบวิดีโอเพื่อเริ่มท่า
      if (mounted) {
        debugPrint("Video error - simulating video completion");
        setState(() {
          isResting = false;
          isLoading = false;
        });
        _startPose();
      }
    }
  }

  void _startPose() {
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

    _startCountdown();
  }

  void _startCountdown() {
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        // เพิ่มการตรวจสอบสถานะการเชื่อมต่ออินเทอร์เน็ต
        if (!isConnected) {
          timer.cancel();
          return;
        }

        if (isResting) {
          timer.cancel();
          return;
        }

        setState(() {
          if (remainingTime > 0) {
            remainingTime--;
          } else {
            timer.cancel();
            _savePoseScore().then((_) {
              setState(() {
                currentPoseIndex++;
              });

              if (currentPoseIndex < yogaPoses.length) {
                // เล่นวิดีโอสอนของท่าถัดไป
                _showInstructionVideo(
                  yogaPoses[currentPoseIndex]['video'],
                );
              } else {
                // ถ้าทำครบทุกท่าแล้ว ให้ไปหน้าผลลัพธ์
                _finishProgram();
              }
            });
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _savePoseScore() async {
    if (currentPoseIndex >= yogaPoses.length || _historyService == null) {
      return;
    }

    final currentPose = yogaPoses[currentPoseIndex];
    final poseId = currentPose['id'];

    // รอให้มีการเก็บข้อมูลอย่างน้อย 3 วินาที
    await Future.delayed(const Duration(seconds: 3));

    // ดึงข้อมูลการทำนายท่า
    final predictions = _poseTracker.getPosePredictions(poseId);

    // ตรวจสอบว่ามีการตรวจจับท่าหรือไม่
    if (predictions.isEmpty) {
      debugPrint('No predictions found for pose $poseId - Retrying...');
      await Future.delayed(const Duration(seconds: 2));

      // ลองอีกครั้งหลังรอเพิ่ม
      final retryPredictions = _poseTracker.getPosePredictions(poseId);
      if (retryPredictions.isEmpty) {
        debugPrint(
            'Still no predictions after retry - Recording default score');
        predictions.add(0.0); // บันทึกคะแนน 0 ถ้าไม่มีข้อมูล
      } else {
        predictions.addAll(retryPredictions);
      }
    }

    // บันทึกคะแนนไปยัง Firestore
    await _historyService!.savePoseScore(
      poseId: poseId,
      score: _scoreCalculator.cumulativeScore,
      predictions: predictions,
      performance: _scoreCalculator.getPerformanceLevel(),
    );

    // รีเซ็ตคะแนนสำหรับท่าต่อไป
    _scoreCalculator.resetScore();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    loadingTimer?.cancel();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progressPercentage = totalTime > 0 ? remainingTime / totalTime : 0;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Camera View
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

          // 3. Detected Pose Card
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: PoseDetectionCardWidget(
              currentPose: currentPredictedPose,
              confidence: poseConfidence,
              isConnected: isConnected,
            ),
          ),

          // 4. Circular Timer
          Positioned(
            top: 200,
            left: 20,
            child: CircularTimerWidget(
              progressPercentage: progressPercentage,
              remainingTime: remainingTime,
              totalTime: totalTime,
            ),
          ),

          // 5. Score Display
          Positioned(
            top: 200,
            right: 20,
            child: ScoreDisplayWidget(
              score: _scoreCalculator.cumulativeScore,
            ),
          ),

          // 6. Score Effect Animation
          if (showScoreEffect)
            Positioned(
              top: 265,
              right: 60,
              child: ScoreEffectWidget(
                addedScore: lastAddedScore,
                animation: _scoreAnimationController,
              ),
            ),

          // 7. Current Pose Display
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: widget.programId != null &&
                    yogaPoses.isNotEmpty &&
                    currentPoseIndex < yogaPoses.length
                ? CurrentPoseDisplayWidget(
                    poseName: yogaPoses[currentPoseIndex]['name'],
                    detectedPose: currentPredictedPose,
                    isResting: isResting,
                  )
                : Container(),
          ),

          // 8. Loading Screen (shown when isLoading is true)
          if (isLoading)
            LoadingScreen(
              countdownSeconds: countdownSeconds,
              loadingProgress: loadingProgress,
            ),
        ],
      ),
    );
  }
}

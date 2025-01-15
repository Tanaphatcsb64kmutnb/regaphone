// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

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
//       ),
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

// class _CameraMediapipeScreenState extends State<CameraMediapipeScreen> {
//   static const platform = MethodChannel('live_camera_view');

//   int remainingTime = 0;
//   int totalTime = 0;
//   int currentPoseIndex = 0;
//   Timer? countdownTimer;
//   bool isResting = false;

//   // เพิ่มตัวแปรสำหรับเก็บผล prediction
//   String currentPredictedPose = "Waiting...";
//   double poseConfidence = 0.0;
//   bool isConnected = true; // สถานะการเชื่อมต่อกับ Flask server

//   List<Map<String, dynamic>> yogaPoses = [];

//   @override
//   void initState() {
//     super.initState();
//     if (widget.programId != null) {
//       fetchYogaPoses();
//     }
//     _setupMethodChannel();
//   }

//   void _setupMethodChannel() {
//     platform.setMethodCallHandler((call) async {
//       switch (call.method) {
//         case 'videoCompleted':
//           if (mounted) {
//             setState(() {
//               isResting = false;
//               currentPoseIndex++;
//             });
//             Future.delayed(const Duration(milliseconds: 100), () {
//               if (mounted) {
//                 startPose();
//               }
//             });
//           }
//           break;
//         case 'onPosePredicted':
//           final Map<String, dynamic> prediction =
//               Map<String, dynamic>.from(call.arguments);
//           setState(() {
//             currentPredictedPose = prediction['pose'] as String;
//             poseConfidence = prediction['confidence'] as double;
//             isConnected = true;
//           });
//           break;
//         case 'onPredictionError':
//           setState(() {
//             isConnected = false;
//           });
//           break;
//       }
//     });
//   }

//   Future<void> fetchYogaPoses() async {
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
//         };
//       }).toList();

//       setState(() {
//         yogaPoses = fetchedPoses;
//         if (yogaPoses.isNotEmpty) {
//           startPose();
//         }
//       });
//     } catch (e) {
//       debugPrint("Error fetching yoga poses: $e");
//     }
//   }

//   void startPose() {
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

//     startCountdown();
//   }

//   void startCountdown() {
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
//             if (!isResting) {
//               showRestVideo();
//             }
//           }
//         });
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   Future<void> showRestVideo() async {
//     setState(() {
//       isResting = true;
//     });

//     countdownTimer?.cancel();

//     try {
//       await platform.invokeMethod('playRestVideo');
//     } catch (e) {
//       debugPrint("Failed to play rest video: $e");
//       if (mounted) {
//         setState(() {
//           isResting = false;
//         });
//         startPose();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     countdownTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentPose = currentPoseIndex < yogaPoses.length
//         ? yogaPoses[currentPoseIndex]
//         : null;

//     // Calculate progress percentage
//     double progressPercentage = remainingTime / totalTime;

//     // Calculate color based on remaining time
//     Color getProgressColor(double progress) {
//       if (progress >= 0.7) {
//         return Colors.green;
//       } else if (progress >= 0.3) {
//         return Color.lerp(
//           Colors.yellow,
//           Colors.green,
//           (progress - 0.3) / 0.4,
//         )!;
//       } else {
//         return Color.lerp(
//           Colors.red,
//           Colors.yellow,
//           progress / 0.3,
//         )!;
//       }
//     }

//     return Scaffold(
//       body: Stack(
//         children: [
//           // Camera View
//           SizedBox(
//             width: double.infinity,
//             height: double.infinity,
//             child: AndroidView(
//               viewType: 'live_camera_view',
//               creationParams: {'camera': 'front'},
//               creationParamsCodec: const StandardMessageCodec(),
//             ),
//           ),

//           // Progress Bar
//           if (widget.programId != null && yogaPoses.isNotEmpty)
//             Positioned(
//               top: 30,
//               left: 20,
//               right: 20,
//               child: Container(
//                 height: 35,
//                 decoration: BoxDecoration(
//                   color: const Color.fromARGB(255, 0, 0, 0),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Stack(
//                   children: [
//                     AnimatedContainer(
//                       duration: const Duration(milliseconds: 500),
//                       width: (MediaQuery.of(context).size.width - 40) *
//                           progressPercentage,
//                       decoration: BoxDecoration(
//                         color: getProgressColor(progressPercentage),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                     ),
//                     Center(
//                       child: Text(
//                         '$remainingTime / $totalTime',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//           // Pose Prediction Display
//           Positioned(
//             top: 80,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.7),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 children: [
//                   Text(
//                     'Detected Pose: $currentPredictedPose',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Confidence: ${(poseConfidence * 100).toStringAsFixed(1)}%',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.9),
//                       fontSize: 16,
//                     ),
//                   ),
//                   if (!isConnected)
//                     const Text(
//                       'Connection Error',
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontSize: 14,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),

//           // Current Pose Display
//           if (widget.programId != null && yogaPoses.isNotEmpty)
//             Positioned(
//               bottom: 60,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.7),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: isResting
//                       ? const Text(
//                           "Resting...",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         )
//                       : currentPose != null
//                           ? Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   currentPose['name'],
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 if (currentPredictedPose == currentPose['name'])
//                                   const Text(
//                                     'Correct Pose! 👍',
//                                     style: TextStyle(
//                                       color: Colors.green,
//                                       fontSize: 18,
//                                     ),
//                                   )
//                               ],
//                             )
//                           : const Text(
//                               "Completed!",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// cameramediapipe.dart
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
  double? lastPredictionScore;
  String? programHistoryId;
  Map<String, List<double>> posePredictions =
      {}; // เพิ่มตัวแปรเก็บค่า predictions

  List<Map<String, dynamic>> yogaPoses = [];

  @override
  void initState() {
    super.initState();
    _initializeUser();
    if (widget.programId != null) {
      fetchYogaPoses();
    }
    _setupMethodChannel();
  }

  Future<void> _initializeUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUser = user.uid;
    }
  }

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
        if (yogaPoses.isNotEmpty) {
          startPose();
        }
      });
    } catch (e) {
      debugPrint("Error fetching yoga poses: $e");
    }
  }

  void _setupMethodChannel() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'videoCompleted':
          if (mounted) {
            // Save the last pose score before moving to next pose
            if (currentPoseIndex < yogaPoses.length) {
              await savePoseScore();
            }

            setState(() {
              isResting = false;
              currentPoseIndex++;
            });

            if (currentPoseIndex >= yogaPoses.length) {
              // Program completed, save program history
              await saveProgramHistory();
              // Navigate to results page
              if (mounted) {
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

        case 'onPosePredicted':
          final Map<String, dynamic> prediction =
              Map<String, dynamic>.from(call.arguments);
          setState(() {
            currentPredictedPose = prediction['pose'] as String;
            lastPredictionScore = prediction['confidence'] as double;
            poseConfidence = lastPredictionScore!;
            isConnected = true;

            // เก็บค่า prediction ระหว่างเล่น
            if (currentPoseIndex < yogaPoses.length) {
              final currentPoseId = yogaPoses[currentPoseIndex]['id'];
              if (!posePredictions.containsKey(currentPoseId)) {
                posePredictions[currentPoseId] = [];
              }
              posePredictions[currentPoseId]!.add(lastPredictionScore! * 100);
              debugPrint(
                  'Added prediction for pose $currentPoseId: ${lastPredictionScore! * 100}');
            }
          });
          break;

        case 'onPredictionError':
          setState(() {
            isConnected = false;
          });
          break;
      }
    });
  }

  Future<void> savePoseScore() async {
    if (currentPoseIndex >= yogaPoses.length) return;

    final currentPose = yogaPoses[currentPoseIndex];
    final poseId = currentPose['id'];

    // คำนวณค่าเฉลี่ยของ predictions ทั้งหมด
    final predictions = posePredictions[poseId] ?? [];
    if (predictions.isEmpty) {
      debugPrint('No predictions found for pose $poseId');
      return;
    }

    final avgScore = predictions.reduce((a, b) => a + b) / predictions.length;
    debugPrint(
        'Average score for pose $poseId: $avgScore (from ${predictions.length} predictions)');

    try {
      // บันทึกค่าเฉลี่ยลง Firebase
      final docRef =
          await FirebaseFirestore.instance.collection('YogaPose History').add({
        'Pose_id': FirebaseFirestore.instance.doc('Yoga Pose/$poseId'),
        'Pose_score': avgScore,
        'Performance': _getPerformanceLevel(avgScore),
        'Date': DateTime.now(),
        'Time': DateTime.now(),
        'User': FirebaseFirestore.instance.doc('Users/$currentUser'),
        'Program':
            FirebaseFirestore.instance.doc('Yoga Program/${widget.programId}'),
        'history_id': '', // จะอัพเดทภายหลัง
        'prediction_count': predictions.length, // เพิ่มจำนวนครั้งที่ predict
        'predictions': predictions, // เก็บค่าทั้งหมดไว้ด้วย
      });

      // Store score for final summary
      poseScores[poseId] = avgScore;
    } catch (e) {
      debugPrint("Error saving pose score: $e");
    }

    // ล้างค่า predictions สำหรับท่าต่อไป
    posePredictions.remove(poseId);
  }

  String _getPerformanceLevel(double score) {
    if (score >= 75) return 'สุดยอดมาก';
    if (score >= 50) return 'ดี';
    if (score >= 25) return 'ปานกลาง';
    return 'พอใช้';
  }

  Future<void> saveProgramHistory() async {
    if (poseScores.isEmpty) return;

    try {
      double totalScore = 0;
      poseScores.forEach((_, score) => totalScore += score);
      final averageScore = totalScore / poseScores.length;

      // Save to YogaProgram History
      final docRef = await FirebaseFirestore.instance
          .collection('YogaProgram History')
          .add({
        'Ovr_score': averageScore,
        'User': FirebaseFirestore.instance.doc('Users/$currentUser'),
        'Program_id':
            FirebaseFirestore.instance.doc('Yoga Program/${widget.programId}'),
        'Date': DateTime.now(),
        'Time': DateTime.now(),
      });

      programHistoryId = docRef.id;

      // Update all YogaPose History entries with the history_id
      final querySnapshot = await FirebaseFirestore.instance
          .collection('YogaPose History')
          .where('Program',
              isEqualTo: FirebaseFirestore.instance
                  .doc('Yoga Program/${widget.programId}'))
          .where('User',
              isEqualTo: FirebaseFirestore.instance.doc('Users/$currentUser'))
          .get();

      for (var doc in querySnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('YogaPose History')
            .doc(doc.id)
            .update({'history_id': docRef.id});
      }
    } catch (e) {
      debugPrint("Error saving program history: $e");
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
        if (isResting) {
          timer.cancel();
          return;
        }

        setState(() {
          if (remainingTime > 0) {
            remainingTime--;
          } else {
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
      if (mounted) {
        setState(() {
          isResting = false;
        });
        startPose();
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

    double progressPercentage = remainingTime / totalTime;

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
                  Text(
                    'Confidence: ${(poseConfidence * 100).toStringAsFixed(1)}%',
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
    } else {
      return Color.lerp(
        Colors.red,
        Colors.yellow,
        progress / 0.3,
      )!;
    }
  }
}

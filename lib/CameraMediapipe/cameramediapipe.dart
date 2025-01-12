// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class CameraMediapipeApp extends StatelessWidget {
//   const CameraMediapipeApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Realtime Pose Detection Demo',
//       home: const CameraMediapipeScreen(),
//     );
//   }
// }

// class CameraMediapipeScreen extends StatefulWidget {
//   const CameraMediapipeScreen({super.key});

//   @override
//   State<CameraMediapipeScreen> createState() => _CameraMediapipeScreenState();
// }

// class _CameraMediapipeScreenState extends State<CameraMediapipeScreen> {
//   bool isFrontCamera = true;
//   static const platform =
//       MethodChannel('live_camera_view'); // สร้าง MethodChannel เพียงครั้งเดียว

//   void toggleCamera() async {
//     try {
//       await platform.invokeMethod(
//         'switchCamera',
//         {'camera': isFrontCamera ? 'front' : 'rear'},
//       );
//       setState(() {
//         isFrontCamera = !isFrontCamera;
//       });
//     } catch (e) {
//       print('Failed to switch camera: $e');
//     }
//   }

//   @override
//   void dispose() {
//     // หากมีการสร้างทรัพยากรเพิ่มเติมหรือจำเป็นต้องปิดการเชื่อมต่อ ให้เพิ่มโค้ดที่นี่
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Realtime Pose Detection'),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return Stack(
//             children: [
//               Center(
//                 child: SizedBox(
//                   width: constraints.maxWidth,
//                   height: constraints.maxHeight,
//                   child: AndroidView(
//                     viewType: 'live_camera_view',
//                     creationParams: {
//                       'camera': isFrontCamera ? 'front' : 'rear'
//                     },
//                     creationParamsCodec: const StandardMessageCodec(),
//                     // ถ้า Flutter SDK และ Native รองรับ Hybrid Composition ให้กำหนด useHybridComposition
//                     // เช่น: creationParamsCodec: const StandardMessageCodec(),
//                     //         // useHybridComposition: true,
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: 20,
//                 left: 20,
//                 right: 20,
//                 child: FloatingActionButton(
//                   onPressed: toggleCamera,
//                   backgroundColor: Colors.blue,
//                   child: Icon(
//                     isFrontCamera ? Icons.camera_front : Icons.camera_rear,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class CameraMediapipeApp extends StatelessWidget {
//   final String? programId; // ทำให้ programId เป็น nullable

//   const CameraMediapipeApp({super.key, this.programId});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Realtime Pose Detection Demo',
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
//   bool isFrontCamera = true;
//   static const platform = MethodChannel('live_camera_view');

//   int remainingTime = 0;
//   int currentPoseIndex = 0;
//   Timer? countdownTimer;

//   List<Map<String, dynamic>> yogaPoses = [];

//   @override
//   void initState() {
//     super.initState();
//     if (widget.programId != null) {
//       fetchYogaPoses(); // ดึงข้อมูลจาก Firebase เมื่อมี programId
//     }
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

//       if (querySnapshot.docs.isEmpty) {
//         print("No yoga poses found for programId: ${widget.programId}");
//       }

//       final fetchedPoses = querySnapshot.docs.map((doc) {
//         print("Fetched pose: ${doc.data()}");
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
//       print("Error fetching yoga poses: $e");
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
//     });

//     countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (remainingTime > 0) {
//         setState(() {
//           remainingTime--;
//         });
//       } else {
//         timer.cancel();
//         showRestVideo();
//       }
//     });
//   }

//   void showRestVideo() async {
//     print("Invoking playRestVideo...");
//     try {
//       await platform.invokeMethod('playRestVideo');
//       print("Rest video started successfully");
//       setState(() {
//         currentPoseIndex++;
//       });
//       startPose();
//     } catch (e) {
//       print("Failed to play rest video: $e");
//     }
//   }

//   void toggleCamera() async {
//     try {
//       await platform.invokeMethod(
//         'switchCamera',
//         {'camera': isFrontCamera ? 'front' : 'rear'},
//       );
//       setState(() {
//         isFrontCamera = !isFrontCamera;
//       });
//     } catch (e) {
//       print('Failed to switch camera: $e');
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

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Realtime Pose Detection'),
//       ),
//       body: Stack(
//         children: [
//           Center(
//             child: SizedBox(
//               width: double.infinity,
//               height: double.infinity,
//               child: AndroidView(
//                 viewType: 'live_camera_view',
//                 creationParams: {'camera': isFrontCamera ? 'front' : 'rear'},
//                 creationParamsCodec: const StandardMessageCodec(),
//               ),
//             ),
//           ),
//           if (widget.programId != null && yogaPoses.isNotEmpty)
//             Positioned(
//               top: 20,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.5),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: currentPose != null
//                       ? Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               "Current Pose: ${currentPose['name']}",
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(
//                               "Time Remaining: $remainingTime s",
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         )
//                       : const Text(
//                           "Yoga Program Completed!",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                 ),
//               ),
//             ),
//           Positioned(
//             bottom: 20,
//             left: 20,
//             right: 20,
//             child: FloatingActionButton(
//               onPressed: toggleCamera,
//               backgroundColor: Colors.blue,
//               child: Icon(
//                 isFrontCamera ? Icons.camera_front : Icons.camera_rear,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// CameraMediapipeApp.dart
// CameraMediapipeApp.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  List<Map<String, dynamic>> yogaPoses = [];

  @override
  void initState() {
    super.initState();
    if (widget.programId != null) {
      fetchYogaPoses();
    }
    _setupMethodChannel();
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
      print("Error fetching yoga poses: $e");
    }
  }

  void _setupMethodChannel() {
    platform.setMethodCallHandler((call) async {
      if (call.method == "videoCompleted") {
        if (mounted) {
          setState(() {
            isResting = false;
            currentPoseIndex++;
          });
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              startPose();
            }
          });
        }
        return null;
      }
      return null;
    });
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
      print("Failed to play rest video: $e");
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

    // Calculate progress percentage
    double progressPercentage = remainingTime / totalTime;

    // Calculate color based on remaining time
    Color getProgressColor(double progress) {
      if (progress >= 0.7) {
        return Colors.green;
      } else if (progress >= 0.3) {
        // Interpolate between green and yellow
        return Color.lerp(
          Colors.yellow,
          Colors.green,
          (progress - 0.3) / 0.4,
        )!;
      } else {
        // Interpolate between red and yellow
        return Color.lerp(
          Colors.red,
          Colors.yellow,
          progress / 0.3,
        )!;
      }
    }

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
                        color: getProgressColor(progressPercentage),
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
                          ? Text(
                              currentPose['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
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
}

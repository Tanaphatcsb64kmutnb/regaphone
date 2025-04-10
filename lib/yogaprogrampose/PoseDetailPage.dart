// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/services.dart';
// import '../services/storage_service.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class PoseDetailPage extends StatefulWidget {
//   final String poseId;
//   static const platform = MethodChannel('single_video_view');

//   const PoseDetailPage({Key? key, required this.poseId}) : super(key: key);

//   @override
//   State<PoseDetailPage> createState() => _PoseDetailPageState();
// }

// class _PoseDetailPageState extends State<PoseDetailPage> with AutomaticKeepAliveClientMixin {
//   final StorageService _storageService = StorageService();
//   String _poseVideoName = '';
//   bool _isVideoPreloading = false;
//   bool _isVideoPreloaded = false;
//   bool _isLoading = true;
//   int _preloadProgress = 0;
//   String _imageUrl = '';
//   Map<String, dynamic>? _poseData;

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();
//     _initMethodChannelListeners();
//     _loadPoseData();
//   }

//   void _initMethodChannelListeners() {
//     PoseDetailPage.platform.setMethodCallHandler((call) async {
//       switch (call.method) {
//         case 'videoPreloadProgress':
//           if (mounted) {
//             setState(() {
//               _preloadProgress = call.arguments['progress'] ?? 0;
//             });
//           }
//           break;
//         case 'videoPreloaded':
//           if (mounted) {
//             setState(() {
//               _isVideoPreloaded = true;
//               _isVideoPreloading = false;
//               _preloadProgress = 100;
//             });
//           }
//           break;
//         case 'videoPreloadFailed':
//           if (mounted) {
//             setState(() {
//               _isVideoPreloading = false;
//               _isVideoPreloaded = false;
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('ไม่สามารถโหลดวิดีโอได้'),
//                 backgroundColor: Colors.red,
//               )
//             );
//           }
//           break;
//       }
//     });
//   }

//   // โหลดข้อมูลท่าโยคะและเตรียมวิดีโอล่วงหน้า
//   Future<void> _loadPoseData() async {
//     try {
//       // ดึงข้อมูลท่าโยคะ
//       final poseDoc = await FirebaseFirestore.instance
//           .collection('Yoga Pose')
//           .doc(widget.poseId)
//           .get();

//       if (poseDoc.exists) {
//         final poseData = poseDoc.data() as Map<String, dynamic>;
//         final posePicture = poseData['Picture'] ?? '';
//         final poseVideo = poseData['Video'] ?? 'rest_video.mp4';

//         // ดึง URL รูปภาพ
//         String imageUrl = '';
//         if (posePicture.isNotEmpty) {
//           imageUrl = await _storageService.getImageUrl(posePicture);
//         }

//         if (mounted) {
//           setState(() {
//             _poseData = poseData;
//             _poseVideoName = poseVideo;
//             _imageUrl = imageUrl;
//             _isLoading = false;
//           });
//         }

//         // เริ่มเตรียมวิดีโอล่วงหน้าทันที
//         _preloadVideo(poseVideo);
//       } else {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('Error loading pose data: $e');
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   // เตรียมวิดีโอล่วงหน้า
//   void _preloadVideo(String videoFileName) {
//     if (_isVideoPreloading || _isVideoPreloaded) return;

//     setState(() {
//       _isVideoPreloading = true;
//       _preloadProgress = 0;
//     });

//     // เริ่มโหลดวิดีโอ
//     PoseDetailPage.platform.invokeMethod(
//       'preloadVideo',
//       {"videoFileName": videoFileName}
//     );
//   }

//   // เล่นวิดีโอ
//   Future<void> _playVideo(String videoFileName) async {
//     try {
//       // ถ้าวิดีโอพร้อมแล้ว ให้ใช้เวอร์ชันที่โหลดไว้ล่วงหน้า
//       await PoseDetailPage.platform.invokeMethod(
//         'playPreloadedVideo',
//         {"videoFileName": videoFileName}
//       );
//     } catch (e) {
//       debugPrint("Error playing preloaded video: $e");

//       // ถ้าเกิดข้อผิดพลาด ใช้วิธีเล่นแบบปกติ
//       try {
//         await PoseDetailPage.platform.invokeMethod(
//           'playSingleVideo',
//           {"videoFileName": videoFileName}
//         );
//       } catch (playError) {
//         debugPrint("Fallback video play error: $playError");
//         // แสดง Snackbar เพื่อแจ้งผู้ใช้
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text('ไม่สามารถเล่นวิดีโอได้: $playError'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);  // สำหรับ AutomaticKeepAliveClientMixin

//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (_poseData == null) {
//       return Scaffold(
//         body: Container(
//           color: Colors.black,
//           child: const Center(
//             child: Text(
//               'ไม่พบข้อมูลท่าโยคะนี้',
//               style: TextStyle(fontSize: 18, color: Colors.white),
//             ),
//           ),
//         ),
//       );
//     }

//     final poseName = _poseData!['Name'] ?? 'No Name';
//     final poseDescription = _poseData!['Description'] ?? 'No Description';
//     final poseTime = _poseData!['Timeup'] ?? 0;

//     return Scaffold(
//       body: Stack(
//         children: [
//           // รูปภาพพื้นหลัง
//           Positioned.fill(
//             child: _imageUrl.isNotEmpty
//                 ? CachedNetworkImage(
//                     imageUrl: _imageUrl,
//                     fit: BoxFit.cover,
//                     placeholder: (context, url) => const Center(
//                       child: CircularProgressIndicator(),
//                     ),
//                     errorWidget: (context, url, error) => const Center(
//                       child: Icon(
//                         Icons.broken_image,
//                         color: Colors.white,
//                         size: 48,
//                       ),
//                     ),
//                   )
//                 : Container(color: Colors.black),
//           ),
//           // ชั้นสีดำโปร่งใส
//           Positioned.fill(
//             child: Container(
//               color: Colors.black.withOpacity(0.7),
//             ),
//           ),
//           // เนื้อหาในหน้า
//           SafeArea(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // ปุ่มย้อนกลับ
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: IconButton(
//                     icon: const Icon(Icons.arrow_back,
//                         color: Colors.white, size: 28),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ),
//                 // ข้อมูลท่าโยคะ
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // ชื่อท่า (ภาษาไทย)
//                       Text(
//                         poseName,
//                         style: const TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       // ชื่อท่า (ภาษาอังกฤษ)
//                       Text(
//                         poseName.toUpperCase(),
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w300,
//                           color: Colors.white70,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       // ระยะเวลา
//                       Row(
//                         children: [
//                           const Icon(Icons.timer,
//                               color: Colors.greenAccent, size: 20),
//                           const SizedBox(width: 8),
//                           Text(
//                             '$poseTime นาที',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               color: Colors.greenAccent,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       // รายละเอียด
//                       Text(
//                         poseDescription,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.white70,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Spacer(),
//                 // ปุ่มดูวิดีโอ
//                 Center(
//                   child: Column(
//                     children: [
//                       // Progress indicator สำหรับการโหลดวิดีโอ
//                       if (_isVideoPreloading)
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           child: LinearProgressIndicator(
//                             value: _preloadProgress / 100,
//                             backgroundColor: Colors.grey.shade300,
//                             valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
//                           ),
//                         ),

//                       const SizedBox(height: 8),

//                       // ปุ่มเล่นวิดีโอ
//                       ElevatedButton.icon(
//                         onPressed: _isVideoPreloading ? null : () {
//                           _playVideo(_poseVideoName);
//                         },
//                         icon: Icon(
//                           _isVideoPreloaded
//                               ? Icons.play_circle_filled
//                               : Icons.play_circle_outline,
//                           color: Colors.white,
//                         ),
//                         label: Text(
//                           _isVideoPreloaded
//                               ? 'ดูวิดีโอ'
//                               : (_isVideoPreloading
//                                   ? 'กำลังเตรียมวิดีโอ... ${_preloadProgress}%'
//                                   : 'ดูวิดีโอ'),
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _isVideoPreloaded
//                               ? Colors.green.shade700
//                               : Colors.grey.shade700,
//                           foregroundColor: Colors.white,
//                           disabledBackgroundColor: Colors.grey.shade600,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 12,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PoseDetailPage extends StatefulWidget {
  final String poseId;
  static const platform = MethodChannel('single_video_view');

  const PoseDetailPage({Key? key, required this.poseId}) : super(key: key);

  @override
  State<PoseDetailPage> createState() => _PoseDetailPageState();
}

class _PoseDetailPageState extends State<PoseDetailPage>
    with AutomaticKeepAliveClientMixin {
  final StorageService _storageService = StorageService();
  String _poseVideoName = '';
  bool _isVideoPreloading = false;
  bool _isVideoPreloaded = false;
  bool _isLoading = true;
  String _imageUrl = '';
  Map<String, dynamic>? _poseData;

  // เพิ่ม Timeout สำหรับการโหลดวิดีโอ
  final Duration _preloadTimeout = const Duration(seconds: 30);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPoseData();
  }

  // โหลดข้อมูลท่าโยคะและเตรียมวิดีโอล่วงหน้า
  Future<void> _loadPoseData() async {
    try {
      // ดึงข้อมูลท่าโยคะ
      final poseDoc = await FirebaseFirestore.instance
          .collection('Yoga Pose')
          .doc(widget.poseId)
          .get();

      if (poseDoc.exists) {
        final poseData = poseDoc.data() as Map<String, dynamic>;
        final posePicture = poseData['Picture'] ?? '';
        final poseVideo = poseData['Video'] ?? 'rest_video.mp4';

        // ดึง URL รูปภาพ
        String imageUrl = '';
        if (posePicture.isNotEmpty) {
          imageUrl = await _storageService.getImageUrl(posePicture);
        }

        if (mounted) {
          setState(() {
            _poseData = poseData;
            _poseVideoName = poseVideo;
            _imageUrl = imageUrl;
            _isLoading = false;
          });
        }

        // เริ่มเตรียมวิดีโอล่วงหน้าทันที
        _preloadVideo(poseVideo);
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading pose data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // เตรียมวิดีโอล่วงหน้า (ไม่ต้องรอการ await)
  void _preloadVideo(String videoFileName) {
    if (_isVideoPreloading || _isVideoPreloaded) return;

    setState(() {
      _isVideoPreloading = true;
    });

    // เริ่มโหลดวิดีโอโดยไม่รอ พร้อมกำหนด Timeout
    Future.any([
      PoseDetailPage.platform
          .invokeMethod('preloadVideo', {"videoFileName": videoFileName}),
      Future.delayed(_preloadTimeout, () {
        throw TimeoutException('Video preload timeout');
      })
    ]).then((_) {
      if (mounted) {
        setState(() {
          _isVideoPreloaded = true;
          _isVideoPreloading = false;
        });
      }
    }).catchError((e) {
      debugPrint("Error preloading video: $e");
      if (mounted) {
        setState(() {
          _isVideoPreloading = false;
          _isVideoPreloaded = false;
        });
      }
    });
  }

  // เล่นวิดีโอ
  Future<void> _playVideo(String videoFileName) async {
    try {
      // เพิ่ม timeout สำหรับการเล่นวิดีโอ
      await Future.any([
        PoseDetailPage.platform.invokeMethod(
            'playPreloadedVideo', {"videoFileName": videoFileName}),
        Future.delayed(_preloadTimeout, () {
          throw TimeoutException('Video play timeout');
        })
      ]);
    } catch (e) {
      debugPrint("Error playing preloaded video: $e");

      // ถ้าเกิดข้อผิดพลาด ใช้วิธีเล่นแบบปกติ
      try {
        await Future.any([
          PoseDetailPage.platform.invokeMethod(
              'playSingleVideo', {"videoFileName": videoFileName}),
          Future.delayed(_preloadTimeout, () {
            throw TimeoutException('Single video play timeout');
          })
        ]);
      } catch (playError) {
        debugPrint("Fallback video play error: $playError");
        // แสดง Snackbar หรือ Dialog เพื่อแจ้งผู้ใช้
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('ไม่สามารถเล่นวิดีโอได้ในขณะนี้: $playError'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // สำหรับ AutomaticKeepAliveClientMixin

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_poseData == null) {
      return Scaffold(
        body: Container(
          color: Colors.black,
          child: const Center(
            child: Text(
              'ไม่พบข้อมูลท่าโยคะนี้',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      );
    }

    final poseName = _poseData!['Name'] ?? 'No Name';
    final poseDescription = _poseData!['Description'] ?? 'No Description';
    final poseTime = _poseData!['Timeup'] ?? 0;

    return Scaffold(
      body: Stack(
        children: [
          // รูปภาพพื้นหลัง
          Positioned.fill(
            child: _imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: _imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  )
                : Container(color: Colors.black),
          ),
          // ชั้นสีดำโปร่งใส
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          // เนื้อหาในหน้า
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ปุ่มย้อนกลับ
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // ข้อมูลท่าโยคะ
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ชื่อท่า (ภาษาไทย)
                      Text(
                        poseName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // ชื่อท่า (ภาษาอังกฤษ)
                      Text(
                        poseName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // ระยะเวลา
                      Row(
                        children: [
                          const Icon(Icons.timer,
                              color: Colors.greenAccent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '$poseTime นาที',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // รายละเอียด
                      Text(
                        poseDescription,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // ปุ่มดูวิดีโอ
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _playVideo(_poseVideoName);
                    },
                    icon: Icon(
                      _isVideoPreloaded
                          ? Icons.play_circle_filled
                          : Icons.play_circle_outline,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isVideoPreloaded
                          ? 'ดูวิดีโอ'
                          : (_isVideoPreloading
                              ? 'กำลังเตรียมวิดีโอ...'
                              : 'ดูวิดีโอ'),
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isVideoPreloaded
                          ? Colors.green.shade700
                          : Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// เพิ่ม Custom Exception สำหรับ Timeout
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // เพิ่ม import นี้

class PoseDetailPage extends StatelessWidget {
  final String poseId;
  static const platform =
      MethodChannel('single_video_view'); // เพิ่ม MethodChannel

  const PoseDetailPage({Key? key, required this.poseId}) : super(key: key);

  // เพิ่มฟังก์ชันเล่นวิดีโอ
  Future<void> _playVideo(String videoFileName) async {
    try {
      await platform
          .invokeMethod('playSingleVideo', {"videoFileName": videoFileName});
    } catch (e) {
      debugPrint("Error playing video: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Yoga Pose')
            .doc(poseId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'ไม่พบข้อมูลท่าโยคะนี้',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            );
          }

          final poseData = snapshot.data!;
          final poseName = poseData['Name'] ?? 'No Name';
          final poseDescription = poseData['Description'] ?? 'No Description';
          final poseTime = poseData['Timeup'] ?? 0;
          final posePicture = poseData['Picture'] ?? '';
          final poseVideo =
              poseData['Video'] ?? 'rest_video.mp4'; // เพิ่มการอ่านฟิลด์ Video

          return Stack(
            children: [
              // รูปภาพพื้นหลัง
              Positioned.fill(
                child: Image.asset(
                  'assets/img/$posePicture',
                  fit: BoxFit.cover,
                ),
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
                    // ปุ่มดูวิดีโอ - แก้ไขเพื่อเล่นวิดีโอจากฟิลด์ Video
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // เล่นวิดีโอตามฟิลด์ Video จาก Firestore
                          _playVideo(poseVideo);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'ดูวิดีโอ',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
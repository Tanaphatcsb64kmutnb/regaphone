import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PoseDetailPage extends StatelessWidget {
  final String poseId; // รับ ID ของท่าโยคะ

  const PoseDetailPage({Key? key, required this.poseId}) : super(key: key);

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

          return Stack(
            children: [
              // รูปภาพพื้นหลัง
              Positioned.fill(
                child: Image.asset(
                  'assets/img/$posePicture', // Path รูปพื้นหลังจาก Firestore
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
                    // ปุ่มดูวิดีโอ
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: ฟังก์ชันเล่นวิดีโอสามารถเพิ่มได้ในอนาคต
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('ฟีเจอร์เล่นวิดีโอยังไม่พร้อมใช้งาน'),
                            ),
                          );
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

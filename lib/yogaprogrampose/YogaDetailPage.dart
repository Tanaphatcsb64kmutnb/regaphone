import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'PoseDetailPage.dart';
import '../CameraMediapipe/cameramediapipe.dart'; // Import หน้า CameraMediapipe

class YogaDetailPage extends StatelessWidget {
  final String programId;

  const YogaDetailPage({Key? key, required this.programId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // พื้นหลังรูปภาพ
          Positioned.fill(
            child: Image.asset(
              'assets/img/officesyndrome.jpg', // Path รูปพื้นหลัง
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
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Yoga Program')
                  .doc(programId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: Text(
                      'ไม่พบข้อมูลโปรแกรมนี้',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  );
                }

                final programData = snapshot.data!;
                final programName = programData['Name'] ?? 'No Name';
                final programTime = programData['Time_up'] ?? 0;

                return Column(
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
                    // ชื่อโปรแกรม
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        programName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // ระยะเวลาโปรแกรม
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ระยะเวลาที่ใช้ทั้งหมด $programTime นาที',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ปุ่มเล่นและ Favorite
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CameraMediapipeApp(), // ไปที่หน้า CameraMediapipe
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
                            child: const Text('เล่น'),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              // TODO: เพิ่มฟังก์ชัน Favorite
                            },
                            icon: const Icon(Icons.favorite_border,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // GridView แสดงรายการท่าโยคะ
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Yoga Pose')
                            .where('Program',
                                isEqualTo: FirebaseFirestore.instance
                                    .doc('Yoga Program/$programId'))
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text(
                                'ไม่มีท่าโยคะในโปรแกรมนี้',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }

                          final yogaPoses = snapshot.data!.docs;

                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: yogaPoses.length,
                            itemBuilder: (context, index) {
                              final yogaPose = yogaPoses[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PoseDetailPage(
                                        poseId: yogaPose.id, // ส่ง Pose ID
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/img/${yogaPose['Picture']}', // Path รูปภาพจาก Firestore
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

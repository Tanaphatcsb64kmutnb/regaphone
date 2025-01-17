// import 'package:flutter/material.dart';

// class HistoryPage extends StatelessWidget {
//   const HistoryPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // ข้อมูลประวัติตัวอย่าง
//     const String programTitle = 'OFFICE SYNDROME';
//     const String lastPlayedDate = '2/8/2567';
//     const String lastPlayedTime = '01:57 น.';
//     const String imagePath = 'assets/img/listBG.png'; // รูปในการ์ด

//     return Scaffold(
//       // ไม่ใส่ appBar เพื่อออกแบบ Header เอง (Stack + Positioned)
//       body: Stack(
//         children: [
//           // ภาพพื้นหลัง
//           Positioned.fill(
//             child: Image.asset(
//               'assets/img/yoga4.png', // พื้นหลังตามต้องการ
//               fit: BoxFit.cover,
//             ),
//           ),

//           // เลเยอร์ไล่สีดำโปร่งใสเล็กน้อย ทับบนพื้นหลัง เพื่อให้อ่านข้อความได้ชัด
//           Positioned.fill(
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.black.withOpacity(0.7),
//                     Colors.black.withOpacity(0.3),
//                     Colors.black.withOpacity(0.7),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // เนื้อหาทับด้านบน
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ปุ่มย้อนกลับ
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: const Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.arrow_back, color: Colors.white),
//                         SizedBox(width: 4),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   // หัวข้อหลัก
//                   const Text(
//                     'ประวัติการเล่นโยคะของคุณ',
//                     style: TextStyle(
//                       fontSize: 28,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   // การ์ดแสดงประวัติล่าสุด
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.4),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: [
//                         // รูปในการ์ด (ทรงโค้งมน)
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: Image.asset(
//                             imagePath,
//                             width: 80,
//                             height: 80,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         const SizedBox(width: 16),

//                         // ข้อความรายละเอียด
//                         const Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 programTitle,
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 'เล่นล่าสุด : $lastPlayedDate\nเวลา: $lastPlayedTime',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.white70,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   // Spacer ดันลงไปด้านล่าง ตามดีไซน์
//                   const Spacer(),

//                   // Footer หรือจะใส่ลายน้ำอะไรก็ได้ตามต้องการ
//                   // Container(
//                   //   alignment: Alignment.center,
//                   //   child: Text(
//                   //     'Footer',
//                   //     style: TextStyle(color: Colors.white38),
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../CameraMediapipe/pose_result.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    print('Current user ID: ${currentUser?.uid}'); // Debug log

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/img/yoga4.png',
              fit: BoxFit.cover,
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child:
                            const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'ประวัติการเล่นโยคะของคุณ',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // History List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('YogaProgramHistory')
                        .where('User', isEqualTo: '/Users/${currentUser?.uid}')
                        .orderBy('Time')
                        .snapshots()
                      ..listen((snapshot) {
                        print('Query path: YogaProgramHistory');
                        print('User path: /Users/${currentUser?.uid}');
                        print(
                            'Received snapshot with ${snapshot.docs.length} documents');
                        for (var doc in snapshot.docs) {
                          print('Document data: ${doc.data()}');
                        }
                      }),
                    builder: (context, snapshot) {
                      // แสดง error ถ้ามี
                      if (snapshot.hasError) {
                        print('Error in StreamBuilder: ${snapshot.error}');
                        return Center(
                          child: Text(
                            'เกิดข้อผิดพลาด: ${snapshot.error}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'ยังไม่มีประวัติการเล่น',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        );
                      }

                      // เรียงข้อมูลใหม่เพื่อให้แสดงล่าสุดก่อน
                      final docs = snapshot.data!.docs.toList()
                        ..sort((a, b) => (b.get('Time') as Timestamp)
                            .compareTo(a.get('Time') as Timestamp));

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;

                          // Debug logs
                          print('Processing document: ${doc.id}');
                          print('Document data: $data');

                          final timestamp = data['Time'] as Timestamp;
                          final date = timestamp.toDate();
                          final programId =
                              data['Program_id'] as DocumentReference;
                          final score = (data['Ovr_score'] as num?) ?? 0;

                          return FutureBuilder<DocumentSnapshot>(
                            future: programId.get(),
                            builder: (context, programSnapshot) {
                              if (!programSnapshot.hasData) {
                                return const SizedBox.shrink();
                              }

                              final programData = programSnapshot.data!.data()
                                  as Map<String, dynamic>;
                              final programName =
                                  programData['Name'] ?? 'Unknown Program';
                              final programImage =
                                  programData['Picture'] ?? 'listBG.png';

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PoseResultPage(
                                          programId: programId.id,
                                          programHistoryId: doc.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Program Image
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.asset(
                                            'assets/img/$programImage',
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.white54,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 16),

                                        // Program Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                programName,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'คะแนน: ${score.round()}%',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              Text(
                                                'เล่นเมื่อ: ${DateFormat('dd/MM/yyyy HH:mm').format(date)} น.',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Arrow Icon
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white54,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../CameraMediapipe/pose_result.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view history',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

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

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'ประวัติการเล่นโยคะของคุณ',
                        style: TextStyle(
                          fontSize: 24,
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
                        .where('User',
                            isEqualTo: FirebaseFirestore.instance
                                .doc('Users/${user?.uid}'))
                        .orderBy('Date', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.white)),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'ยังไม่มีประวัติการเล่นโยคะ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final doc = snapshot.data!.docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final score = data['Ovr_score'] as double? ?? 0.0;
                          final date = (data['Date'] as Timestamp).toDate();
                          final programRef =
                              data['Program_id'] as DocumentReference;

                          return FutureBuilder<DocumentSnapshot>(
                            future: programRef.get(),
                            builder: (context, programSnapshot) {
                              if (!programSnapshot.hasData) {
                                return const SizedBox();
                              }

                              final programData = programSnapshot.data!.data()
                                  as Map<String, dynamic>?;
                              final programName =
                                  programData?['Name'] ?? 'Unknown Program';
                              final programImage =
                                  programData?['Picture'] ?? 'listBG.png';

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PoseResultPage(
                                          programId: programRef.id,
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
                                                'คะแนน: ${score.toStringAsFixed(1)}%',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: _getScoreColor(score),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                'เล่นเมื่อ: ${DateFormat('dd/MM/yyyy HH:mm').format(date)}',
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

  Color _getScoreColor(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.yellow;
    if (score >= 25) return Colors.orange;
    return Colors.red;
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'PoseDetailPage.dart';
// import '../CameraMediapipe/cameramediapipe.dart'; // Import หน้า CameraMediapipe

// class YogaDetailPage extends StatelessWidget {
//   final String programId;

//   const YogaDetailPage({Key? key, required this.programId}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     debugPrint(
//         'Program ID received: $programId'); // ตรวจสอบ Program ID ที่รับเข้ามา

//     return Scaffold(
//       body: Stack(
//         children: [
//           // พื้นหลังรูปภาพ
//           Positioned.fill(
//             child: Image.asset(
//               'assets/img/officesyndrome.jpg', // Path รูปพื้นหลัง
//               fit: BoxFit.cover,
//             ),
//           ),
//           // ชั้นสีดำโปร่งใส
//           Positioned.fill(
//             child: Container(
//               color: Colors.black.withOpacity(0.7),
//             ),
//           ),
//           // เนื้อหาในหน้า
//           SafeArea(
//             child: FutureBuilder<DocumentSnapshot>(
//               future: FirebaseFirestore.instance
//                   .collection('Yoga Program')
//                   .doc(programId)
//                   .get(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (!snapshot.hasData || !snapshot.data!.exists) {
//                   debugPrint(
//                       'No program data found for Program ID: $programId');
//                   return const Center(
//                     child: Text(
//                       'ไม่พบข้อมูลโปรแกรมนี้',
//                       style: TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                   );
//                 }

//                 final programData = snapshot.data!;
//                 debugPrint(
//                     'Program Data: ${programData.data()}'); // Debug ข้อมูลโปรแกรม

//                 final programName = programData['Name'] ?? 'No Name';
//                 final programTime = programData['Time_up'] ?? 0;

//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // ปุ่มย้อนกลับ
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: IconButton(
//                         icon: const Icon(Icons.arrow_back,
//                             color: Colors.white, size: 28),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                     ),
//                     // ชื่อโปรแกรม
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Text(
//                         programName.toUpperCase(),
//                         style: const TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                     // ระยะเวลาโปรแกรม
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Text(
//                         'ระยะเวลาที่ใช้ทั้งหมด $programTime นาที',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.greenAccent,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     // ปุ่มเล่นและ Favorite
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: Row(
//                         children: [
//                           ElevatedButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => CameraMediapipeApp(
//                                       programId: programId), // ส่ง programId
//                                 ),
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.grey.shade700,
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             child: const Text('เล่น'),
//                           ),
//                           const SizedBox(width: 8),
//                           IconButton(
//                             onPressed: () {
//                               // TODO: เพิ่มฟังก์ชัน Favorite
//                             },
//                             icon: const Icon(Icons.favorite_border,
//                                 color: Colors.white),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     // GridView แสดงรายการท่าโยคะ
//                     Expanded(
//                       child: StreamBuilder<QuerySnapshot>(
//                         stream: FirebaseFirestore.instance
//                             .collection('Yoga Pose')
//                             .where('Program',
//                                 isEqualTo: FirebaseFirestore.instance
//                                     .doc('Yoga Program/$programId'))
//                             .snapshots(), // ดึงข้อมูลทั้งหมด
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return const Center(
//                                 child: CircularProgressIndicator());
//                           }
//                           if (!snapshot.hasData ||
//                               snapshot.data!.docs.isEmpty) {
//                             debugPrint('No Yoga Pose data found!');
//                             return const Center(
//                               child: Text(
//                                 'ไม่มีข้อมูลโยคะ',
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             );
//                           }

//                           final yogaPoses = snapshot.data!.docs;
//                           debugPrint('Total Yoga Poses: ${yogaPoses.length}');
//                           for (var pose in yogaPoses) {
//                             debugPrint(
//                                 'Pose ID: ${pose.id}, Data: ${pose.data()}');
//                           }

//                           return GridView.builder(
//                             padding: const EdgeInsets.all(16),
//                             gridDelegate:
//                                 const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               crossAxisSpacing: 8,
//                               mainAxisSpacing: 8,
//                             ),
//                             itemCount: yogaPoses.length,
//                             itemBuilder: (context, index) {
//                               final yogaPose = yogaPoses[index];
//                               return GestureDetector(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => PoseDetailPage(
//                                         poseId: yogaPose.id,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(12),
//                                   child: Image.asset(
//                                     'assets/img/${yogaPose['Picture']}',
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'PoseDetailPage.dart';
import '../CameraMediapipe/cameramediapipe.dart'; // Import หน้า CameraMediapipe

class YogaDetailPage extends StatelessWidget {
  final String programId;

  const YogaDetailPage({Key? key, required this.programId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint(
        'Program ID received: $programId'); // ตรวจสอบ Program ID ที่รับเข้ามา

    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Yoga Program')
            .doc(programId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            debugPrint('No program data found for Program ID: $programId');
            return const Center(
              child: Text(
                'ไม่พบข้อมูลโปรแกรมนี้',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            );
          }

          final programData = snapshot.data!;
          debugPrint(
              'Program Data: ${programData.data()}'); // Debug ข้อมูลโปรแกรม

          final programName = programData['Name'] ?? 'No Name';
          final programTime = programData['Time_up'] ?? 0;
          final backgroundFileName = programData['Picture'] ??
              ''; // ดึงชื่อไฟล์พื้นหลังจาก field Picture

          return Stack(
            children: [
              // พื้นหลัง (ใช้รูปจาก assets ตามชื่อไฟล์ที่ดึงมา)
              Positioned.fill(
                child: backgroundFileName.isNotEmpty
                    ? Image.asset(
                        'assets/img/$backgroundFileName', // ใช้ชื่อไฟล์จาก field Picture
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white,
                              size: 48,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 48,
                        ),
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
                      debugPrint(
                          'No program data found for Program ID: $programId');
                      return const Center(
                        child: Text(
                          'ไม่พบข้อมูลโปรแกรมนี้',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      );
                    }

                    final programData = snapshot.data!;
                    debugPrint(
                        'Program Data: ${programData.data()}'); // Debug ข้อมูลโปรแกรม

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
                                      builder: (context) => CameraMediapipeApp(
                                          programId:
                                              programId), // ส่ง programId
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
                                .snapshots(), // ดึงข้อมูลทั้งหมด
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                debugPrint('No Yoga Pose data found!');
                                return const Center(
                                  child: Text(
                                    'ไม่มีข้อมูลโยคะ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              }

                              final yogaPoses = snapshot.data!.docs;
                              debugPrint(
                                  'Total Yoga Poses: ${yogaPoses.length}');
                              for (var pose in yogaPoses) {
                                debugPrint(
                                    'Pose ID: ${pose.id}, Data: ${pose.data()}');
                              }

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
                                            poseId: yogaPose.id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        'assets/img/${yogaPose['Picture']}',
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
          );
        },
      ),
    );
  }
}

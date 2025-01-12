// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'YogaDetailPage.dart'; // สำหรับแสดงท่าที่อยู่ในโปรแกรมนั้น

// class ProgramDetailPage extends StatelessWidget {
//   final String programId;

//   const ProgramDetailPage({Key? key, required this.programId})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<DocumentSnapshot>(
//         future: FirebaseFirestore.instance
//             .collection('Yoga Program')
//             .doc(programId)
//             .get(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return const Center(
//               child: Text(
//                 'ไม่พบข้อมูลโปรแกรมนี้',
//                 style: TextStyle(fontSize: 18, color: Colors.white),
//               ),
//             );
//           }

//           final programData = snapshot.data!;
//           final programName = programData['Name'] ?? 'No Name';
//           final programDescription =
//               programData['Description'] ?? 'No Description';

//           return Stack(
//             children: [
//               // พื้นหลัง
//               Positioned.fill(
//                 child: Image.asset(
//                   'assets/img/listBG.png', // Path รูปพื้นหลัง
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               // ชั้นสีดำโปร่งใส
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black.withOpacity(0.7),
//                 ),
//               ),
//               // เนื้อหา
//               SafeArea(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // ชื่อโปรแกรม
//                       Text(
//                         programName,
//                         style: const TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       // คำอธิบายโปรแกรม
//                       Text(
//                         programDescription,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.white70,
//                         ),
//                       ),
//                       const Spacer(),
//                       // ปุ่มดูรายละเอียดเพิ่มเติม
//                       Center(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => YogaDetailPage(
//                                   programId: programId, // ส่ง ID ของโปรแกรม
//                                 ),
//                               ),
//                             );
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFFA0A0A0),
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: const Text(
//                             'ดูรายละเอียดเพิ่มเติม',
//                             style: TextStyle(fontSize: 16),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       // ปุ่มย้อนกลับ
//                       Center(
//                         child: TextButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           child: const Text(
//                             '< ย้อนกลับ',
//                             style: TextStyle(fontSize: 16, color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     ],
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'YogaDetailPage.dart'; // สำหรับแสดงท่าที่อยู่ในโปรแกรมนั้น

class ProgramDetailPage extends StatelessWidget {
  final String programId;

  const ProgramDetailPage({Key? key, required this.programId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            return const Center(
              child: Text(
                'ไม่พบข้อมูลโปรแกรมนี้',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            );
          }

          final programData = snapshot.data!;
          final programName = programData['Name'] ?? 'No Name';
          final programDescription =
              programData['Description'] ?? 'No Description';
          final pictureFileName =
              programData['Picture'] ?? ''; // ดึงชื่อไฟล์รูปจาก field Picture

          return Stack(
            children: [
              // พื้นหลัง (ใช้รูปจาก assets ตามชื่อไฟล์ที่ดึงมา)
              Positioned.fill(
                child: pictureFileName.isNotEmpty
                    ? Image.asset(
                        'assets/img/$pictureFileName', // ใช้ชื่อไฟล์จาก field Picture
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
              // เนื้อหา
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ชื่อโปรแกรม
                      Text(
                        programName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // คำอธิบายโปรแกรม
                      Text(
                        programDescription,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const Spacer(),
                      // ปุ่มดูรายละเอียดเพิ่มเติม
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => YogaDetailPage(
                                  programId: programId, // ส่ง ID ของโปรแกรม
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA0A0A0),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'ดูรายละเอียดเพิ่มเติม',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // ปุ่มย้อนกลับ
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            '< ย้อนกลับ',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

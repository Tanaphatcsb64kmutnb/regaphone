// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // เพิ่ม import นี้
// import './ProgramDetailPage.dart';

// class YogaListPage extends StatelessWidget {
//   const YogaListPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser;

//     return Scaffold(
//       body: Stack(
//         children: [
//           // พื้นหลังรูป listBG.png
//           Positioned.fill(
//             child: Image.asset(
//               'assets/img/listBG.png', // Path ของรูป listBG.png
//               fit: BoxFit.cover,
//             ),
//           ),
//           // ชั้นสีดำโปร่งใส
//           Positioned.fill(
//             child: Container(
//               color: Colors.black.withOpacity(0.8), // ปรับความโปร่งใส
//             ),
//           ),
//           SafeArea(
//             child: Column(
//               children: [
//                 // AppBar
//                 AppBar(
//                   backgroundColor: Colors.transparent,
//                   elevation: 0,
//                   title: const Text(
//                     'REGA', // ชื่อแอป
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   centerTitle: true,
//                   leading: IconButton(
//                     icon: const Icon(Icons.arrow_back, color: Colors.white),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ),
//                 // เนื้อหาในหน้า
//                 Expanded(
//                   child: StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance
//                         .collection('Yoga Program')
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                         return const Center(
//                           child: Text(
//                             'ไม่มีรายการโยคะในขณะนี้',
//                             style: TextStyle(color: Colors.white, fontSize: 16),
//                           ),
//                         );
//                       }

//                       final yogaPrograms = snapshot.data!.docs;

//                       return ListView.builder(
//                         padding: const EdgeInsets.all(16),
//                         itemCount: yogaPrograms.length,
//                         itemBuilder: (context, index) {
//                           final yogaProgram = yogaPrograms[index];
//                           final pictureFileName = yogaProgram['Picture'] ??
//                               ''; // ชื่อไฟล์รูปภาพจาก field Picture

//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 16),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(16),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.5),
//                                   blurRadius: 10,
//                                   spreadRadius: 1,
//                                   offset: const Offset(0, 5),
//                                 ),
//                               ],
//                             ),
//                             child: Stack(
//                               children: [
//                                 // รูปภาพของรายการ
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(16),
//                                   child: pictureFileName.isNotEmpty
//                                       ? Image.asset(
//                                           'assets/img/$pictureFileName', // ใช้ชื่อไฟล์รูปภาพ
//                                           width: double.infinity,
//                                           height: 180,
//                                           fit: BoxFit.cover,
//                                         )
//                                       : const Center(
//                                           child: Icon(
//                                             Icons.broken_image,
//                                             color: Colors.white,
//                                             size: 48,
//                                           ),
//                                         ),
//                                 ),
//                                 // เลเยอร์โปร่งใส
//                                 Positioned.fill(
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(16),
//                                       color: Colors.black
//                                           .withOpacity(0.4), // ปรับ opacity
//                                     ),
//                                   ),
//                                 ),
//                                 // ชื่อโปรแกรม
//                                 Positioned(
//                                   top: 16,
//                                   left: 16,
//                                   child: Text(
//                                     yogaProgram['Name'] ?? 'No Name',
//                                     style: const TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                                 // "Yoga Therapy" Text
//                                 Positioned(
//                                   top: 16,
//                                   right: 16,
//                                   child: const Text(
//                                     'Yoga Therapy',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.white70,
//                                     ),
//                                   ),
//                                 ),
//                                 // ปุ่ม Know More
//                                 Positioned(
//                                   bottom: 16,
//                                   right: 16,
//                                   child: ElevatedButton(
//                                     onPressed: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               ProgramDetailPage(
//                                             programId: yogaProgram.id,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor:
//                                           const Color.fromARGB(164, 0, 0, 0),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                     ),
//                                     child: const Text(
//                                       'Know More',
//                                       style: TextStyle(
//                                           fontSize: 14, color: Colors.white),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
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
import 'package:firebase_auth/firebase_auth.dart';
import './ProgramDetailPage.dart';
import 'package:firebase_storage/firebase_storage.dart'; // เพิ่ม import สำหรับ Firebase Storage

class YogaListPage extends StatelessWidget {
  const YogaListPage({Key? key}) : super(key: key);

  // เพิ่มฟังก์ชันสำหรับดึง URL ของรูปภาพจาก Firebase Storage
  Future<String> _getImageUrl(String imageName) async {
    try {
      if (imageName.isEmpty) return '';

      // ใช้ Reference เพื่อชี้ไปที่ไฟล์ในพาธที่ต้องการ
      final ref = FirebaseStorage.instance.ref().child('Yogapose/$imageName');
      // ดึง URL สำหรับดาวน์โหลด
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Error getting image URL: $e");
      return ''; // ส่งค่าว่างกลับไปในกรณีที่มีข้อผิดพลาด
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          // พื้นหลังรูป listBG.png - แก้ไขเป็นใช้ FutureBuilder เพื่อโหลดรูปจาก Storage
          Positioned.fill(
            child: FutureBuilder<String>(
              future: _getImageUrl(
                  'listBG.png'), // เปลี่ยนเป็นชื่อไฟล์ที่ถูกต้องในพาธ Yogapose/
              builder: (context, urlSnapshot) {
                if (urlSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!urlSnapshot.hasData || urlSnapshot.data!.isEmpty) {
                  return Container(
                    color: Colors.black, // ถ้าไม่มีรูปใช้พื้นหลังสีดำแทน
                  );
                }
                // ใช้ Network Image แทน Asset Image
                return Image.network(
                  urlSnapshot.data!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color:
                          Colors.black, // ถ้าโหลดรูปมีปัญหาใช้พื้นหลังสีดำแทน
                    );
                  },
                );
              },
            ),
          ),
          // ชั้นสีดำโปร่งใส
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.8), // ปรับความโปร่งใส
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // AppBar
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: const Text(
                    'REGA', // ชื่อแอป
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // เนื้อหาในหน้า
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Yoga Program')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'ไม่มีรายการโยคะในขณะนี้',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        );
                      }

                      final yogaPrograms = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: yogaPrograms.length,
                        itemBuilder: (context, index) {
                          final yogaProgram = yogaPrograms[index];
                          final pictureFileName = yogaProgram['Picture'] ?? '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // รูปภาพของรายการ - แก้ไขเป็นใช้ FutureBuilder เพื่อโหลดรูปจาก Storage
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: FutureBuilder<String>(
                                    future: _getImageUrl(pictureFileName),
                                    builder: (context, urlSnapshot) {
                                      if (urlSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Container(
                                          width: double.infinity,
                                          height: 180,
                                          color: Colors.grey.shade800,
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }
                                      if (!urlSnapshot.hasData ||
                                          urlSnapshot.data!.isEmpty) {
                                        return Container(
                                          width: double.infinity,
                                          height: 180,
                                          color: Colors.grey.shade800,
                                          child: const Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              color: Colors.white,
                                              size: 48,
                                            ),
                                          ),
                                        );
                                      }
                                      // ใช้ Network Image แทน Asset Image
                                      return Image.network(
                                        urlSnapshot.data!,
                                        width: double.infinity,
                                        height: 180,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            width: double.infinity,
                                            height: 180,
                                            color: Colors.grey.shade800,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: double.infinity,
                                            height: 180,
                                            color: Colors.grey.shade800,
                                            child: const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                color: Colors.white,
                                                size: 48,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                // เลเยอร์โปร่งใส
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.black
                                          .withOpacity(0.4), // ปรับ opacity
                                    ),
                                  ),
                                ),
                                // ชื่อโปรแกรม
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  child: Text(
                                    yogaProgram['Name'] ?? 'No Name',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                // "Yoga Therapy" Text

                                // ปุ่ม Know More
                                Positioned(
                                  bottom: 16,
                                  right: 16,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProgramDetailPage(
                                            programId: yogaProgram.id,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(164, 0, 0, 0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Know More',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

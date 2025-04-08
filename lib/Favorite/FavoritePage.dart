// // FavoritePage.dart
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../yogaprogrampose/ProgramDetailPage.dart';

// class FavoritePage extends StatelessWidget {
//   final String userId;

//   const FavoritePage({Key? key, required this.userId}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // ภาพพื้นหลัง
//           Positioned.fill(
//             child: Image.asset(
//               'assets/img/yoga2.png',
//               fit: BoxFit.cover,
//             ),
//           ),
//           // Gradient overlay
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
//           // เนื้อหาหลัก
//           SafeArea(
//             child: Column(
//               children: [
//                 // ส่วนหัวพร้อมปุ่มย้อนกลับและหัวข้อตรงกลาง
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   child: Stack(
//                     children: [
//                       // ปุ่มย้อนกลับด้านซ้าย
//                       Positioned(
//                         left: 16,
//                         child: GestureDetector(
//                           onTap: () => Navigator.pop(context),
//                           child: const Icon(
//                             Icons.arrow_back,
//                             color: Colors.white,
//                             size: 24,
//                           ),
//                         ),
//                       ),
//                       // หัวข้อตรงกลาง
//                       const Center(
//                         child: Text(
//                           'รายการโปรด',
//                           style: TextStyle(
//                             fontSize: 20,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // ส่วนเนื้อหา
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: StreamBuilder<QuerySnapshot>(
//                       stream: FirebaseFirestore.instance
//                           .collection('FavoriteYogaProgram')
//                           .where('userId',
//                               isEqualTo: FirebaseFirestore.instance
//                                   .doc('Users/$userId'))
//                           .snapshots(),
//                       builder: (context, favSnapshot) {
//                         if (favSnapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(
//                               child: CircularProgressIndicator());
//                         }

//                         if (!favSnapshot.hasData ||
//                             favSnapshot.data!.docs.isEmpty) {
//                           return const Center(
//                             child: Text(
//                               'ยังไม่มีรายการโปรด',
//                               style:
//                                   TextStyle(color: Colors.white, fontSize: 16),
//                             ),
//                           );
//                         }

//                         return ListView.builder(
//                           itemCount: favSnapshot.data!.docs.length,
//                           itemBuilder: (context, index) {
//                             final favoriteDoc = favSnapshot.data!.docs[index];
//                             final programRef = favoriteDoc['yogaProgramId']
//                                 as DocumentReference;

//                             return FutureBuilder<DocumentSnapshot>(
//                               future: programRef.get(),
//                               builder: (context, programSnapshot) {
//                                 if (!programSnapshot.hasData) {
//                                   return const SizedBox();
//                                 }

//                                 final programData = programSnapshot.data!;
//                                 final programName =
//                                     programData['Name'] ?? 'No Name';
//                                 final description =
//                                     programData['Description'] ??
//                                         'No Description';
//                                 final pictureFileName =
//                                     programData['Picture'] ?? '';

//                                 return Padding(
//                                   padding: const EdgeInsets.only(bottom: 16),
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               ProgramDetailPage(
//                                             programId: programRef.id,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     child: Container(
//                                       padding: const EdgeInsets.all(16),
//                                       decoration: BoxDecoration(
//                                         color: Colors.black.withOpacity(0.4),
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: Row(
//                                         children: [
//                                           ClipRRect(
//                                             borderRadius:
//                                                 BorderRadius.circular(8),
//                                             child: Image.asset(
//                                               'assets/img/$pictureFileName',
//                                               width: 80,
//                                               height: 80,
//                                               fit: BoxFit.cover,
//                                               errorBuilder:
//                                                   (context, error, stackTrace) {
//                                                 return Container(
//                                                   width: 80,
//                                                   height: 80,
//                                                   color: Colors.grey,
//                                                   child: const Icon(
//                                                       Icons.broken_image),
//                                                 );
//                                               },
//                                             ),
//                                           ),
//                                           const SizedBox(width: 16),
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   programName,
//                                                   style: const TextStyle(
//                                                     fontSize: 18,
//                                                     color: Colors.white,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(height: 4),
//                                                 Text(
//                                                   description,
//                                                   style: const TextStyle(
//                                                     fontSize: 14,
//                                                     color: Colors.white70,
//                                                   ),
//                                                   maxLines: 2,
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         );
//                       },
//                     ),
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
import '../yogaprogrampose/ProgramDetailPage.dart';
import 'package:firebase_storage/firebase_storage.dart'; // เพิ่ม import สำหรับ Firebase Storage

class FavoritePage extends StatelessWidget {
  final String userId;

  const FavoritePage({Key? key, required this.userId}) : super(key: key);

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
    return Scaffold(
      body: Stack(
        children: [
          // ภาพพื้นหลัง - แก้ไขเป็นใช้ FutureBuilder เพื่อโหลดรูปจาก Storage
          Positioned.fill(
            child: FutureBuilder<String>(
              future: _getImageUrl(
                  'yoga2.png'), // เปลี่ยนเป็นชื่อไฟล์ที่ถูกต้องในพาธ Yogapose/
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
          // Gradient overlay
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
          // เนื้อหาหลัก
          SafeArea(
            child: Column(
              children: [
                // ส่วนหัวพร้อมปุ่มย้อนกลับและหัวข้อตรงกลาง
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Stack(
                    children: [
                      // ปุ่มย้อนกลับด้านซ้าย
                      Positioned(
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      // หัวข้อตรงกลาง
                      const Center(
                        child: Text(
                          'รายการโปรด',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ส่วนเนื้อหา
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('FavoriteYogaProgram')
                          .where('userId',
                              isEqualTo: FirebaseFirestore.instance
                                  .doc('Users/$userId'))
                          .snapshots(),
                      builder: (context, favSnapshot) {
                        if (favSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!favSnapshot.hasData ||
                            favSnapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'ยังไม่มีรายการโปรด',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: favSnapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final favoriteDoc = favSnapshot.data!.docs[index];
                            final programRef = favoriteDoc['yogaProgramId']
                                as DocumentReference;

                            return FutureBuilder<DocumentSnapshot>(
                              future: programRef.get(),
                              builder: (context, programSnapshot) {
                                if (!programSnapshot.hasData) {
                                  return const SizedBox();
                                }

                                final programData = programSnapshot.data!;
                                final programName =
                                    programData['Name'] ?? 'No Name';
                                final description =
                                    programData['Description'] ??
                                        'No Description';
                                final pictureFileName =
                                    programData['Picture'] ?? '';

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProgramDetailPage(
                                            programId: programRef.id,
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
                                          // แก้ไขเป็นใช้ FutureBuilder เพื่อโหลดรูปจาก Storage
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: FutureBuilder<String>(
                                              future:
                                                  _getImageUrl(pictureFileName),
                                              builder:
                                                  (context, imageSnapshot) {
                                                if (imageSnapshot
                                                        .connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Container(
                                                    width: 80,
                                                    height: 80,
                                                    color: Colors.grey.shade800,
                                                    child: const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  );
                                                }

                                                if (!imageSnapshot.hasData ||
                                                    imageSnapshot
                                                        .data!.isEmpty) {
                                                  return Container(
                                                    width: 80,
                                                    height: 80,
                                                    color: Colors.grey.shade800,
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      color: Colors.white,
                                                    ),
                                                  );
                                                }

                                                return Image.network(
                                                  imageSnapshot.data!,
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Container(
                                                      width: 80,
                                                      height: 80,
                                                      color:
                                                          Colors.grey.shade800,
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(
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
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      width: 80,
                                                      height: 80,
                                                      color:
                                                          Colors.grey.shade800,
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                        color: Colors.white,
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 16),
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
                                                  description,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white70,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

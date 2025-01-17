// import 'package:flutter/material.dart';

// class FavoritePage extends StatelessWidget {
//   const FavoritePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // ข้อมูลตัวอย่าง (Dummy)
//     const String programTitle = 'STRESS FREE YOGA';
//     const String description = 'โปรแกรมโยคะลดความเครียด';
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
//                     'รายการโปรดของคุณ',
//                     style: TextStyle(
//                       fontSize: 28,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   // การ์ดแสดงรายการโปรดล่าสุด (ตัวอย่าง 1 ใบ)
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
//                                 description,
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
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// FavoritePage.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../yogaprogrampose/ProgramDetailPage.dart';

class FavoritePage extends StatelessWidget {
  final String userId;

  const FavoritePage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/img/yoga4.png',
              fit: BoxFit.cover,
            ),
          ),
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, color: Colors.white),
                        SizedBox(width: 4),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'รายการโปรดของคุณ',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
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
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.asset(
                                              'assets/img/$pictureFileName',
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: Colors.grey,
                                                  child: const Icon(
                                                      Icons.broken_image),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

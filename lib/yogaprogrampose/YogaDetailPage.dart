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
//             debugPrint('No program data found for Program ID: $programId');
//             return const Center(
//               child: Text(
//                 'ไม่พบข้อมูลโปรแกรมนี้',
//                 style: TextStyle(fontSize: 18, color: Colors.white),
//               ),
//             );
//           }

//           final programData = snapshot.data!;
//           debugPrint(
//               'Program Data: ${programData.data()}'); // Debug ข้อมูลโปรแกรม

//           final programName = programData['Name'] ?? 'No Name';
//           final programTime = programData['Time_up'] ?? 0;
//           final backgroundFileName = programData['Picture'] ??
//               ''; // ดึงชื่อไฟล์พื้นหลังจาก field Picture

//           return Stack(
//             children: [
//               // พื้นหลัง (ใช้รูปจาก assets ตามชื่อไฟล์ที่ดึงมา)
//               Positioned.fill(
//                 child: backgroundFileName.isNotEmpty
//                     ? Image.asset(
//                         'assets/img/$backgroundFileName', // ใช้ชื่อไฟล์จาก field Picture
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return const Center(
//                             child: Icon(
//                               Icons.broken_image,
//                               color: Colors.white,
//                               size: 48,
//                             ),
//                           );
//                         },
//                       )
//                     : const Center(
//                         child: Icon(
//                           Icons.broken_image,
//                           color: Colors.white,
//                           size: 48,
//                         ),
//                       ),
//               ),
//               // ชั้นสีดำโปร่งใส
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black.withOpacity(0.7),
//                 ),
//               ),
//               // เนื้อหาในหน้า
//               SafeArea(
//                 child: FutureBuilder<DocumentSnapshot>(
//                   future: FirebaseFirestore.instance
//                       .collection('Yoga Program')
//                       .doc(programId)
//                       .get(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//                     if (!snapshot.hasData || !snapshot.data!.exists) {
//                       debugPrint(
//                           'No program data found for Program ID: $programId');
//                       return const Center(
//                         child: Text(
//                           'ไม่พบข้อมูลโปรแกรมนี้',
//                           style: TextStyle(fontSize: 18, color: Colors.white),
//                         ),
//                       );
//                     }

//                     final programData = snapshot.data!;
//                     debugPrint(
//                         'Program Data: ${programData.data()}'); // Debug ข้อมูลโปรแกรม

//                     final programName = programData['Name'] ?? 'No Name';
//                     final programTime = programData['Time_up'] ?? 0;

//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // ปุ่มย้อนกลับ
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: IconButton(
//                             icon: const Icon(Icons.arrow_back,
//                                 color: Colors.white, size: 28),
//                             onPressed: () => Navigator.pop(context),
//                           ),
//                         ),
//                         // ชื่อโปรแกรม
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           child: Text(
//                             programName.toUpperCase(),
//                             style: const TextStyle(
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                         // ระยะเวลาโปรแกรม
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           child: Text(
//                             'ระยะเวลาที่ใช้ทั้งหมด $programTime นาที',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               color: Colors.greenAccent,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         // ปุ่มเล่นและ Favorite
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           child: Row(
//                             children: [
//                               ElevatedButton(
//                                 onPressed: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => CameraMediapipeApp(
//                                           programId:
//                                               programId), // ส่ง programId
//                                     ),
//                                   );
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.grey.shade700,
//                                   foregroundColor: Colors.white,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 child: const Text('เล่น'),
//                               ),
//                               const SizedBox(width: 8),
//                               IconButton(
//                                 onPressed: () {
//                                   // TODO: เพิ่มฟังก์ชัน Favorite
//                                 },
//                                 icon: const Icon(Icons.favorite_border,
//                                     color: Colors.white),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         // GridView แสดงรายการท่าโยคะ
//                         Expanded(
//                           child: StreamBuilder<QuerySnapshot>(
//                             stream: FirebaseFirestore.instance
//                                 .collection('Yoga Pose')
//                                 .where('Program',
//                                     isEqualTo: FirebaseFirestore.instance
//                                         .doc('Yoga Program/$programId'))
//                                 .snapshots(), // ดึงข้อมูลทั้งหมด
//                             builder: (context, snapshot) {
//                               if (snapshot.connectionState ==
//                                   ConnectionState.waiting) {
//                                 return const Center(
//                                     child: CircularProgressIndicator());
//                               }
//                               if (!snapshot.hasData ||
//                                   snapshot.data!.docs.isEmpty) {
//                                 debugPrint('No Yoga Pose data found!');
//                                 return const Center(
//                                   child: Text(
//                                     'ไม่มีข้อมูลโยคะ',
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                 );
//                               }

//                               final yogaPoses = snapshot.data!.docs;
//                               debugPrint(
//                                   'Total Yoga Poses: ${yogaPoses.length}');
//                               for (var pose in yogaPoses) {
//                                 debugPrint(
//                                     'Pose ID: ${pose.id}, Data: ${pose.data()}');
//                               }

//                               return GridView.builder(
//                                 padding: const EdgeInsets.all(16),
//                                 gridDelegate:
//                                     const SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount: 2,
//                                   crossAxisSpacing: 8,
//                                   mainAxisSpacing: 8,
//                                 ),
//                                 itemCount: yogaPoses.length,
//                                 itemBuilder: (context, index) {
//                                   final yogaPose = yogaPoses[index];
//                                   return GestureDetector(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => PoseDetailPage(
//                                             poseId: yogaPose.id,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(12),
//                                       child: Image.asset(
//                                         'assets/img/${yogaPose['Picture']}',
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// YogaDetailPage.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'PoseDetailPage.dart';
import '../CameraMediapipe/cameramediapipe.dart';

class YogaDetailPage extends StatefulWidget {
  // Changed to StatefulWidget
  final String programId;
  final String userId; // Added userId parameter

  const YogaDetailPage({
    Key? key,
    required this.programId,
    required this.userId,
  }) : super(key: key);

  @override
  State<YogaDetailPage> createState() => _YogaDetailPageState();
}

class _YogaDetailPageState extends State<YogaDetailPage> {
  // Favorite handling methods
  Future<bool> checkIfFavorite() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('FavoriteYogaProgram')
        .where('userId',
            isEqualTo: FirebaseFirestore.instance.doc('Users/${widget.userId}'))
        .where('yogaProgramId',
            isEqualTo: FirebaseFirestore.instance
                .doc('Yoga Program/${widget.programId}'))
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> toggleFavorite() async {
    final userRef = FirebaseFirestore.instance.doc('Users/${widget.userId}');
    final programRef =
        FirebaseFirestore.instance.doc('Yoga Program/${widget.programId}');

    final isFavorite = await checkIfFavorite();

    if (isFavorite) {
      // Remove from favorites
      final querySnapshot = await FirebaseFirestore.instance
          .collection('FavoriteYogaProgram')
          .where('userId', isEqualTo: userRef)
          .where('yogaProgramId', isEqualTo: programRef)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } else {
      // Add to favorites
      await FirebaseFirestore.instance.collection('FavoriteYogaProgram').add({
        'userId': userRef,
        'yogaProgramId': programRef,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    setState(() {}); // Trigger rebuild to update UI
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Program ID received: ${widget.programId}');

    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Yoga Program')
            .doc(widget.programId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            debugPrint(
                'No program data found for Program ID: ${widget.programId}');
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
          final backgroundFileName = programData['Picture'] ?? '';

          return Stack(
            children: [
              Positioned.fill(
                child: backgroundFileName.isNotEmpty
                    ? Image.asset(
                        'assets/img/$backgroundFileName',
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
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
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
                                    programId: widget.programId,
                                  ),
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
                          // Updated Favorite Button
                          FutureBuilder<bool>(
                            future: checkIfFavorite(),
                            builder: (context, snapshot) {
                              return IconButton(
                                onPressed: toggleFavorite,
                                icon: Icon(
                                  snapshot.data == true
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: snapshot.data == true
                                      ? Colors.red
                                      : Colors.white,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Yoga Pose')
                            .where('Program',
                                isEqualTo: FirebaseFirestore.instance
                                    .doc('Yoga Program/${widget.programId}'))
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
                                'ไม่มีข้อมูลโยคะ',
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

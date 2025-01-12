import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './ProgramDetailPage.dart';

class YogaListPage extends StatelessWidget {
  const YogaListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // พื้นหลังรูป listBG.png
          Positioned.fill(
            child: Image.asset(
              'assets/img/listBG.png', // Path ของรูป listBG.png
              fit: BoxFit.cover,
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
                    'Rega', // ชื่อแอป
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
                          final pictureFileName = yogaProgram['Picture'] ??
                              ''; // ชื่อไฟล์รูปภาพจาก field Picture

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
                                // รูปภาพของรายการ
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: pictureFileName.isNotEmpty
                                      ? Image.asset(
                                          'assets/img/$pictureFileName', // ใช้ชื่อไฟล์รูปภาพ
                                          width: double.infinity,
                                          height: 180,
                                          fit: BoxFit.cover,
                                        )
                                      : const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.white,
                                            size: 48,
                                          ),
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                // "Yoga Therapy" Text
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: const Text(
                                    'Yoga Therapy',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../CameraMediapipe/pose_result.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/storage_service.dart'; // import StorageService

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final StorageService _storageService = StorageService();
  String? _backgroundImageUrl;
  bool _isLoading = true;

  // Cache สำหรับเก็บข้อมูลโปรแกรม (ลดการเรียก Firestore ซ้ำๆ)
  final Map<String, Map<String, dynamic>> _programCache = {};

  @override
  void initState() {
    super.initState();
    _loadBackgroundImage();
  }

  // โหลดรูปภาพพื้นหลังล่วงหน้า
  Future<void> _loadBackgroundImage() async {
    try {
      final url = await _storageService.getImageUrl('yoga3.png');
      if (mounted) {
        setState(() {
          _backgroundImageUrl = url;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading background image: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // โหลดข้อมูลของโปรแกรมและรูปภาพ (ใช้ cache)
  Future<Map<String, dynamic>> _getProgramData(
      DocumentReference programRef) async {
    try {
      // ถ้ามีอยู่ใน cache แล้ว ใช้ข้อมูลจาก cache
      if (_programCache.containsKey(programRef.id)) {
        return _programCache[programRef.id]!;
      }

      // ถ้าไม่มีใน cache โหลดจาก Firestore
      final programDoc = await programRef.get();
      if (!programDoc.exists) {
        return {
          'id': programRef.id,
          'name': 'Unknown Program',
          'imageUrl': '',
        };
      }

      final programData = programDoc.data() as Map<String, dynamic>?;
      final programName = programData?['Name'] ?? 'Unknown Program';
      final pictureFileName = programData?['Picture'] ?? '';

      // โหลด URL รูปภาพ
      String imageUrl = '';
      if (pictureFileName.isNotEmpty) {
        imageUrl = await _storageService.getImageUrl(pictureFileName);
      }

      // เก็บข้อมูลลงใน cache
      final cachedData = {
        'id': programRef.id,
        'name': programName,
        'imageUrl': imageUrl,
      };

      _programCache[programRef.id] = cachedData;
      return cachedData;
    } catch (e) {
      debugPrint('Error loading program data: $e');
      return {
        'id': programRef.id,
        'name': 'Error Loading Program',
        'imageUrl': '',
      };
    }
  }

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true, // เพิ่มบรรทัดนี้
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ประวัติการใช้งาน',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Image - ใช้ CachedNetworkImage แทน
          Positioned.fill(
            child: _isLoading
                ? Container(color: Colors.black)
                : (_backgroundImageUrl?.isNotEmpty == true
                    ? CachedNetworkImage(
                        imageUrl: _backgroundImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.black),
                        errorWidget: (context, url, error) =>
                            Container(color: Colors.black),
                      )
                    : Container(color: Colors.black)),
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
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
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

                      // ใช้ FutureBuilder แบบมี cache
                      return FutureBuilder<Map<String, dynamic>>(
                        future: _getProgramData(programRef),
                        builder: (context, programSnapshot) {
                          // แสดง loading ที่มีขนาดเท่ากับ item เพื่อป้องกัน layout shift
                          if (!programSnapshot.hasData) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 0.5,
                                  ),
                                ),
                                height: 112, // ความสูงประมาณของ item
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            );
                          }

                          final programData = programSnapshot.data!;

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
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Program Image - ใช้ CachedNetworkImage
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: programData['imageUrl'].isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: programData['imageUrl'],
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey.shade800,
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey.shade800,
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey.shade800,
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.white,
                                              ),
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
                                            programData['name'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Text(
                                                'คะแนน: ',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              Text(
                                                '${score.toStringAsFixed(1)}%',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: _getScoreColor(score),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
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
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return const Color(0xFFFFD700);
    if (score >= 25) return Colors.orange;
    return Colors.red;
  }
}

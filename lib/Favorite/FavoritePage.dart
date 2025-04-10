import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../yogaprogrampose/ProgramDetailPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/storage_service.dart'; // import StorageService ที่สร้างไว้

class FavoritePage extends StatefulWidget {
  final String userId;

  const FavoritePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final StorageService _storageService = StorageService();
  String? _backgroundImageUrl;
  bool _isLoading = true;
  List<Map<String, dynamic>> _favoritePrograms = [];

  @override
  void initState() {
    super.initState();
    _loadBackgroundImage();
  }

  // โหลดรูปภาพพื้นหลังล่วงหน้า
  Future<void> _loadBackgroundImage() async {
    try {
      final url = await _storageService.getImageUrl('yoga2.png');
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

  // โหลดข้อมูลโปรแกรมโปรด
  Future<List<Map<String, dynamic>>> _loadFavoritePrograms(
      List<DocumentSnapshot> favoriteDocs) async {
    final programs = <Map<String, dynamic>>[];
    final futures = <Future<void>>[];

    for (var favoriteDoc in favoriteDocs) {
      final programRef = favoriteDoc['yogaProgramId'] as DocumentReference;

      final future = programRef.get().then((programSnapshot) async {
        if (!programSnapshot.exists) return;

        final programData = programSnapshot.data() as Map<String, dynamic>;
        final pictureFileName = programData['Picture'] ?? '';

        // ดึง URL รูปภาพ
        String imageUrl = '';
        if (pictureFileName.isNotEmpty) {
          imageUrl = await _storageService.getImageUrl(pictureFileName);
        }

        programs.add({
          'id': programSnapshot.id,
          'name': programData['Name'] ?? 'No Name',
          'description': programData['Description'] ?? 'No Description',
          'imageUrl': imageUrl,
        });
      });

      futures.add(future);
    }

    await Future.wait(futures);
    return programs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ภาพพื้นหลัง - ใช้ CachedNetworkImage แทน
          Positioned.fill(
            child: _isLoading
                ? Container(color: Colors.black)
                : (_backgroundImageUrl != null &&
                        _backgroundImageUrl!.isNotEmpty
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
                                  .doc('Users/${widget.userId}'))
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

                        // ใช้ FutureBuilder เพื่อโหลดข้อมูลทั้งหมดพร้อมกัน
                        return FutureBuilder<List<Map<String, dynamic>>>(
                          future: _loadFavoritePrograms(favSnapshot.data!.docs),
                          builder: (context, programsSnapshot) {
                            if (programsSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final programs = programsSnapshot.data ?? [];

                            if (programs.isEmpty) {
                              return const Center(
                                child: Text(
                                  'ไม่พบข้อมูลโปรแกรม',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: programs.length,
                              itemBuilder: (context, index) {
                                final program = programs[index];

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProgramDetailPage(
                                            programId: program['id'],
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
                                          // ใช้ CachedNetworkImage แทน
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: program['imageUrl']
                                                    .isNotEmpty
                                                ? CachedNetworkImage(
                                                    imageUrl:
                                                        program['imageUrl'],
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) =>
                                                            Container(
                                                      width: 80,
                                                      height: 80,
                                                      color:
                                                          Colors.grey.shade800,
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
                                                      color:
                                                          Colors.grey.shade800,
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
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  program['name'],
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  program['description'],
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

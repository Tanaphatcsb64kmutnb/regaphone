import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './ProgramDetailPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/storage_service.dart'; // ปรับให้ import จากไฟล์แยก

class YogaListPage extends StatefulWidget {
  const YogaListPage({Key? key}) : super(key: key);

  @override
  State<YogaListPage> createState() => _YogaListPageState();
}

class _YogaListPageState extends State<YogaListPage> {
  final StorageService _storageService = StorageService();
  String? _backgroundImageUrl;
  bool _isLoading = true;
  List<Map<String, dynamic>> _yogaPrograms = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // โหลดข้อมูลทั้งหมดที่จำเป็นล่วงหน้า
  Future<void> _loadData() async {
    try {
      // 1. โหลดรูปพื้นหลังพร้อมกับดึงข้อมูลโปรแกรม
      final futures = await Future.wait([
        _storageService.getImageUrl('listBG.png'),
        FirebaseFirestore.instance.collection('Yoga Program').get(),
      ]);

      // บันทึก URL ของรูปพื้นหลัง
      final backgroundUrl = futures[0] as String;
      final programsSnapshot = futures[1] as QuerySnapshot;

      // สร้างรายการข้อมูลโปรแกรมทั้งหมด
      final programs = <Map<String, dynamic>>[];
      final imageFutures = <Future<void>>[];

      for (var doc in programsSnapshot.docs) {
        final program = {
          'id': doc.id,
          'name': doc['Name'] ?? 'No Name',
          'pictureFileName': doc['Picture'] ?? '',
          'imageUrl': '',
        };

        programs.add(program);

        // ถ้ามีรูปภาพ ให้โหลด URL ของรูปภาพล่วงหน้า
        if (program['pictureFileName'].isNotEmpty) {
          final future = _storageService
              .getImageUrl(program['pictureFileName'])
              .then((url) {
            program['imageUrl'] = url;
          });

          imageFutures.add(future);
        }
      }

      // รอให้โหลด URL ของรูปภาพทั้งหมดเสร็จ
      await Future.wait(imageFutures);

      if (mounted) {
        setState(() {
          _backgroundImageUrl = backgroundUrl;
          _yogaPrograms = programs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // นำทางไปยังหน้ารายละเอียดโปรแกรม
  void _navigateToProgramDetail(String programId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgramDetailPage(
          programId: programId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // พื้นหลัง
                Positioned.fill(
                  child: _backgroundImageUrl?.isNotEmpty == true
                      ? CachedNetworkImage(
                          imageUrl: _backgroundImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.black),
                          errorWidget: (context, url, error) =>
                              Container(color: Colors.black),
                        )
                      : Container(color: Colors.black),
                ),
                // ชั้นสีดำโปร่งใส
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
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
                          'REGA',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        centerTitle: true,
                        leading: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      // เนื้อหาในหน้า
                      Expanded(
                        child: _yogaPrograms.isEmpty
                            ? const Center(
                                child: Text(
                                  'ไม่มีรายการโยคะในขณะนี้',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _yogaPrograms.length,
                                itemBuilder: (context, index) {
                                  final program = _yogaPrograms[index];

                                  return GestureDetector(
                                    onTap: () =>
                                        _navigateToProgramDetail(program['id']),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          splashColor:
                                              Colors.white.withOpacity(0.3),
                                          highlightColor:
                                              Colors.white.withOpacity(0.1),
                                          onTap: () => _navigateToProgramDetail(
                                              program['id']),
                                          child: Stack(
                                            children: [
                                              // รูปภาพของรายการ
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: program['imageUrl']
                                                        .isNotEmpty
                                                    ? CachedNetworkImage(
                                                        imageUrl:
                                                            program['imageUrl'],
                                                        width: double.infinity,
                                                        height: 180,
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
                                                                Container(
                                                          width:
                                                              double.infinity,
                                                          height: 180,
                                                          color: Colors
                                                              .grey.shade800,
                                                          child: const Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          ),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Container(
                                                          width:
                                                              double.infinity,
                                                          height: 180,
                                                          color: Colors
                                                              .grey.shade800,
                                                          child: const Center(
                                                            child: Icon(
                                                              Icons
                                                                  .broken_image,
                                                              color:
                                                                  Colors.white,
                                                              size: 48,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : Container(
                                                        width: double.infinity,
                                                        height: 180,
                                                        color: Colors
                                                            .grey.shade800,
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            color: Colors.white,
                                                            size: 48,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                              // เลเยอร์โปร่งใส
                                              Positioned.fill(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    color: Colors.black
                                                        .withOpacity(0.4),
                                                  ),
                                                ),
                                              ),
                                              // ชื่อโปรแกรม
                                              Positioned(
                                                top: 16,
                                                left: 16,
                                                right: 16,
                                                child: Text(
                                                  program['name'],
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              // ปุ่ม Know More
                                              Positioned(
                                                bottom: 16,
                                                right: 16,
                                                child: ElevatedButton(
                                                  onPressed: () =>
                                                      _navigateToProgramDetail(
                                                          program['id']),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            164, 0, 0, 0),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Know More',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
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

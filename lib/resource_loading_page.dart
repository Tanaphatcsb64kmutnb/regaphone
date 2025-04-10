import 'package:flutter/material.dart';
import '../services/resource_service.dart';

class ResourceLoadingPage extends StatefulWidget {
  final Widget nextPage;

  const ResourceLoadingPage({Key? key, required this.nextPage})
      : super(key: key);

  @override
  State<ResourceLoadingPage> createState() => _ResourceLoadingPageState();
}

class _ResourceLoadingPageState extends State<ResourceLoadingPage> {
  final ResourceService _resourceService = ResourceService();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkAndLoadResources();
  }

  Future<void> _checkAndLoadResources() async {
    try {
      final needToLoad = await _resourceService.needToLoadResources();

      if (needToLoad) {
        // เริ่มโหลดทรัพยากร
        setState(() {
          _isLoading = true;
          _hasError = false;
        });

        await _resourceService.loadAllResources();

        // โหลดเสร็จสิ้น
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // ไปยังหน้าถัดไป
          _navigateToNextPage();
        }
      } else {
        // ไม่จำเป็นต้องโหลด ไปยังหน้าถัดไปเลย
        _navigateToNextPage();
      }
    } catch (e) {
      // จัดการข้อผิดพลาด
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _navigateToNextPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => widget.nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/listBG.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.7),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // แสดงโลโก้หรือชื่อแอป
                  const Text(
                    'REGA',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'กำลังโหลดทรัพยากร...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // แสดงความคืบหน้าการโหลด
                  if (_isLoading) ...[
                    // แถบแสดงความคืบหน้า
                    ValueListenableBuilder<double>(
                      valueListenable: _resourceService.progressNotifier,
                      builder: (context, progress, _) {
                        return Column(
                          children: [
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[700],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.greenAccent,
                              ),
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // แสดงชื่อไฟล์ที่กำลังโหลด
                    ValueListenableBuilder<String>(
                      valueListenable: _resourceService.currentFileNotifier,
                      builder: (context, fileName, _) {
                        return Text(
                          fileName.isEmpty ? '' : 'กำลังโหลด: $fileName',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ],

                  // แสดงข้อผิดพลาด
                  if (_hasError) ...[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'เกิดข้อผิดพลาด: $_errorMessage',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _checkAndLoadResources,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('ลองอีกครั้ง'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

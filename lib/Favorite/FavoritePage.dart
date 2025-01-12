import 'package:flutter/material.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ข้อมูลตัวอย่าง (Dummy)
    const String programTitle = 'STRESS FREE YOGA';
    const String description = 'โปรแกรมโยคะลดความเครียด';
    const String imagePath = 'assets/img/listBG.png'; // รูปในการ์ด

    return Scaffold(
      // ไม่ใส่ appBar เพื่อออกแบบ Header เอง (Stack + Positioned)
      body: Stack(
        children: [
          // ภาพพื้นหลัง
          Positioned.fill(
            child: Image.asset(
              'assets/img/yoga4.png', // พื้นหลังตามต้องการ
              fit: BoxFit.cover,
            ),
          ),

          // เลเยอร์ไล่สีดำโปร่งใสเล็กน้อย ทับบนพื้นหลัง เพื่อให้อ่านข้อความได้ชัด
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

          // เนื้อหาทับด้านบน
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ปุ่มย้อนกลับ
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

                  // หัวข้อหลัก
                  const Text(
                    'รายการโปรดของคุณ',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // การ์ดแสดงรายการโปรดล่าสุด (ตัวอย่าง 1 ใบ)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // รูปในการ์ด (ทรงโค้งมน)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            imagePath,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // ข้อความรายละเอียด
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                programTitle,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Spacer ดันลงไปด้านล่าง ตามดีไซน์
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

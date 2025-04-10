import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'เกี่ยวกับเรา',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/img/yoga4.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'REGA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'REGA คืออะไร?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'REGA (Rehabilitation with Yoga and AI) คือแอปพลิเคชันสำหรับฝึกโยคะบำบัดที่ผสานเทคโนโลยี AI เพื่อให้ผู้ใช้งานสามารถฝึกโยคะได้อย่างปลอดภัย มีประสิทธิภาพ และลดความเสี่ยงจากการบาดเจ็บ โดยใช้ MediaPipe ตรวจจับ keypoints ของร่างกาย พร้อมกับการประมวลผลด้วยโมเดล LSTM ร่วมกับ CNN และการตรวจสอบมุมร่างกาย (Angle Checking) เพื่อให้ feedback แบบเรียลไทม์',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildInfoSection(
                    icon: Icons.health_and_safety,
                    title: 'วัตถุประสงค์ของเรา',
                    content:
                        'เพื่อให้ผู้ใช้งานสามารถฝึกโยคะได้อย่างถูกต้องและปลอดภัยด้วยระบบ AI ตรวจจับข้อผิดพลาดแบบเรียลไทม์ พร้อมทั้งเก็บข้อมูลพฤติกรรมและความก้าวหน้าในการฝึก',
                  ),
                  _buildInfoSection(
                    icon: Icons.devices,
                    title: 'ระบบที่ใช้ในแอปพลิเคชัน',
                    content:
                        'แอปผู้ใช้งานพัฒนาด้วย Flutter และระบบผู้ดูแลพัฒนาด้วย React ใช้ Firebase สำหรับจัดเก็บข้อมูลทั้งหมด มีโปรแกรมโยคะ 2 หมวด ได้แก่ โปรแกรมบรรเทาอาการปวด และโปรแกรมฟื้นฟูภาวะสุขภาพ เช่น โรคหัวใจหรือความดันโลหิตสูง',
                  ),
                  _buildInfoSection(
                    icon: Icons.analytics,
                    title: 'ความสามารถหลัก',
                    content:
                        'ระบบสามารถตรวจจับ keypoints จาก MediaPipe วิเคราะห์ด้วย LSTM + CNN และ Angle Checking ให้ feedback แบบ real-time พร้อมทั้งแสดงผลคะแนนและพัฒนาการของผู้ใช้ตลอดการฝึก',
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'ติดต่อเรา',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactItem(
                    icon: Icons.email,
                    text: 's6404062663100@email.kmutnb.ac.th',
                  ),
                  const SizedBox(height: 12),
                  _buildContactItem(
                    icon: Icons.phone,
                    text: '09-900-73444',
                  ),
                  const SizedBox(height: 12),
                  _buildContactItem(
                    icon: Icons.location_on,
                    text: 'กรุงเทพมหานคร, ประเทศไทย',
                  ),
                  const SizedBox(height: 40),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      '© ${DateTime.now().year} REGA. All rights reserved.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Text(
              content,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

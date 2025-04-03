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
            // Header image
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
            // About section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'แอพพลิเคชันโยคะสำหรับทุกคน',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'REGA เป็นแอพพลิเคชันโยคะที่ออกแบบมาเพื่อช่วยให้ผู้ใช้ทุกระดับสามารถฝึกโยคะได้อย่างถูกต้องและปลอดภัย โดยใช้เทคโนโลยี AI ในการวิเคราะห์และแนะนำท่าทางที่ถูกต้อง',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Mission section
                  _buildInfoSection(
                    icon: Icons.flag,
                    title: 'พันธกิจของเรา',
                    content: 'เรามุ่งมั่นที่จะทำให้การฝึกโยคะเข้าถึงได้สำหรับทุกคน ไม่ว่าจะอยู่ที่ไหน มีประสบการณ์มากน้อยเพียงใด เราเชื่อว่าโยคะสามารถเปลี่ยนแปลงชีวิตและสุขภาพของคุณได้ในทางที่ดีขึ้น',
                  ),
                  
                  // Technology section
                  _buildInfoSection(
                    icon: Icons.smart_toy,
                    title: 'เทคโนโลยีของเรา',
                    content: 'REGA ใช้เทคโนโลยี AI และ Computer Vision ในการตรวจจับและวิเคราะห์ท่าทางของผู้ใช้ แล้วให้คำแนะนำในการปรับปรุงแบบเรียลไทม์ เพื่อให้ผู้ใช้สามารถฝึกโยคะได้อย่างถูกต้องและปลอดภัย',
                  ),
                  
                  // Team section
                  _buildInfoSection(
                    icon: Icons.people,
                    title: 'ทีมของเรา',
                    content: 'ทีมของเราประกอบด้วยนักพัฒนาซอฟต์แวร์ ผู้เชี่ยวชาญด้านโยคะ และนักออกแบบประสบการณ์ผู้ใช้ที่มีความหลงใหลในการสร้างประสบการณ์การฝึกโยคะที่ดีที่สุดสำหรับผู้ใช้ทุกคน',
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Contact section
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
                    text: 'contact@rega-yoga.com',
                  ),
                  const SizedBox(height: 12),
                  _buildContactItem(
                    icon: Icons.phone,
                    text: '02-123-4567',
                  ),
                  const SizedBox(height: 12),
                  _buildContactItem(
                    icon: Icons.location_on,
                    text: 'กรุงเทพมหานคร, ประเทศไทย',
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Social links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(Icons.facebook, () {}),
                      const SizedBox(width: 20),
                      _buildSocialButton(Icons.camera_alt, () {}),
                      const SizedBox(width: 20),
                      _buildSocialButton(Icons.tiktok, () {}),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Footer
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
  
  Widget _buildSocialButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class NoInternetDialog extends StatelessWidget {
  final VoidCallback onNavigateHome;

  const NoInternetDialog({
    super.key,
    required this.onNavigateHome,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF13121A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: Colors.red.withOpacity(0.5),
          width: 2,
        ),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.wifi_off,
            color: Colors.red,
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            'การเชื่อมต่อขัดข้อง',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
      content: Text(
        'ไม่พบการเชื่อมต่ออินเทอร์เน็ต โปรดตรวจสอบการเชื่อมต่อของคุณและลองใหม่อีกครั้ง',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
      ),
      actions: [
        TextButton(
          onPressed: onNavigateHome,
          style: TextButton.styleFrom(
            backgroundColor: Colors.purple.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'กลับไปหน้าหลัก',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}

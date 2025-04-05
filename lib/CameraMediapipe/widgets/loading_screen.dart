import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final int countdownSeconds;
  final double loadingProgress;

  const LoadingScreen({
    super.key,
    required this.countdownSeconds,
    required this.loadingProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'เริ่มต้นใน: $countdownSeconds',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'เตรียมพร้อม...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 40),
            // แถบแสดงความคืบหน้า
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(5),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: loadingProgress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.greenAccent,
                        Colors.green,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

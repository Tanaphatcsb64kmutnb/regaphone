import 'package:flutter/material.dart';

class CircularTimerWidget extends StatelessWidget {
  final double progressPercentage;
  final int remainingTime;
  final int totalTime;

  const CircularTimerWidget({
    super.key,
    required this.progressPercentage,
    required this.remainingTime,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    Color timerColor;
    if (progressPercentage > 0.7) {
      timerColor = Colors.green;
    } else if (progressPercentage > 0.3) {
      timerColor = const Color(0xFFFFA000);
    } else {
      timerColor = Colors.red;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13121A).withOpacity(0.85),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // วงกลมพื้นหลัง
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 5,
            backgroundColor: const Color(0xFF2A2B3D),
          ),
          // วงกลมแสดงความคืบหน้า
          CircularProgressIndicator(
            value: progressPercentage,
            strokeWidth: 5,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(timerColor),
          ),
          // แสดงเฉพาะเวลาที่เหลือ
          Center(
            child: Text(
              '$remainingTime',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimerBarWidget extends StatelessWidget {
  final double progressPercentage;
  final int remainingTime;
  final int totalTime;

  const TimerBarWidget({
    super.key,
    required this.progressPercentage,
    required this.remainingTime,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // พื้นหลังหลัก
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF13121A),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          // พื้นหลังของแถบความคืบหน้า
          Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A2B3D),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          // แถบความคืบหน้า
          Padding(
            padding: const EdgeInsets.all(5),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width:
                  (MediaQuery.of(context).size.width - 50) * progressPercentage,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: progressPercentage > 0.5
                      ? [
                          const Color(0xFF4CAF50),
                          const Color(0xFF8BC34A),
                        ]
                      : [
                          const Color(0xFFFFA000),
                          const Color(0xFFFFD700),
                        ],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: (progressPercentage > 0.5
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFFFA000))
                        .withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: -2,
                  ),
                ],
              ),
            ),
          ),
          // Timer icon and text
          Row(
            children: [
              const SizedBox(width: 15),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2A2B3D),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(
                  Icons.timer,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$remainingTime',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

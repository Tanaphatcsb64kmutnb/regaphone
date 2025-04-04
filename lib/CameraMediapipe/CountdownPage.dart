import 'dart:async';
import 'package:flutter/material.dart';
import '../CameraMediapipe/cameramediapipe.dart';

class CountdownPage extends StatefulWidget {
  final String programId;
  
  const CountdownPage({Key? key, required this.programId}) : super(key: key);
  
  @override
  State<CountdownPage> createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  int countdown = 3;
  double progress = 0.0;
  
  @override
  void initState() {
    super.initState();
    startCountdown();
  }
  
  void startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (countdown > 1) {
            countdown--;
            progress = (3 - countdown) / 3;
          } else {
            timer.cancel();
            // ไปยังหน้า CameraMediapipe
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CameraMediapipeApp(
                  programId: widget.programId,
                ),
              ),
            );
          }
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'เริ่มต้นใน: $countdown',
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
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(5),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.greenAccent, Colors.green],
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
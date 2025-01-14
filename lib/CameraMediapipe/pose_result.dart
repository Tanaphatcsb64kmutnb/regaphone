// pose_result.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PoseResultPage extends StatelessWidget {
  final String programId;
  final String programHistoryId;

  const PoseResultPage({
    Key? key,
    required this.programId,
    required this.programHistoryId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint(
        'Building PoseResultPage with programHistoryId: $programHistoryId');

    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('YogaProgram History') // ชื่อ collection ที่ถูกต้อง
            .doc(programHistoryId)
            .snapshots(),
        builder: (context, programSnapshot) {
          if (!programSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!programSnapshot.data!.exists) {
            return const Center(
                child: Text('ไม่พบข้อมูลประวัติ',
                    style: TextStyle(color: Colors.white)));
          }

          final programData =
              programSnapshot.data!.data() as Map<String, dynamic>;
          final overallScore = programData['Ovr_score'] ?? 0.0;
          final timestamp = programData['Time'] as Timestamp?;
          final date = timestamp?.toDate() ?? DateTime.now();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('YogaPose History') // ชื่อ collection ที่ถูกต้อง
                .where('history_id', isEqualTo: programHistoryId)
                .snapshots(),
            builder: (context, poseSnapshot) {
              if (!poseSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final poses = poseSnapshot.data!.docs;

              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.of(context)
                                  .popUntil((route) => route.isFirst),
                            ),
                            const Expanded(
                              child: Text(
                                'ผลลัพธ์ของคุณ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                      ),

                      // Overall Score
                      Container(
                        width: 150,
                        height: 150,
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getScoreColor(overallScore),
                            width: 4,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${overallScore.round()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              '/100',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Time Display
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('HH:mm').format(date),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Pose Results Grid
                      GridView.builder(
                        padding: const EdgeInsets.all(16),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: poses.length,
                        itemBuilder: (context, index) {
                          final pose =
                              poses[index].data() as Map<String, dynamic>;
                          final score = pose['Pose_score'] ?? 0.0;

                          return FutureBuilder<DocumentSnapshot>(
                            future:
                                (pose['Pose_id'] as DocumentReference).get(),
                            builder: (context, poseSnapshot) {
                              if (!poseSnapshot.hasData) {
                                return const SizedBox();
                              }

                              final poseData = poseSnapshot.data!.data()
                                  as Map<String, dynamic>;
                              final poseName =
                                  poseData['Name'] ?? 'Unknown Pose';
                              final poseImage = poseData['Picture'] ?? '';

                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: AssetImage('assets/img/$poseImage'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        _getScoreColor(score).withOpacity(0.8),
                                        _getScoreColor(score).withOpacity(0.3),
                                      ],
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Score Display
                                      Positioned(
                                        right: 10,
                                        top: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: Text(
                                            '${score.round()}%',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Performance Level
                                      Positioned(
                                        left: 10,
                                        top: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: Text(
                                            _getPerformanceText(score),
                                            style: TextStyle(
                                              color: _getScoreColor(score),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Pose Name
                                      Positioned(
                                        left: 10,
                                        right: 10,
                                        bottom: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: Text(
                                            poseName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),

                      // Finish Button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context)
                                .popUntil((route) => route.isFirst),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white10,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'เสร็จสิ้น',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.yellow;
    if (score >= 25) return Colors.orange;
    return Colors.red;
  }

  String _getPerformanceText(double score) {
    if (score >= 75) return 'สุดยอดมาก!';
    if (score >= 50) return 'ดี';
    if (score >= 25) return 'ปานกลาง';
    return 'ต้องฝึกฝนเพิ่มเติม';
  }
}

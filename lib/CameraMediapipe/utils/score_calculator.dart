class ScoreCalculator {
  // ค่า multiplier สำหรับคำนวณคะแนน
  final double scoreMultiplier;

  // คะแนนสะสมทั้งหมด
  double cumulativeScore = 0.0;

  // บันทึกคะแนนที่เพิ่มล่าสุด
  double lastAddedScore = 0.0;

  ScoreCalculator({this.scoreMultiplier = 0.1});

  /// คำนวณคะแนนจากความแม่นยำในการตรวจจับท่า
  ///
  /// [angleScore] คือค่าความแม่นยำ (0-100)
  /// [isPoseCorrect] ท่าที่ทำนายได้ถูกต้องหรือไม่
  ///
  /// คืนค่า true ถ้ามีการเพิ่มคะแนนใหม่
  bool calculateScore(double angleScore, bool isPoseCorrect) {
    if (!isPoseCorrect) {
      return false;
    }

    // คำนวณคะแนนเมื่อทำท่าถูกต้อง
    double addedScore = angleScore * scoreMultiplier;

    // ตรวจสอบไม่ให้คะแนนเกิน 100
    if (cumulativeScore + addedScore > 100) {
      addedScore = 100 - cumulativeScore; // เพิ่มแค่พอให้ครบ 100

      if (addedScore <= 0) {
        // กรณีคะแนนครบ 100 แล้ว ไม่เพิ่มคะแนนอีก
        addedScore = 0;
        return false;
      }
    }

    cumulativeScore += addedScore;
    lastAddedScore = addedScore;

    return addedScore > 0;
  }

  /// รีเซ็ตคะแนนสะสม
  void resetScore() {
    cumulativeScore = 0.0;
    lastAddedScore = 0.0;
  }

  /// ประเมินระดับผลการเล่น
  String getPerformanceLevel() {
    if (cumulativeScore >= 75) return 'สุดยอดมาก';
    if (cumulativeScore >= 50) return 'ดี';
    if (cumulativeScore >= 25) return 'ปานกลาง';
    return 'พอใช้';
  }
}

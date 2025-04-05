import 'package:flutter/material.dart';

class ScoreDisplayWidget extends StatelessWidget {
  final double score;

  const ScoreDisplayWidget({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF13121A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.stars,
            color: Color(0xFFFFD700),
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            '${score.toStringAsFixed(0)}/100',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreEffectWidget extends StatelessWidget {
  final double addedScore;
  final Animation<double> animation;

  const ScoreEffectWidget({
    super.key,
    required this.addedScore,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: 1.0 - animation.value,
          child: Transform.translate(
            offset: Offset(0, -30 * animation.value),
            child: Text(
              '+${addedScore.toStringAsFixed(1)}',
              style: TextStyle(
                color: const Color(0xFFFFD700),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 8.0,
                    color: Colors.black.withOpacity(0.7),
                    offset: const Offset(1.0, 1.0),
                  ),
                  Shadow(
                    blurRadius: 12.0,
                    color: const Color(0xFFFFD700).withOpacity(0.4),
                    offset: const Offset(0.0, 0.0),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class HorizontalScoreDisplayWidget extends StatelessWidget {
  final double score;

  const HorizontalScoreDisplayWidget({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF13121A).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: Color(0xFFFFD700),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${score.toStringAsFixed(0)}/100',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ConfidenceIndicatorWidget extends StatelessWidget {
  final double confidence;

  const ConfidenceIndicatorWidget({
    super.key,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    Color indicatorColor;
    if (confidence > 0.7) {
      indicatorColor = Colors.green;
    } else if (confidence > 0.4) {
      indicatorColor = Colors.amber;
    } else {
      indicatorColor = Colors.red;
    }

    return Row(
      children: [
        Text(
          '${(confidence * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            color: indicatorColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 100,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: confidence,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    indicatorColor.withOpacity(0.7),
                    indicatorColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

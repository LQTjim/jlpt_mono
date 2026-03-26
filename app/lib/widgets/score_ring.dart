import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ScoreRing extends StatelessWidget {
  final int score;
  final int total;
  final double size;

  const ScoreRing({
    super.key,
    required this.score,
    required this.total,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (score / total * 100).round() : 0;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: total > 0 ? score / total : 0,
          trackColor: AppColors.divider,
          fillColor: AppColors.terracotta,
          strokeWidth: size * 0.07,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$score / $total',
                style: TextStyle(
                  fontSize: size * 0.08,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Fill
    if (progress > 0) {
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.strokeWidth != strokeWidth;
}

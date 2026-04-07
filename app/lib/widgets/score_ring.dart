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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : AppColors.inkDark;
    final subtitleColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: total > 0 ? score / total : 0,
          trackColor: isDark ? const Color(0xFF44403c) : const Color(0xFFe3dfde),
          fillColor: AppColors.terracottaMuted,
          strokeWidth: size * 0.08,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$score / $total',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: size * 0.1,
                  fontWeight: FontWeight.bold,
                  color: subtitleColor,
                  letterSpacing: 1.5,
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

  // High-frequency deterministic noise for pencil texture
  double _noise(double theta, int seed) {
    double res = sin(theta * (60 + seed * 5)) +
                 sin(theta * (120 + seed * 3)) * 0.5 +
                 cos(theta * (180 + seed)) * 0.25;
    return res / 1.75;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track (Dashed)
    final trackStrokeWidth = strokeWidth * 0.75; // slightly thinner track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackStrokeWidth
      ..strokeCap = StrokeCap.butt;

    final circumference = 2 * pi * radius;
    const dashLength = 6.0;
    const dashSpace = 6.0;
    final numDashes = (circumference / (dashLength + dashSpace)).floor();
    final sweepAngle = (dashLength / circumference) * 2 * pi;
    final spaceAngle = (dashSpace / circumference) * 2 * pi;

    double startAngle = -pi / 2;
    for (int i = 0; i < numDashes; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        trackPaint,
      );
      startAngle += sweepAngle + spaceAngle;
    }

    // Fill (Graphite Pencil Brush Texture)
    if (progress > 0) {
      double startTheta = -pi / 2;
      double sweepTheta = 2 * pi * progress;

      // 1. Draw a semi-transparent rough core so the bulk of the color is grounded
      final corePaint = Paint()
        ..color = fillColor.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.5
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startTheta,
        sweepTheta,
        false,
        corePaint,
      );

      // 2. Draw multiple overlapping noisy strokes for the "毛邊" (rough edge) effect
      final int scratchCount = 18;
      final int steps = max(10, (sweepTheta * radius / 3).toInt()); // sufficient steps for a dense jaggy path

      for (int i = 0; i < scratchCount; i++) {
        final path = Path();

        // Distribute strokes across the width of the ring
        double normalizedOffset = (i / (scratchCount - 1)) - 0.5;
        double radiusOffset = normalizedOffset * strokeWidth * 0.85;

        // Varying thin widths for realism
        double scratchWidth = strokeWidth * (0.05 + (i % 4) * 0.05);

        final scratchPaint = Paint()
          ..color = fillColor.withValues(alpha: 0.15 + (i % 3) * 0.1) // varied low opacity
          ..style = PaintingStyle.stroke
          ..strokeWidth = scratchWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        for (int s = 0; s <= steps; s++) {
          double t = s / steps;
          double theta = startTheta + t * sweepTheta;

          // Apply pseudo-random noise to make the path jittery
          double wave = _noise(theta, i) * strokeWidth * 0.2;
          double currentRadius = radius + radiusOffset + wave;

          double x = center.dx + currentRadius * cos(theta);
          double y = center.dy + currentRadius * sin(theta);

          if (s == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        canvas.drawPath(path, scratchPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.strokeWidth != strokeWidth;
}

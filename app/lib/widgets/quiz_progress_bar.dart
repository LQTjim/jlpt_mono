import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class QuizProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const QuizProgressBar({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? current / total : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark ? const Color(0xFF44403c) : const Color(0xFFe3dfde);

    return SizedBox(
      width: double.infinity,
      height: 14, // Slightly enlarged to 14 so waves don't clip
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: progress),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return CustomPaint(
            painter: _PencilProgressPainter(
              progress: value,
              trackColor: trackColor,
              fillColor: AppColors.terracottaMuted, // Match Graphite Design
            ),
          );
        },
      ),
    );
  }
}

class _PencilProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;

  _PencilProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
  });

  double _noise(double x, int seed) {
    double res = sin(x * 0.15 + seed * 5) +
                 sin(x * 0.35 + seed * 3) * 0.5 +
                 cos(x * 0.5 + seed) * 0.25;
    return res / 1.75;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Draw dashed background track
    final trackStrokeWidth = size.height * 0.3;
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackStrokeWidth
      ..strokeCap = StrokeCap.butt; 

    double currentX = 0;
    const dashLength = 5.0;
    const dashSpace = 4.0;
    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, size.height / 2),
        Offset(min(currentX + dashLength, size.width), size.height / 2),
        trackPaint,
      );
      currentX += dashLength + dashSpace;
    }

    if (progress <= 0) return;

    double fillWidth = size.width * progress;

    // 2. Semi-transparent core to anchor visual weight
    final corePaint = Paint()
      ..color = fillColor.withValues(alpha: 1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.5
      ..strokeCap = StrokeCap.round;

    // Slightly padded so round caps don't spill too far
    canvas.drawLine(
        Offset(min(fillWidth, size.height * 0.3), size.height / 2),
        Offset(max(size.height * 0.3, fillWidth - size.height * 0.3), size.height / 2),
        corePaint);

    // 3. Wavy random strokes for graphite sketch texture
    final int scratchCount = 14;
    for (int i = 0; i < scratchCount; i++) {
      final path = Path();

      double normalizedOffset = (i / (scratchCount - 1)) - 0.5;
      double yOffset = normalizedOffset * size.height * 0.75;

      double lineWeight = size.height * (0.05 + (i % 4) * 0.05);

      final scratchPaint = Paint()
        ..color = fillColor.withValues(alpha: 0.8 + (i % 3) * 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWeight
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      int steps = max(2, (fillWidth / 3).toInt()); // Step every ~3 pixels
      for (int s = 0; s <= steps; s++) {
        double x = s / steps * fillWidth;
        double wave = _noise(x, i) * size.height * 0.2;
        double y = size.height / 2 + yOffset + wave;

        if (s == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, scratchPaint);
    }
  }

  @override
  bool shouldRepaint(_PencilProgressPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.fillColor != fillColor;
}

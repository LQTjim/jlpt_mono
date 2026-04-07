import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/sketch_borders.dart';

class StudySummaryCard extends StatelessWidget {
  final int totalQuizzes;
  final int averageScore;
  final int currentStreak;
  final String totalQuizzesLabel;
  final String averageScoreLabel;
  final String currentStreakLabel;

  const StudySummaryCard({
    super.key,
    required this.totalQuizzes,
    required this.averageScore,
    required this.currentStreak,
    required this.totalQuizzesLabel,
    required this.averageScoreLabel,
    required this.currentStreakLabel,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.15);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: SketchBorders.v0,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          _StatColumn(
            value: '$totalQuizzes',
            label: totalQuizzesLabel,
            locale: locale,
          ),
          _wavyDivider(borderColor),
          _StatColumn(
            value: '$averageScore%',
            label: averageScoreLabel,
            locale: locale,
          ),
          _wavyDivider(borderColor),
          _StatColumn(
            value: '$currentStreak',
            label: currentStreakLabel,
            locale: locale,
          ),
        ],
      ),
    );
  }

  Widget _wavyDivider(Color color) {
    return SizedBox(
      width: 4,
      height: 48,
      child: CustomPaint(painter: _WavyLinePainter(color: color)),
    );
  }
}

class _WavyLinePainter extends CustomPainter {
  final Color color;

  _WavyLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    // Draw a slight zigzag to look hand-drawn
    path.lineTo(size.width / 2 + 1.5, size.height * 0.3);
    path.lineTo(size.width / 2 - 1.5, size.height * 0.7);
    path.lineTo(size.width / 2, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavyLinePainter old) => old.color != color;
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final Locale locale;

  const _StatColumn({
    required this.value,
    required this.label,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? const Color(0xFFa8a29e) : const Color(0xFF7f6f6c);

    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
              color: AppColors.terracottaMuted, // Graphite theme's primary
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

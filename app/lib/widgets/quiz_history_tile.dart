import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/sketch_borders.dart';
import 'jlpt_level_tag.dart';

class QuizHistoryTile extends StatelessWidget {
  final String date;
  final String jlptLevel;
  final int score;
  final int total;

  const QuizHistoryTile({
    super.key,
    required this.date,
    required this.jlptLevel,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (score / total * 100).round() : 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.15);
    final subtitleColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    // Give each card a seemingly "random" hand-drawn border layout based on its data
    final int randIndex = date.hashCode ^ score;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: SketchBorders.forIndex(randIndex),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            // Date
            Text(
              date,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: subtitleColor,
              ),
            ),
            const SizedBox(width: 12),

            JlptLevelTag(level: jlptLevel),

            const Spacer(),

            // Score Ratio
            Text(
              '$score/$total',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: subtitleColor,
              ),
            ),
            const SizedBox(width: 12),

            // Percentage Big
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
                color: _percentageColor(percentage),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _percentageColor(int percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 50) return AppColors.terracottaMuted;
    return AppColors.error;
  }
}

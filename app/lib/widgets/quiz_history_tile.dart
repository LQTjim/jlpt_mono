import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_tag.dart';

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

    return ClipRRect(
      borderRadius: AppSpacing.radiusMd,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          border: Border.all(color: AppColors.divider),
          borderRadius: AppSpacing.radiusMd,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: AppColors.terracotta),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
                  child: Row(
        children: [
          // Date
          Text(
            date,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // JLPT badge
          AppTag(label: jlptLevel, color: AppColors.terracotta),

          const Spacer(),

          // Score
          Text(
            '$score/$total',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Percentage
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _percentageColor(percentage),
            ),
          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Color _percentageColor(int percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 50) return AppColors.terracotta;
    return AppColors.error;
  }
}

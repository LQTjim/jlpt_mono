import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

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

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: AppSpacing.radiusMd,
        border: Border.all(color: AppColors.divider),
        boxShadow: AppSpacing.cardShadow,
      ),
      child: Row(
        children: [
          _StatColumn(
            value: '$totalQuizzes',
            label: totalQuizzesLabel,
            locale: locale,
          ),
          _verticalDivider,
          _StatColumn(
            value: '$averageScore%',
            label: averageScoreLabel,
            locale: locale,
          ),
          _verticalDivider,
          _StatColumn(
            value: '$currentStreak',
            label: currentStreakLabel,
            locale: locale,
          ),
        ],
      ),
    );
  }

  static const _verticalDivider = SizedBox(
    width: 1,
    height: 40,
    child: ColoredBox(color: AppColors.divider),
  );
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
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.headingMedium(locale).copyWith(
              color: AppColors.terracotta,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.bodySmall(locale),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum QuizOptionState { idle, selected }

class QuizOptionCard extends StatelessWidget {
  final String label;
  final String text;
  final QuizOptionState state;
  final VoidCallback? onTap;

  const QuizOptionCard({
    super.key,
    required this.label,
    required this.text,
    this.state = QuizOptionState.idle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = state == QuizOptionState.selected;

    return Material(
      color: isSelected
          ? AppColors.terracotta.withValues(alpha: 0.08)
          : AppColors.warmWhite,
      borderRadius: AppSpacing.radiusMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.radiusMd,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppSpacing.radiusMd,
            border: Border.all(
              color: isSelected ? AppColors.terracotta : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.terracotta : Colors.transparent,
                borderRadius: AppSpacing.radiusSm,
                border: Border.all(
                  color: isSelected
                      ? AppColors.terracotta
                      : AppColors.textSecondary,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.terracottaDark
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.terracotta,
                size: 22,
              ),
          ],
        ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

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

    return ClipRRect(
      borderRadius: AppSpacing.radiusFull,
      child: SizedBox(
        height: 6,
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.divider,
          valueColor:
              const AlwaysStoppedAnimation<Color>(AppColors.terracotta),
        ),
      ),
    );
  }
}

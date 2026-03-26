import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum QuizResultState { correct, incorrect, skipped }

class QuizResultCard extends StatelessWidget {
  final int questionNumber;
  final String questionText;
  final String? userAnswer;
  final String correctAnswer;
  final QuizResultState state;

  const QuizResultCard({
    super.key,
    required this.questionNumber,
    required this.questionText,
    this.userAnswer,
    required this.correctAnswer,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
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
              Container(width: 4, color: _accentColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(_icon, color: _accentColor, size: 24),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: _buildContent()),
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

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Q$questionNumber  $questionText',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        if (state == QuizResultState.correct)
          Text(
            correctAnswer,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        if (state == QuizResultState.incorrect) ...[
          Text.rich(
            TextSpan(children: [
              const TextSpan(
                text: '你的答案: ',
                style:
                    TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              TextSpan(
                text: userAnswer ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(children: [
              const TextSpan(
                text: '正解: ',
                style:
                    TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              TextSpan(
                text: correctAnswer,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ]),
          ),
        ],
        if (state == QuizResultState.skipped)
          Text.rich(
            TextSpan(children: [
              const TextSpan(
                text: '跳過  正解: ',
                style:
                    TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              TextSpan(
                text: correctAnswer,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ]),
          ),
      ],
    );
  }

  Color get _accentColor => switch (state) {
        QuizResultState.correct => AppColors.success,
        QuizResultState.incorrect => AppColors.error,
        QuizResultState.skipped => AppColors.textHint,
      };

  IconData get _icon => switch (state) {
        QuizResultState.correct => Icons.check_circle,
        QuizResultState.incorrect => Icons.cancel,
        QuizResultState.skipped => Icons.remove_circle_outline,
      };
}

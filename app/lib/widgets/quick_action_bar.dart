import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_button.dart';

class QuickActionBar extends StatelessWidget {
  final String startQuizLabel;
  final String browseVocabularyLabel;
  final VoidCallback? onStartQuiz;
  final VoidCallback? onBrowseVocabulary;

  const QuickActionBar({
    super.key,
    required this.startQuizLabel,
    required this.browseVocabularyLabel,
    this.onStartQuiz,
    this.onBrowseVocabulary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: startQuizLabel,
            icon: Icons.quiz_outlined,
            variant: AppButtonVariant.outlined,
            onPressed: onStartQuiz,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppButton(
            label: browseVocabularyLabel,
            icon: Icons.menu_book_outlined,
            variant: AppButtonVariant.outlined,
            onPressed: onBrowseVocabulary,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_button.dart';

class QuickActionBar extends StatelessWidget {
  final String startQuizLabel;
  final String browseVocabularyLabel;
  final String flashcardLabel;
  final VoidCallback? onStartQuiz;
  final VoidCallback? onBrowseVocabulary;
  final VoidCallback? onFlashcard;

  const QuickActionBar({
    super.key,
    required this.startQuizLabel,
    required this.browseVocabularyLabel,
    required this.flashcardLabel,
    this.onStartQuiz,
    this.onBrowseVocabulary,
    this.onFlashcard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.radiusMd,
        boxShadow: AppSpacing.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          AppIconTextButton(
            label: startQuizLabel,
            icon: Icons.quiz_outlined,
            onPressed: onStartQuiz,
          ),
          _divider(),
          AppIconTextButton(
            label: browseVocabularyLabel,
            icon: Icons.menu_book_outlined,
            onPressed: onBrowseVocabulary,
          ),
          _divider(),
          AppIconTextButton(
            label: flashcardLabel,
            icon: Icons.style_outlined,
            onPressed: onFlashcard,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 36,
        color: AppColors.divider,
      );
}

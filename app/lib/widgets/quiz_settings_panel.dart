import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum QuestionType { meaning, reverse, sentenceFill }

class QuizSettingsPanel extends StatelessWidget {
  final String selectedLevel;
  final QuestionType selectedType;
  final ValueChanged<String> onLevelChanged;
  final ValueChanged<QuestionType> onTypeChanged;

  static const levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  const QuizSettingsPanel({
    super.key,
    required this.selectedLevel,
    required this.selectedType,
    required this.onLevelChanged,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: AppSpacing.radiusMd,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // JLPT Level
          Text(
            l10n.jlptLevel.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: AppSpacing.radiusSm,
              border: Border.all(color: AppColors.divider),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedLevel,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary),
                items: levels
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onLevelChanged(v);
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Question type
          Text(
            l10n.questionType.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildTypeRadio(QuestionType.meaning, l10n.questionTypeMeaning),
          _buildTypeRadio(QuestionType.reverse, l10n.questionTypeReverse),
          _buildTypeRadio(QuestionType.sentenceFill, l10n.questionTypeSentenceFill),
        ],
      ),
    );
  }

  Widget _buildTypeRadio(QuestionType type, String label) {
    final selected = selectedType == type;
    return InkWell(
      onTap: () => onTypeChanged(type),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? AppColors.terracotta : AppColors.textHint,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

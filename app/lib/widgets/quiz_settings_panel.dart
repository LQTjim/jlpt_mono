import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_button.dart';

enum QuestionType { meaning, reverse, sentenceFill }

class QuizSettingsPanel extends StatelessWidget {
  final String selectedLevel;
  final Set<QuestionType> selectedTypes;
  final ValueChanged<String> onLevelChanged;
  final ValueChanged<Set<QuestionType>> onTypesChanged;
  final VoidCallback? onStart;

  static const levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  const QuizSettingsPanel({
    super.key,
    required this.selectedLevel,
    required this.selectedTypes,
    required this.onLevelChanged,
    required this.onTypesChanged,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'JLPT LEVEL',
            style: TextStyle(
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

          // Question types
          const Text(
            'QUESTION TYPES',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildTypeCheckbox(QuestionType.meaning, '詞義選擇'),
          _buildTypeCheckbox(QuestionType.reverse, '反向選擇'),
          _buildTypeCheckbox(QuestionType.sentenceFill, '例句填空'),
          const SizedBox(height: AppSpacing.md),

          // Start button
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: '開始測驗',
              onPressed: selectedTypes.isNotEmpty ? onStart : null,
              size: AppButtonSize.large,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCheckbox(QuestionType type, String label) {
    final checked = selectedTypes.contains(type);
    return InkWell(
      onTap: () {
        final updated = Set<QuestionType>.from(selectedTypes);
        if (checked && updated.length > 1) {
          updated.remove(type);
        } else if (!checked) {
          updated.add(type);
        }
        onTypesChanged(updated);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(
              checked ? Icons.check_box : Icons.check_box_outline_blank,
              color: checked ? AppColors.terracotta : AppColors.textHint,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: checked ? FontWeight.w600 : FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

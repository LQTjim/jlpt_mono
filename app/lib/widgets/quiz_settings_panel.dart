import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/sketch_borders.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? AppColors.inkLight : AppColors.inkDark;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.15);
    final subtitleColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: SketchBorders.v0,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // JLPT Level Header
          Text(
            l10n.jlptLevel.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 12),
          
          // JLPT Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceLight,
              borderRadius: SketchBorders.v1,
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedLevel,
                isExpanded: true,
                dropdownColor: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceLight,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                icon: Icon(Icons.expand_more, color: subtitleColor),
                items: levels
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onLevelChanged(v);
                },
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Question Type Header
          Text(
            l10n.questionType.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 12),
          
          // Question Types Radios
          _buildTypeRadio(context, QuestionType.meaning, l10n.questionTypeMeaning, 2),
          _buildTypeRadio(context, QuestionType.reverse, l10n.questionTypeReverse, 3),
          _buildTypeRadio(context, QuestionType.sentenceFill, l10n.questionTypeSentenceFill, 4),
        ],
      ),
    );
  }

  Widget _buildTypeRadio(BuildContext context, QuestionType type, String label, int index) {
    final selected = selectedType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = selected
        ? (isDark ? AppColors.inkLight : AppColors.inkDark)
        : (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.15));

    final bgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? AppColors.inkLight : AppColors.inkDark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () => onTypeChanged(type),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: SketchBorders.forIndex(index),
            border: Border.all(
              color: borderColor,
              width: selected ? 2.0 : 1.5,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.terracottaMuted : borderColor,
                    width: 2.0,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.terracottaMuted,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

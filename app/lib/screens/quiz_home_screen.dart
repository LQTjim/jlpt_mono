import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../utils/date_utils.dart' show formatMonthDay;
import '../providers/jlpt_level_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/quiz_history_tile.dart';
import '../widgets/quiz_settings_panel.dart';
import 'flashcard_session_screen.dart';
import 'quiz_session_screen.dart';

class QuizHomeScreen extends StatefulWidget {
  const QuizHomeScreen({super.key});

  @override
  State<QuizHomeScreen> createState() => _QuizHomeScreenState();
}

class _QuizHomeScreenState extends State<QuizHomeScreen> {
  String _selectedLevel = 'N5';
  String? _flashcardLevel;
  QuestionType _selectedType = QuestionType.meaning;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().loadHistory();
      final jlptLevel = context.read<JlptLevelProvider>().level;
      setState(() => _selectedLevel = jlptLevel.label);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final quiz = context.watch<QuizProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.quizTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Settings (always visible)
            QuizSettingsPanel(
              selectedLevel: _selectedLevel,
              selectedType: _selectedType,
              onLevelChanged: (v) => setState(() => _selectedLevel = v),
              onTypeChanged: (v) => setState(() => _selectedType = v),
            ),
            const SizedBox(height: AppSpacing.md),

            // Start button
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: l10n.startQuiz,
                icon: Icons.play_arrow,
                size: AppButtonSize.large,
                onPressed: quiz.isStarting ? null : () => _startQuiz(quiz),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: l10n.flashcardPractice,
                icon: Icons.style_outlined,
                variant: AppButtonVariant.outlined,
                size: AppButtonSize.large,
                onPressed: () => _showFlashcardSheet(l10n),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Recent scores
            _buildHistory(l10n, quiz),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory(AppLocalizations l10n, QuizProvider quiz) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recentScores,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (quiz.isLoadingHistory)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: CircularProgressIndicator(),
            ),
          )
        else if (quiz.history.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: Text(
                l10n.noQuizHistory,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textHint,
                ),
              ),
            ),
          )
        else
          ...quiz.history.map((h) {
            final date = formatMonthDay(h.completedAt);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: QuizHistoryTile(
                date: date,
                jlptLevel: h.jlptLevel,
                score: h.score,
                total: h.total,
              ),
            );
          }),
      ],
    );
  }

  void _showFlashcardSheet(AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.warmWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        var level = _flashcardLevel ?? _selectedLevel;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.style_outlined,
                          color: AppColors.terracotta, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        l10n.flashcardPractice,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
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
                  Row(
                    children: QuizSettingsPanel.levels.map((l) {
                      final selected = level == l;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: GestureDetector(
                          onTap: () => setSheetState(() => level = l),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.terracotta
                                  : Colors.transparent,
                              borderRadius: AppSpacing.radiusMd,
                              border: Border.all(
                                color: selected
                                    ? AppColors.terracotta
                                    : AppColors.divider,
                              ),
                            ),
                            child: Text(
                              l,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: l10n.flashcardStart,
                      icon: Icons.play_arrow,
                      size: AppButtonSize.large,
                      onPressed: () {
                        setState(() => _flashcardLevel = level);
                        Navigator.of(sheetContext).pop();
                        Navigator.of(this.context).push(MaterialPageRoute(
                          builder: (_) =>
                              FlashcardSessionScreen(jlptLevel: level),
                        ));
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _startQuiz(QuizProvider quiz) async {
    final typeString = switch (_selectedType) {
      QuestionType.meaning => 'MEANING',
      QuestionType.reverse => 'REVERSE',
      QuestionType.sentenceFill => 'SENTENCE_FILL',
    };

    final locale = context.read<LocaleProvider>().effectiveLocale.languageCode;
    await quiz.startQuiz(
        jlptLevel: _selectedLevel, questionType: typeString, locale: locale);

    if (!mounted) return;
    if (quiz.startError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(quiz.startError!)),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QuizSessionScreen()),
    );

    // Refresh history when returning from quiz
    if (mounted) {
      context.read<QuizProvider>().loadHistory();
    }
  }

}

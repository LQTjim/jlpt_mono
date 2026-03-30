import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/jlpt_level_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/quiz_history_tile.dart';
import '../widgets/quiz_settings_panel.dart';
import 'quiz_session_screen.dart';

class QuizHomeScreen extends StatefulWidget {
  const QuizHomeScreen({super.key});

  @override
  State<QuizHomeScreen> createState() => _QuizHomeScreenState();
}

class _QuizHomeScreenState extends State<QuizHomeScreen> {
  String _selectedLevel = 'N5';
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
            final date = _formatDate(h.completedAt);
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

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.month}/${dt.day}';
  }
}

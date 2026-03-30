import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/quiz_models.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/quiz_result_card.dart';
import '../widgets/score_ring.dart';
import 'quiz_session_screen.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final quiz = context.watch<QuizProvider>();
    final result = quiz.submitResult;

    if (result == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.quizResult),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    ScoreRing(
                      score: result.score,
                      total: result.total,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ..._buildResultCards(quiz, result),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(context, l10n, quiz),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResultCards(
    QuizProvider quiz,
    QuizSubmitResponse result,
  ) {
    final questions = quiz.questions;
    final resultMap = <int, QuizResultItem>{};
    for (final r in result.results) {
      resultMap[r.questionId] = r;
    }

    return questions.map((q) {
      final r = resultMap[q.id];
      if (r == null) return const SizedBox.shrink();

      final QuizResultState state;
      if (r.selectedKey == null) {
        state = QuizResultState.skipped;
      } else if (r.correct) {
        state = QuizResultState.correct;
      } else {
        state = QuizResultState.incorrect;
      }

      // Find the text for user's answer and correct answer
      final correctText =
          q.options.where((o) => o.key == r.correctKey).firstOrNull?.text ?? '';
      final userText = r.selectedKey != null
          ? q.options.where((o) => o.key == r.selectedKey).firstOrNull?.text
          : null;

      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: QuizResultCard(
          questionNumber: questions.indexOf(q) + 1,
          questionText: _stemText(q),
          userAnswer: userText,
          correctAnswer: correctText,
          state: state,
        ),
      );
    }).toList();
  }

  String _stemText(QuizQuestionItem q) {
    return switch (q.type) {
      'MEANING' => '${q.stem.kanji ?? q.stem.hiragana ?? ''} → ?',
      'REVERSE' => '${q.stem.definitionZh ?? q.stem.definitionEn ?? ''} → ?',
      'SENTENCE_FILL' => q.stem.sentence ?? '',
      _ => '',
    };
  }

  Widget _buildBottomButtons(
    BuildContext context,
    AppLocalizations l10n,
    QuizProvider quiz,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                label: l10n.retryQuiz,
                variant: AppButtonVariant.outlined,
                onPressed: quiz.isStarting ? null : () => _retry(context, quiz),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppButton(
                label: l10n.backToHome,
                onPressed: () => _goHome(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _retry(BuildContext context, QuizProvider quiz) async {
    final level = quiz.lastJlptLevel;
    final type = quiz.lastQuestionType;
    final locale = quiz.lastLocale;
    if (level == null || type == null || locale == null) return;

    await quiz.startQuiz(jlptLevel: level, questionType: type, locale: locale);

    if (!context.mounted) return;
    if (quiz.startError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(quiz.startError!)),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const QuizSessionScreen()),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

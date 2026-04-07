import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/quiz_models.dart';
import '../providers/locale_provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/quiz_option_card.dart';
import '../widgets/quiz_progress_bar.dart';
import 'quiz_result_screen.dart';

class QuizSessionScreen extends StatefulWidget {
  const QuizSessionScreen({super.key});

  @override
  State<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends State<QuizSessionScreen> {
  late PageController _pageController;

  int _lastSyncedIndex = 0;
  int? _pendingAdvanceIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _syncPage(int targetIndex) {
    if (_lastSyncedIndex != targetIndex && _pageController.hasClients) {
      _lastSyncedIndex = targetIndex;
      _pageController.animateToPage(
        targetIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final quiz = context.watch<QuizProvider>();

    if (quiz.isSubmitting) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.quizResult,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    // Navigate to result when submit completes
    if (quiz.submitResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const QuizResultScreen()),
        );
      });
      return const SizedBox.shrink();
    }

    final current = quiz.currentIndex + 1;
    final total = quiz.questions.length;

    // Sync page when provider index changes (e.g., skip, auto-advance)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncPage(quiz.currentIndex);
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showQuitDialog(context, l10n);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.questionLabel(current, total)),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showQuitDialog(context, l10n),
          ),
          actions: [
            TextButton(
              onPressed: _pendingAdvanceIndex != null
                  ? null
                  : () => quiz.skipQuestion(),
              child: Text(
                l10n.skip,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: QuizProgressBar(current: current, total: total),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: _pendingAdvanceIndex != null
                    ? const NeverScrollableScrollPhysics()
                    : null,
                itemCount: quiz.questions.length,
                onPageChanged: (index) {
                  _lastSyncedIndex = index;
                  quiz.goToQuestion(index);
                },
                itemBuilder: (context, index) {
                  return _buildQuestion(
                    context,
                    l10n,
                    quiz,
                    quiz.questions[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(
    BuildContext context,
    AppLocalizations l10n,
    QuizProvider quiz,
    QuizQuestionItem question,
  ) {
    final locale = context.watch<LocaleProvider>().effectiveLocale;
    final isZh = locale.languageCode == 'zh';
    final selectedKey = quiz.answers[question.id];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type label
          Text(
            _typeLabel(l10n, question.type),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Stem
          _buildStem(question, isZh),
          const SizedBox(height: AppSpacing.lg),

          // Options
          ...question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = selectedKey == option.key;
            final isLocked = _pendingAdvanceIndex != null;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: QuizOptionCard(
                index: index,
                label: option.key,
                text: option.text,
                state: isSelected
                    ? QuizOptionState.selected
                    : QuizOptionState.idle,
                onTap: isLocked
                    ? null
                    : () => _onOptionTap(quiz, question, option.key),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStem(QuizQuestionItem question, bool isZh) {
    final stem = question.stem;

    switch (question.type) {
      case 'MEANING':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (stem.kanji != null && stem.kanji!.isNotEmpty)
              Text(
                stem.kanji!,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            if (stem.hiragana != null)
              Text(
                stem.hiragana!,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        );
      case 'REVERSE':
        final definition = isZh
            ? (stem.definitionZh ?? stem.definitionEn ?? '')
            : (stem.definitionEn ?? stem.definitionZh ?? '');
        return Text(
          definition,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        );
      case 'SENTENCE_FILL':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stem.sentence ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            if (stem.translation != null && stem.translation!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                stem.translation!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _onOptionTap(QuizProvider quiz, QuizQuestionItem question, String key) {
    // Ignore taps if this question already has a pending auto-advance
    if (_pendingAdvanceIndex == quiz.currentIndex) return;

    quiz.selectAnswer(question.id, key);

    final tappedIndex = quiz.currentIndex;
    setState(() => _pendingAdvanceIndex = tappedIndex);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _pendingAdvanceIndex = null);
      // Only advance if still on the same page (swipe/skip didn't move us)
      if (quiz.currentIndex != tappedIndex) return;
      if (quiz.isLastQuestion) {
        quiz.submitQuiz();
      } else {
        quiz.nextQuestion();
      }
    });
  }

  String _typeLabel(AppLocalizations l10n, String type) {
    return switch (type) {
      'MEANING' => l10n.questionTypeMeaning,
      'REVERSE' => l10n.questionTypeReverse,
      'SENTENCE_FILL' => l10n.questionTypeSentenceFill,
      _ => type,
    };
  }

  void _showQuitDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmQuit),
        content: Text(l10n.confirmQuitMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              l10n.confirm,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/flashcard_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/flashcard_card.dart';

class FlashcardSessionScreen extends StatefulWidget {
  final String jlptLevel;

  const FlashcardSessionScreen({super.key, required this.jlptLevel});

  @override
  State<FlashcardSessionScreen> createState() => _FlashcardSessionScreenState();
}

class _FlashcardSessionScreenState extends State<FlashcardSessionScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Reset state immediately so the first build sees a clean loading state
    // (no notification — safe during initState).
    context.read<FlashcardProvider>().prepareForNewSession();
    // Fetch after the first frame to avoid notifyListeners during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<FlashcardProvider>().loadSession(widget.jlptLevel);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final flashcard = context.watch<FlashcardProvider>();
    final locale = context.read<LocaleProvider>().effectiveLocale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text(
          '${l10n.flashcardTitle} · ${widget.jlptLevel}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: flashcard.isLoading
          ? const Center(child: CircularProgressIndicator())
          : flashcard.error != null
          ? _buildError(l10n, flashcard)
          : flashcard.isEmpty
          ? _buildEmpty(l10n)
          : _buildSession(flashcard, locale, l10n),
    );
  }

  Widget _buildError(AppLocalizations l10n, FlashcardProvider flashcard) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.errorLoadingWords,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => flashcard.loadSession(widget.jlptLevel),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    return Center(
      child: Text(
        l10n.noWordsFound,
        style: const TextStyle(color: AppColors.textHint),
      ),
    );
  }

  Widget _buildSession(
    FlashcardProvider flashcard,
    String locale,
    AppLocalizations l10n,
  ) {
    final total = flashcard.words.length;
    final current = flashcard.currentIndex;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.flashcardCardCount(current + 1, total),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildProgressBar(current, total),
        const SizedBox(height: AppSpacing.lg),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: GestureDetector(
              onTap: flashcard.flipCurrent,
              child: PageView.builder(
                controller: _pageController,
                itemCount: total,
                onPageChanged: flashcard.setIndex,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    child: FlashcardCard(
                      word: flashcard.words[index],
                      isFlipped: index == current && flashcard.isFlipped,
                      locale: locale,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        Text(
          l10n.flashcardFlip,
          style: const TextStyle(fontSize: 12, color: AppColors.textHint),
        ),
        const SizedBox(height: AppSpacing.md),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              total.clamp(0, 20),
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: i == current ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == current
                      ? AppColors.terracotta
                      : AppColors.divider,
                  borderRadius: AppSpacing.radiusFull,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildProgressBar(int current, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ClipRRect(
        borderRadius: AppSpacing.radiusFull,
        child: LinearProgressIndicator(
          value: total == 0 ? 0 : (current + 1) / total,
          minHeight: 4,
          backgroundColor: AppColors.divider,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.terracotta),
        ),
      ),
    );
  }
}


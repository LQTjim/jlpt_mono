import 'dart:math';

import 'package:flutter/material.dart';

import '../models/word_summary.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_tag.dart';

class FlashcardCard extends StatefulWidget {
  final WordSummary word;
  final bool isFlipped;
  final String locale;

  const FlashcardCard({
    super.key,
    required this.word,
    required this.isFlipped,
    required this.locale,
  });

  @override
  State<FlashcardCard> createState() => _FlashcardCardState();
}

class _FlashcardCardState extends State<FlashcardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    if (widget.isFlipped) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(FlashcardCard old) {
    super.didUpdateWidget(old);
    if (widget.isFlipped != old.isFlipped) {
      widget.isFlipped ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final angle = _anim.value * pi;
        final showFront = angle < pi / 2;

        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle);
        if (!showFront) transform.rotateY(-pi);

        return Transform(
          alignment: Alignment.center,
          transform: transform,
          child: showFront ? _buildFront() : _buildBack(),
        );
      },
    );
  }

  Widget _buildFront() {
    final word = widget.word;
    final hasKanji = word.kanji != null && word.kanji!.isNotEmpty;

    return _cardShell(
      backgroundColor: AppColors.warmWhite,
      child: Stack(
        children: [
          if (word.jlptLevel != null)
            Positioned(
              top: 0,
              right: 0,
              child: AppTag(label: word.jlptLevel!, color: AppColors.terracotta),
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasKanji) ...[
                  Text(
                    word.kanji!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    word.hiragana,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else
                  Text(
                    word.hiragana,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    final word = widget.word;
    final isZh = widget.locale == 'zh';
    final definition = isZh ? word.definitionZh : word.definitionEn;

    return _cardShell(
      backgroundColor: AppColors.cream,
      child: Stack(
        children: [
          if (word.jlptLevel != null)
            Positioned(
              top: 0,
              right: 0,
              child: AppTag(label: word.jlptLevel!, color: AppColors.terracotta),
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (definition != null) ...[
                  Text(
                    definition,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (word.partOfSpeech != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.sageMuted.withValues(alpha: 0.3),
                      borderRadius: AppSpacing.radiusFull,
                    ),
                    child: Text(
                      word.partOfSpeech!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardShell({required Widget child, required Color backgroundColor}) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppSpacing.radiusLg,
        boxShadow: AppSpacing.elevatedShadow,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';

import '../models/word_summary.dart';
import '../theme/app_colors.dart';
import 'app_tag.dart';
import 'jlpt_level_tag.dart';

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

  // --- Hand-drawn Styles ---
  BorderRadius _getSketchBorder(int index) {
    switch (index.abs() % 4) {
      case 0:
        return const BorderRadius.only(
          topLeft: Radius.elliptical(14, 20),
          topRight: Radius.elliptical(180, 10),
          bottomRight: Radius.elliptical(12, 28),
          bottomLeft: Radius.elliptical(160, 12),
        );
      case 1:
        return const BorderRadius.only(
          topLeft: Radius.elliptical(180, 12),
          topRight: Radius.elliptical(10, 24),
          bottomRight: Radius.elliptical(150, 12),
          bottomLeft: Radius.elliptical(14, 18),
        );
      case 2:
        return const BorderRadius.only(
          topLeft: Radius.elliptical(10, 26),
          topRight: Radius.elliptical(150, 10),
          bottomRight: Radius.elliptical(14, 20),
          bottomLeft: Radius.elliptical(180, 14),
        );
      case 3:
      default:
        return const BorderRadius.only(
          topLeft: Radius.elliptical(160, 10),
          topRight: Radius.elliptical(14, 22),
          bottomRight: Radius.elliptical(180, 12),
          bottomLeft: Radius.elliptical(12, 26),
        );
    }
  }


  Widget _cardShell({required Widget child, required Color backgroundColor, required int hash}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.inkLight : AppColors.inkDark;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: _getSketchBorder(hash),
        border: Border.all(color: borderColor, width: 2.0),
      ),
      padding: const EdgeInsets.all(28.0),
      child: child,
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final textColor = isDark ? AppColors.inkLight : AppColors.inkDark;
    final subtitleColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return _cardShell(
      backgroundColor: isDark ? const Color(0xFF1c1917) : Colors.white,
      hash: word.hiragana.hashCode,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (word.jlptLevel != null)
            Positioned(
              top: -8,
              right: -8,
              child: JlptLevelTag(level: word.jlptLevel!),
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasKanji) ...[
                  Text(
                    word.kanji!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    word.hiragana,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: subtitleColor,
                    ),
                  ),
                ] else
                  Text(
                    word.hiragana,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: textColor,
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
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.inkLight : AppColors.inkDark;

    return _cardShell(
      // Back commonly uses a slightly warm off-color or just the cream/warmWhite depending on mode
      backgroundColor: isDark ? AppColors.surfaceElevatedDark : AppColors.cream,
      hash: word.hiragana.hashCode,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (word.jlptLevel != null)
            Positioned(
              top: -8,
              right: -8,
              child: JlptLevelTag(level: word.jlptLevel!),
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
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (word.partOfSpeech != null)
                  AppTag(label: word.partOfSpeech!, color: AppColors.sageMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

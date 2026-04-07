import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

enum QuizResultState { correct, incorrect, skipped }

class QuizResultCard extends StatelessWidget {
  final int questionNumber;
  final String questionText;
  final String? userAnswer;
  final String correctAnswer;
  final QuizResultState state;

  const QuizResultCard({
    super.key,
    required this.questionNumber,
    required this.questionText,
    this.userAnswer,
    required this.correctAnswer,
    required this.state,
  });

  BorderRadius get _sketchBorder {
    switch (questionNumber % 4) {
      case 0:
        return const BorderRadius.only(
          topLeft: Radius.elliptical(12, 20),
          topRight: Radius.elliptical(180, 10),
          bottomRight: Radius.elliptical(8, 24),
          bottomLeft: Radius.elliptical(160, 12),
        );
      case 1:
        return const BorderRadius.only(
          topLeft: Radius.elliptical(180, 12),
          topRight: Radius.elliptical(10, 22),
          bottomRight: Radius.elliptical(150, 10),
          bottomLeft: Radius.elliptical(12, 18),
        );
      case 2:
        return const BorderRadius.only(
          topLeft: Radius.elliptical(8, 24),
          topRight: Radius.elliptical(150, 10),
          bottomRight: Radius.elliptical(12, 20),
          bottomLeft: Radius.elliptical(180, 12),
        );
      case 3:
      default:
        return const BorderRadius.only(
          topLeft: Radius.elliptical(150, 10),
          topRight: Radius.elliptical(12, 18),
          bottomRight: Radius.elliptical(180, 12),
          bottomLeft: Radius.elliptical(10, 22),
        );
    }
  }

  BorderRadius get _sketchBorderLight {
    switch (questionNumber % 4) {
      case 0:
        return const BorderRadius.only(
          topLeft: Radius.elliptical(14, 18),
          topRight: Radius.elliptical(160, 12),
          bottomRight: Radius.elliptical(10, 22),
          bottomLeft: Radius.elliptical(180, 10),
        );
      case 1:
        return const BorderRadius.only(
          topLeft: Radius.elliptical(160, 10),
          topRight: Radius.elliptical(12, 20),
          bottomRight: Radius.elliptical(180, 12),
          bottomLeft: Radius.elliptical(14, 16),
        );
      case 2:
        return const BorderRadius.only(
          topLeft: Radius.elliptical(10, 26),
          topRight: Radius.elliptical(140, 11),
          bottomRight: Radius.elliptical(14, 18),
          bottomLeft: Radius.elliptical(160, 13),
        );
      case 3:
      default:
        return const BorderRadius.only(
          topLeft: Radius.elliptical(140, 12),
          topRight: Radius.elliptical(14, 16),
          bottomRight: Radius.elliptical(160, 10),
          bottomLeft: Radius.elliptical(8, 24),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCorrect = state == QuizResultState.correct;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = isCorrect
        ? (isDark ? const Color(0xFFe3dfde) : const Color(0xFF161313))
        : (isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.15));

    final bgColor = isDark ? const Color(0xFF1c1917) : Colors.white;
    final textColor = isDark ? const Color(0xFFe3dfde) : const Color(0xFF161313);
    final subtitleColor = isDark ? const Color(0xFFa8a29e) : const Color(0xFF7f6f6c);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: isCorrect ? _sketchBorder : _sketchBorderLight,
        border: Border.all(
          color: borderColor,
          width: isCorrect ? 2.0 : 1.5,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Ink Stamp background for correct answer
          if (isCorrect)
            Positioned(
              top: -8,
              right: -8,
              child: Transform.rotate(
                angle: 12 * pi / 180,
                child: Icon(
                  Icons.verified,
                  size: 80,
                  color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(_icon, color: _accentColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildContent(l10n, textColor, subtitleColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, Color textColor, Color subtitleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$questionText',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            height: 1.3,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),

        // Correct
        if (state == QuizResultState.correct)
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: l10n.yourAnswer + ' ',
                style: TextStyle(fontSize: 12, color: subtitleColor),
              ),
              TextSpan(
                text: correctAnswer,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
              ),
            ]),
          ),

        // Incorrect
        if (state == QuizResultState.incorrect) ...[
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: l10n.yourAnswer + ' ',
                style: TextStyle(fontSize: 12, color: subtitleColor),
              ),
              TextSpan(
                text: userAnswer ?? '',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.error),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${l10n.correctAnswerLabel} $correctAnswer',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: AppColors.success,
              ),
            ),
          ),
        ],

        // Skipped
        if (state == QuizResultState.skipped) ...[
          Text(
            l10n.skippedLabel,
            style: TextStyle(fontSize: 12, color: subtitleColor, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${l10n.correctAnswerLabel} $correctAnswer',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color get _accentColor => switch (state) {
        QuizResultState.correct => AppColors.success,
        QuizResultState.incorrect => AppColors.error,
        QuizResultState.skipped => AppColors.textHint,
      };

  IconData get _icon => switch (state) {
        QuizResultState.correct => Icons.check_circle,
        QuizResultState.incorrect => Icons.cancel,
        QuizResultState.skipped => Icons.remove_circle_outline,
      };
}

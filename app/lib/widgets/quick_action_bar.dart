import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/sketch_borders.dart';
import 'app_button.dart';

class QuickActionBar extends StatelessWidget {
  final String startQuizLabel;
  final String browseVocabularyLabel;
  final String flashcardLabel;
  final VoidCallback? onStartQuiz;
  final VoidCallback? onBrowseVocabulary;
  final VoidCallback? onFlashcard;

  const QuickActionBar({
    super.key,
    required this.startQuizLabel,
    required this.browseVocabularyLabel,
    required this.flashcardLabel,
    this.onStartQuiz,
    this.onBrowseVocabulary,
    this.onFlashcard,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.15);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: SketchBorders.v0,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: AppIconTextButton(
              label: startQuizLabel,
              icon: Icons.quiz_outlined,
              onPressed: onStartQuiz,
            ),
          ),
          _wavyDivider(borderColor),
          Expanded(
            child: AppIconTextButton(
              label: browseVocabularyLabel,
              icon: Icons.menu_book_outlined,
              onPressed: onBrowseVocabulary,
            ),
          ),
          _wavyDivider(borderColor),
          Expanded(
            child: AppIconTextButton(
              label: flashcardLabel,
              icon: Icons.style_outlined,
              onPressed: onFlashcard,
            ),
          ),
        ],
      ),
    );
  }

  Widget _wavyDivider(Color color) {
    return SizedBox(
      width: 4,
      height: 36,
      child: CustomPaint(painter: _WavyLinePainter(color: color)),
    );
  }
}

class _WavyLinePainter extends CustomPainter {
  final Color color;

  _WavyLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    // Draw a slight zigzag to look hand-drawn
    path.lineTo(size.width / 2 + 1.5, size.height * 0.3);
    path.lineTo(size.width / 2 - 1.5, size.height * 0.7);
    path.lineTo(size.width / 2, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavyLinePainter old) => old.color != color;
}

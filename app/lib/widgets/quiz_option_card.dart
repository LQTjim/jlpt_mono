import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum QuizOptionState { idle, selected }

class QuizOptionCard extends StatelessWidget {
  final String label;
  final String text;
  final QuizOptionState state;
  final VoidCallback? onTap;
  final int index;

  const QuizOptionCard({
    super.key,
    required this.label,
    required this.text,
    required this.index,
    this.state = QuizOptionState.idle,
    this.onTap,
  });

  // Two sets of sketch borders that "wiggle" between each other on selection
  static const List<BorderRadius> _borders = [
    BorderRadius.only(topLeft: Radius.elliptical(12, 20), topRight: Radius.elliptical(180, 10), bottomRight: Radius.elliptical(8, 24), bottomLeft: Radius.elliptical(160, 12)),
    BorderRadius.only(topLeft: Radius.elliptical(180, 12), topRight: Radius.elliptical(10, 22), bottomRight: Radius.elliptical(150, 10), bottomLeft: Radius.elliptical(12, 18)),
    BorderRadius.only(topLeft: Radius.elliptical(8, 24), topRight: Radius.elliptical(150, 10), bottomRight: Radius.elliptical(12, 20), bottomLeft: Radius.elliptical(180, 12)),
    BorderRadius.only(topLeft: Radius.elliptical(150, 10), topRight: Radius.elliptical(12, 18), bottomRight: Radius.elliptical(180, 12), bottomLeft: Radius.elliptical(10, 22)),
  ];

  static const List<BorderRadius> _bordersLight = [
    BorderRadius.only(topLeft: Radius.elliptical(14, 18), topRight: Radius.elliptical(160, 12), bottomRight: Radius.elliptical(10, 22), bottomLeft: Radius.elliptical(180, 10)),
    BorderRadius.only(topLeft: Radius.elliptical(160, 10), topRight: Radius.elliptical(12, 20), bottomRight: Radius.elliptical(180, 12), bottomLeft: Radius.elliptical(14, 16)),
    BorderRadius.only(topLeft: Radius.elliptical(10, 26), topRight: Radius.elliptical(140, 11), bottomRight: Radius.elliptical(14, 18), bottomLeft: Radius.elliptical(160, 13)),
    BorderRadius.only(topLeft: Radius.elliptical(140, 12), topRight: Radius.elliptical(14, 16), bottomRight: Radius.elliptical(160, 10), bottomLeft: Radius.elliptical(8, 24)),
  ];

  BorderRadius get _sketchBorder => _borders[index % 4];
  BorderRadius get _sketchBorderLight => _bordersLight[index % 4];

  @override
  Widget build(BuildContext context) {
    final isSelected = state == QuizOptionState.selected;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = isSelected
        ? (isDark ? AppColors.inkLight : AppColors.inkDark)
        : (isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.black.withValues(alpha: 0.15));

    final bgColor = isDark ? AppColors.surfaceDark : Colors.white;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: isSelected ? _sketchBorder : _sketchBorderLight,
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.terracottaMuted : Colors.transparent,
                borderRadius: isSelected ? _sketchBorderLight : _sketchBorder,
                border: Border.all(
                  color: isSelected ? AppColors.terracottaMuted : borderColor,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.inkLight : AppColors.inkDark),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: isDark ? AppColors.inkLight : AppColors.inkDark,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.terracottaMuted,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

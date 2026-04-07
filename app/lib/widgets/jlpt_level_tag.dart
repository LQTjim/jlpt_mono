import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Read-only JLPT level badge with sketch-style border.
class JlptLevelTag extends StatelessWidget {
  final String level;

  const JlptLevelTag({super.key, required this.level});

  static const _sketchBorder = BorderRadius.only(
    topLeft: Radius.elliptical(14, 18),
    topRight: Radius.elliptical(60, 4),
    bottomRight: Radius.elliptical(10, 16),
    bottomLeft: Radius.elliptical(56, 3),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.terracottaMuted.withValues(alpha: 0.1),
        borderRadius: _sketchBorder,
        border: Border.all(
          color: AppColors.terracottaMuted.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      child: Text(
        level.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: AppColors.terracottaMuted,
        ),
      ),
    );
  }
}

/// Selectable JLPT level chip for filter bars and level pickers.
class JlptLevelChip extends StatelessWidget {
  final String level;
  final bool selected;
  final VoidCallback onTap;

  const JlptLevelChip({
    super.key,
    required this.level,
    required this.selected,
    required this.onTap,
  });

  static const _sketchBorderSelected = BorderRadius.only(
    topLeft: Radius.elliptical(160, 2),
    topRight: Radius.elliptical(12, 20),
    bottomRight: Radius.elliptical(180, 4),
    bottomLeft: Radius.elliptical(14, 16),
  );

  static const _sketchBorderIdle = BorderRadius.only(
    topLeft: Radius.elliptical(14, 18),
    topRight: Radius.elliptical(160, 4),
    bottomRight: Radius.elliptical(10, 22),
    bottomLeft: Radius.elliptical(180, 2),
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = selected
        ? AppColors.terracottaMuted
        : (isDark ? AppColors.surfaceDark : Colors.transparent);

    final borderColor = selected
        ? AppColors.terracottaMuted
        : (isDark
            ? Colors.white.withValues(alpha: 0.2)
            : AppColors.inkDark.withValues(alpha: 0.2));

    final textColor = selected
        ? Colors.white
        : (isDark ? AppColors.inkLight : AppColors.inkDark);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius:
              selected ? _sketchBorderSelected : _sketchBorderIdle,
          border: Border.all(color: borderColor, width: selected ? 2.0 : 1.5),
        ),
        child: Text(
          level.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

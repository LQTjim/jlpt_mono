import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum AppButtonVariant { filled, outlined, text }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool iconTrailing;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconTrailing = false,
  });

  BorderRadius _getSketchBorder(int index) {
    switch (index.abs() % 4) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final primaryColor = AppColors.terracottaMuted;
    final textIconColor = isDark ? AppColors.inkLight : AppColors.inkDark;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2);

    return switch (variant) {
      AppButtonVariant.filled => _buildFilled(primaryColor),
      AppButtonVariant.outlined => _buildOutlined(borderColor, textIconColor),
      AppButtonVariant.text => _buildText(textIconColor),
    };
  }

  Widget _buildFilled(Color primaryColor) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.divider,
        disabledForegroundColor: AppColors.textHint,
        textStyle: _textStyle,
        shape: RoundedRectangleBorder(borderRadius: _getSketchBorder(label.hashCode)),
        padding: _padding,
        elevation: 0,
      ),
      child: _buildChild(Colors.white),
    );
  }

  Widget _buildOutlined(Color borderCol, Color textIconColor) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: textIconColor,
        disabledForegroundColor: AppColors.textHint,
        textStyle: _textStyle,
        side: BorderSide(
          color: onPressed != null ? borderCol : AppColors.divider,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: _getSketchBorder(label.hashCode)),
        padding: _padding,
      ),
      child: _buildChild(textIconColor),
    );
  }

  Widget _buildText(Color textIconColor) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textIconColor,
        disabledForegroundColor: AppColors.textHint,
        textStyle: _textStyle,
        shape: RoundedRectangleBorder(borderRadius: _getSketchBorder(label.hashCode)),
        padding: _padding,
      ),
      child: _buildChild(textIconColor),
    );
  }

  Widget _buildChild(Color iconColor) {
    final textWidget = Text(label.toUpperCase());

    if (icon == null) return textWidget;

    final iconWidget = Icon(icon, size: _iconSize, color: onPressed != null ? iconColor : AppColors.textHint);
    final gap = const SizedBox(width: 8);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: iconTrailing
          ? [textWidget, gap, iconWidget]
          : [iconWidget, gap, textWidget],
    );
  }

  TextStyle get _textStyle => switch (size) {
        AppButtonSize.small => const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2),
        AppButtonSize.medium => const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5),
        AppButtonSize.large => const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 2.0),
      };

  EdgeInsets get _padding => switch (size) {
        AppButtonSize.small => const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
        AppButtonSize.medium => const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
        AppButtonSize.large => const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 18),
      };

  double get _iconSize => switch (size) {
        AppButtonSize.small => 16,
        AppButtonSize.medium => 18,
        AppButtonSize.large => 22,
      };
}

/// 小型圖標+文字按鈕（如 HINT、REPORT）
class AppIconTextButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const AppIconTextButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textCol,
        shape: const RoundedRectangleBorder(
           borderRadius: BorderRadius.only(
             topLeft: Radius.elliptical(8, 12),
             topRight: Radius.elliptical(40, 4),
             bottomRight: Radius.elliptical(6, 14),
             bottomLeft: Radius.elliptical(60, 6),
           )
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: onPressed != null ? textCol : AppColors.textHint),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: onPressed != null ? textCol : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

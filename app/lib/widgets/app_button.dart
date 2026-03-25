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

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      AppButtonVariant.filled => _buildFilled(),
      AppButtonVariant.outlined => _buildOutlined(),
      AppButtonVariant.text => _buildText(),
    };
  }

  Widget _buildFilled() {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.divider,
        disabledForegroundColor: AppColors.textHint,
        textStyle: _textStyle,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.radiusMd),
        padding: _padding,
        elevation: 0,
      ),
      child: _buildChild(Colors.white),
    );
  }

  Widget _buildOutlined() {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.terracotta,
        disabledForegroundColor: AppColors.textHint,
        textStyle: _textStyle,
        side: BorderSide(
          color: onPressed != null ? AppColors.terracotta : AppColors.divider,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.radiusMd),
        padding: _padding,
      ),
      child: _buildChild(AppColors.terracotta),
    );
  }

  Widget _buildText() {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        disabledForegroundColor: AppColors.textHint,
        textStyle: _textStyle,
        padding: _padding,
      ),
      child: _buildChild(AppColors.textPrimary),
    );
  }

  Widget _buildChild(Color iconColor) {
    if (icon == null) return Text(label);

    final iconWidget = Icon(icon, size: _iconSize, color: onPressed != null ? iconColor : AppColors.textHint);
    final textWidget = Text(label);
    final gap = SizedBox(width: AppSpacing.sm);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: iconTrailing
          ? [textWidget, gap, iconWidget]
          : [iconWidget, gap, textWidget],
    );
  }

  TextStyle get _textStyle => switch (size) {
        AppButtonSize.small => const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        AppButtonSize.medium => const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        AppButtonSize.large => const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      };

  EdgeInsets get _padding => switch (size) {
        AppButtonSize.small => const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        AppButtonSize.medium => const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        AppButtonSize.large => const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 18),
      };

  double get _iconSize => switch (size) {
        AppButtonSize.small => 16,
        AppButtonSize.medium => 18,
        AppButtonSize.large => 20,
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
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(height: 2),
          Text(label),
        ],
      ),
    );
  }
}

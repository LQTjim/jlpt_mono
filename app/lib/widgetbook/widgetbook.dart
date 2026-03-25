import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/app_button.dart';

void main() {
  runApp(const WidgetbookApp());
}

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      themeMode: ThemeMode.light,
      addons: [
        ThemeAddon(
          themes: [WidgetbookTheme(name: 'Light', data: AppTheme.light)],
          themeBuilder: (context, theme, child) =>
              Theme(data: theme, child: child),
          initialTheme: WidgetbookTheme(name: 'Light', data: AppTheme.light),
        ),
        ViewportAddon([
          ViewportData(
            name: 'iPhone 13',
            width: 390,
            height: 844,
            pixelRatio: 3,
            platform: TargetPlatform.iOS,
          ),
          ViewportData(
            name: 'Samsung Galaxy S20',
            width: 360,
            height: 800,
            pixelRatio: 3,
            platform: TargetPlatform.android,
          ),
        ]),
      ],
      directories: [
        WidgetbookCategory(
          name: 'Tokens',
          children: [
            WidgetbookComponent(name: 'Colors', useCases: [
              WidgetbookUseCase(
                  name: 'Palette', builder: (_) => const _ColorPalette()),
            ]),
            WidgetbookComponent(name: 'Typography', useCases: [
              WidgetbookUseCase(
                  name: 'Scale', builder: (_) => const _TypographyScale()),
            ]),
            WidgetbookComponent(name: 'Spacing', useCases: [
              WidgetbookUseCase(
                  name: 'Scale', builder: (_) => const _SpacingScale()),
            ]),
          ],
        ),
        WidgetbookCategory(
          name: 'Components',
          children: [
            WidgetbookComponent(name: 'AppButton', useCases: [
              WidgetbookUseCase(
                  name: 'All Variants', builder: (_) => const _ButtonShowcase()),
            ]),
            WidgetbookComponent(name: 'AppIconTextButton', useCases: [
              WidgetbookUseCase(
                  name: 'Examples', builder: (_) => const _IconTextButtonShowcase()),
            ]),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Color Palette Preview
// ---------------------------------------------------------------------------

class _ColorPalette extends StatelessWidget {
  const _ColorPalette();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('Backgrounds', [
            _swatch('cream', AppColors.cream),
            _swatch('warmWhite', AppColors.warmWhite),
          ]),
          _section('Primary', [
            _swatch('terracotta', AppColors.terracotta),
            _swatch('terracottaLight', AppColors.terracottaLight),
            _swatch('terracottaDark', AppColors.terracottaDark),
          ]),
          _section('Secondary', [
            _swatch('sage', AppColors.sage),
            _swatch('sageMuted', AppColors.sageMuted),
          ]),
          _section('Neutrals', [
            _swatch('textPrimary', AppColors.textPrimary),
            _swatch('textSecondary', AppColors.textSecondary),
            _swatch('textHint', AppColors.textHint),
            _swatch('divider', AppColors.divider),
          ]),
          _section('Semantic', [
            _swatch('error', AppColors.error),
            _swatch('success', AppColors.success),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> swatches) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(spacing: 12, runSpacing: 12, children: swatches),
        ],
      ),
    );
  }

  Widget _swatch(String name, Color color) {
    final isLight = color.computeLuminance() > 0.5;
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: isLight
                ? Border.all(color: const Color(0xFFE0E0E0))
                : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Typography Scale Preview
// ---------------------------------------------------------------------------

class _TypographyScale extends StatelessWidget {
  const _TypographyScale();

  @override
  Widget build(BuildContext context) {
    const jp = Locale('ja');
    const zh = Locale('zh');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- UI Japanese ---
          const Text('UI — Japanese',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('headingLarge 日本語の見出し', style: AppTypography.headingLarge(jp)),
          Text('headingMedium お知らせ', style: AppTypography.headingMedium(jp)),
          Text('headingSmall カテゴリー', style: AppTypography.headingSmall(jp)),
          Text('bodyLarge これは本文のサンプルです。', style: AppTypography.bodyLarge(jp)),
          Text('bodyMedium 補足テキスト', style: AppTypography.bodyMedium(jp)),
          Text('bodySmall ヒント表示', style: AppTypography.bodySmall(jp)),
          Text('labelLarge ボタンラベル', style: AppTypography.labelLarge(jp)),
          const SizedBox(height: 24),

          // --- UI 繁體中文 ---
          const Text('UI — 繁體中文',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('headingLarge 每日挑戰', style: AppTypography.headingLarge(zh)),
          Text('headingMedium 分類瀏覽', style: AppTypography.headingMedium(zh)),
          Text('headingSmall 學習紀錄', style: AppTypography.headingSmall(zh)),
          Text('bodyLarge 這是內文的範例文字。', style: AppTypography.bodyLarge(zh)),
          Text('bodyMedium 補充說明', style: AppTypography.bodyMedium(zh)),
          Text('bodySmall 提示文字', style: AppTypography.bodySmall(zh)),
          Text('labelLarge 按鈕標籤', style: AppTypography.labelLarge(zh)),
          const SizedBox(height: 24),

          // --- Content 固定 JP ---
          const Text('Content — 固定 JP',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('食べる', style: AppTypography.contentHeading),
          Text('試験に落ちて落ち込んでいます。', style: AppTypography.contentBody),
          Text('たべる — 吃、食用', style: AppTypography.contentCaption),
          const SizedBox(height: 24),

          // --- 混合文字測試 ---
          const Text('Mixed — 中日混合 (fallback test)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('這個單字是「食べる」，意思是吃。', style: AppTypography.bodyLarge(zh)),
          Text('「落ち込む」的中文是沮喪、消沉。', style: AppTypography.bodyMedium(zh)),
          Text('The word 食べる means "to eat".', style: AppTypography.bodyLarge(jp)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Spacing Scale Preview
// ---------------------------------------------------------------------------

class _SpacingScale extends StatelessWidget {
  const _SpacingScale();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Spacing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _spacingRow('xs', AppSpacing.xs),
          _spacingRow('sm', AppSpacing.sm),
          _spacingRow('md', AppSpacing.md),
          _spacingRow('lg', AppSpacing.lg),
          _spacingRow('xl', AppSpacing.xl),
          _spacingRow('xxl', AppSpacing.xxl),
          const SizedBox(height: 24),
          const Text('Border Radius',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _radiusBox('radiusSm', AppSpacing.radiusSm),
              _radiusBox('radiusMd', AppSpacing.radiusMd),
              _radiusBox('radiusLg', AppSpacing.radiusLg),
              _radiusBox('radiusFull', AppSpacing.radiusFull),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Shadows',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            children: [
              _shadowBox('card', AppSpacing.cardShadow),
              const SizedBox(width: 24),
              _shadowBox('elevated', AppSpacing.elevatedShadow),
            ],
          ),
        ],
      ),
    );
  }

  Widget _spacingRow(String name, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
              width: 40,
              child: Text(name, style: const TextStyle(fontSize: 13))),
          Container(
            width: value,
            height: 24,
            color: AppColors.terracotta,
          ),
          const SizedBox(width: 8),
          Text('${value.toInt()}px',
              style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _radiusBox(String name, BorderRadius radius) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.terracottaLight,
            borderRadius: radius,
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _shadowBox(String name, List<BoxShadow> shadow) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.warmWhite,
            borderRadius: AppSpacing.radiusMd,
            boxShadow: shadow,
          ),
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Button Showcase
// ---------------------------------------------------------------------------

class _ButtonShowcase extends StatelessWidget {
  const _ButtonShowcase();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Filled ---
          const Text('Filled',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppButton(label: 'START', size: AppButtonSize.large, onPressed: () {}),
              AppButton(label: 'Next Question', icon: Icons.arrow_forward, iconTrailing: true, onPressed: () {}),
              AppButton(label: 'Small', size: AppButtonSize.small, onPressed: () {}),
              const AppButton(label: 'Disabled'),
            ],
          ),
          const SizedBox(height: 24),

          // --- Outlined ---
          const Text('Outlined',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppButton(label: 'TRY AGAIN', variant: AppButtonVariant.outlined, icon: Icons.refresh, onPressed: () {}),
              AppButton(label: 'Outlined', variant: AppButtonVariant.outlined, onPressed: () {}),
              AppButton(label: 'Small', variant: AppButtonVariant.outlined, size: AppButtonSize.small, onPressed: () {}),
              const AppButton(label: 'Disabled', variant: AppButtonVariant.outlined),
            ],
          ),
          const SizedBox(height: 24),

          // --- Text ---
          const Text('Text',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppButton(label: 'REVIEW ANSWERS', variant: AppButtonVariant.text, onPressed: () {}),
              AppButton(label: 'BACK TO DASHBOARD', variant: AppButtonVariant.text, onPressed: () {}),
              const AppButton(label: 'Disabled', variant: AppButtonVariant.text),
            ],
          ),
          const SizedBox(height: 24),

          // --- Full width ---
          const Text('Full Width',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AppButton(label: 'Next Question', size: AppButtonSize.large, icon: Icons.arrow_forward, iconTrailing: true, onPressed: () {}),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: AppButton(label: 'TRY AGAIN', variant: AppButtonVariant.outlined, icon: Icons.refresh, onPressed: () {}),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: AppButton(label: 'BACK TO DASHBOARD', variant: AppButtonVariant.text, onPressed: () {}),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Icon Text Button Showcase
// ---------------------------------------------------------------------------

class _IconTextButtonShowcase extends StatelessWidget {
  const _IconTextButtonShowcase();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Icon Text Buttons',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIconTextButton(label: 'HINT', icon: Icons.lightbulb_outline, onPressed: () {}),
              const SizedBox(width: 32),
              AppIconTextButton(label: 'REPORT', icon: Icons.flag_outlined, onPressed: () {}),
              const SizedBox(width: 32),
              AppIconTextButton(label: 'SHARE', icon: Icons.share_outlined, onPressed: () {}),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Disabled',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIconTextButton(label: 'HINT', icon: Icons.lightbulb_outline),
              SizedBox(width: 32),
              AppIconTextButton(label: 'REPORT', icon: Icons.flag_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

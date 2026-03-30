import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:widgetbook/widgetbook.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../widgets/app_button.dart';
import '../widgets/quiz_history_tile.dart';
import '../widgets/quiz_option_card.dart';
import '../widgets/quiz_progress_bar.dart';
import '../widgets/quiz_result_card.dart';
import '../widgets/quiz_settings_panel.dart';
import '../widgets/score_ring.dart';

void main() {
  runApp(const WidgetbookApp());
}

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      themeMode: ThemeMode.light,
      appBuilder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Material(child: child),
      ),
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
        WidgetbookCategory(
          name: 'Quiz',
          children: [
            WidgetbookComponent(name: 'QuizOptionCard', useCases: [
              WidgetbookUseCase(
                  name: 'States', builder: (_) => const _QuizOptionCardShowcase()),
            ]),
            WidgetbookComponent(name: 'QuizProgressBar', useCases: [
              WidgetbookUseCase(
                  name: 'Progress', builder: (_) => const _QuizProgressBarShowcase()),
            ]),
            WidgetbookComponent(name: 'ScoreRing', useCases: [
              WidgetbookUseCase(
                  name: 'Scores', builder: (_) => const _ScoreRingShowcase()),
            ]),
            WidgetbookComponent(name: 'QuizResultCard', useCases: [
              WidgetbookUseCase(
                  name: 'States', builder: (_) => const _QuizResultCardShowcase()),
            ]),
            WidgetbookComponent(name: 'QuizSettingsPanel', useCases: [
              WidgetbookUseCase(
                  name: 'Interactive', builder: (_) => const _QuizSettingsPanelShowcase()),
            ]),
            WidgetbookComponent(name: 'QuizHistoryTile', useCases: [
              WidgetbookUseCase(
                  name: 'Examples', builder: (_) => const _QuizHistoryTileShowcase()),
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
// Quiz Option Card Showcase
// ---------------------------------------------------------------------------

class _QuizOptionCardShowcase extends StatefulWidget {
  const _QuizOptionCardShowcase();

  @override
  State<_QuizOptionCardShowcase> createState() =>
      _QuizOptionCardShowcaseState();
}

class _QuizOptionCardShowcaseState extends State<_QuizOptionCardShowcase> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final options = [
      ('A', '吃'),
      ('B', '喝'),
      ('C', '玩'),
      ('D', '跑'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Interactive',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...options.map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: QuizOptionCard(
                  label: o.$1,
                  text: o.$2,
                  state: _selected == o.$1
                      ? QuizOptionState.selected
                      : QuizOptionState.idle,
                  onTap: () => setState(() => _selected = o.$1),
                ),
              )),
          const SizedBox(height: 24),
          const Text('Japanese Word Options',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const QuizOptionCard(
              label: 'A', text: '食べる (たべる)', state: QuizOptionState.idle),
          const SizedBox(height: 8),
          const QuizOptionCard(
              label: 'B',
              text: '飲む (のむ)',
              state: QuizOptionState.selected),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quiz Progress Bar Showcase
// ---------------------------------------------------------------------------

class _QuizProgressBarShowcase extends StatelessWidget {
  const _QuizProgressBarShowcase();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Progress States',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...[1, 3, 5, 8, 10].map((i) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Q$i / 10',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    QuizProgressBar(current: i, total: 10),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Score Ring Showcase
// ---------------------------------------------------------------------------

class _ScoreRingShowcase extends StatelessWidget {
  const _ScoreRingShowcase();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Score Ring Sizes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const ScoreRing(score: 8, total: 10, size: 180),
          const SizedBox(height: 32),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              const ScoreRing(score: 10, total: 10, size: 100),
              const ScoreRing(score: 5, total: 10, size: 100),
              const ScoreRing(score: 2, total: 10, size: 100),
              const ScoreRing(score: 0, total: 10, size: 100),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quiz Result Card Showcase
// ---------------------------------------------------------------------------

class _QuizResultCardShowcase extends StatelessWidget {
  const _QuizResultCardShowcase();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Result States',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const QuizResultCard(
            questionNumber: 1,
            questionText: '食べる → ?',
            correctAnswer: '吃',
            state: QuizResultState.correct,
          ),
          const SizedBox(height: 8),
          const QuizResultCard(
            questionNumber: 2,
            questionText: '飲む → ?',
            userAnswer: '吃',
            correctAnswer: '喝',
            state: QuizResultState.incorrect,
          ),
          const SizedBox(height: 8),
          const QuizResultCard(
            questionNumber: 3,
            questionText: '朝ごはんを＿＿＿。',
            correctAnswer: '食べる',
            state: QuizResultState.skipped,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quiz Settings Panel Showcase
// ---------------------------------------------------------------------------

class _QuizSettingsPanelShowcase extends StatefulWidget {
  const _QuizSettingsPanelShowcase();

  @override
  State<_QuizSettingsPanelShowcase> createState() =>
      _QuizSettingsPanelShowcaseState();
}

class _QuizSettingsPanelShowcaseState
    extends State<_QuizSettingsPanelShowcase> {
  String _level = 'N5';
  QuestionType _type = QuestionType.meaning;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: QuizSettingsPanel(
        selectedLevel: _level,
        selectedType: _type,
        onLevelChanged: (v) => setState(() => _level = v),
        onTypeChanged: (v) => setState(() => _type = v),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quiz History Tile Showcase
// ---------------------------------------------------------------------------

class _QuizHistoryTileShowcase extends StatelessWidget {
  const _QuizHistoryTileShowcase();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Scores',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const QuizHistoryTile(
              date: '3/26', jlptLevel: 'N5', score: 9, total: 10),
          const SizedBox(height: 8),
          const QuizHistoryTile(
              date: '3/25', jlptLevel: 'N4', score: 7, total: 10),
          const SizedBox(height: 8),
          const QuizHistoryTile(
              date: '3/24', jlptLevel: 'N5', score: 4, total: 10),
          const SizedBox(height: 8),
          const QuizHistoryTile(
              date: '3/23', jlptLevel: 'N3', score: 10, total: 10),
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

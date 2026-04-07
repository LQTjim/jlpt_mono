import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:widgetbook/widgetbook.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import 'package:provider/provider.dart';

import '../providers/audio_provider.dart';
import '../services/audio_service.dart';
import '../models/word_summary.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_button.dart';
import '../widgets/app_loading_screen.dart';
import '../widgets/audio_play_button.dart';
import '../widgets/jlpt_level_tag.dart';
import '../widgets/flashcard_card.dart';
import '../widgets/greeting_header.dart';
import '../widgets/quick_action_bar.dart';
import '../widgets/quiz_history_tile.dart';
import '../widgets/quiz_option_card.dart';
import '../widgets/quiz_progress_bar.dart';
import '../widgets/quiz_result_card.dart';
import '../widgets/quiz_settings_panel.dart';
import '../widgets/score_ring.dart';
import '../widgets/study_summary_card.dart';

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
          name: 'Flashcard',
          children: [
            WidgetbookComponent(name: 'FlashcardCard', useCases: [
              WidgetbookUseCase(
                  name: 'Front (with kanji)',
                  builder: (_) => _FlashcardFrontShowcase()),
              WidgetbookUseCase(
                  name: 'Back (meaning)',
                  builder: (_) => _FlashcardBackShowcase()),
              WidgetbookUseCase(
                  name: 'Kana only (no kanji)',
                  builder: (_) => _FlashcardKanaOnlyShowcase()),
            ]),
          ],
        ),
        WidgetbookCategory(
          name: 'Vocabulary',
          children: [
            WidgetbookComponent(name: 'AudioPlayButton', useCases: [
              WidgetbookUseCase(
                  name: 'All States',
                  builder: (_) => const _AudioPlayButtonShowcase()),
            ]),
          ],
        ),
        WidgetbookCategory(
          name: 'Components',
          children: [
            WidgetbookComponent(name: 'AppLoadingScreen', useCases: [
              WidgetbookUseCase(
                  name: 'Default', builder: (_) => const AppLoadingScreen()),
            ]),
            WidgetbookComponent(name: 'AppButton', useCases: [
              WidgetbookUseCase(
                  name: 'All Variants', builder: (_) => const _ButtonShowcase()),
            ]),
            WidgetbookComponent(name: 'AppIconTextButton', useCases: [
              WidgetbookUseCase(
                  name: 'Examples', builder: (_) => const _IconTextButtonShowcase()),
            ]),
            WidgetbookComponent(name: 'AppBottomNavBar', useCases: [
              WidgetbookUseCase(
                  name: 'Interactive',
                  builder: (_) => const _AppBottomNavBarShowcase()),
              WidgetbookUseCase(
                  name: 'All Items Selected',
                  builder: (_) => const _AppBottomNavBarAllStatesShowcase()),
            ]),
            WidgetbookComponent(name: 'JlptLevelTag', useCases: [
              WidgetbookUseCase(
                  name: 'All Levels',
                  builder: (_) => const _JlptLevelTagShowcase()),
            ]),
            WidgetbookComponent(name: 'JlptLevelChip', useCases: [
              WidgetbookUseCase(
                  name: 'Interactive',
                  builder: (_) => const _JlptLevelChipShowcase()),
            ]),
          ],
        ),
        WidgetbookCategory(
          name: 'Dashboard',
          children: [
            WidgetbookComponent(name: 'GreetingHeader', useCases: [
              WidgetbookUseCase(
                  name: 'Variants', builder: (_) => const _GreetingHeaderShowcase()),
            ]),
            WidgetbookComponent(name: 'StudySummaryCard', useCases: [
              WidgetbookUseCase(
                  name: 'States', builder: (_) => const _StudySummaryCardShowcase()),
            ]),
            WidgetbookComponent(name: 'QuickActionBar', useCases: [
              WidgetbookUseCase(
                  name: 'Interactive', builder: (_) => const _QuickActionBarShowcase()),
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
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final o = entry.value;
            return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: QuizOptionCard(
                  index: index,
                  label: o.$1,
                  text: o.$2,
                  state: _selected == o.$1
                      ? QuizOptionState.selected
                      : QuizOptionState.idle,
                  onTap: () => setState(() => _selected = o.$1),
                ),
              );
          }),
          const SizedBox(height: 24),
          const Text('Japanese Word Options',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const QuizOptionCard(
              index: 0, label: 'A', text: '食べる (たべる)', state: QuizOptionState.idle),
          const SizedBox(height: 8),
          const QuizOptionCard(
              index: 1,
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
// Greeting Header Showcase
// ---------------------------------------------------------------------------

class _GreetingHeaderShowcase extends StatelessWidget {
  const _GreetingHeaderShowcase();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('With Avatar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const GreetingHeader(
            name: 'Kevin',
            jlptLevel: 'N5',
            greeting: '早安，',
            pictureUrl: null,
          ),
          const SizedBox(height: 24),
          const Text('Morning',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const GreetingHeader(
            name: 'Kevin',
            jlptLevel: 'N3',
            greeting: 'Good morning, ',
          ),
          const SizedBox(height: 24),
          const Text('Evening',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const GreetingHeader(
            name: '使用者',
            jlptLevel: 'N1',
            greeting: '晚安，',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Study Summary Card Showcase
// ---------------------------------------------------------------------------

class _StudySummaryCardShowcase extends StatelessWidget {
  const _StudySummaryCardShowcase();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('With Data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const StudySummaryCard(
            totalQuizzes: 42,
            averageScore: 78,
            currentStreak: 5,
            totalQuizzesLabel: '測驗數',
            averageScoreLabel: '平均分',
            currentStreakLabel: '連續天數',
          ),
          const SizedBox(height: 24),
          const Text('Empty State',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const StudySummaryCard(
            totalQuizzes: 0,
            averageScore: 0,
            currentStreak: 0,
            totalQuizzesLabel: 'Quizzes',
            averageScoreLabel: 'Average',
            currentStreakLabel: 'Streak',
          ),
          const SizedBox(height: 24),
          const Text('High Stats',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const StudySummaryCard(
            totalQuizzes: 365,
            averageScore: 95,
            currentStreak: 30,
            totalQuizzesLabel: 'Quizzes',
            averageScoreLabel: 'Average',
            currentStreakLabel: 'Streak',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Action Bar Showcase
// ---------------------------------------------------------------------------

class _QuickActionBarShowcase extends StatelessWidget {
  const _QuickActionBarShowcase();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enabled',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          QuickActionBar(
            startQuizLabel: '開始測驗',
            browseVocabularyLabel: '瀏覽單字',
            flashcardLabel: '單字卡',
            onStartQuiz: () {},
            onBrowseVocabulary: () {},
            onFlashcard: () {},
          ),
          const SizedBox(height: 24),
          const Text('English',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          QuickActionBar(
            startQuizLabel: 'Start Quiz',
            browseVocabularyLabel: 'Vocabulary',
            flashcardLabel: 'Flashcard',
            onStartQuiz: () {},
            onBrowseVocabulary: () {},
            onFlashcard: () {},
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Audio Play Button Showcase
// ---------------------------------------------------------------------------

class _AudioPlayButtonShowcase extends StatelessWidget {
  const _AudioPlayButtonShowcase();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Play (idle / failed)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _audioButtonWithState(AudioStatus.idle),
          const SizedBox(height: 24),
          const Text('Loading (generating or playing)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _audioButtonWithState(AudioStatus.loading),
          const SizedBox(height: 24),
          const Text('In context (header)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _headerPreview(),
        ],
      ),
    );
  }

  Widget _audioButtonWithState(AudioStatus status) {
    const wordId = 1;
    return ChangeNotifierProvider(
      create: (_) => AudioProvider(
        _nullAudioService,
        initialStates: {
          wordId: AudioWordState(
            status: status,
            presignedUrl: status == AudioStatus.ready ? 'https://example.com/audio.mp3' : null,
          ),
        },
      ),
      child: const AudioPlayButton(wordId: wordId),
    );
  }

  Widget _headerPreview() {
    const wordId = 2;
    return ChangeNotifierProvider(
      create: (_) => AudioProvider(
        _nullAudioService,
        initialStates: {
          wordId: const AudioWordState(status: AudioStatus.idle),
        },
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text('こんにちは',
                style: TextStyle(fontSize: 20, color: AppColors.textSecondary)),
            SizedBox(width: 4),
            AudioPlayButton(wordId: wordId),
          ],
        ),
      ),
    );
  }
}

/// No-op AudioService for Widgetbook stories — never makes real network calls.
AudioService get _nullAudioService => AudioService.stub();

// ---------------------------------------------------------------------------
// Flashcard Showcases
// ---------------------------------------------------------------------------

final _mockWordWithKanji = WordSummary(
  id: 1,
  kanji: '食べる',
  hiragana: 'たべる',
  romaji: 'taberu',
  definitionZh: '吃、食用',
  definitionEn: 'to eat',
  partOfSpeech: 'verb',
  jlptLevel: 'N5',
);

final _mockWordKanaOnly = WordSummary(
  id: 2,
  kanji: null,
  hiragana: 'たくさん',
  romaji: 'takusan',
  definitionZh: '很多、大量',
  definitionEn: 'many, a lot',
  partOfSpeech: 'adverb',
  jlptLevel: 'N5',
);

class _FlashcardFrontShowcase extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  _FlashcardFrontShowcase();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: SizedBox(
          height: 320,
          child: FlashcardCard(
            word: _mockWordWithKanji,
            isFlipped: false,
            locale: 'zh',
          ),
        ),
      ),
    );
  }
}

class _FlashcardBackShowcase extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  _FlashcardBackShowcase();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: SizedBox(
          height: 320,
          child: FlashcardCard(
            word: _mockWordWithKanji,
            isFlipped: true,
            locale: 'zh',
          ),
        ),
      ),
    );
  }
}

class _FlashcardKanaOnlyShowcase extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  _FlashcardKanaOnlyShowcase();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: SizedBox(
          height: 320,
          child: FlashcardCard(
            word: _mockWordKanaOnly,
            isFlipped: false,
            locale: 'zh',
          ),
        ),
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

// ---------------------------------------------------------------------------
// AppBottomNavBar Showcase
// ---------------------------------------------------------------------------

final _defaultNavItems = [
  const AppNavItemData(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    label: 'Home',
  ),
  const AppNavItemData(
    icon: Icons.menu_book_outlined,
    activeIcon: Icons.menu_book,
    label: 'Vocabulary',
  ),
  const AppNavItemData(
    icon: Icons.edit_note,
    activeIcon: Icons.edit_note,
    label: 'Quiz',
  ),
  const AppNavItemData(
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: 'Profile',
  ),
];

class _AppBottomNavBarShowcase extends StatefulWidget {
  const _AppBottomNavBarShowcase();

  @override
  State<_AppBottomNavBarShowcase> createState() =>
      _AppBottomNavBarShowcaseState();
}

class _AppBottomNavBarShowcaseState extends State<_AppBottomNavBarShowcase> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Center(
            child: Text(
              'Tab $_selectedIndex selected',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        AppBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTap: (i) => setState(() => _selectedIndex = i),
          items: _defaultNavItems,
        ),
      ],
    );
  }
}

class _AppBottomNavBarAllStatesShowcase extends StatelessWidget {
  const _AppBottomNavBarAllStatesShowcase();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int selected = 0; selected < 4; selected++) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'Selected: ${_defaultNavItems[selected].label}',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            AppBottomNavBar(
              selectedIndex: selected,
              onItemTap: (_) {},
              items: _defaultNavItems,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// JlptLevelTag Showcase
// ---------------------------------------------------------------------------

class _JlptLevelTagShowcase extends StatelessWidget {
  const _JlptLevelTagShowcase();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            JlptLevelTag(level: 'N5'),
            JlptLevelTag(level: 'N4'),
            JlptLevelTag(level: 'N3'),
            JlptLevelTag(level: 'N2'),
            JlptLevelTag(level: 'N1'),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// JlptLevelChip Showcase
// ---------------------------------------------------------------------------

class _JlptLevelChipShowcase extends StatefulWidget {
  const _JlptLevelChipShowcase();

  @override
  State<_JlptLevelChipShowcase> createState() => _JlptLevelChipShowcaseState();
}

class _JlptLevelChipShowcaseState extends State<_JlptLevelChipShowcase> {
  String _selected = 'N5';

  @override
  Widget build(BuildContext context) {
    const levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: levels.map((level) {
            return JlptLevelChip(
              level: level,
              selected: _selected == level,
              onTap: () => setState(() => _selected = level),
            );
          }).toList(),
        ),
      ),
    );
  }
}

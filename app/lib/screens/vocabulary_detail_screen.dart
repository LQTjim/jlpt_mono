import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/example.dart';
import '../models/related_word.dart';
import '../models/word_detail.dart';
import '../providers/locale_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/app_tag.dart';
import '../widgets/audio_play_button.dart';
import '../widgets/jlpt_level_tag.dart';

class VocabularyDetailScreen extends StatefulWidget {
  final int wordId;
  const VocabularyDetailScreen({super.key, required this.wordId});

  @override
  State<VocabularyDetailScreen> createState() => _VocabularyDetailScreenState();
}

class _VocabularyDetailScreenState extends State<VocabularyDetailScreen> {
  late Future<WordDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<VocabularyProvider>().service.getWordDetail(widget.wordId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = context.watch<LocaleProvider>().effectiveLocale;

    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<WordDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.errorLoadingWords,
                      style: AppTypography.bodyLarge(locale)),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => setState(() {
                      _future = context
                          .read<VocabularyProvider>()
                          .service
                          .getWordDetail(widget.wordId);
                    }),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          return _DetailContent(
              word: snapshot.data!, locale: locale, l10n: l10n);
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final WordDetail word;
  final Locale locale;
  final AppLocalizations l10n;

  const _DetailContent({
    required this.word,
    required this.locale,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isZh = locale.languageCode == 'zh';

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildHeader(isZh),
        if (word.examples.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildSection(
              l10n.examples,
              word.examples
                  .map((e) => _ExampleTile(example: e, locale: locale))
                  .toList()),
        ],
        if (word.relations.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildSection(
              l10n.relatedWords,
              word.relations
                  .map((r) =>
                      _RelatedWordTile(relation: r, locale: locale, l10n: l10n))
                  .toList()),
        ],
      ],
    );
  }

  Widget _buildHeader(bool isZh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (word.kanji != null)
          Text(word.kanji!,
              style: AppTypography.contentHeading.copyWith(fontSize: 36)),
        const SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(word.hiragana,
                style: AppTypography.contentBody
                    .copyWith(fontSize: 20, color: AppColors.textSecondary)),
            const SizedBox(width: AppSpacing.xs),
            AudioPlayButton(wordId: word.id),
          ],
        ),
        if (word.romaji != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(word.romaji!, style: AppTypography.bodySmall(locale)),
        ],
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            if (word.jlptLevel != null)
              JlptLevelTag(level: word.jlptLevel!),
            if (word.partOfSpeech != null) ...[
              const SizedBox(width: AppSpacing.sm),
              AppTag(label: word.partOfSpeech!, color: AppColors.sage),
            ],
            if (word.verbType != null) ...[
              const SizedBox(width: AppSpacing.sm),
              AppTag(label: word.verbType!, color: AppColors.sageMuted),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (word.definitionZh != null)
          Text(word.definitionZh!, style: AppTypography.bodyLarge(locale)),
        if (word.definitionEn != null && !isZh) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(word.definitionEn!, style: AppTypography.bodyLarge(locale)),
        ],
        if (word.definitionEn != null && isZh) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(word.definitionEn!, style: AppTypography.bodyMedium(locale)),
        ],
        if (word.notes != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(word.notes!,
              style: AppTypography.bodySmall(locale)
                  .copyWith(fontStyle: FontStyle.italic)),
        ],
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.headingSmall(locale)),
        const SizedBox(height: AppSpacing.sm),
        ...children,
      ],
    );
  }
}

class _ExampleTile extends StatelessWidget {
  final Example example;
  final Locale locale;
  const _ExampleTile({required this.example, required this.locale});

  @override
  Widget build(BuildContext context) {
    final isZh = locale.languageCode == 'zh';
    final translation = isZh ? example.sentenceZh : example.sentenceEn;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          borderRadius: AppSpacing.radiusMd,
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(example.sentenceJp, style: AppTypography.contentBody),
            if (translation != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(translation, style: AppTypography.bodyMedium(locale)),
            ],
          ],
        ),
      ),
    );
  }
}

class _RelatedWordTile extends StatelessWidget {
  final RelatedWord relation;
  final Locale locale;
  final AppLocalizations l10n;

  const _RelatedWordTile({
    required this.relation,
    required this.locale,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isZh = locale.languageCode == 'zh';
    final definition = isZh ? relation.definitionZh : relation.definitionEn;
    final typeLabel = switch (relation.relationType) {
      'synonym' => l10n.synonym,
      'antonym' => l10n.antonym,
      _ => l10n.related,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusMd,
          side: BorderSide(color: AppColors.divider),
        ),
        tileColor: AppColors.warmWhite,
        title: Row(
          children: [
            if (relation.kanji != null) ...[
              Text(relation.kanji!, style: AppTypography.contentBody),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(relation.hiragana, style: AppTypography.contentCaption),
          ],
        ),
        subtitle: definition != null
            ? Text(definition, style: AppTypography.bodySmall(locale))
            : null,
        trailing: AppTag(label: typeLabel, color: AppColors.sage),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => VocabularyDetailScreen(wordId: relation.id),
          ));
        },
      ),
    );
  }
}

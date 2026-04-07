import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/word_summary.dart';
import '../providers/locale_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/jlpt_level_tag.dart';
import 'vocabulary_detail_screen.dart';

class VocabularyListScreen extends StatefulWidget {
  const VocabularyListScreen({super.key});

  @override
  State<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VocabularyProvider>().loadWords(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = context.watch<LocaleProvider>().effectiveLocale;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabVocabulary)),
      body: Column(
        children: [
          _buildSearchBar(l10n, locale),
          _buildLevelFilter(l10n, locale),
          Expanded(child: _buildWordList(l10n, locale)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n, Locale locale) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0,
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          hintStyle: AppTypography.bodyMedium(locale),
          prefixIcon: Icon(Icons.search, color: AppColors.textHint),
          filled: true,
          fillColor: AppColors.warmWhite,
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          border: OutlineInputBorder(
            borderRadius: AppSpacing.radiusMd,
            borderSide: BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppSpacing.radiusMd,
            borderSide: BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppSpacing.radiusMd,
            borderSide: BorderSide(color: AppColors.terracotta),
          ),
        ),
        onSubmitted: (value) {
          final provider = context.read<VocabularyProvider>();
          provider.setFilters(
                keyword: value.isEmpty ? null : value,
                jlptLevel: provider.jlptLevel,
              );
        },
      ),
    );
  }

  Widget _buildLevelFilter(AppLocalizations l10n, Locale locale) {
    const levels = ['N5', 'N4', 'N3', 'N2', 'N1'];
    final selectedLevel = context.watch<VocabularyProvider>().jlptLevel;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: AppSpacing.sm,
      ),
      child: SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            JlptLevelChip(
              level: l10n.allLevels,
              selected: selectedLevel == null,
              onTap: () => _onLevelSelected(null),
            ),
            const SizedBox(width: AppSpacing.sm),
            ...levels.map((level) {
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: JlptLevelChip(
                  level: level,
                  selected: selectedLevel == level,
                  onTap: () => _onLevelSelected(level),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _onLevelSelected(String? level) {
    context.read<VocabularyProvider>().setFilters(
          jlptLevel: level,
          keyword: _searchController.text.isEmpty
              ? null
              : _searchController.text,
        );
  }

  Widget _buildWordList(AppLocalizations l10n, Locale locale) {
    return Consumer<VocabularyProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.words.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.words.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.errorLoadingWords,
                    style: AppTypography.bodyLarge(locale)),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => provider.loadWords(refresh: true),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          );
        }

        if (provider.words.isEmpty) {
          return Center(
            child: Text(l10n.noWordsFound,
                style: AppTypography.bodyLarge(locale)),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification &&
                notification.metrics.extentAfter < 200) {
              provider.loadWords();
            }
            return false;
          },
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: provider.words.length + (provider.hasMore ? 1 : 0),
            separatorBuilder: (_, _) => const Divider(height: 1,
                indent: AppSpacing.md, endIndent: AppSpacing.md),
            itemBuilder: (context, index) {
              if (index >= provider.words.length) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return _WordListTile(
                word: provider.words[index],
                locale: locale,
                onTap: () => _openDetail(provider.words[index].id),
              );
            },
          ),
        );
      },
    );
  }

  void _openDetail(int wordId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VocabularyDetailScreen(wordId: wordId),
      ),
    );
  }
}

class _WordListTile extends StatelessWidget {
  final WordSummary word;
  final Locale locale;
  final VoidCallback onTap;

  const _WordListTile({
    required this.word,
    required this.locale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isZh = locale.languageCode == 'zh';
    final definition = isZh ? word.definitionZh : word.definitionEn;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: AppSpacing.xs,
      ),
      onTap: onTap,
      title: Row(
        children: [
          if (word.kanji != null) ...[
            Text(word.kanji!, style: AppTypography.contentHeading),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Text(word.hiragana, style: AppTypography.contentCaption),
          ),
        ],
      ),
      subtitle: definition != null
          ? Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(definition, style: AppTypography.bodyMedium(locale),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            )
          : null,
      trailing: word.jlptLevel != null
          ? JlptLevelTag(level: word.jlptLevel!)
          : null,
    );
  }
}


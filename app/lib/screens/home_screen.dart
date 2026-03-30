import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../utils/date_utils.dart' show formatMonthDay;
import '../providers/dashboard_provider.dart';
import '../providers/jlpt_level_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/greeting_header.dart';
import '../widgets/quick_action_bar.dart';
import '../widgets/quiz_history_tile.dart';
import '../widgets/study_summary_card.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int index) onNavigateToTab;

  const HomeScreen({super.key, required this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _recentQuizzesLimit = 3;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dashboard = context.watch<DashboardProvider>();
    final auth = context.watch<AuthProvider>();
    final jlptLevel = context.watch<JlptLevelProvider>().level.label;

    final user = auth.user;
    final greeting = _greeting(l10n);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<DashboardProvider>().load(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GreetingHeader(
                  name: user?.name ?? '',
                  pictureUrl: user?.pictureUrl,
                  jlptLevel: jlptLevel,
                  greeting: greeting,
                ),
                const SizedBox(height: AppSpacing.lg),

                _buildSummary(l10n, dashboard),
                const SizedBox(height: AppSpacing.md),

                QuickActionBar(
                  startQuizLabel: l10n.startQuiz,
                  browseVocabularyLabel: l10n.browseVocabulary,
                  onStartQuiz: () => widget.onNavigateToTab(2),
                  onBrowseVocabulary: () => widget.onNavigateToTab(1),
                ),
                const SizedBox(height: AppSpacing.lg),

                _buildRecentQuizzes(l10n, dashboard),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(AppLocalizations l10n, DashboardProvider dashboard) {
    if (dashboard.isLoading && dashboard.summary == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final summary = dashboard.summary;
    return StudySummaryCard(
      totalQuizzes: summary?.totalQuizzes ?? 0,
      averageScore: summary?.averageScore ?? 0,
      currentStreak: summary?.currentStreak ?? 0,
      totalQuizzesLabel: l10n.totalQuizzes,
      averageScoreLabel: l10n.averageScore,
      currentStreakLabel: l10n.currentStreak,
    );
  }

  Widget _buildRecentQuizzes(AppLocalizations l10n, DashboardProvider dashboard) {
    if (dashboard.summary == null) return const SizedBox.shrink();

    final quizzes = dashboard.summary!.recentQuizzes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.recentScores,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '($_recentQuizzesLimit)',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (quizzes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(
              child: Text(
                l10n.noRecentQuizzes,
                style: const TextStyle(fontSize: 14, color: AppColors.textHint),
              ),
            ),
          )
        else
          ...quizzes.map((h) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: QuizHistoryTile(
                date: formatMonthDay(h.completedAt),
                jlptLevel: h.jlptLevel,
                score: h.score,
                total: h.total,
              ),
            )),
      ],
    );
  }

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.greetingMorning;
    if (hour < 18) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }
}

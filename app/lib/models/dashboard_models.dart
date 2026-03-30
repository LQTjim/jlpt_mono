import 'quiz_models.dart';

class DashboardSummary {
  final int totalQuizzes;
  final int averageScore;
  final int currentStreak;
  final List<QuizHistoryItem> recentQuizzes;

  DashboardSummary({
    required this.totalQuizzes,
    required this.averageScore,
    required this.currentStreak,
    required this.recentQuizzes,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalQuizzes: (json['totalQuizzes'] as num).toInt(),
      averageScore: (json['averageScore'] as num).toInt(),
      currentStreak: (json['currentStreak'] as num).toInt(),
      recentQuizzes: (json['recentQuizzes'] as List<dynamic>)
          .map((e) => QuizHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

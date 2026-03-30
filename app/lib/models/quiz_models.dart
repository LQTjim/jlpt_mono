class QuizStartResponse {
  final int sessionId;
  final List<QuizQuestionItem> questions;

  QuizStartResponse({required this.sessionId, required this.questions});

  factory QuizStartResponse.fromJson(Map<String, dynamic> json) {
    return QuizStartResponse(
      sessionId: (json['sessionId'] as num).toInt(),
      questions: (json['questions'] as List<dynamic>)
          .map((e) => QuizQuestionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuizQuestionItem {
  final int id;
  final String type;
  final QuizStem stem;
  final List<QuizOption> options;

  QuizQuestionItem({
    required this.id,
    required this.type,
    required this.stem,
    required this.options,
  });

  factory QuizQuestionItem.fromJson(Map<String, dynamic> json) {
    return QuizQuestionItem(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      stem: QuizStem.fromJson(json['stem'] as Map<String, dynamic>),
      options: (json['options'] as List<dynamic>)
          .map((e) => QuizOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuizStem {
  final String? kanji;
  final String? hiragana;
  final String? sentence;
  final String? translation;
  final String? definitionZh;
  final String? definitionEn;

  QuizStem({
    this.kanji,
    this.hiragana,
    this.sentence,
    this.translation,
    this.definitionZh,
    this.definitionEn,
  });

  factory QuizStem.fromJson(Map<String, dynamic> json) {
    return QuizStem(
      kanji: json['kanji'] as String?,
      hiragana: json['hiragana'] as String?,
      sentence: json['sentence'] as String?,
      translation: json['translation'] as String?,
      definitionZh: json['definitionZh'] as String?,
      definitionEn: json['definitionEn'] as String?,
    );
  }
}

class QuizOption {
  final String key;
  final String text;

  QuizOption({required this.key, required this.text});

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      key: json['key'] as String,
      text: json['text'] as String,
    );
  }
}

class QuizSubmitResponse {
  final int sessionId;
  final int score;
  final int total;
  final List<QuizResultItem> results;

  QuizSubmitResponse({
    required this.sessionId,
    required this.score,
    required this.total,
    required this.results,
  });

  factory QuizSubmitResponse.fromJson(Map<String, dynamic> json) {
    return QuizSubmitResponse(
      sessionId: (json['sessionId'] as num).toInt(),
      score: (json['score'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      results: (json['results'] as List<dynamic>)
          .map((e) => QuizResultItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuizResultItem {
  final int questionId;
  final bool correct;
  final String correctKey;
  final String? selectedKey;

  QuizResultItem({
    required this.questionId,
    required this.correct,
    required this.correctKey,
    this.selectedKey,
  });

  factory QuizResultItem.fromJson(Map<String, dynamic> json) {
    return QuizResultItem(
      questionId: (json['questionId'] as num).toInt(),
      correct: json['correct'] as bool,
      correctKey: json['correctKey'] as String,
      selectedKey: json['selectedKey'] as String?,
    );
  }
}

class QuizHistoryItem {
  final int sessionId;
  final String jlptLevel;
  final int score;
  final int total;
  final String completedAt;

  QuizHistoryItem({
    required this.sessionId,
    required this.jlptLevel,
    required this.score,
    required this.total,
    required this.completedAt,
  });

  factory QuizHistoryItem.fromJson(Map<String, dynamic> json) {
    return QuizHistoryItem(
      sessionId: (json['sessionId'] as num).toInt(),
      jlptLevel: json['jlptLevel'] as String,
      score: (json['score'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      completedAt: json['completedAt'] as String,
    );
  }
}

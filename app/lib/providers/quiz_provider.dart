import 'package:flutter/foundation.dart';

import '../models/quiz_models.dart';
import '../services/quiz_service.dart';

class QuizProvider extends ChangeNotifier {
  final QuizService service;

  QuizProvider(this.service);

  // --- Quiz session state ---
  int? _sessionId;
  List<QuizQuestionItem> _questions = [];
  int _currentIndex = 0;
  Map<int, String?> _answers = {}; // questionId → selectedKey (null = skipped)
  bool _isStarting = false;
  String? _startError;

  // --- Submit state ---
  QuizSubmitResponse? _submitResult;
  bool _isSubmitting = false;
  String? _submitError;

  // --- History state ---
  List<QuizHistoryItem> _history = [];
  bool _isLoadingHistory = false;
  String? _historyError;

  // --- Last quiz settings (for "retry") ---
  String? _lastJlptLevel;
  String? _lastQuestionType;
  String? _lastLocale;

  // Getters
  int? get sessionId => _sessionId;
  List<QuizQuestionItem> get questions => _questions;
  int get currentIndex => _currentIndex;
  Map<int, String?> get answers => _answers;
  bool get isStarting => _isStarting;
  String? get startError => _startError;

  QuizSubmitResponse? get submitResult => _submitResult;
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;

  List<QuizHistoryItem> get history => _history;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get historyError => _historyError;

  String? get lastJlptLevel => _lastJlptLevel;
  String? get lastQuestionType => _lastQuestionType;
  String? get lastLocale => _lastLocale;

  QuizQuestionItem? get currentQuestion =>
      _currentIndex < _questions.length ? _questions[_currentIndex] : null;

  bool get isLastQuestion => _currentIndex == _questions.length - 1;

  Future<void> startQuiz({
    required String jlptLevel,
    required String questionType,
    required String locale,
  }) async {
    _isStarting = true;
    _startError = null;
    notifyListeners();

    try {
      final response = await service.startQuiz(
        jlptLevel: jlptLevel,
        questionType: questionType,
        locale: locale,
      );

      _sessionId = response.sessionId;
      _questions = response.questions;
      _currentIndex = 0;
      _answers = {};
      _submitResult = null;
      _submitError = null;
      _lastJlptLevel = jlptLevel;
      _lastQuestionType = questionType;
      _lastLocale = locale;
    } catch (e) {
      _startError = e.toString();
    } finally {
      _isStarting = false;
      notifyListeners();
    }
  }

  void selectAnswer(int questionId, String key) {
    _answers[questionId] = key;
    notifyListeners();
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void skipQuestion() {
    final q = currentQuestion;
    if (q != null) {
      _answers[q.id] = null;
      notifyListeners();
    }
    if (!isLastQuestion) {
      nextQuestion();
    } else {
      submitQuiz();
    }
  }

  Future<void> submitQuiz() async {
    if (_sessionId == null || _isSubmitting) return;

    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      final answerList = _questions.map((q) {
        return {
          'questionId': q.id,
          'selectedKey': _answers[q.id],
        };
      }).toList();

      _submitResult = await service.submitQuiz(
        sessionId: _sessionId!,
        answers: answerList,
      );
    } catch (e) {
      _submitError = e.toString();
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory() async {
    _isLoadingHistory = true;
    _historyError = null;
    notifyListeners();

    try {
      final result = await service.getHistory();
      _history = result.content;
    } catch (e) {
      _historyError = e.toString();
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  void reset() {
    _sessionId = null;
    _questions = [];
    _currentIndex = 0;
    _answers = {};
    _submitResult = null;
    _submitError = null;
    _startError = null;
    notifyListeners();
  }
}

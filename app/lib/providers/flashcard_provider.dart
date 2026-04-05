import 'package:flutter/foundation.dart';

import '../models/word_summary.dart';
import '../services/vocabulary_service.dart';

class FlashcardProvider extends ChangeNotifier {
  final VocabularyService _service;

  FlashcardProvider(this._service);

  List<WordSummary> _words = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isLoading = false;
  String? _error;
  int _generation = 0;

  List<WordSummary> get words => _words;
  int get currentIndex => _currentIndex;
  bool get isFlipped => _isFlipped;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _words.isEmpty;
  bool get isFirst => _currentIndex == 0;
  bool get isLast => _currentIndex == _words.length - 1;

  /// Synchronously resets to a clean loading state without notifying listeners.
  /// Safe to call from [State.initState] before the first build.
  void prepareForNewSession() {
    _generation++;
    _isLoading = true;
    _error = null;
    _words = [];
    _currentIndex = 0;
    _isFlipped = false;
  }

  Future<void> loadSession(String jlptLevel) async {
    final gen = ++_generation;

    _isLoading = true;
    _error = null;
    _words = [];
    _currentIndex = 0;
    _isFlipped = false;
    notifyListeners();

    try {
      final words = await _service.getRandomFlashcards(jlptLevel: jlptLevel, count: 20);
      if (gen != _generation) return;
      _words = words;
    } catch (e) {
      if (gen != _generation) return;
      _error = e.toString();
    } finally {
      if (gen == _generation) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void flipCurrent() {
    _isFlipped = !_isFlipped;
    notifyListeners();
  }

  void setIndex(int index) {
    if (index == _currentIndex) return;
    _currentIndex = index.clamp(0, _words.isEmpty ? 0 : _words.length - 1);
    _isFlipped = false;
    notifyListeners();
  }

  void next() {
    if (!isLast) {
      _currentIndex++;
      _isFlipped = false;
      notifyListeners();
    }
  }

  void previous() {
    if (!isFirst) {
      _currentIndex--;
      _isFlipped = false;
      notifyListeners();
    }
  }

  void reset() {
    _words = [];
    _currentIndex = 0;
    _isFlipped = false;
    _error = null;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart' hide Category;

import '../models/category.dart';
import '../models/word_summary.dart';
import '../services/vocabulary_service.dart';

class VocabularyProvider extends ChangeNotifier {
  final VocabularyService service;

  VocabularyProvider(this.service);

  List<WordSummary> _words = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  int _generation = 0;
  String? _error;

  String? _jlptLevel;
  String? _partOfSpeech;
  int? _categoryId;
  String? _keyword;

  List<Category> _categories = [];

  List<WordSummary> get words => _words;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String? get jlptLevel => _jlptLevel;
  String? get partOfSpeech => _partOfSpeech;
  int? get categoryId => _categoryId;
  String? get keyword => _keyword;
  List<Category> get categories => _categories;

  Future<void> loadWords({bool refresh = false}) async {
    if (!refresh && _isLoading) return;
    if (!refresh && !_hasMore) return;

    if (refresh) {
      _generation++;
      _currentPage = 0;
      _hasMore = true;
    }

    final gen = _generation;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await service.searchWords(
        jlptLevel: _jlptLevel,
        partOfSpeech: _partOfSpeech,
        categoryId: _categoryId,
        keyword: _keyword,
        page: _currentPage,
      );

      if (gen != _generation) return;

      if (refresh) {
        _words = result.content;
      } else {
        _words = [..._words, ...result.content];
      }
      _hasMore = !result.last;
      _currentPage++;
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

  void setFilters({
    String? jlptLevel,
    String? partOfSpeech,
    int? categoryId,
    String? keyword,
  }) {
    _jlptLevel = jlptLevel;
    _partOfSpeech = partOfSpeech;
    _categoryId = categoryId;
    _keyword = keyword;
    loadWords(refresh: true);
  }

  void clearFilters() {
    _jlptLevel = null;
    _partOfSpeech = null;
    _categoryId = null;
    _keyword = null;
    loadWords(refresh: true);
  }

  Future<void> loadCategories() async {
    if (_categories.isNotEmpty) return;
    try {
      _categories = await service.getCategories();
      notifyListeners();
    } catch (_) {
      // Categories are optional; fail silently
    }
  }
}

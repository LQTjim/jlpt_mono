import 'dart:convert';

import '../models/category.dart';
import '../models/page_response.dart';
import '../models/word_detail.dart';
import '../models/word_summary.dart';
import 'api_client.dart';

class VocabularyService {
  final ApiClient _apiClient;

  VocabularyService(this._apiClient);

  Future<PageResponse<WordSummary>> searchWords({
    String? jlptLevel,
    String? partOfSpeech,
    int? categoryId,
    String? keyword,
    int page = 0,
    int size = 20,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'size': '$size',
    };
    if (jlptLevel != null) params['jlptLevel'] = jlptLevel;
    if (partOfSpeech != null) params['partOfSpeech'] = partOfSpeech;
    if (categoryId != null) params['categoryId'] = '$categoryId';
    if (keyword != null && keyword.isNotEmpty) params['keyword'] = keyword;

    final query = Uri(queryParameters: params).query;
    final response = await _apiClient.get('/api/vocabulary?$query');

    if (response.statusCode != 200) {
      throw Exception('Failed to load words: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PageResponse.fromJson(json, WordSummary.fromJson);
  }

  Future<WordDetail> getWordDetail(int id) async {
    final response = await _apiClient.get('/api/vocabulary/$id');

    if (response.statusCode != 200) {
      throw Exception('Failed to load word detail: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return WordDetail.fromJson(json);
  }

  Future<List<Category>> getCategories() async {
    final response = await _apiClient.get('/api/vocabulary/categories');

    if (response.statusCode != 200) {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as List<dynamic>;
    return json
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

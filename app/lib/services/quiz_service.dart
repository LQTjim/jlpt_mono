import 'dart:convert';

import '../models/page_response.dart';
import '../models/quiz_models.dart';
import 'api_client.dart';

class QuizService {
  final ApiClient _apiClient;

  QuizService(this._apiClient);

  Future<QuizStartResponse> startQuiz({
    required String jlptLevel,
    required String questionType,
    required String locale,
  }) async {
    final response = await _apiClient.post('/api/quiz/start', body: {
      'jlptLevel': jlptLevel,
      'questionType': questionType,
      'locale': locale,
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to start quiz: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return QuizStartResponse.fromJson(json);
  }

  Future<QuizSubmitResponse> submitQuiz({
    required int sessionId,
    required List<Map<String, dynamic>> answers,
  }) async {
    final response = await _apiClient.post(
      '/api/quiz/$sessionId/submit',
      body: {'answers': answers},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit quiz: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return QuizSubmitResponse.fromJson(json);
  }

  Future<PageResponse<QuizHistoryItem>> getHistory({
    int page = 0,
    int size = 5,
  }) async {
    final response =
        await _apiClient.get('/api/quiz/history?page=$page&size=$size');

    if (response.statusCode != 200) {
      throw Exception('Failed to load quiz history: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PageResponse.fromJson(json, QuizHistoryItem.fromJson);
  }
}

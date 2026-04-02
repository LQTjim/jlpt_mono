import 'dart:convert';

import '../models/audio_response.dart';
import 'api_client.dart';

class AudioService {
  final ApiClient? _apiClient;

  AudioService(ApiClient apiClient) : _apiClient = apiClient;

  /// No-op constructor for Widgetbook stories and tests — throws if called.
  AudioService.stub() : _apiClient = null;

  Future<AudioResponse> requestAudio(int vocabularyId) async {
    final response =
        await _apiClient!.post('/api/audio/generate/$vocabularyId');
    if (response.statusCode != 200 && response.statusCode != 202) {
      throw Exception('Failed to request audio: ${response.statusCode}');
    }
    return AudioResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<AudioResponse> getStatus(int jobId) async {
    final response = await _apiClient!.get('/api/audio/status/$jobId');
    if (response.statusCode != 200) {
      throw Exception('Failed to get audio status: ${response.statusCode}');
    }
    return AudioResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }
}

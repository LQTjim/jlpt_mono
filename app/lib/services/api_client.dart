import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'auth_service.dart';

class ApiClient {
  final AuthService _authService;
  final http.Client _httpClient;
  final Future<void> Function() onAuthFailure;

  ApiClient(
    this._authService, {
    required this.onAuthFailure,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _withAuthRetry(
    Future<http.Response> Function() request,
  ) async {
    var response = await request();

    if (response.statusCode == 401) {
      final refreshed = await _authService.refreshAccessToken();
      if (refreshed) {
        response = await request();
      } else {
        await onAuthFailure();
      }
    }

    return response;
  }

  Future<http.Response> get(String path) {
    return _withAuthRetry(
      () async => _httpClient.get(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: await _headers(),
      ),
    );
  }

  Future<http.Response> post(String path, {Object? body}) {
    return _withAuthRetry(
      () async => _httpClient.post(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }
}

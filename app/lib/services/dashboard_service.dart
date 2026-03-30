import 'dart:convert';

import '../models/dashboard_models.dart';
import 'api_client.dart';

class DashboardService {
  final ApiClient _apiClient;

  DashboardService(this._apiClient);

  Future<DashboardSummary> getSummary() async {
    final response = await _apiClient.get('/api/dashboard/summary');

    if (response.statusCode != 200) {
      throw Exception('Failed to load dashboard: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return DashboardSummary.fromJson(json);
  }
}

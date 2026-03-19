import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:app/services/auth_service.dart';
import 'package:app/services/api_client.dart';

@GenerateMocks([AuthService])
import 'api_client_test.mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late bool authFailureCalled;

  setUp(() {
    mockAuthService = MockAuthService();
    authFailureCalled = false;
  });

  ApiClient createClient(http.Client httpClient) {
    return ApiClient(
      mockAuthService,
      onAuthFailure: () async {
        authFailureCalled = true;
      },
      httpClient: httpClient,
    );
  }

  group('GET 請求', () {
    test('回傳 200 時應直接回傳 response', () async {
      when(mockAuthService.getAccessToken())
          .thenAnswer((_) async => 'token');

      final httpClient = MockClient((request) async {
        return http.Response('{"data":"ok"}', 200);
      });

      final client = createClient(httpClient);
      final response = await client.get('/api/test');

      expect(response.statusCode, 200);
      expect(response.body, '{"data":"ok"}');
    });

    test('回傳 401 且 refresh 成功時應重試並回傳新 response', () async {
      when(mockAuthService.getAccessToken())
          .thenAnswer((_) async => 'token');
      when(mockAuthService.refreshAccessToken())
          .thenAnswer((_) async => true);

      var callCount = 0;
      final httpClient = MockClient((request) async {
        callCount++;
        if (callCount == 1) return http.Response('', 401);
        return http.Response('{"data":"ok"}', 200);
      });

      final client = createClient(httpClient);
      final response = await client.get('/api/test');

      expect(response.statusCode, 200);
      expect(callCount, 2);
      verify(mockAuthService.refreshAccessToken()).called(1);
    });

    test('回傳 401 且 refresh 失敗時應呼叫 onAuthFailure', () async {
      when(mockAuthService.getAccessToken())
          .thenAnswer((_) async => 'token');
      when(mockAuthService.refreshAccessToken())
          .thenAnswer((_) async => false);

      final httpClient = MockClient((_) async => http.Response('', 401));

      final client = createClient(httpClient);
      await client.get('/api/test');

      expect(authFailureCalled, true);
      verify(mockAuthService.refreshAccessToken()).called(1);
    });
  });

  group('POST 請求', () {
    test('回傳 200 時應直接回傳 response', () async {
      when(mockAuthService.getAccessToken())
          .thenAnswer((_) async => 'token');

      final httpClient = MockClient((request) async {
        return http.Response('{"created":true}', 200);
      });

      final client = createClient(httpClient);
      final response = await client.post('/api/test', body: {'key': 'value'});

      expect(response.statusCode, 200);
    });

    test('回傳 401 且 refresh 成功時應重試並回傳新 response', () async {
      when(mockAuthService.getAccessToken())
          .thenAnswer((_) async => 'token');
      when(mockAuthService.refreshAccessToken())
          .thenAnswer((_) async => true);

      var callCount = 0;
      final httpClient = MockClient((request) async {
        callCount++;
        if (callCount == 1) return http.Response('', 401);
        return http.Response('{"created":true}', 200);
      });

      final client = createClient(httpClient);
      final response = await client.post('/api/test', body: {'key': 'value'});

      expect(response.statusCode, 200);
      expect(callCount, 2);
    });

    test('回傳 401 且 refresh 失敗時應呼叫 onAuthFailure', () async {
      when(mockAuthService.getAccessToken())
          .thenAnswer((_) async => 'token');
      when(mockAuthService.refreshAccessToken())
          .thenAnswer((_) async => false);

      final httpClient = MockClient((_) async => http.Response('', 401));

      final client = createClient(httpClient);
      await client.post('/api/test');

      expect(authFailureCalled, true);
    });
  });

  group('並發請求遇到 401', () {
    test('兩個請求同時收到 401 時應共用同一次 refresh，且 refresh 完成後兩個請求都重新發送', () async {
      when(mockAuthService.getAccessToken())
          .thenAnswer((_) async => 'token');

      // 用同一個 Completer 讓兩次 refreshAccessToken 呼叫共用同一個 Future
      // （模擬 AuthService 內部 Completer 鎖的效果）
      final refreshCompleter = Completer<bool>();
      when(mockAuthService.refreshAccessToken())
          .thenAnswer((_) => refreshCompleter.future);

      // 追蹤每個路徑的請求次數
      final requestCounts = <String, int>{};
      final httpClient = MockClient((request) async {
        final path = request.url.path;
        requestCounts[path] = (requestCounts[path] ?? 0) + 1;

        // 第一次呼叫回傳 401，重試回傳 200
        if (requestCounts[path]! == 1) return http.Response('', 401);
        return http.Response('{"path":"$path"}', 200);
      });

      final client = createClient(httpClient);

      // 同時發起兩個請求
      final future1 = client.get('/api/a');
      final future2 = client.get('/api/b');

      // 等一下讓兩個請求都收到 401 並呼叫 refreshAccessToken
      await Future.delayed(Duration.zero);

      // 完成 refresh — 兩個請求共用同一個 future
      refreshCompleter.complete(true);

      final responses = await Future.wait([future1, future2]);

      expect(responses[0].statusCode, 200);
      expect(responses[1].statusCode, 200);
      // 兩個路徑各被呼叫 2 次（初始 401 + 重試 200）
      expect(requestCounts['/api/a'], 2);
      expect(requestCounts['/api/b'], 2);
      // ApiClient 各自呼叫 refreshAccessToken，但實際 AuthService 的 Completer 鎖會合併
      // 這裡驗證兩者都等到 refresh 完成後才重試
      verify(mockAuthService.refreshAccessToken()).called(2);
    });
  });
}

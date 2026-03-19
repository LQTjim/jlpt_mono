import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:app/services/auth_service.dart';
import 'package:app/services/api_client.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/models/user.dart';

@GenerateMocks([AuthService])
import 'auth_provider_test.mocks.dart';

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  group('Google 登入', () {
    test('成功時 isAuthenticated 應為 true 且 isLoading 狀態變化正確', () async {
      final user = User(email: 'test@example.com', name: 'Test User');
      when(mockAuthService.signInWithGoogle()).thenAnswer((_) async => user);

      final provider = AuthProvider(authService: mockAuthService);

      // 追蹤 isLoading 變化
      final loadingStates = <bool>[];
      provider.addListener(() {
        loadingStates.add(provider.isLoading);
      });

      await provider.signInWithGoogle();

      expect(provider.isAuthenticated, true);
      expect(provider.user?.email, 'test@example.com');
      expect(provider.error, isNull);
      // isLoading: true → false
      expect(loadingStates, [true, false]);
    });

    test('失敗時 error 應有錯誤訊息', () async {
      when(mockAuthService.signInWithGoogle())
          .thenThrow(Exception('Sign-in failed'));

      final provider = AuthProvider(authService: mockAuthService);
      await provider.signInWithGoogle();

      expect(provider.isAuthenticated, false);
      expect(provider.error, contains('Sign-in failed'));
      expect(provider.isLoading, false);
    });
  });

  group('自動登入', () {
    test('有 token 且 /me 成功時 isAuthenticated 應為 true', () async {
      when(mockAuthService.isLoggedIn()).thenAnswer((_) async => true);
      when(mockAuthService.getAccessToken())
          .thenAnswer((_) async => 'token');

      final httpClient = MockClient((request) async {
        if (request.url.path == '/api/auth/me') {
          return http.Response(
            jsonEncode({
              'email': 'test@example.com',
              'name': 'Test User',
            }),
            200,
          );
        }
        return http.Response('', 404);
      });

      final apiClient = ApiClient(
        mockAuthService,
        onAuthFailure: () async {},
        httpClient: httpClient,
      );

      final provider = AuthProvider(
        authService: mockAuthService,
        apiClient: apiClient,
      );

      await provider.tryAutoLogin();

      expect(provider.isAuthenticated, true);
      expect(provider.user?.email, 'test@example.com');
      expect(provider.isLoading, false);
    });

    test('無 token 時 isAuthenticated 應為 false', () async {
      when(mockAuthService.isLoggedIn()).thenAnswer((_) async => false);

      final provider = AuthProvider(authService: mockAuthService);
      await provider.tryAutoLogin();

      expect(provider.isAuthenticated, false);
      expect(provider.isLoading, false);
    });

    test('網路錯誤時應保留 tokens 不強制登出', () async {
      when(mockAuthService.isLoggedIn()).thenAnswer((_) async => true);
      when(mockAuthService.getAccessToken())
          .thenAnswer((_) async => 'token');

      final httpClient = MockClient((request) async {
        throw Exception('Network error');
      });

      final apiClient = ApiClient(
        mockAuthService,
        onAuthFailure: () async {},
        httpClient: httpClient,
      );

      final provider = AuthProvider(
        authService: mockAuthService,
        apiClient: apiClient,
      );

      await provider.tryAutoLogin();

      // 網路錯誤不應觸發登出
      expect(provider.isAuthenticated, false);
      expect(provider.isLoading, false);
      verifyNever(mockAuthService.signOut());
    });
  });

  group('登出', () {
    test('應清除 user 並通知 listeners', () async {
      // 先登入
      final user = User(email: 'test@example.com', name: 'Test User');
      when(mockAuthService.signInWithGoogle()).thenAnswer((_) async => user);
      when(mockAuthService.signOut()).thenAnswer((_) async {});

      final provider = AuthProvider(authService: mockAuthService);
      await provider.signInWithGoogle();
      expect(provider.isAuthenticated, true);

      // 追蹤 listener
      var notified = false;
      provider.addListener(() => notified = true);

      await provider.signOut();

      expect(provider.isAuthenticated, false);
      expect(provider.user, isNull);
      expect(notified, true);
      verify(mockAuthService.signOut()).called(1);
    });
  });
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:app/services/auth_service.dart';

@GenerateMocks([FlutterSecureStorage, GoogleSignIn, GoogleSignInAccount, GoogleSignInAuthentication])
import 'auth_service_test.mocks.dart';

void main() {
  late MockFlutterSecureStorage mockStorage;
  late MockGoogleSignIn mockGoogleSignIn;
  late AuthService authService;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    mockGoogleSignIn = MockGoogleSignIn();
  });

  AuthService createServiceWithClient(http.Client client) {
    return AuthService(
      storage: mockStorage,
      googleSignIn: mockGoogleSignIn,
      httpClient: client,
    );
  }

  group('Google 登入', () {
    test('成功時應儲存 tokens 並回傳 User', () async {
      final mockAccount = MockGoogleSignInAccount();
      final mockAuth = MockGoogleSignInAuthentication();

      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
      when(mockAccount.authentication).thenAnswer((_) async => mockAuth);
      when(mockAuth.idToken).thenReturn('google-id-token');
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async {});

      final client = MockClient((request) async {
        if (request.url.path == '/api/auth/google') {
          return http.Response(
            jsonEncode({
              'accessToken': 'access-token',
              'refreshToken': 'refresh-token',
              'email': 'test@example.com',
              'name': 'Test User',
              'pictureUrl': 'https://example.com/pic.jpg',
            }),
            200,
          );
        }
        return http.Response('Not found', 404);
      });

      authService = createServiceWithClient(client);
      final user = await authService.signInWithGoogle();

      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      verify(mockStorage.write(key: 'access_token', value: 'access-token'));
      verify(mockStorage.write(key: 'refresh_token', value: 'refresh-token'));
    });

    test('使用者取消時應拋出 Exception', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      final client = MockClient((_) async => http.Response('', 200));
      authService = createServiceWithClient(client);

      expect(() => authService.signInWithGoogle(), throwsException);
    });
  });

  group('刷新 access token', () {
    test('成功時應儲存新的 tokens 並回傳 true', () async {
      when(mockStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'old-refresh');
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async {});

      final client = MockClient((request) async {
        if (request.url.path == '/api/auth/refresh') {
          return http.Response(
            jsonEncode({
              'accessToken': 'new-access',
              'refreshToken': 'new-refresh',
            }),
            200,
          );
        }
        return http.Response('', 404);
      });

      authService = createServiceWithClient(client);
      final result = await authService.refreshAccessToken();

      expect(result, true);
      verify(mockStorage.write(key: 'access_token', value: 'new-access'));
      verify(mockStorage.write(key: 'refresh_token', value: 'new-refresh'));
    });

    test('失敗時應回傳 false', () async {
      when(mockStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'old-refresh');

      final client = MockClient((_) async => http.Response('', 401));

      authService = createServiceWithClient(client);
      final result = await authService.refreshAccessToken();

      expect(result, false);
    });

    test('並發呼叫時應只發送一次 HTTP request', () async {
      when(mockStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'refresh-token');
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async {});

      var requestCount = 0;
      final completer = Completer<http.Response>();

      final client = MockClient((request) async {
        if (request.url.path == '/api/auth/refresh') {
          requestCount++;
          return completer.future;
        }
        return http.Response('', 404);
      });

      authService = createServiceWithClient(client);

      // 同時發起兩次 refresh
      final future1 = authService.refreshAccessToken();
      final future2 = authService.refreshAccessToken();

      // 完成 HTTP 請求
      completer.complete(http.Response(
        jsonEncode({
          'accessToken': 'new-access',
          'refreshToken': 'new-refresh',
        }),
        200,
      ));

      final results = await Future.wait([future1, future2]);

      expect(results, [true, true]);
      expect(requestCount, 1); // 只發了一次 HTTP request
    });
  });

  group('登出', () {
    test('應呼叫 backend logout 並清除本地 tokens', () async {
      when(mockStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'refresh-token');
      when(mockStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async {});
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

      var logoutCalled = false;
      final client = MockClient((request) async {
        if (request.url.path == '/api/auth/logout') {
          logoutCalled = true;
          return http.Response('', 200);
        }
        return http.Response('', 404);
      });

      authService = createServiceWithClient(client);
      await authService.signOut();

      expect(logoutCalled, true);
      verify(mockStorage.delete(key: 'access_token'));
      verify(mockStorage.delete(key: 'refresh_token'));
      verify(mockGoogleSignIn.signOut());
    });

    test('backend 呼叫失敗時仍應清除本地 tokens', () async {
      when(mockStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'refresh-token');
      when(mockStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async {});
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

      final client = MockClient((request) async {
        throw Exception('Network error');
      });

      authService = createServiceWithClient(client);
      await authService.signOut();

      // 即使 backend 失敗，本地 tokens 仍應被清除
      verify(mockStorage.delete(key: 'access_token'));
      verify(mockStorage.delete(key: 'refresh_token'));
      verify(mockGoogleSignIn.signOut());
    });
  });
}

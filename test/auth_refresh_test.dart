import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavify/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:wavify/features/auth/data/interceptors/auth_interceptor.dart';
import 'package:wavify/features/auth/data/models/user_model.dart';

class InMemoryAuthLocalDataSource implements AuthLocalDataSource {
  String? _accessToken;
  String? _refreshToken;
  UserModel? _user;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<void> saveAccessToken(String accessToken) async {
    _accessToken = accessToken;
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    _refreshToken = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _user = null;
  }

  @override
  Future<void> clearUser() async {
    _user = null;
  }

  @override
  Future<void> saveUser(UserModel user) async {
    _user = user;
  }

  @override
  Future<UserModel?> getUser() async => _user;
}

class MockHttpAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;

  MockHttpAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

String _buildMockJwt({required int expSeconds}) {
  final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'HS512', 'typ': 'JWT'})));
  final payload = base64Url.encode(utf8.encode(jsonEncode({
    'sub': 'user@wavify.com',
    'exp': expSeconds,
  })));
  return '$header.$payload.signature';
}

ResponseBody _jsonResponse(Map<String, dynamic> body, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  group('AuthInterceptor Automatic Token Refresh & Rotation Tests', () {
    late InMemoryAuthLocalDataSource localDataSource;
    late Dio mainDio;
    late Dio refreshDio;
    bool sessionExpiredCalled = false;

    setUp(() {
      localDataSource = InMemoryAuthLocalDataSource();
      mainDio = Dio();
      refreshDio = Dio();
      sessionExpiredCalled = false;
    });

    test('isJwtExpired detects expired and valid JWT tokens accurately', () {
      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final expiredJwt = _buildMockJwt(expSeconds: nowSec - 60);
      final expiringSoonJwt = _buildMockJwt(expSeconds: nowSec + 10);
      final validJwt = _buildMockJwt(expSeconds: nowSec + 900);

      expect(AuthInterceptor.isJwtExpired(expiredJwt), isTrue);
      expect(AuthInterceptor.isJwtExpired(expiringSoonJwt), isTrue);
      expect(AuthInterceptor.isJwtExpired(validJwt), isFalse);
    });

    test(
      'Proactive refresh in onRequest: refreshes expired accessToken BEFORE sending request and omits Authorization header on /refresh',
      () async {
        final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final expiredAccessToken = _buildMockJwt(expSeconds: nowSec - 120);
        final freshAccessToken = _buildMockJwt(expSeconds: nowSec + 900);

        await localDataSource.saveTokens(
          accessToken: expiredAccessToken,
          refreshToken: 'uuid-refresh-token-1',
        );

        String? refreshAuthHeaderReceived;
        int refreshCalls = 0;

        refreshDio.httpClientAdapter = MockHttpAdapter((options) async {
          refreshCalls++;
          refreshAuthHeaderReceived = options.headers['Authorization']?.toString();
          return _jsonResponse({
            'code': 200,
            'result': {
              'accessToken': freshAccessToken,
              'refreshToken': 'uuid-refresh-token-2',
            },
          }, 200);
        });

        String? protectedEndpointAuthHeader;
        mainDio.httpClientAdapter = MockHttpAdapter((options) async {
          protectedEndpointAuthHeader = options.headers['Authorization']?.toString();
          return _jsonResponse({'code': 200, 'result': 'ok'}, 200);
        });

        mainDio.interceptors.add(
          AuthInterceptor(
            localDataSource: localDataSource,
            refreshDio: refreshDio,
            refreshEndpoint: 'http://localhost:8080/api/v1/auth/refresh',
            onTokenExpired: () => sessionExpiredCalled = true,
          ),
        );

        final response = await mainDio.get('http://localhost:8080/api/v1/users/current-user');

        expect(response.statusCode, 200);
        expect(refreshCalls, 1);
        // Crucial: /auth/refresh must NOT receive an Authorization header with the UUID refreshToken
        expect(refreshAuthHeaderReceived, isNull);
        // Protected endpoint receives the new rotated accessToken on its very first attempt
        expect(protectedEndpointAuthHeader, 'Bearer $freshAccessToken');
        expect(await localDataSource.getAccessToken(), freshAccessToken);
        expect(await localDataSource.getRefreshToken(), 'uuid-refresh-token-2');
        expect(sessionExpiredCalled, isFalse);
      },
    );

    test(
      'Reactive refresh in onError: intercepts 401, rotates tokens, and retries request seamlessly',
      () async {
        final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final validLookingAccessToken = _buildMockJwt(expSeconds: nowSec + 600);
        final rotatedAccessToken = _buildMockJwt(expSeconds: nowSec + 900);

        await localDataSource.saveTokens(
          accessToken: validLookingAccessToken,
          refreshToken: 'uuid-refresh-token-initial',
        );

        int mainCallCount = 0;
        mainDio.httpClientAdapter = MockHttpAdapter((options) async {
          mainCallCount++;
          return _jsonResponse({'code': 401, 'message': 'Unauthenticated'}, 401);
        });

        int refreshDioCallCount = 0;
        refreshDio.httpClientAdapter = MockHttpAdapter((options) async {
          refreshDioCallCount++;
          if (options.path.contains('/auth/refresh')) {
            // Verify no Authorization header is sent to /auth/refresh
            expect(options.headers['Authorization'], isNull);
            return _jsonResponse({
              'code': 200,
              'result': {
                'accessToken': rotatedAccessToken,
                'refreshToken': 'uuid-refresh-token-rotated',
              },
            }, 200);
          }
          // Retried request via refreshDio.fetch
          expect(options.headers['Authorization'], 'Bearer $rotatedAccessToken');
          return _jsonResponse({'code': 200, 'result': {'id': 'u1', 'username': 'WavifyUser'}}, 200);
        });

        mainDio.interceptors.add(
          AuthInterceptor(
            localDataSource: localDataSource,
            refreshDio: refreshDio,
            refreshEndpoint: 'http://localhost:8080/api/v1/auth/refresh',
            onTokenExpired: () => sessionExpiredCalled = true,
          ),
        );

        final response = await mainDio.get('http://localhost:8080/api/v1/users/current-user');

        expect(response.statusCode, 200);
        expect(mainCallCount, 1);
        expect(refreshDioCallCount, 2); // 1 for /refresh, 1 for retry
        expect(await localDataSource.getAccessToken(), rotatedAccessToken);
        expect(await localDataSource.getRefreshToken(), 'uuid-refresh-token-rotated');
        expect(sessionExpiredCalled, isFalse);
      },
    );

    test(
      'Retried request failing with 400/413 does NOT clear tokens or log user out',
      () async {
        final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final initialToken = _buildMockJwt(expSeconds: nowSec + 600);
        final rotatedToken = _buildMockJwt(expSeconds: nowSec + 900);

        await localDataSource.saveTokens(
          accessToken: initialToken,
          refreshToken: 'uuid-refresh-valid',
        );

        mainDio.httpClientAdapter = MockHttpAdapter((options) async {
          return _jsonResponse({'code': 401, 'message': 'Expired'}, 401);
        });

        refreshDio.httpClientAdapter = MockHttpAdapter((options) async {
          if (options.path.contains('/auth/refresh')) {
            return _jsonResponse({
              'code': 200,
              'result': {
                'accessToken': rotatedToken,
                'refreshToken': 'uuid-refresh-new',
              },
            }, 200);
          }
          // Retried request returns 413 Payload Too Large
          return _jsonResponse({'code': 413, 'message': 'File too large'}, 413);
        });

        mainDio.interceptors.add(
          AuthInterceptor(
            localDataSource: localDataSource,
            refreshDio: refreshDio,
            refreshEndpoint: 'http://localhost:8080/api/v1/auth/refresh',
            onTokenExpired: () => sessionExpiredCalled = true,
          ),
        );

        await expectLater(
          mainDio.post('http://localhost:8080/api/v1/songs'),
          throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 413)),
        );

        // User must STILL be logged in with the newly rotated tokens!
        expect(sessionExpiredCalled, isFalse);
        expect(await localDataSource.getAccessToken(), rotatedToken);
        expect(await localDataSource.getRefreshToken(), 'uuid-refresh-new');
      },
    );

    test(
      'When refreshToken itself is expired/revoked (401 from /auth/refresh), clears tokens and triggers onTokenExpired',
      () async {
        final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final expiredToken = _buildMockJwt(expSeconds: nowSec - 100);

        await localDataSource.saveTokens(
          accessToken: expiredToken,
          refreshToken: 'uuid-refresh-revoked',
        );

        refreshDio.httpClientAdapter = MockHttpAdapter((options) async {
          return _jsonResponse({'code': 401, 'message': 'Unauthenticated'}, 401);
        });

        mainDio.httpClientAdapter = MockHttpAdapter((options) async {
          return _jsonResponse({'code': 401, 'message': 'Unauthenticated'}, 401);
        });

        mainDio.interceptors.add(
          AuthInterceptor(
            localDataSource: localDataSource,
            refreshDio: refreshDio,
            refreshEndpoint: 'http://localhost:8080/api/v1/auth/refresh',
            onTokenExpired: () => sessionExpiredCalled = true,
          ),
        );

        await expectLater(
          mainDio.get('http://localhost:8080/api/v1/users/current-user'),
          throwsA(isA<DioException>()),
        );

        expect(sessionExpiredCalled, isTrue);
        expect(await localDataSource.getAccessToken(), isNull);
        expect(await localDataSource.getRefreshToken(), isNull);
      },
    );
  });
}

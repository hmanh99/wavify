import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../datasources/auth_local_data_source.dart';
import '../models/auth_tokens_model.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource localDataSource;
  final Dio refreshDio;
  final String refreshEndpoint;
  final void Function()? onTokenExpired;

  Completer<String?>? _refreshCompleter;

  AuthInterceptor({
    required this.localDataSource,
    required this.refreshDio,
    this.refreshEndpoint = '/api/v1/auth/refresh',
    this.onTokenExpired,
  });

  /// Checks whether a JWT token is expired (or will expire within [bufferSeconds]).
  /// Returns `false` for non-JWT opaque tokens so tests/mocks are unaffected.
  static bool isJwtExpired(String token, {int bufferSeconds = 30}) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final normalized = base64Url.normalize(parts[1]);
      final payloadJson = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(payloadJson);
      if (payloadMap is! Map<String, dynamic>) return false;

      final exp = payloadMap['exp'];
      if (exp is num) {
        final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        return (nowSeconds + bufferSeconds) >= exp.toInt();
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  bool _isPublicAuthPath(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/logout') ||
        path.endsWith('/login') ||
        path.endsWith('/register') ||
        path.endsWith('/refresh');
  }

  /// Performs single-flight Refresh Token Rotation.
  /// Returns the new accessToken if successful, or `null` if refresh failed.
  Future<String?> _refreshAccessToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    try {
      final currentRefreshToken = await localDataSource.getRefreshToken();
      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        await localDataSource.clearTokens();
        onTokenExpired?.call();
        completer.complete(null);
        return null;
      }

      Response<dynamic>? refreshResponse;
      DioException? lastError;

      try {
        // IMPORTANT: Do NOT send 'Authorization: Bearer <refreshToken>' header
        // because refreshToken is a UUID, not a JWT, and Spring Security's
        // BearerTokenAuthenticationFilter would reject a non-JWT Bearer header with 401.
        refreshResponse = await refreshDio.post(
          refreshEndpoint,
          data: {
            'refreshToken': currentRefreshToken,
          },
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
      } on DioException catch (e) {
        lastError = e;
      }

      if (refreshResponse != null &&
          (refreshResponse.statusCode == 200 || refreshResponse.statusCode == 201)) {
        final data = refreshResponse.data is Map<String, dynamic>
            ? refreshResponse.data as Map<String, dynamic>
            : <String, dynamic>{};

        final newTokens = AuthTokensModel.fromJson(data);

        if (newTokens.accessToken.isNotEmpty) {
          await localDataSource.saveTokens(
            accessToken: newTokens.accessToken,
            refreshToken: newTokens.refreshToken.isNotEmpty
                ? newTokens.refreshToken
                : currentRefreshToken,
          );

          if (newTokens.user != null) {
            await localDataSource.saveUser(newTokens.user!);
          }

          completer.complete(newTokens.accessToken);
          return newTokens.accessToken;
        }
      }

      // Check if server explicitly rejected the refresh token (expired or revoked)
      final statusCode = lastError?.response?.statusCode ?? refreshResponse?.statusCode;
      if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
        await localDataSource.clearTokens();
        onTokenExpired?.call();
      }

      completer.complete(null);
      return null;
    } catch (_) {
      completer.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublicAuthPath(options.path)) {
      String? token = await localDataSource.getAccessToken();

      // Proactive token refresh BEFORE sending request (prevents 401 and protects FormData streams)
      if (token == null || token.isEmpty || isJwtExpired(token)) {
        final refreshToken = await localDataSource.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final refreshedToken = await _refreshAccessToken();
          if (refreshedToken != null && refreshedToken.isNotEmpty) {
            token = refreshedToken;
          }
        }
      }

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final requestOptions = err.requestOptions;

    // Do not intercept non-401 errors, public auth endpoints, or already-retried requests
    if (response?.statusCode != 401 ||
        _isPublicAuthPath(requestOptions.path) ||
        requestOptions.extra['__retried_after_refresh__'] == true) {
      return handler.next(err);
    }

    // Check if another concurrent request already refreshed the access token
    final failedAuthHeader = requestOptions.headers['Authorization']?.toString() ?? '';
    final latestAccessToken = await localDataSource.getAccessToken();

    String? newAccessToken;
    if (latestAccessToken != null &&
        latestAccessToken.isNotEmpty &&
        !isJwtExpired(latestAccessToken, bufferSeconds: 5) &&
        failedAuthHeader.isNotEmpty &&
        failedAuthHeader != 'Bearer $latestAccessToken') {
      newAccessToken = latestAccessToken;
    } else {
      newAccessToken = await _refreshAccessToken();
    }

    if (newAccessToken == null || newAccessToken.isEmpty) {
      return handler.next(err);
    }

    // Retry the original request with the new accessToken (outside refresh try/catch)
    try {
      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      requestOptions.extra['__retried_after_refresh__'] = true;

      final clonedResponse = await refreshDio.fetch(requestOptions);
      return handler.resolve(clonedResponse);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    } catch (_) {
      return handler.next(err);
    }
  }
}

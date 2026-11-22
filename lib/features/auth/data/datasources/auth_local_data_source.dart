import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveAccessToken(String accessToken);
  Future<void> saveRefreshToken(String refreshToken);
  Future<void> clearTokens();

  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyUser = 'auth_current_user';

  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
      : secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await secureStorage.write(key: _keyAccessToken, value: accessToken);
    await secureStorage.write(key: _keyRefreshToken, value: refreshToken);
  }

  @override
  Future<String?> getAccessToken() async {
    return secureStorage.read(key: _keyAccessToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return secureStorage.read(key: _keyRefreshToken);
  }

  @override
  Future<void> saveAccessToken(String accessToken) async {
    await secureStorage.write(key: _keyAccessToken, value: accessToken);
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    await secureStorage.write(key: _keyRefreshToken, value: refreshToken);
  }

  @override
  Future<void> clearTokens() async {
    await secureStorage.delete(key: _keyAccessToken);
    await secureStorage.delete(key: _keyRefreshToken);
    await secureStorage.delete(key: _keyUser);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await secureStorage.write(key: _keyUser, value: jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getUser() async {
    final raw = await secureStorage.read(key: _keyUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await secureStorage.delete(key: _keyUser);
  }
}


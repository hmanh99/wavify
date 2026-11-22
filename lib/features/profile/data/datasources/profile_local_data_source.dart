import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<void> saveProfile(UserProfileModel profile);
  Future<UserProfileModel?> getProfile();
  Future<void> clearProfile();
  Future<String?> getRefreshToken();
  Future<void> clearAuthTokens();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const String _keyProfile = 'cached_user_profile';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyUser = 'auth_current_user';
  final FlutterSecureStorage secureStorage;

  ProfileLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
      : secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  Future<void> saveProfile(UserProfileModel profile) async {
    await secureStorage.write(key: _keyProfile, value: jsonEncode(profile.toJson()));
  }

  @override
  Future<UserProfileModel?> getProfile() async {
    final raw = await secureStorage.read(key: _keyProfile);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfileModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearProfile() async {
    await secureStorage.delete(key: _keyProfile);
  }

  @override
  Future<String?> getRefreshToken() async {
    return secureStorage.read(key: _keyRefreshToken);
  }

  @override
  Future<void> clearAuthTokens() async {
    await secureStorage.delete(key: _keyAccessToken);
    await secureStorage.delete(key: _keyRefreshToken);
    await secureStorage.delete(key: _keyUser);
  }
}

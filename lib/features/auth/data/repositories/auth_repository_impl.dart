import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../interceptors/auth_interceptor.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final result = await remoteDataSource.login(
      LoginRequestModel(email: email, password: password),
    );

    await localDataSource.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );

    if (result.user != null) {
      await localDataSource.saveUser(result.user!);
    }

    return result;
  }

  @override
  Future<AuthTokens> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final result = await remoteDataSource.register(
      RegisterRequestModel(
        fullName: fullName,
        email: email,
        password: password,
      ),
    );

    // If backend returns tokens directly on register
    if (result.accessToken.isNotEmpty) {
      await localDataSource.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      if (result.user != null) {
        await localDataSource.saveUser(result.user!);
      }

      return result;
    }

    // Backend returns UserResponse without tokens (e.g. Spring Boot /register)
    // Automatically login to retrieve JWT tokens and authenticate the session seamlessly
    return await login(email: email, password: password);
  }

  @override
  Future<AuthTokens> refreshToken() async {
    final currentRefreshToken = await localDataSource.getRefreshToken();
    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      throw Exception('Không tìm thấy refresh token');
    }

    final result = await remoteDataSource.refresh(currentRefreshToken);

    // Refresh Token Rotation: overwrite existing tokens with brand new tokens
    await localDataSource.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken.isNotEmpty
          ? result.refreshToken
          : currentRefreshToken,
    );

    if (result.user != null) {
      await localDataSource.saveUser(result.user!);
    }

    return result;
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearTokens();
  }

  @override
  Future<bool> isAuthenticated() async {
    final accessToken = await localDataSource.getAccessToken();
    final refreshStr = await localDataSource.getRefreshToken();

    final hasAccess = accessToken != null && accessToken.isNotEmpty;
    final hasRefresh = refreshStr != null && refreshStr.isNotEmpty;

    if (!hasAccess && !hasRefresh) {
      return false;
    }

    // Proactively refresh if accessToken is missing or expired and we have a refreshToken
    if ((!hasAccess || AuthInterceptor.isJwtExpired(accessToken)) && hasRefresh) {
      try {
        await refreshToken();
        return true;
      } catch (e) {
        final msg = e.toString();
        // If server explicitly rejected refresh token (401/400), session is expired
        if (msg.contains('401') ||
            msg.contains('không chính xác') ||
            msg.contains('Unauthenticated') ||
            msg.contains('không hợp lệ')) {
          await localDataSource.clearTokens();
          return false;
        }
        // If offline/connection error, allow cached session
        return true;
      }
    }

    return true;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return localDataSource.getUser();
  }
}

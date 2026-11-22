import '../entities/auth_tokens.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<AuthTokens> login({
    required String email,
    required String password,
  });

  Future<AuthTokens> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<AuthTokens> refreshToken();

  Future<void> logout();

  Future<bool> isAuthenticated();

  Future<UserEntity?> getCurrentUser();
}


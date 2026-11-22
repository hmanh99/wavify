import '../entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Future<UserProfileEntity> getProfile();

  Future<UserProfileEntity> updateProfile({
    required String userId,
    String? username,
    String? email,
    String? password,
  });

  Future<void> logout();
}


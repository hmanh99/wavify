import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/update_user_request_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserProfileEntity> getProfile() async {
    try {
      final remoteProfile = await remoteDataSource.getCurrentUser();
      await localDataSource.saveProfile(remoteProfile);
      return remoteProfile;
    } catch (e) {
      // Fallback to local cache if offline
      final cached = await localDataSource.getProfile();
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<UserProfileEntity> updateProfile({
    required String userId,
    String? username,
    String? email,
    String? password,
  }) async {
    final updated = await remoteDataSource.updateUser(
      userId,
      UpdateUserRequestModel(
        username: username,
        email: email,
        password: password,
      ),
    );

    await localDataSource.saveProfile(updated);
    return updated;
  }

  @override
  Future<void> logout() async {
    final refreshToken = await localDataSource.getRefreshToken();
    try {
      await remoteDataSource.logout(refreshToken);
    } catch (_) {}
    await localDataSource.clearProfile();
    await localDataSource.clearAuthTokens();
  }
}

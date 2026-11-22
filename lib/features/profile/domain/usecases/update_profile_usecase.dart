import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<UserProfileEntity> call({
    required String userId,
    String? username,
    String? email,
    String? password,
  }) {
    return repository.updateProfile(
      userId: userId,
      username: username,
      email: email,
      password: password,
    );
  }
}


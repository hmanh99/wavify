import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ProfileRepository profileRepository;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.profileRepository,
  }) : super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) {
      emit(const ProfileLoading());
    }
    try {
      final profile = await getProfileUseCase();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileFailure(_cleanError(e)));
    }
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state is ProfileLoaded
        ? (state as ProfileLoaded).profile
        : (state is ProfileUpdateSuccess
            ? (state as ProfileUpdateSuccess).profile
            : null);

    if (event.username != null &&
        event.username!.trim().isNotEmpty &&
        event.username!.trim().length < 4) {
      emit(ProfileFailure(
        'Tên người dùng phải có tối thiểu 4 ký tự',
        profile: current,
      ));
      return;
    }

    if (event.password != null &&
        event.password!.trim().isNotEmpty &&
        event.password!.trim().length < 8) {
      emit(ProfileFailure(
        'Mật khẩu mới phải có tối thiểu 8 ký tự',
        profile: current,
      ));
      return;
    }

    if (current != null) {
      emit(ProfileUpdating(current));
    } else {
      emit(const ProfileLoading());
    }

    try {
      final updated = await updateProfileUseCase(
        userId: event.userId,
        username: event.username,
        email: event.email,
        password: event.password,
      );
      emit(ProfileUpdateSuccess(updated, 'Cập nhật thông tin thành công'));
      emit(ProfileLoaded(updated));
    } catch (e) {
      emit(ProfileFailure(_cleanError(e), profile: current));
      if (current != null) {
        emit(ProfileLoaded(current));
      }
    }
  }

  Future<void> _onLogoutRequested(
    ProfileLogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      await profileRepository.logout();
    } finally {
      emit(const ProfileLoggedOut());
    }
  }

  String _cleanError(dynamic error) {
    final str = error.toString();
    if (str.startsWith('Exception: ')) {
      return str.substring('Exception: '.length);
    }
    return str;
  }
}


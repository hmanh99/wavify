import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavify/core/di/service_locator.dart';
import 'package:wavify/core/theme/app_theme.dart';
import 'package:wavify/features/profile/data/models/update_user_request_model.dart';
import 'package:wavify/features/profile/data/models/user_profile_model.dart';
import 'package:wavify/features/profile/domain/entities/user_profile_entity.dart';
import 'package:wavify/features/profile/domain/repositories/profile_repository.dart';
import 'package:wavify/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:wavify/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:wavify/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:wavify/features/profile/presentation/bloc/profile_event.dart';
import 'package:wavify/features/profile/presentation/bloc/profile_state.dart';
import 'package:wavify/features/profile/presentation/pages/profile_page.dart';
import 'package:wavify/features/profile/presentation/widgets/profile_header_card.dart';

class MockProfileRepository implements ProfileRepository {
  UserProfileEntity profile = const UserProfileEntity(
    id: 'user-123',
    username: 'Sarwar Jahan',
    email: 'sarwar@example.com',
    role: 'USER',
  );
  bool logoutCalled = false;
  bool shouldThrow = false;

  @override
  Future<UserProfileEntity> getProfile() async {
    if (shouldThrow) {
      throw Exception('Lỗi nạp thông tin người dùng');
    }
    return profile;
  }

  @override
  Future<UserProfileEntity> updateProfile({
    required String userId,
    String? username,
    String? email,
    String? password,
  }) async {
    if (shouldThrow) {
      throw Exception('Lỗi cập nhật');
    }
    profile = profile.copyWith(
      username: username ?? profile.username,
      email: email ?? profile.email,
    );
    return profile;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }
}

void main() {
  setUp(() async {
    await sl.reset();
    await initAuthDependencies();
    await initProfileDependencies();
  });

  group('Profile Models & Entities Tests', () {
    test('UserProfileModel parses Spring Boot ApiResponse result map', () {
      final json = {
        'code': 1000,
        'result': {
          'id': 'u100',
          'username': 'wavify_lover',
          'email': 'lover@wavify.app',
          'role': 'USER',
          'created_at': '2026-11-01T10:00:00Z',
        }
      };

      final model = UserProfileModel.fromJson(json);
      expect(model.id, 'u100');
      expect(model.username, 'wavify_lover');
      expect(model.email, 'lover@wavify.app');
      expect(model.role, 'USER');
      expect(model.createdAt, isNotNull);
    });

    test('UpdateUserRequestModel toJson filters out null fields', () {
      const req = UpdateUserRequestModel(
        username: 'new_name',
        password: 'new_password_123',
      );
      final json = req.toJson();
      expect(json['username'], 'new_name');
      expect(json['password'], 'new_password_123');
      expect(json.containsKey('email'), isFalse);
    });
  });

  group('ProfileBloc Tests', () {
    late MockProfileRepository mockRepo;
    late GetProfileUseCase getProfileUseCase;
    late UpdateProfileUseCase updateProfileUseCase;
    late ProfileBloc bloc;

    setUp(() {
      mockRepo = MockProfileRepository();
      getProfileUseCase = GetProfileUseCase(mockRepo);
      updateProfileUseCase = UpdateProfileUseCase(mockRepo);
      bloc = ProfileBloc(
        getProfileUseCase: getProfileUseCase,
        updateProfileUseCase: updateProfileUseCase,
        profileRepository: mockRepo,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is ProfileInitial', () {
      expect(bloc.state, const ProfileInitial());
    });

    test('ProfileLoadRequested emits ProfileLoading then ProfileLoaded', () async {
      bloc.add(const ProfileLoadRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const ProfileLoading(),
          ProfileLoaded(mockRepo.profile),
        ]),
      );
    });

    test('ProfileUpdateRequested validates username min length 4', () async {
      bloc.emit(ProfileLoaded(mockRepo.profile));

      bloc.add(const ProfileUpdateRequested(
        userId: 'user-123',
        username: 'abc', // < 4 chars
      ));

      await expectLater(
        bloc.stream,
        emits(
          ProfileFailure(
            'Tên người dùng phải có tối thiểu 4 ký tự',
            profile: mockRepo.profile,
          ),
        ),
      );
    });

    test('ProfileUpdateRequested validates password min length 8', () async {
      bloc.emit(ProfileLoaded(mockRepo.profile));

      bloc.add(const ProfileUpdateRequested(
        userId: 'user-123',
        password: '123', // < 8 chars
      ));

      await expectLater(
        bloc.stream,
        emits(
          ProfileFailure(
            'Mật khẩu mới phải có tối thiểu 8 ký tự',
            profile: mockRepo.profile,
          ),
        ),
      );
    });

    test('ProfileLogoutRequested calls logout on repository and emits ProfileLoggedOut', () async {
      bloc.add(const ProfileLogoutRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const ProfileLoading(),
          const ProfileLoggedOut(),
        ]),
      );
      expect(mockRepo.logoutCalled, isTrue);
    });
  });

  group('ProfilePage UI Tests', () {
    testWidgets('ProfilePage renders header, menu items and logout button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockRepo = MockProfileRepository();
      final testBloc = ProfileBloc(
        getProfileUseCase: GetProfileUseCase(mockRepo),
        updateProfileUseCase: UpdateProfileUseCase(mockRepo),
        profileRepository: mockRepo,
      );

      await tester.pumpWidget(
        BlocProvider<ProfileBloc>.value(
          value: testBloc..add(const ProfileLoadRequested()),
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ProfilePage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Hồ sơ của tôi'), findsOneWidget);
      expect(find.byType(ProfileHeaderCard), findsOneWidget);
      expect(find.text('Sarwar Jahan'), findsOneWidget);
      expect(find.text('Member'), findsOneWidget);

      expect(find.text('Chỉnh sửa thông tin cá nhân'), findsOneWidget);
      expect(find.text('Đăng xuất'), findsWidgets);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavify/core/constants/colors_constant.dart';
import 'package:wavify/core/l10n/app_l10n.dart';
import 'package:wavify/core/l10n/bloc/locale_bloc.dart';
import 'package:wavify/core/theme/app_theme.dart';
import 'package:wavify/core/theme/app_tokens.dart';
import 'package:wavify/core/theme/bloc/theme_bloc.dart';
import 'package:wavify/features/profile/domain/entities/user_profile_entity.dart';
import 'package:wavify/features/profile/domain/repositories/profile_repository.dart';
import 'package:wavify/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:wavify/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:wavify/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:wavify/features/profile/presentation/bloc/profile_state.dart';
import 'package:wavify/features/profile/presentation/pages/profile_page.dart';

class _StubProfileRepository implements ProfileRepository {
  @override
  Future<UserProfileEntity> getProfile() async => const UserProfileEntity(
        id: 'u1',
        username: 'dark_mode_user',
        email: 'dark@wavify.app',
        role: 'USER',
      );

  @override
  Future<void> logout() async {}

  @override
  Future<UserProfileEntity> updateProfile({
    required String userId,
    String? username,
    String? email,
    String? password,
  }) async =>
      await getProfile();
}

void main() {
  group('Dark Theme Palette & Tokens', () {
    test('AppTheme.darkTheme maps ColorsConstant dark palette accurately', () {
      final theme = AppTheme.darkTheme;
      final semantic = theme.extension<AppSemanticColors>();

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, ColorsConstant.scaffoldBackground);
      expect(theme.colorScheme.primary, ColorsConstant.primary);
      expect(theme.colorScheme.onPrimary, ColorsConstant.onPrimary);
      expect(theme.colorScheme.surface, ColorsConstant.cardBackground);
      expect(theme.colorScheme.onSurface, ColorsConstant.textPrimary);
      expect(theme.colorScheme.onSurfaceVariant, ColorsConstant.textSecondary);
      expect(theme.colorScheme.outline, ColorsConstant.border);
      expect(theme.colorScheme.error, ColorsConstant.error);
      expect(theme.colorScheme.onError, ColorsConstant.onError);

      expect(semantic, isNotNull);
      expect(semantic!.cardSurface, ColorsConstant.cardBackground);
      expect(semantic.inputFill, ColorsConstant.inputBackground);
      expect(semantic.subtleBorder, ColorsConstant.border);
      expect(semantic.navBackground, ColorsConstant.bottomNavBackground);
      expect(semantic.textMuted, ColorsConstant.textSecondary);
      expect(semantic.overlay, ColorsConstant.overlay);
    });
  });

  group('ThemeBloc Unit Tests', () {
    test('defaults to ThemeMode.system and changes/toggles cleanly', () async {
      final bloc = ThemeBloc();
      expect(bloc.state.themeMode, ThemeMode.system);

      bloc.add(const ThemeChangeRequested(ThemeMode.dark));
      await pumpEventQueue();
      expect(bloc.state.themeMode, ThemeMode.dark);

      bloc.add(const ThemeToggleRequested());
      await pumpEventQueue();
      expect(bloc.state.themeMode, ThemeMode.light);

      bloc.add(const ThemeToggleRequested());
      await pumpEventQueue();
      expect(bloc.state.themeMode, ThemeMode.dark);

      bloc.setThemeMode(ThemeMode.system);
      await pumpEventQueue();
      expect(bloc.state.themeMode, ThemeMode.system);

      await bloc.close();
    });
  });

  group('ProfilePage Dark Mode Selector Widget Tests', () {
    testWidgets('ProfilePage switches between Light and Dark themes via dialog', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(411, 891);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = _StubProfileRepository();
      final profileBloc = ProfileBloc(
        getProfileUseCase: GetProfileUseCase(repo),
        updateProfileUseCase: UpdateProfileUseCase(repo),
        profileRepository: repo,
      )..emit(
          const ProfileLoaded(
            UserProfileEntity(
              id: 'u1',
              username: 'dark_mode_user',
              email: 'dark@wavify.app',
              role: 'USER',
            ),
          ),
        );
      final themeBloc = ThemeBloc();
      final localeBloc = LocaleBloc();
      addTearDown(() async {
        await profileBloc.close();
        await themeBloc.close();
        await localeBloc.close();
      });

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ProfileBloc>.value(value: profileBloc),
            BlocProvider<ThemeBloc>.value(value: themeBloc),
            BlocProvider<LocaleBloc>.value(value: localeBloc),
          ],
          child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return MaterialApp(
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.themeMode,
                locale: const Locale('vi'),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                home: const ProfilePage(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially system mode
      expect(find.text('Nền tối'), findsOneWidget);
      expect(find.text('Theo hệ thống'), findsOneWidget);

      // Open theme dialog and switch to Dark
      await tester.tap(find.text('Nền tối'));
      await tester.pumpAndSettle();
      expect(find.text('Chế độ hiển thị'), findsOneWidget);

      await tester.tap(find.text('Tối'));
      await tester.pumpAndSettle();

      expect(themeBloc.state.themeMode, ThemeMode.dark);
      expect(find.text('Tối'), findsOneWidget);
      final darkScaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(darkScaffold.backgroundColor, ColorsConstant.scaffoldBackground);

      // Open theme dialog and switch to Light
      await tester.tap(find.text('Nền tối'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sáng'));
      await tester.pumpAndSettle();

      expect(themeBloc.state.themeMode, ThemeMode.light);
      expect(find.text('Sáng'), findsOneWidget);
      final lightScaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(
        lightScaffold.backgroundColor,
        ColorsConstant.lightScaffoldBackground,
      );
    });
  });
}

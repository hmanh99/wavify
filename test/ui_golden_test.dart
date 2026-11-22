import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavify/core/l10n/app_l10n.dart';
import 'package:wavify/core/theme/app_theme.dart';
import 'package:wavify/features/home/domain/entities/song_entity.dart';
import 'package:wavify/features/home/domain/repositories/home_repository.dart';
import 'package:wavify/features/home/domain/usecases/get_all_songs_usecase.dart';
import 'package:wavify/features/home/presentation/bloc/home_bloc.dart';
import 'package:wavify/features/home/presentation/bloc/home_state.dart';
import 'package:wavify/features/home/presentation/pages/home_page.dart';
import 'package:wavify/features/listen/data/models/song_model.dart';
import 'package:wavify/features/listen/presentation/bloc/player_bloc.dart';
import 'package:wavify/features/listen/presentation/bloc/player_state.dart';
import 'package:wavify/features/listen/presentation/pages/listen_page.dart';
import 'package:wavify/features/profile/domain/entities/user_profile_entity.dart';
import 'package:wavify/features/profile/domain/repositories/profile_repository.dart';
import 'package:wavify/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:wavify/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:wavify/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:wavify/features/profile/presentation/bloc/profile_state.dart';
import 'package:wavify/features/profile/presentation/pages/profile_page.dart';

import 'listen_playback_test.dart';

class _GoldenHomeRepo implements HomeRepository {
  @override
  Future<List<SongEntity>> getAllSongs({int page = 0, int size = 50}) async =>
      const [];
}

class _GoldenProfileRepo implements ProfileRepository {
  @override
  Future<UserProfileEntity> getProfile() async => const UserProfileEntity(
        id: 'u1',
        username: 'minimal_user',
        email: 'minimal@wavify.app',
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
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapGolden(Widget child, ThemeData theme) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    );
  }

  testWidgets('Golden: HomePage Dark & Light Mode', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const songs = [
      SongEntity(
        id: 's1',
        title: 'Midnight Serenade',
        artist: 'Acoustic Dreams',
        album: 'Nightfall',
        durationSec: 210,
        fileUrl: 'https://example.com/1.mp3',
      ),
      SongEntity(
        id: 's2',
        title: 'Glass Horizon',
        artist: 'Monochrome',
        album: 'Quiet',
        durationSec: 185,
        fileUrl: 'https://example.com/2.mp3',
      ),
    ];

    final homeBloc = HomeBloc(getAllSongsUseCase: GetAllSongsUseCase(_GoldenHomeRepo()))
      ..emit(const HomeLoaded(allSongs: songs, filteredSongs: songs));
    addTearDown(homeBloc.close);

    await tester.pumpWidget(
      BlocProvider<HomeBloc>.value(
        value: homeBloc,
        child: wrapGolden(const HomePage(), AppTheme.darkTheme),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(find.byType(HomePage), matchesGoldenFile('goldens/home_dark.png'));

    await tester.pumpWidget(
      BlocProvider<HomeBloc>.value(
        value: homeBloc,
        child: wrapGolden(const HomePage(), AppTheme.lightTheme),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(find.byType(HomePage), matchesGoldenFile('goldens/home_light.png'));
  });

  testWidgets('Golden: ListenPage Dark & Light Mode', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakeAudio = FakeAudioPlayerService();
    final playerBloc = PlayerBloc(audioPlayerService: fakeAudio)
      ..emit(
        const PlayerState(
          playlist: [
            SongModel(
              id: 's1',
              title: 'Midnight Serenade',
              artist: 'Acoustic Dreams',
              duration: Duration(minutes: 3, seconds: 30),
            ),
          ],
          currentIndex: 0,
          totalDuration: Duration(minutes: 3, seconds: 30),
          currentPosition: Duration(seconds: 75),
        ),
      );
    addTearDown(() async {
      await playerBloc.close();
      await fakeAudio.dispose();
    });

    await tester.pumpWidget(
      BlocProvider<PlayerBloc>.value(
        value: playerBloc,
        child: wrapGolden(const ListenPage(), AppTheme.darkTheme),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(find.byType(ListenPage), matchesGoldenFile('goldens/listen_dark.png'));

    await tester.pumpWidget(
      BlocProvider<PlayerBloc>.value(
        value: playerBloc,
        child: wrapGolden(const ListenPage(), AppTheme.lightTheme),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(find.byType(ListenPage), matchesGoldenFile('goldens/listen_light.png'));
  });

  testWidgets('Golden: ProfilePage Dark & Light Mode', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repo = _GoldenProfileRepo();
    final profileBloc = ProfileBloc(
      getProfileUseCase: GetProfileUseCase(repo),
      updateProfileUseCase: UpdateProfileUseCase(repo),
      profileRepository: repo,
    )..emit(
        const ProfileLoaded(
          UserProfileEntity(
            id: 'u1',
            username: 'minimal_user',
            email: 'minimal@wavify.app',
            role: 'USER',
          ),
        ),
      );
    addTearDown(profileBloc.close);

    await tester.pumpWidget(
      BlocProvider<ProfileBloc>.value(
        value: profileBloc,
        child: wrapGolden(const ProfilePage(), AppTheme.darkTheme),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(find.byType(ProfilePage), matchesGoldenFile('goldens/profile_dark.png'));

    await tester.pumpWidget(
      BlocProvider<ProfileBloc>.value(
        value: profileBloc,
        child: wrapGolden(const ProfilePage(), AppTheme.lightTheme),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(find.byType(ProfilePage), matchesGoldenFile('goldens/profile_light.png'));
  });
}

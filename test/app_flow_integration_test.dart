import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavify/core/di/service_locator.dart';
import 'package:wavify/core/l10n/app_l10n.dart';
import 'package:wavify/core/l10n/bloc/locale_bloc.dart';
import 'package:wavify/core/router/app_router.dart';
import 'package:wavify/core/services/playback_bridge.dart';
import 'package:wavify/core/theme/app_theme.dart';
import 'package:wavify/features/auth/domain/entities/auth_tokens.dart';
import 'package:wavify/features/auth/domain/entities/user_entity.dart';
import 'package:wavify/features/auth/domain/repositories/auth_repository.dart';
import 'package:wavify/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:wavify/features/auth/domain/usecases/login_usecase.dart';
import 'package:wavify/features/auth/domain/usecases/logout_usecase.dart';
import 'package:wavify/features/auth/domain/usecases/register_usecase.dart';
import 'package:wavify/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wavify/features/history/domain/entities/history_entity.dart';
import 'package:wavify/features/history/domain/repositories/history_repository.dart';
import 'package:wavify/features/history/domain/usecases/clear_history_usecase.dart';
import 'package:wavify/features/history/domain/usecases/delete_history_item_usecase.dart';
import 'package:wavify/features/history/domain/usecases/get_history_usecase.dart';
import 'package:wavify/features/history/domain/usecases/record_history_usecase.dart';
import 'package:wavify/features/history/presentation/bloc/history_bloc.dart';
import 'package:wavify/features/home/domain/entities/song_entity.dart' as home;
import 'package:wavify/features/home/domain/repositories/home_repository.dart';
import 'package:wavify/features/home/domain/usecases/get_all_songs_usecase.dart';
import 'package:wavify/features/home/presentation/bloc/home_bloc.dart';
import 'package:wavify/features/home/presentation/bloc/home_event.dart';
import 'package:wavify/features/listen/presentation/bloc/player_bloc.dart';
import 'package:wavify/features/playlist/domain/entities/playlist_entity.dart';
import 'package:wavify/features/playlist/domain/entities/song_entity.dart' as pl;
import 'package:wavify/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:wavify/features/playlist/domain/usecases/add_song_to_playlist_usecase.dart';
import 'package:wavify/features/playlist/domain/usecases/add_songs_to_playlist_usecase.dart';
import 'package:wavify/features/playlist/domain/usecases/create_playlist_usecase.dart';
import 'package:wavify/features/playlist/domain/usecases/delete_playlist_usecase.dart';
import 'package:wavify/features/playlist/domain/usecases/get_available_songs_usecase.dart';
import 'package:wavify/features/playlist/domain/usecases/get_my_playlists_usecase.dart';
import 'package:wavify/features/playlist/domain/usecases/get_playlist_detail_usecase.dart';
import 'package:wavify/features/playlist/domain/usecases/remove_song_from_playlist_usecase.dart';
import 'package:wavify/features/playlist/domain/usecases/reorder_playlist_songs_usecase.dart';
import 'package:wavify/features/playlist/domain/usecases/update_playlist_usecase.dart';
import 'package:wavify/features/playlist/presentation/bloc/playlist_bloc.dart';
import 'package:wavify/features/playlist/presentation/bloc/playlist_event.dart';
import 'package:wavify/features/profile/domain/entities/user_profile_entity.dart';
import 'package:wavify/features/profile/domain/repositories/profile_repository.dart';
import 'package:wavify/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:wavify/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:wavify/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:wavify/features/profile/presentation/bloc/profile_event.dart';
import 'package:wavify/features/upload/domain/entities/song_entity.dart' as up;
import 'package:wavify/features/upload/domain/repositories/song_repository.dart';
import 'package:wavify/features/upload/domain/usecases/delete_song_usecase.dart';
import 'package:wavify/features/upload/domain/usecases/get_my_songs_usecase.dart';
import 'package:wavify/features/upload/domain/usecases/update_song_usecase.dart';
import 'package:wavify/features/upload/domain/usecases/upload_song_usecase.dart';
import 'package:wavify/features/upload/presentation/bloc/upload_bloc.dart';
import 'package:wavify/features/upload/presentation/bloc/upload_event.dart';

import 'listen_playback_test.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<UserEntity?> getCurrentUser() async => const UserEntity(
        id: 'user-1',
        email: 'minimal@wavify.app',
        fullName: 'minimal_user',
      );
  @override
  Future<bool> isAuthenticated() async => false;
  @override
  Future<AuthTokens> login({required String email, required String password}) async =>
      const AuthTokens(accessToken: 'a', refreshToken: 'r');
  @override
  Future<void> logout() async {}
  @override
  Future<AuthTokens> refreshToken() async =>
      const AuthTokens(accessToken: 'a2', refreshToken: 'r2');
  @override
  Future<AuthTokens> register({
    required String fullName,
    required String email,
    required String password,
  }) async =>
      const AuthTokens(accessToken: 'a', refreshToken: 'r');
}

class _FakeHomeRepository implements HomeRepository {
  @override
  Future<List<home.SongEntity>> getAllSongs({int page = 0, int size = 50}) async =>
      const [
        home.SongEntity(
          id: 's1',
          title: 'Midnight Serenade',
          artist: 'Acoustic Dreams',
          album: 'Nightfall',
          durationSec: 210,
          fileUrl: 'https://example.com/1.mp3',
        ),
        home.SongEntity(
          id: 's2',
          title: 'Glass Horizon',
          artist: 'Monochrome',
          album: 'Quiet',
          durationSec: 190,
          fileUrl: 'https://example.com/2.mp3',
        ),
      ];
}

class _FakePlaylistRepository implements PlaylistRepository {
  final List<PlaylistEntity> _playlists = [
    const PlaylistEntity(
      id: 'pl-1',
      name: 'Minimal Focus',
      description: 'Calm work tunes',
      visibility: 'PUBLIC',
      songCount: 1,
      songs: [
        pl.SongEntity(
          id: 's1',
          title: 'Midnight Serenade',
          artist: 'Acoustic Dreams',
          album: 'Nightfall',
          durationSec: 210,
          fileUrl: 'https://example.com/1.mp3',
        ),
      ],
    ),
  ];

  @override
  Future<List<pl.SongEntity>> getAllSongs({int page = 0, int size = 50}) async =>
      const [
        pl.SongEntity(
          id: 's1',
          title: 'Midnight Serenade',
          artist: 'Acoustic Dreams',
          album: 'Nightfall',
          durationSec: 210,
          fileUrl: 'https://example.com/1.mp3',
        ),
        pl.SongEntity(
          id: 's2',
          title: 'Glass Horizon',
          artist: 'Monochrome',
          album: 'Quiet',
          durationSec: 190,
          fileUrl: 'https://example.com/2.mp3',
        ),
      ];

  @override
  Future<List<PlaylistEntity>> getMyPlaylists() async => _playlists;
  @override
  Future<PlaylistEntity> getPlaylistById(String playlistId) async =>
      _playlists.firstWhere((p) => p.id == playlistId);
  @override
  Future<PlaylistEntity> createPlaylist({
    required String name,
    String? description,
    String? coverUrl,
    String visibility = 'PUBLIC',
  }) async {
    final created = PlaylistEntity(
      id: 'pl-${_playlists.length + 1}',
      name: name,
      description: description,
      visibility: visibility,
      songCount: 0,
      songs: const [],
    );
    _playlists.add(created);
    return created;
  }

  @override
  Future<PlaylistEntity> updatePlaylist({
    required String playlistId,
    required String name,
    String? description,
    String? coverUrl,
    String? visibility,
  }) async => _playlists.first;
  @override
  Future<void> deletePlaylist(String playlistId) async {}
  @override
  Future<PlaylistEntity> addSongToPlaylist({
    required String playlistId,
    required String songId,
  }) async => _playlists.first;
  @override
  Future<PlaylistEntity> addSongsToPlaylist({
    required String playlistId,
    required List<String> songIds,
  }) async => _playlists.first;
  @override
  Future<PlaylistEntity> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  }) async => _playlists.first;
  @override
  Future<PlaylistEntity> reorderPlaylistSongs({
    required String playlistId,
    required List<String> songIds,
  }) async => _playlists.first;
}

class _FakeHistoryRepository implements HistoryRepository {
  @override
  Future<void> clearHistory() async {}
  @override
  Future<void> deleteHistoryItem(String historyId) async {}
  @override
  Future<List<HistoryEntity>> getHistory({int page = 0, int size = 20}) async =>
      const [];
  @override
  Future<void> recordHistory(String songId) async {}
}

class _FakeProfileRepository implements ProfileRepository {
  UserProfileEntity _profile = const UserProfileEntity(
    id: 'user-1',
    username: 'minimal_user',
    email: 'minimal@wavify.app',
    role: 'USER',
  );
  @override
  Future<UserProfileEntity> getProfile() async => _profile;
  @override
  Future<void> logout() async {}
  @override
  Future<UserProfileEntity> updateProfile({
    required String userId,
    String? username,
    String? email,
    String? password,
  }) async {
    _profile = _profile.copyWith(username: username, email: email);
    return _profile;
  }
}

class _FakeSongRepository implements SongRepository {
  @override
  Future<void> deleteSong(String songId) async {}
  @override
  Future<List<up.SongEntity>> getMySongs() async => const [];
  @override
  Future<up.SongEntity> updateSong({
    required String songId,
    required String title,
    required String artist,
    String? album,
    required String visibility,
  }) async =>
      const up.SongEntity(
        id: 'u1',
        title: 'Updated',
        artist: 'Artist',
        fileUrl: '',
      );
  @override
  Future<up.SongEntity> uploadSong({
    required String title,
    required String artist,
    String? album,
    required String visibility,
    String? audioPath,
    Uint8List? audioBytes,
    String? audioFileName,
    String? coverPath,
    Uint8List? coverBytes,
    String? coverFileName,
    void Function(int sent, int total)? onSendProgress,
  }) async =>
      const up.SongEntity(
        id: 'u1',
        title: 'Uploaded',
        artist: 'Artist',
        fileUrl: '',
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Full App Navigation & Flow Integration Test with Mock Data Layer',
    (tester) async {
      tester.view.physicalSize = const Size(411, 891);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await sl.reset();

      final fakeAuthRepo = _FakeAuthRepository();
      final fakeHomeRepo = _FakeHomeRepository();
      final fakePlaylistRepo = _FakePlaylistRepository();
      final fakeHistoryRepo = _FakeHistoryRepository();
      final fakeProfileRepo = _FakeProfileRepository();
      final fakeSongRepo = _FakeSongRepository();
      final fakeAudio = FakeAudioPlayerService();

      final playerBloc = PlayerBloc(audioPlayerService: fakeAudio);
      sl.registerSingleton<PlayerBloc>(playerBloc);
      sl.registerSingleton<PlaybackBridge>(playerBloc);
      sl.registerLazySingleton<PlaylistRepository>(() => fakePlaylistRepo);
      sl.registerLazySingleton<GetAvailableSongsUseCase>(
        () => GetAvailableSongsUseCase(fakePlaylistRepo),
      );

      final authBloc = AuthBloc(
        loginUseCase: LoginUseCase(fakeAuthRepo),
        registerUseCase: RegisterUseCase(fakeAuthRepo),
        logoutUseCase: LogoutUseCase(fakeAuthRepo),
        checkAuthStatusUseCase: CheckAuthStatusUseCase(fakeAuthRepo),
        authRepository: fakeAuthRepo,
      );
      final localeBloc = LocaleBloc();
      final profileBloc = ProfileBloc(
        getProfileUseCase: GetProfileUseCase(fakeProfileRepo),
        updateProfileUseCase: UpdateProfileUseCase(fakeProfileRepo),
        profileRepository: fakeProfileRepo,
      )..add(const ProfileLoadRequested());
      final uploadBloc = UploadBloc(
        uploadSongUseCase: UploadSongUseCase(fakeSongRepo),
        updateSongUseCase: UpdateSongUseCase(fakeSongRepo),
        deleteSongUseCase: DeleteSongUseCase(fakeSongRepo),
        getMySongsUseCase: GetMySongsUseCase(fakeSongRepo),
      )..add(const LoadMySongsRequested());
      final homeBloc = HomeBloc(
        getAllSongsUseCase: GetAllSongsUseCase(fakeHomeRepo),
      )..add(const HomeLoadSongsRequested());
      final playlistBloc = PlaylistBloc(
        getMyPlaylistsUseCase: GetMyPlaylistsUseCase(fakePlaylistRepo),
        getPlaylistDetailUseCase: GetPlaylistDetailUseCase(fakePlaylistRepo),
        createPlaylistUseCase: CreatePlaylistUseCase(fakePlaylistRepo),
        updatePlaylistUseCase: UpdatePlaylistUseCase(fakePlaylistRepo),
        deletePlaylistUseCase: DeletePlaylistUseCase(fakePlaylistRepo),
        addSongToPlaylistUseCase: AddSongToPlaylistUseCase(fakePlaylistRepo),
        addSongsToPlaylistUseCase: AddSongsToPlaylistUseCase(fakePlaylistRepo),
        removeSongFromPlaylistUseCase:
            RemoveSongFromPlaylistUseCase(fakePlaylistRepo),
        reorderPlaylistSongsUseCase:
            ReorderPlaylistSongsUseCase(fakePlaylistRepo),
      )..add(const LoadPlaylistsRequested());
      final historyBloc = HistoryBloc(
        getHistoryUseCase: GetHistoryUseCase(fakeHistoryRepo),
        recordHistoryUseCase: RecordHistoryUseCase(fakeHistoryRepo),
        clearHistoryUseCase: ClearHistoryUseCase(fakeHistoryRepo),
        deleteHistoryItemUseCase: DeleteHistoryItemUseCase(fakeHistoryRepo),
      );

      addTearDown(() async {
        await authBloc.close();
        await localeBloc.close();
        await profileBloc.close();
        await uploadBloc.close();
        await homeBloc.close();
        await playlistBloc.close();
        await historyBloc.close();
        await playerBloc.close();
        await fakeAudio.dispose();
        await sl.reset();
      });

      AppRouter.router.go(AppRouter.signIn);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<LocaleBloc>.value(value: localeBloc),
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<ProfileBloc>.value(value: profileBloc),
            BlocProvider<UploadBloc>.value(value: uploadBloc),
            BlocProvider<HomeBloc>.value(value: homeBloc),
            BlocProvider<PlaylistBloc>.value(value: playlistBloc),
            BlocProvider<HistoryBloc>.value(value: historyBloc),
            BlocProvider<PlayerBloc>.value(value: playerBloc),
          ],
          child: BlocBuilder<LocaleBloc, LocaleState>(
            builder: (context, localeState) {
              return MaterialApp.router(
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: ThemeMode.dark,
                routerConfig: AppRouter.router,
                locale: localeState.locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
              );
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Starts on SignInPage and logs in
      expect(find.text('Đăng nhập'), findsWidgets);
      await tester.enterText(find.byType(TextField).first, 'minimal@wavify.app');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
      await tester.pumpAndSettle();

      // 2. Navigated to Home and displays songs
      expect(find.text('Midnight Serenade'), findsWidgets);
      expect(find.text('Glass Horizon'), findsWidgets);

      // Search filters songs
      await tester.enterText(find.byType(TextField).first, 'Glass');
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Midnight Serenade'), findsNothing);
      expect(find.text('Glass Horizon'), findsOneWidget);

      // Clear search
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump(const Duration(milliseconds: 100));

      // 3. Tap song to play -> opens Listen tab
      await tester.tap(find.text('Glass Horizon').first);
      await tester.pumpAndSettle();
      expect(fakeAudio.playCallCount, 1);

      // 4. Switch to Favourite tab & open PlaylistDetail
      await tester.tap(find.byTooltip('Yêu thích'));
      await tester.pumpAndSettle();
      expect(find.text('Minimal Focus'), findsOneWidget);

      await tester.tap(find.text('Minimal Focus'));
      await tester.pumpAndSettle();
      expect(find.text('Calm work tunes'), findsOneWidget);

      // Back from PlaylistDetail
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // 5. Switch to Upload tab
      await tester.tap(find.byTooltip('Đăng tải'));
      await tester.pumpAndSettle();
      expect(find.text('Đăng tải bài hát'), findsOneWidget);

      // 6. Switch to Profile tab & open History
      await tester.tap(find.byTooltip('Cá nhân'));
      await tester.pumpAndSettle();
      expect(find.text('minimal_user'), findsOneWidget);

      await tester.tap(find.text('Lịch sử phát nhạc'));
      await tester.pumpAndSettle();
      expect(find.text('Chưa có lịch sử phát nhạc'), findsOneWidget);

      // Back to Profile & switch language to English
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ngôn ngữ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(find.text('My Profile'), findsOneWidget);
    },
  );
}

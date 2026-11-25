import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wavify/core/di/service_locator.dart';
import 'package:wavify/core/l10n/app_l10n.dart';
import 'package:wavify/core/l10n/bloc/locale_bloc.dart';
import 'package:wavify/core/services/playback_bridge.dart';
import 'package:wavify/core/theme/app_theme.dart';
import 'package:wavify/core/widgets/app_scaffold_with_nav_bar.dart';
import 'package:wavify/features/auth/domain/entities/auth_tokens.dart';
import 'package:wavify/features/auth/domain/entities/user_entity.dart';
import 'package:wavify/features/auth/domain/repositories/auth_repository.dart';
import 'package:wavify/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:wavify/features/auth/domain/usecases/login_usecase.dart';
import 'package:wavify/features/auth/domain/usecases/logout_usecase.dart';
import 'package:wavify/features/auth/domain/usecases/register_usecase.dart';
import 'package:wavify/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wavify/features/auth/presentation/pages/sign_in_page.dart';
import 'package:wavify/features/auth/presentation/pages/sign_up_page.dart';
import 'package:wavify/features/favorite/presentation/pages/all_favorites_page.dart';
import 'package:wavify/features/history/domain/entities/history_entity.dart';
import 'package:wavify/features/history/domain/entities/history_song_entity.dart';
import 'package:wavify/features/history/domain/repositories/history_repository.dart';
import 'package:wavify/features/history/domain/usecases/clear_history_usecase.dart';
import 'package:wavify/features/history/domain/usecases/delete_history_item_usecase.dart';
import 'package:wavify/features/history/domain/usecases/get_history_usecase.dart';
import 'package:wavify/features/history/domain/usecases/record_history_usecase.dart';
import 'package:wavify/features/history/presentation/bloc/history_bloc.dart';
import 'package:wavify/features/history/presentation/bloc/history_state.dart';
import 'package:wavify/features/history/presentation/pages/history_page.dart';
import 'package:wavify/features/home/domain/entities/song_entity.dart' as home;
import 'package:wavify/features/home/domain/repositories/home_repository.dart';
import 'package:wavify/features/home/domain/usecases/get_all_songs_usecase.dart';
import 'package:wavify/features/home/presentation/bloc/home_bloc.dart';
import 'package:wavify/features/home/presentation/bloc/home_state.dart';
import 'package:wavify/features/home/presentation/pages/home_page.dart';
import 'package:wavify/features/listen/data/datasources/audio_player_service.dart';
import 'package:wavify/features/listen/data/models/song_model.dart';
import 'package:wavify/features/listen/presentation/bloc/player_bloc.dart';
import 'package:wavify/features/listen/presentation/bloc/player_state.dart';
import 'package:wavify/features/listen/presentation/pages/listen_page.dart';
import 'package:wavify/features/favorite/domain/entities/playlist_entity.dart';
import 'package:wavify/features/favorite/domain/entities/song_entity.dart'
    as pl;
import 'package:wavify/features/favorite/domain/repositories/playlist_repository.dart';
import 'package:wavify/features/favorite/domain/usecases/add_song_to_playlist_usecase.dart';
import 'package:wavify/features/favorite/domain/usecases/add_songs_to_playlist_usecase.dart';
import 'package:wavify/features/favorite/domain/usecases/create_playlist_usecase.dart';
import 'package:wavify/features/favorite/domain/usecases/delete_playlist_usecase.dart';
import 'package:wavify/features/favorite/domain/usecases/get_my_playlists_usecase.dart';
import 'package:wavify/features/favorite/domain/usecases/get_playlist_detail_usecase.dart';
import 'package:wavify/features/favorite/domain/usecases/remove_song_from_playlist_usecase.dart';
import 'package:wavify/features/favorite/domain/usecases/reorder_playlist_songs_usecase.dart';
import 'package:wavify/features/favorite/domain/usecases/update_playlist_usecase.dart';
import 'package:wavify/features/favorite/presentation/bloc/playlist_bloc.dart';
import 'package:wavify/features/favorite/presentation/bloc/playlist_state.dart';
import 'package:wavify/features/favorite/presentation/pages/favourite_page.dart';
import 'package:wavify/features/favorite/presentation/pages/playlist_detail_page.dart';
import 'package:wavify/features/favorite/presentation/widgets/add_multiple_songs_bottom_sheet.dart';
import 'package:wavify/features/favorite/presentation/widgets/create_edit_playlist_dialog.dart';
import 'package:wavify/features/profile/domain/entities/user_profile_entity.dart';
import 'package:wavify/features/profile/domain/repositories/profile_repository.dart';
import 'package:wavify/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:wavify/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:wavify/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:wavify/features/profile/presentation/bloc/profile_state.dart';
import 'package:wavify/features/profile/presentation/pages/profile_page.dart';
import 'package:wavify/features/profile/presentation/widgets/edit_profile_bottom_sheet.dart';
import 'package:wavify/features/upload/domain/entities/song_entity.dart' as up;
import 'package:wavify/features/upload/domain/repositories/song_repository.dart';
import 'package:wavify/features/upload/domain/usecases/delete_song_usecase.dart';
import 'package:wavify/features/upload/domain/usecases/get_my_songs_usecase.dart';
import 'package:wavify/features/upload/domain/usecases/update_song_usecase.dart';
import 'package:wavify/features/upload/domain/usecases/upload_song_usecase.dart';
import 'package:wavify/features/upload/presentation/bloc/upload_bloc.dart';
import 'package:wavify/features/upload/presentation/bloc/upload_state.dart';
import 'package:wavify/features/upload/presentation/pages/upload_music_page.dart';
import 'package:wavify/features/upload/presentation/widgets/edit_song_dialog.dart';

class _StubAuthRepo implements AuthRepository {
  @override
  Future<UserEntity?> getCurrentUser() async => null;
  @override
  Future<bool> isAuthenticated() async => false;
  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async => AuthTokens.empty;
  @override
  Future<void> logout() async {}
  @override
  Future<AuthTokens> refreshToken() async => AuthTokens.empty;
  @override
  Future<AuthTokens> register({
    required String fullName,
    required String email,
    required String password,
  }) async => AuthTokens.empty;
}

class _StubHomeRepo implements HomeRepository {
  @override
  Future<List<home.SongEntity>> getAllSongs({
    int page = 0,
    int size = 50,
  }) async => _sampleHomeSongs;
}

class _StubPlaylistRepo implements PlaylistRepository {
  @override
  Future<PlaylistEntity> addSongToPlaylist({
    required String playlistId,
    required String songId,
  }) async => _samplePlaylist;
  @override
  Future<PlaylistEntity> addSongsToPlaylist({
    required String playlistId,
    required List<String> songIds,
  }) async => _samplePlaylist;
  @override
  Future<PlaylistEntity> createPlaylist({
    required String name,
    String? description,
    String? coverUrl,
    String visibility = 'PUBLIC',
  }) async => _samplePlaylist;
  @override
  Future<void> deletePlaylist(String playlistId) async {}
  @override
  Future<List<pl.SongEntity>> getAllSongs({
    int page = 0,
    int size = 50,
  }) async => _samplePlaylistSongs;
  @override
  Future<List<PlaylistEntity>> getMyPlaylists() async => [_samplePlaylist];
  @override
  Future<List<PlaylistEntity>> searchPublicPlaylists({
    String? keyword,
    int page = 0,
    int size = 20,
  }) async => [_samplePlaylist];
  @override
  Future<PlaylistEntity> getPlaylistById(String playlistId) async =>
      _samplePlaylist;
  @override
  Future<PlaylistEntity> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  }) async => _samplePlaylist;
  @override
  Future<PlaylistEntity> reorderPlaylistSongs({
    required String playlistId,
    required List<String> songIds,
  }) async => _samplePlaylist;
  @override
  Future<PlaylistEntity> updatePlaylist({
    required String playlistId,
    required String name,
    String? description,
    String? coverUrl,
    String? visibility,
  }) async => _samplePlaylist;
}

class _StubHistoryRepo implements HistoryRepository {
  @override
  Future<void> clearHistory() async {}
  @override
  Future<void> deleteHistoryItem(String historyId) async {}
  @override
  Future<List<HistoryEntity>> getHistory({int page = 0, int size = 20}) async =>
      _sampleHistory;
  @override
  Future<void> recordHistory(String songId) async {}
}

class _StubProfileRepo implements ProfileRepository {
  @override
  Future<UserProfileEntity> getProfile() async => _sampleProfile;
  @override
  Future<void> logout() async {}
  @override
  Future<UserProfileEntity> updateProfile({
    required String userId,
    String? username,
    String? email,
    String? password,
  }) async => _sampleProfile;
}

class _StubSongRepo implements SongRepository {
  @override
  Future<void> deleteSong(String songId) async {}
  @override
  Future<List<up.SongEntity>> getMySongs() async => _sampleUploadSongs;
  @override
  Future<up.SongEntity> updateSong({
    required String songId,
    required String title,
    required String artist,
    String? album,
    required String visibility,
  }) async => _sampleUploadSongs.first;
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
  }) async => _sampleUploadSongs.first;
}

class _StubAudioService implements AudioPlayerService {
  final _statusCtrl = StreamController<AudioPlayerStatus>.broadcast();
  final _posCtrl = StreamController<Duration>.broadcast();
  final _durCtrl = StreamController<Duration>.broadcast();
  final _compCtrl = StreamController<void>.broadcast();
  @override
  Stream<AudioPlayerStatus> get statusStream => _statusCtrl.stream;
  @override
  Stream<Duration> get positionStream => _posCtrl.stream;
  @override
  Stream<Duration> get durationStream => _durCtrl.stream;
  @override
  Stream<void> get completeStream => _compCtrl.stream;
  @override
  AudioPlayerStatus get currentStatus => AudioPlayerStatus.paused;
  @override
  Duration get currentPosition => const Duration(seconds: 42);
  @override
  Duration get currentDuration => const Duration(minutes: 3, seconds: 15);
  @override
  Future<void> play(String? url, {Duration? fallbackDuration}) async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> resume() async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> seek(Duration position) async {}
  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> dispose() async {
    await _statusCtrl.close();
    await _posCtrl.close();
    await _durCtrl.close();
    await _compCtrl.close();
  }
}

const _sampleHomeSongs = [
  home.SongEntity(
    id: 's1',
    title: 'Midnight Serenade With A Very Long Title To Test Overflow',
    artist: 'Acoustic Dreams Featuring Guest',
    album: 'Nightfall Deluxe',
    durationSec: 210,
    fileUrl: 'https://example.com/1.mp3',
    coverUrl: null,
  ),
  home.SongEntity(
    id: 's2',
    title: 'Neon Skyline',
    artist: 'Synthwave Boy',
    album: 'Retro 80s',
    durationSec: 185,
    fileUrl: 'https://example.com/2.mp3',
    coverUrl: null,
  ),
];

const _samplePlaylistSongs = [
  pl.SongEntity(
    id: 's1',
    title: 'Midnight Serenade',
    artist: 'Acoustic Dreams',
    album: 'Nightfall',
    durationSec: 210,
    fileUrl: 'https://example.com/1.mp3',
    coverUrl: null,
  ),
  pl.SongEntity(
    id: 's2',
    title: 'Neon Skyline',
    artist: 'Synthwave Boy',
    album: 'Retro 80s',
    durationSec: 185,
    fileUrl: 'https://example.com/2.mp3',
    coverUrl: null,
  ),
];

const _samplePlaylist = PlaylistEntity(
  id: 'pl-1',
  name: 'Late Night Minimalist Focus Mix',
  description: 'Curated calm instrumental beats for deep work',
  visibility: 'PUBLIC',
  songCount: 2,
  songs: _samplePlaylistSongs,
);

const _sampleUploadSongs = [
  up.SongEntity(
    id: 'u1',
    title: 'Echoes of Dawn',
    artist: 'Sarwar Jahan',
    album: 'Golden Sky',
    durationSec: 215,
    fileUrl: 'https://example.com/u1.mp3',
    coverUrl: null,
    visibility: 'PUBLIC',
  ),
];

const _sampleProfile = UserProfileEntity(
  id: 'user-1',
  username: 'alex_minimal',
  email: 'alex@wavify.app',
  role: 'USER',
);

final _sampleHistory = [
  HistoryEntity(
    id: 'h1',
    song: const HistorySongEntity(
      id: 's1',
      title: 'Midnight City',
      artist: 'M83',
      duration: Duration(seconds: 243),
      fileUrl: 'https://example.com/1.mp3',
    ),
    playedAt: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
];

const _matrixSizes = <Size>[
  Size(320, 568),
  Size(360, 800),
  Size(411, 891),
  Size(768, 1024),
  Size(1024, 768),
];

const _matrixScales = <double>[1.0, 1.5, 2.0];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthBloc authBloc;
  late HomeBloc homeBloc;
  late PlayerBloc playerBloc;
  late PlaylistBloc playlistBloc;
  late HistoryBloc historyBloc;
  late ProfileBloc profileBloc;
  late UploadBloc uploadBloc;
  late LocaleBloc localeBloc;

  setUp(() async {
    await sl.reset();

    final authRepo = _StubAuthRepo();
    authBloc = AuthBloc(
      loginUseCase: LoginUseCase(authRepo),
      registerUseCase: RegisterUseCase(authRepo),
      logoutUseCase: LogoutUseCase(authRepo),
      checkAuthStatusUseCase: CheckAuthStatusUseCase(authRepo),
      authRepository: authRepo,
    );

    final homeRepo = _StubHomeRepo();
    homeBloc = HomeBloc(getAllSongsUseCase: GetAllSongsUseCase(homeRepo))
      ..emit(
        HomeLoaded(allSongs: _sampleHomeSongs, filteredSongs: _sampleHomeSongs),
      );

    playerBloc = PlayerBloc(audioPlayerService: _StubAudioService());
    playerBloc.emit(
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
        currentPosition: Duration(seconds: 45),
      ),
    );
    sl.registerSingleton<PlayerBloc>(playerBloc);
    sl.registerSingleton<PlaybackBridge>(playerBloc);

    final plRepo = _StubPlaylistRepo();
    playlistBloc =
        PlaylistBloc(
          getMyPlaylistsUseCase: GetMyPlaylistsUseCase(plRepo),
          getPlaylistDetailUseCase: GetPlaylistDetailUseCase(plRepo),
          createPlaylistUseCase: CreatePlaylistUseCase(plRepo),
          updatePlaylistUseCase: UpdatePlaylistUseCase(plRepo),
          deletePlaylistUseCase: DeletePlaylistUseCase(plRepo),
          addSongToPlaylistUseCase: AddSongToPlaylistUseCase(plRepo),
          addSongsToPlaylistUseCase: AddSongsToPlaylistUseCase(plRepo),
          removeSongFromPlaylistUseCase: RemoveSongFromPlaylistUseCase(plRepo),
          reorderPlaylistSongsUseCase: ReorderPlaylistSongsUseCase(plRepo),
        )..emit(
          const PlaylistState(
            playlists: [_samplePlaylist],
            selectedPlaylist: _samplePlaylist,
            status: PlaylistStatus.loaded,
          ),
        );

    final histRepo = _StubHistoryRepo();
    historyBloc = HistoryBloc(
      getHistoryUseCase: GetHistoryUseCase(histRepo),
      recordHistoryUseCase: RecordHistoryUseCase(histRepo),
      clearHistoryUseCase: ClearHistoryUseCase(histRepo),
      deleteHistoryItemUseCase: DeleteHistoryItemUseCase(histRepo),
    )..emit(HistoryLoaded(_sampleHistory));

    final profRepo = _StubProfileRepo();
    profileBloc = ProfileBloc(
      getProfileUseCase: GetProfileUseCase(profRepo),
      updateProfileUseCase: UpdateProfileUseCase(profRepo),
      profileRepository: profRepo,
    )..emit(const ProfileLoaded(_sampleProfile));

    final songRepo = _StubSongRepo();
    uploadBloc = UploadBloc(
      uploadSongUseCase: UploadSongUseCase(songRepo),
      updateSongUseCase: UpdateSongUseCase(songRepo),
      deleteSongUseCase: DeleteSongUseCase(songRepo),
      getMySongsUseCase: GetMySongsUseCase(songRepo),
    )..emit(const MySongsLoaded(_sampleUploadSongs));

    localeBloc = LocaleBloc();
  });

  tearDown(() async {
    await authBloc.close();
    await homeBloc.close();
    await playerBloc.close();
    await playlistBloc.close();
    await historyBloc.close();
    await profileBloc.close();
    await uploadBloc.close();
    await localeBloc.close();
    await sl.reset();
  });

  Widget wrapApp(
    Widget child, {
    required ThemeData theme,
    double textScale = 1.0,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<HomeBloc>.value(value: homeBloc),
        BlocProvider<PlayerBloc>.value(value: playerBloc),
        BlocProvider<PlaylistBloc>.value(value: playlistBloc),
        BlocProvider<HistoryBloc>.value(value: historyBloc),
        BlocProvider<ProfileBloc>.value(value: profileBloc),
        BlocProvider<UploadBloc>.value(value: uploadBloc),
        BlocProvider<LocaleBloc>.value(value: localeBloc),
      ],
      child: MaterialApp(
        theme: theme,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, widget) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: widget!,
          );
        },
        home: child,
      ),
    );
  }

  Future<void> pumpAndVerifyNoErrors(
    WidgetTester tester, {
    required Size size,
    required ThemeData theme,
    required double textScale,
    required Widget page,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final errors = <FlutterErrorDetails>[];
    final prevOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      errors.add(details);
    };
    try {
      await tester.pumpWidget(
        wrapApp(page, theme: theme, textScale: textScale),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    } finally {
      FlutterError.onError = prevOnError;
    }

    expect(
      errors,
      isEmpty,
      reason:
          'Unexpected FlutterErrors at $size, scale=$textScale, brightness=${theme.brightness}: '
          '${errors.map((e) => e.exceptionAsString()).join('\n')}',
    );
  }

  Future<void> checkAccessibility(
    WidgetTester tester, {
    required ThemeData theme,
    required Widget page,
  }) async {
    tester.view.physicalSize = const Size(411, 891);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(wrapApp(page, theme: theme));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    } finally {
      handle.dispose();
    }
  }

  group('Phase 4 Responsive Matrix: Sizes x TextScales x Themes', () {
    final screens = <String, Widget Function()>{
      'SignInPage': () => const SignInPage(),
      'SignUpPage': () => const SignUpPage(),
      'HomePage': () => const HomePage(),
      'ListenPage': () => const ListenPage(),
      'FavouritePage': () => const FavouritePage(),
      'AllFavoritesPage': () => const AllFavoritesPage(),
      'PlaylistDetailPage': () => const PlaylistDetailPage(playlistId: 'pl-1'),
      'UploadMusicPage': () => const UploadMusicPage(),
      'ProfilePage': () => const ProfilePage(),
      'HistoryPage': () => const HistoryPage(),
      'CreateEditPlaylistDialog': () =>
          const Scaffold(body: CreateEditPlaylistDialog()),
      'EditSongDialog': () =>
          Scaffold(body: EditSongDialog(song: _sampleUploadSongs.first)),
      'EditProfileBottomSheet': () =>
          const Scaffold(body: EditProfileBottomSheet(profile: _sampleProfile)),
      'AddMultipleSongsBottomSheet': () => Scaffold(
        body: AddMultipleSongsBottomSheet(
          playlist: _samplePlaylist,
          availableSongs: const [
            pl.SongEntity(
              id: 's3',
              title: 'Extra Track',
              artist: 'Artist 3',
              fileUrl: 'https://example.com/3.mp3',
              durationSec: 160,
            ),
          ],
        ),
      ),
    };

    for (final entry in screens.entries) {
      testWidgets(
        '${entry.key} renders cleanly across 5 sizes x 3 scales x 2 themes',
        (tester) async {
          for (final theme in [AppTheme.darkTheme, AppTheme.lightTheme]) {
            for (final size in _matrixSizes) {
              for (final scale in _matrixScales) {
                await pumpAndVerifyNoErrors(
                  tester,
                  size: size,
                  theme: theme,
                  textScale: scale,
                  page: entry.value(),
                );
              }
            }
          }
        },
      );
    }

    testWidgets(
      'AppScaffoldWithNavBar renders cleanly at 320x568 & scale 2.0 in both themes',
      (tester) async {
        final router = GoRouter(
          initialLocation: '/home',
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (_, _, shell) =>
                  AppScaffoldWithNavBar(navigationShell: shell),
              branches: [
                StatefulShellBranch(
                  routes: [
                    GoRoute(path: '/home', builder: (_, _) => const HomePage()),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/favourite',
                      builder: (_, _) => const FavouritePage(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/listen',
                      builder: (_, _) => const ListenPage(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/upload',
                      builder: (_, _) => const UploadMusicPage(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/profile',
                      builder: (_, _) => const ProfilePage(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        for (final theme in [AppTheme.darkTheme, AppTheme.lightTheme]) {
          for (final size in [const Size(320, 568), const Size(1024, 768)]) {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1.0;
            addTearDown(() {
              tester.view.resetPhysicalSize();
              tester.view.resetDevicePixelRatio();
            });

            await tester.pumpWidget(
              MultiBlocProvider(
                providers: [
                  BlocProvider<AuthBloc>.value(value: authBloc),
                  BlocProvider<HomeBloc>.value(value: homeBloc),
                  BlocProvider<PlayerBloc>.value(value: playerBloc),
                  BlocProvider<PlaylistBloc>.value(value: playlistBloc),
                  BlocProvider<HistoryBloc>.value(value: historyBloc),
                  BlocProvider<ProfileBloc>.value(value: profileBloc),
                  BlocProvider<UploadBloc>.value(value: uploadBloc),
                  BlocProvider<LocaleBloc>.value(value: localeBloc),
                ],
                child: MaterialApp.router(
                  theme: theme,
                  routerConfig: router,
                  locale: const Locale('en'),
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  builder: (context, widget) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: const TextScaler.linear(2.0)),
                    child: widget!,
                  ),
                ),
              ),
            );
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 50));
            expect(tester.takeException(), isNull);
          }
        }
      },
    );
  });

  group('Phase 4 Accessibility Guidelines (Light & Dark)', () {
    final a11yScreens = <String, Widget Function()>{
      'SignInPage': () => const SignInPage(),
      'SignUpPage': () => const SignUpPage(),
      'HomePage': () => const HomePage(),
      'ListenPage': () => const ListenPage(),
      'FavouritePage': () => const FavouritePage(),
      'AllFavoritesPage': () => const AllFavoritesPage(),
      'PlaylistDetailPage': () => const PlaylistDetailPage(playlistId: 'pl-1'),
      'UploadMusicPage': () => const UploadMusicPage(),
      'ProfilePage': () => const ProfilePage(),
      'HistoryPage': () => const HistoryPage(),
    };

    for (final entry in a11yScreens.entries) {
      testWidgets(
        '${entry.key} passes TapTarget, LabeledTapTarget, Contrast in Dark mode',
        (tester) async {
          await checkAccessibility(
            tester,
            theme: AppTheme.darkTheme,
            page: entry.value(),
          );
        },
      );

      testWidgets(
        '${entry.key} passes TapTarget, LabeledTapTarget, Contrast in Light mode',
        (tester) async {
          await checkAccessibility(
            tester,
            theme: AppTheme.lightTheme,
            page: entry.value(),
          );
        },
      );
    }
  });

  group('Phase 4 States Verification (Loading / Empty / Error)', () {
    testWidgets(
      'HomePage displays Loading, Error (with Retry), and Empty states cleanly',
      (tester) async {
        homeBloc.emit(const HomeLoading());
        await tester.pumpWidget(
          wrapApp(const HomePage(), theme: AppTheme.darkTheme),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);

        homeBloc.emit(const HomeFailure('Network timeout'));
        await tester.pump();
        expect(find.text('Try again'), findsOneWidget);

        homeBloc.emit(const HomeLoaded(allSongs: [], filteredSongs: []));
        await tester.pump();
        expect(find.text('Upload music now'), findsOneWidget);
      },
    );

    testWidgets('ListenPage displays Empty state cleanly', (tester) async {
      playerBloc.emit(const PlayerState());
      await tester.pumpWidget(
        wrapApp(const ListenPage(), theme: AppTheme.lightTheme),
      );
      await tester.pump();
      expect(find.text('No song selected'), findsOneWidget);
      expect(find.text('Explore Songs'), findsOneWidget);
    });

    testWidgets(
      'HistoryPage displays Loading, Error, and Empty states cleanly',
      (tester) async {
        historyBloc.emit(const HistoryLoading());
        await tester.pumpWidget(
          wrapApp(const HistoryPage(), theme: AppTheme.darkTheme),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);

        historyBloc.emit(const HistoryFailure('Failed'));
        await tester.pump();
        expect(find.text('Try again'), findsOneWidget);

        historyBloc.emit(const HistoryLoaded([]));
        await tester.pump();
        expect(find.text('No playback history yet'), findsOneWidget);
      },
    );

    testWidgets('ProfilePage displays Loading and Error states cleanly', (
      tester,
    ) async {
      profileBloc.emit(const ProfileLoading());
      await tester.pumpWidget(
        wrapApp(const ProfilePage(), theme: AppTheme.darkTheme),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      profileBloc.emit(const ProfileFailure('Profile error'));
      await tester.pump();
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets(
      'SignInPage and SignUpPage header images span full viewport width',
      (tester) async {
        tester.view.physicalSize = const Size(411, 891);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        for (final page in const [SignInPage(), SignUpPage()]) {
          await tester.pumpWidget(wrapApp(page, theme: AppTheme.lightTheme));
          await tester.pump();

          final imageBox = tester.renderObject<RenderBox>(find.byType(Image));
          expect(imageBox.size.width, 411.0);
        }
      },
    );
  });
}

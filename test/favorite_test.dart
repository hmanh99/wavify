import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavify/core/l10n/app_l10n.dart';
import 'package:wavify/core/theme/app_theme.dart';
import 'package:wavify/features/auth/domain/entities/auth_tokens.dart';
import 'package:wavify/features/auth/domain/entities/user_entity.dart';
import 'package:wavify/features/auth/domain/repositories/auth_repository.dart';
import 'package:wavify/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:wavify/features/auth/domain/usecases/login_usecase.dart';
import 'package:wavify/features/auth/domain/usecases/logout_usecase.dart';
import 'package:wavify/features/auth/domain/usecases/register_usecase.dart';
import 'package:wavify/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wavify/features/auth/presentation/bloc/auth_state.dart';
import 'package:wavify/features/favorite/data/datasources/favorite_remote_data_source.dart';
import 'package:wavify/features/favorite/domain/entities/favorite_playlist_item.dart';
import 'package:wavify/features/favorite/domain/entities/favorite_song_item.dart';
import 'package:wavify/features/favorite/domain/repositories/favorite_repository.dart';
import 'package:wavify/features/favorite/domain/usecases/add_favorite_playlist_usecase.dart';
import 'package:wavify/features/favorite/domain/usecases/add_favorite_song_usecase.dart';
import 'package:wavify/features/favorite/domain/usecases/check_favorite_playlists_usecase.dart';
import 'package:wavify/features/favorite/domain/usecases/check_favorite_songs_usecase.dart';
import 'package:wavify/features/favorite/domain/usecases/get_favorite_playlists_usecase.dart';
import 'package:wavify/features/favorite/domain/usecases/get_favorite_songs_usecase.dart';
import 'package:wavify/features/favorite/domain/usecases/remove_favorite_playlist_usecase.dart';
import 'package:wavify/features/favorite/domain/usecases/remove_favorite_song_usecase.dart';
import 'package:wavify/features/favorite/presentation/bloc/favorite_bloc.dart';
import 'package:wavify/features/favorite/presentation/bloc/favorite_event.dart';
import 'package:wavify/features/favorite/presentation/bloc/favorite_state.dart';
import 'package:wavify/features/favorite/data/datasources/playlist_remote_data_source.dart';
import 'package:wavify/features/favorite/domain/entities/playlist_entity.dart';
import 'package:wavify/features/favorite/domain/entities/song_entity.dart';
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

import 'playlist_test.dart';

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

class _FakeFavoriteRepository implements FavoriteRepository {
  final List<FavoriteSongItem> songs = [
    FavoriteSongItem(
      song: const SongEntity(
        id: 'song-1',
        title: 'Midnight Echo',
        artist: 'Luna Ray',
        album: 'Starlight',
        durationSec: 215,
        fileUrl: 'https://example.com/1.mp3',
      ),
      favoritedAt: DateTime.utc(2026, 11, 20),
    ),
  ];

  final List<FavoritePlaylistItem> playlists = [
    FavoritePlaylistItem(
      playlist: const PlaylistEntity(
        id: 'pl-fav-1',
        name: 'Late Night Coding',
        ownerId: 'owner-2',
        ownerName: 'alex_dev',
        visibility: 'PUBLIC',
      ),
      favoritedAt: DateTime.utc(2026, 11, 20),
    ),
  ];

  bool throwOnMutate = false;

  @override
  Future<List<FavoriteSongItem>> getFavoriteSongs({
    int page = 0,
    int size = 50,
  }) async => List.of(songs);

  @override
  Future<FavoriteSongItem> addFavoriteSong(String songId) async {
    if (throwOnMutate) {
      throw const FavoriteApiException('Server error', statusCode: 500);
    }
    final item = FavoriteSongItem(
      song: SongEntity(
        id: songId,
        title: 'Added Song $songId',
        artist: 'New Artist',
        fileUrl: 'https://example.com/$songId.mp3',
        durationSec: 180,
      ),
      favoritedAt: DateTime.utc(2026, 11, 23),
    );
    songs.removeWhere((e) => e.song.id == songId);
    songs.insert(0, item);
    return item;
  }

  @override
  Future<void> removeFavoriteSong(String songId) async {
    if (throwOnMutate) {
      throw const FavoriteApiException('Server error', statusCode: 500);
    }
    songs.removeWhere((e) => e.song.id == songId);
  }

  @override
  Future<bool> checkFavoriteSong(String songId) async =>
      songs.any((e) => e.song.id == songId);

  @override
  Future<Map<String, bool>> checkFavoriteSongs(List<String> songIds) async => {
    for (final id in songIds) id: songs.any((e) => e.song.id == id),
  };

  @override
  Future<List<FavoritePlaylistItem>> getFavoritePlaylists({
    int page = 0,
    int size = 50,
  }) async => List.of(playlists);

  @override
  Future<FavoritePlaylistItem> addFavoritePlaylist(String playlistId) async {
    if (throwOnMutate) {
      throw const FavoriteApiException('Server error', statusCode: 500);
    }
    final item = FavoritePlaylistItem(
      playlist: PlaylistEntity(
        id: playlistId,
        name: 'Playlist $playlistId',
        ownerName: 'creator',
        visibility: 'PUBLIC',
      ),
      favoritedAt: DateTime.utc(2026, 11, 23),
    );
    playlists.removeWhere((e) => e.playlist.id == playlistId);
    playlists.insert(0, item);
    return item;
  }

  @override
  Future<void> removeFavoritePlaylist(String playlistId) async {
    if (throwOnMutate) {
      throw const FavoriteApiException('Server error', statusCode: 500);
    }
    playlists.removeWhere((e) => e.playlist.id == playlistId);
  }

  @override
  Future<bool> checkFavoritePlaylist(String playlistId) async =>
      playlists.any((e) => e.playlist.id == playlistId);

  @override
  Future<Map<String, bool>> checkFavoritePlaylists(
    List<String> playlistIds,
  ) async => {
    for (final id in playlistIds) id: playlists.any((e) => e.playlist.id == id),
  };
}

FavoriteBloc _buildFavoriteBloc(
  _FakeFavoriteRepository repo, {
  void Function(Set<String>)? onSongFavoritesChanged,
}) {
  return FavoriteBloc(
    getFavoriteSongsUseCase: GetFavoriteSongsUseCase(repo),
    addFavoriteSongUseCase: AddFavoriteSongUseCase(repo),
    removeFavoriteSongUseCase: RemoveFavoriteSongUseCase(repo),
    checkFavoriteSongsUseCase: CheckFavoriteSongsUseCase(repo),
    getFavoritePlaylistsUseCase: GetFavoritePlaylistsUseCase(repo),
    addFavoritePlaylistUseCase: AddFavoritePlaylistUseCase(repo),
    removeFavoritePlaylistUseCase: RemoveFavoritePlaylistUseCase(repo),
    checkFavoritePlaylistsUseCase: CheckFavoritePlaylistsUseCase(repo),
    onSongFavoritesChanged: onSongFavoritesChanged,
  );
}

PlaylistBloc _buildPlaylistBloc(FakePlaylistRepository repo) {
  return PlaylistBloc(
    getMyPlaylistsUseCase: GetMyPlaylistsUseCase(repo),
    getPlaylistDetailUseCase: GetPlaylistDetailUseCase(repo),
    createPlaylistUseCase: CreatePlaylistUseCase(repo),
    updatePlaylistUseCase: UpdatePlaylistUseCase(repo),
    deletePlaylistUseCase: DeletePlaylistUseCase(repo),
    addSongToPlaylistUseCase: AddSongToPlaylistUseCase(repo),
    addSongsToPlaylistUseCase: AddSongsToPlaylistUseCase(repo),
    removeSongFromPlaylistUseCase: RemoveSongFromPlaylistUseCase(repo),
    reorderPlaylistSongsUseCase: ReorderPlaylistSongsUseCase(repo),
  );
}

void main() {
  group('FavoriteRemoteDataSourceImpl API Contract Tests', () {
    test('getFavoriteSongs parses ApiResponse<Page<FavoriteSongResponse>>', () async {
      final dio = Dio();
      String? capturedPath;
      Map<String, dynamic>? capturedQuery;

      dio.httpClientAdapter = MockHttpAdapter((options) async {
        capturedPath = options.path;
        capturedQuery = options.queryParameters;
        return ResponseBody.fromString(
          jsonEncode({
            'code': 200,
            'message': 'Get favorite songs successful',
            'result': {
              'content': [
                {
                  'song': {
                    'id': 'song-uuid-1',
                    'title': 'Ocean Eyes',
                    'artist': 'Wave',
                    'album': 'Blue',
                    'durationSec': 200,
                    'fileUrl': 'https://cdn.example.com/ocean.mp3',
                    'coverUrl': 'https://cdn.example.com/ocean.jpg',
                    'visibility': 'PUBLIC',
                    'status': 'READY',
                  },
                  'favoritedAt': '2026-11-23T09:00:00Z',
                },
              ],
              'totalElements': 1,
              'totalPages': 1,
            },
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final ds = FavoriteRemoteDataSourceImpl(dio: dio);
      final items = await ds.getFavoriteSongs(page: 0, size: 50);

      expect(capturedPath, '/api/v1/favorites/songs');
      expect(capturedQuery?['page'], 0);
      expect(capturedQuery?['size'], 50);
      expect(items.length, 1);
      expect(items.first.song.id, 'song-uuid-1');
      expect(items.first.song.title, 'Ocean Eyes');
      expect(items.first.favoritedAt, DateTime.utc(2026, 11, 23, 9));
    });

    test('getFavoritePlaylists parses ApiResponse<Page<FavoritePlaylistResponse>> with owner', () async {
      final dio = Dio();
      String? capturedPath;

      dio.httpClientAdapter = MockHttpAdapter((options) async {
        capturedPath = options.path;
        return ResponseBody.fromString(
          jsonEncode({
            'code': 200,
            'message': 'Get favorite playlists successful',
            'result': {
              'content': [
                {
                  'playlist': {
                    'id': 'pl-uuid-1',
                    'owner': {
                      'id': 'user-uuid-9',
                      'username': 'melody_maker',
                      'email': 'melody@example.com',
                      'role': 'USER',
                    },
                    'name': 'Study Beats',
                    'visibility': 'PUBLIC',
                    'createdAt': '2026-11-20T08:00:00Z',
                    'songs': null,
                  },
                  'favoritedAt': '2026-11-23T09:15:00Z',
                },
              ],
            },
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final ds = FavoriteRemoteDataSourceImpl(dio: dio);
      final items = await ds.getFavoritePlaylists();

      expect(capturedPath, '/api/v1/favorites/playlists');
      expect(items.length, 1);
      expect(items.first.playlist.id, 'pl-uuid-1');
      expect(items.first.playlist.name, 'Study Beats');
      expect(items.first.playlist.ownerId, 'user-uuid-9');
      expect(items.first.playlist.ownerName, 'melody_maker');
      expect(items.first.favoritedAt, DateTime.utc(2026, 11, 23, 9, 15));
    });

    test('checkFavoriteSongs chunks >100 IDs to satisfy backend @Size(max = 100)', () async {
      final dio = Dio();
      final requests = <List<dynamic>>[];

      dio.httpClientAdapter = MockHttpAdapter((options) async {
        expect(options.path, '/api/v1/favorites/songs/check');
        final ids = (options.data as Map<String, dynamic>)['ids'] as List<dynamic>;
        requests.add(ids);
        return ResponseBody.fromString(
          jsonEncode({
            'code': 200,
            'result': {for (final id in ids) id.toString(): id == 'id-5'},
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final ds = FavoriteRemoteDataSourceImpl(dio: dio);
      final allIds = List.generate(125, (i) => 'id-$i');
      final result = await ds.checkFavoriteSongs(allIds);

      expect(requests.length, 2);
      expect(requests[0].length, 100);
      expect(requests[1].length, 25);
      expect(result['id-5'], isTrue);
      expect(result['id-6'], isFalse);
    });

    test('PlaylistRemoteDataSourceImpl.searchPublicPlaylists calls /api/v1/playlists/search', () async {
      final dio = Dio();
      String? capturedPath;
      Map<String, dynamic>? capturedQuery;

      dio.httpClientAdapter = MockHttpAdapter((options) async {
        capturedPath = options.path;
        capturedQuery = options.queryParameters;
        return ResponseBody.fromString(
          jsonEncode({
            'code': 200,
            'result': {
              'content': [
                {
                  'id': 'pub-pl-1',
                  'owner': {'id': 'u-99', 'username': 'dj_zen'},
                  'name': 'Zen Acoustic',
                  'visibility': 'PUBLIC',
                },
              ],
            },
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final ds = PlaylistRemoteDataSourceImpl(dio: dio);
      final results = await ds.searchPublicPlaylists(keyword: 'Zen');

      expect(capturedPath, '/api/v1/playlists/search');
      expect(capturedQuery?['keyword'], 'Zen');
      expect(results.length, 1);
      expect(results.first.ownerId, 'u-99');
      expect(results.first.ownerName, 'dj_zen');
    });
  });

  group('FavoriteBloc Tests', () {
    test('LoadFavoritesRequested populates songs, playlists, and notifies songIds', () async {
      final repo = _FakeFavoriteRepository();
      Set<String>? syncedIds;
      final bloc = _buildFavoriteBloc(
        repo,
        onSongFavoritesChanged: (ids) => syncedIds = ids,
      );
      addTearDown(bloc.close);

      bloc.add(const LoadFavoritesRequested());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<FavoriteState>((s) => s.isLoading),
          predicate<FavoriteState>(
            (s) =>
                s.status == FavoriteStatus.loaded &&
                s.favoriteSongs.length == 1 &&
                s.favoritePlaylists.length == 1 &&
                s.isSongFavorite('song-1') &&
                s.isPlaylistFavorite('pl-fav-1'),
          ),
        ]),
      );
      expect(syncedIds, {'song-1'});
    });

    test('ToggleFavoriteSongRequested adds/removes and rolls back on failure', () async {
      final repo = _FakeFavoriteRepository();
      final bloc = _buildFavoriteBloc(repo);
      addTearDown(bloc.close);

      bloc.add(const LoadFavoritesRequested());
      await pumpEventQueue();

      // Remove existing favorite
      bloc.add(const ToggleFavoriteSongRequested(songId: 'song-1'));
      await pumpEventQueue();
      expect(bloc.state.isSongFavorite('song-1'), isFalse);
      expect(repo.songs, isEmpty);

      // Re-add favorite
      bloc.add(
        const ToggleFavoriteSongRequested(
          songId: 'song-2',
          song: SongEntity(
            id: 'song-2',
            title: 'Added Song song-2',
            artist: 'New Artist',
            fileUrl: 'https://example.com/song-2.mp3',
          ),
        ),
      );
      await pumpEventQueue();
      expect(bloc.state.isSongFavorite('song-2'), isTrue);
      expect(repo.songs.length, 1);

      // Failure triggers rollback
      repo.throwOnMutate = true;
      bloc.add(const ToggleFavoriteSongRequested(songId: 'song-2'));
      await pumpEventQueue();
      expect(bloc.state.isSongFavorite('song-2'), isTrue);
      expect(bloc.state.favoriteSongs.length, 1);
    });

    test('ToggleFavoritePlaylistRequested adds/removes and rolls back on failure', () async {
      final repo = _FakeFavoriteRepository();
      final bloc = _buildFavoriteBloc(repo);
      addTearDown(bloc.close);

      bloc.add(const LoadFavoritesRequested());
      await pumpEventQueue();

      // Remove existing favorite playlist
      bloc.add(const ToggleFavoritePlaylistRequested(playlistId: 'pl-fav-1'));
      await pumpEventQueue();
      expect(bloc.state.isPlaylistFavorite('pl-fav-1'), isFalse);
      expect(repo.playlists, isEmpty);

      // Add new favorite playlist
      bloc.add(
        const ToggleFavoritePlaylistRequested(
          playlistId: 'pl-fav-2',
          playlist: PlaylistEntity(
            id: 'pl-fav-2',
            name: 'Playlist pl-fav-2',
          ),
        ),
      );
      await pumpEventQueue();
      expect(bloc.state.isPlaylistFavorite('pl-fav-2'), isTrue);

      // Failure triggers rollback
      repo.throwOnMutate = true;
      bloc.add(const ToggleFavoritePlaylistRequested(playlistId: 'pl-fav-2'));
      await pumpEventQueue();
      expect(bloc.state.isPlaylistFavorite('pl-fav-2'), isTrue);
    });
  });

  group('Favorite UI Integration Tests', () {
    testWidgets('FavouritePage renders real favorite songs/playlists without fallback mock data', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final favRepo = _FakeFavoriteRepository();
      final favBloc = _buildFavoriteBloc(favRepo);
      final plRepo = FakePlaylistRepository();
      final plBloc = _buildPlaylistBloc(plRepo);
      addTearDown(() async {
        await favBloc.close();
        await plBloc.close();
      });

      favBloc.add(const LoadFavoritesRequested());

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<FavoriteBloc>.value(value: favBloc),
            BlocProvider<PlaylistBloc>.value(value: plBloc),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const FavouritePage(),
          ),
        ),
      );
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pumpAndSettle();

      // Real favorite artist, favorite playlist, and favorite song appear
      expect(find.text('Luna Ray'), findsWidgets);
      expect(find.text('Late Night Coding'), findsOneWidget);
      expect(find.text('Midnight Echo'), findsOneWidget);

      // Tap heart icon on favorite song to unfavorite
      await tester.tap(find.byTooltip('Remove from favorites').last);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pumpAndSettle();

      // Empty state shows directly with ZERO fallback to other server songs
      expect(find.text('Midnight Echo'), findsNothing);
      expect(find.text('No songs yet'), findsOneWidget);
    });

    testWidgets('PlaylistDetailPage shows favorite toggles and hides owner actions for non-owners', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final favRepo = _FakeFavoriteRepository();
      final favBloc = _buildFavoriteBloc(favRepo);
      final plRepo = FakePlaylistRepository();
      plRepo.playlists = [
        const PlaylistEntity(
          id: 'pl-other',
          name: 'Other User Mix',
          ownerId: 'owner-999',
          ownerName: 'someone_else',
          visibility: 'PUBLIC',
          songCount: 1,
          songs: [
            SongEntity(
              id: 'song-1',
              title: 'Midnight Echo',
              artist: 'Luna Ray',
              fileUrl: 'https://example.com/1.mp3',
              durationSec: 215,
            ),
          ],
        ),
      ];
      final plBloc = _buildPlaylistBloc(plRepo);
      plBloc.emit(
        PlaylistState(
          playlists: plRepo.playlists,
          selectedPlaylist: plRepo.playlists.first,
          status: PlaylistStatus.loaded,
        ),
      );

      final stubAuthRepo = _StubAuthRepo();
      final authBloc = AuthBloc(
        loginUseCase: LoginUseCase(stubAuthRepo),
        registerUseCase: RegisterUseCase(stubAuthRepo),
        logoutUseCase: LogoutUseCase(stubAuthRepo),
        checkAuthStatusUseCase: CheckAuthStatusUseCase(stubAuthRepo),
        authRepository: stubAuthRepo,
      )..emit(
          const AuthAuthenticated(
            tokens: AuthTokens.empty,
            user: UserEntity(
              id: 'current-user-1',
              email: 'me@wavify.app',
              fullName: 'Me',
            ),
          ),
        );

      addTearDown(() async {
        await favBloc.close();
        await plBloc.close();
        await authBloc.close();
      });

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<FavoriteBloc>.value(value: favBloc),
            BlocProvider<PlaylistBloc>.value(value: plBloc),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const PlaylistDetailPage(playlistId: 'pl-other'),
          ),
        ),
      );
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pumpAndSettle();

      // Non-owner does NOT see Add Songs, Reorder, Edit menu, or Remove from playlist
      expect(find.text('Add Songs'), findsNothing);
      expect(find.byTooltip('Reorder songs'), findsNothing);
      expect(find.byTooltip('Remove from playlist'), findsNothing);

      // Non-owner DOES see Add to favorites for playlist and Remove from favorites for already-favorited song-1
      expect(find.byTooltip('Add to favorites'), findsOneWidget);
      expect(find.byTooltip('Remove from favorites'), findsOneWidget);

      // Tap favorite playlist button in AppBar
      await tester.tap(find.byTooltip('Add to favorites').first);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pumpAndSettle();

      expect(favBloc.state.isPlaylistFavorite('pl-other'), isTrue);
    });

    testWidgets(
      'FavouritePage limits favorite songs & playlists to 3 and See more opens AllFavoritesPage with full lists',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final favRepo = _FakeFavoriteRepository();
        favRepo.songs
          ..clear()
          ..addAll(
            List.generate(
              7,
              (i) => FavoriteSongItem(
                song: SongEntity(
                  id: 'song-${i + 1}',
                  title: 'Fav Song ${i + 1}',
                  artist: 'Artist ${i + 1}',
                  fileUrl: 'https://example.com/${i + 1}.mp3',
                  durationSec: 180 + i,
                ),
                favoritedAt: DateTime.utc(2026, 11, 20),
              ),
            ),
          );
        favRepo.playlists
          ..clear()
          ..addAll(
            List.generate(
              7,
              (i) => FavoritePlaylistItem(
                playlist: PlaylistEntity(
                  id: 'pl-fav-${i + 1}',
                  name: 'Fav Playlist ${i + 1}',
                  ownerName: 'creator_${i + 1}',
                  visibility: 'PUBLIC',
                  songCount: i + 1,
                ),
                favoritedAt: DateTime.utc(2026, 11, 20),
              ),
            ),
          );

        final favBloc = _buildFavoriteBloc(favRepo);
        final plRepo = FakePlaylistRepository();
        final plBloc = _buildPlaylistBloc(plRepo);
        addTearDown(() async {
          await favBloc.close();
          await plBloc.close();
        });

        favBloc.add(const LoadFavoritesRequested());

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<FavoriteBloc>.value(value: favBloc),
              BlocProvider<PlaylistBloc>.value(value: plBloc),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              locale: const Locale('en'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const FavouritePage(),
            ),
          ),
        );
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pumpAndSettle();

        // Only first 3 playlists and songs are shown on FavouritePage
        expect(find.text('Fav Playlist 1'), findsOneWidget);
        expect(find.text('Fav Playlist 3'), findsOneWidget);
        expect(find.text('Fav Playlist 4'), findsNothing);
        expect(find.text('Fav Playlist 7'), findsNothing);

        expect(find.text('Fav Song 1'), findsOneWidget);
        expect(find.text('Fav Song 3'), findsOneWidget);
        expect(find.text('Fav Song 4'), findsNothing);
        expect(find.text('Fav Song 7'), findsNothing);

        // Two "See more" buttons appear (one for playlists, one for songs)
        expect(find.text('See more'), findsNWidgets(2));

        // Tap "See more" under Favorite Playlists (first button)
        await tester.ensureVisible(find.text('See more').first);
        await tester.tap(find.text('See more').first);
        await tester.pumpAndSettle();

        // AllFavoritesPage opens on Playlists tab showing all 7 playlists
        expect(find.text('All Favorites'), findsOneWidget);
        expect(find.text('Fav Playlist 7'), findsOneWidget);

        // Switch to Songs tab to verify all 7 favorite songs are shown
        await tester.tap(find.text('Songs (7)'));
        await tester.pumpAndSettle();
        expect(find.text('Fav Song 1'), findsOneWidget);
        expect(find.text('Fav Song 7'), findsOneWidget);

        // Search inside AllFavoritesPage filters songs cleanly
        await tester.enterText(find.byType(TextField), 'Fav Song 7');
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byType(ListView),
            matching: find.text('Fav Song 7'),
          ),
          findsOneWidget,
        );
        expect(find.text('Fav Song 1'), findsNothing);
      },
    );
  });
}

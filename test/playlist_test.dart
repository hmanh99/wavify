import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavify/core/theme/app_theme.dart';
import 'package:wavify/features/playlist/domain/entities/song_entity.dart';
import 'package:wavify/features/playlist/data/models/create_playlist_request_model.dart';
import 'package:wavify/features/playlist/data/models/playlist_model.dart';
import 'package:wavify/features/playlist/data/models/update_playlist_request_model.dart';
import 'package:wavify/features/playlist/domain/entities/playlist_entity.dart';
import 'package:wavify/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:wavify/features/playlist/domain/usecases/add_song_to_playlist_usecase.dart';
import 'package:wavify/features/playlist/domain/usecases/add_songs_to_playlist_usecase.dart';
import 'package:wavify/features/playlist/domain/usecases/create_playlist_usecase.dart';
import 'package:wavify/features/playlist/domain/usecases/delete_playlist_usecase.dart';
import 'package:wavify/features/playlist/domain/usecases/get_my_playlists_usecase.dart';
import 'package:wavify/features/playlist/domain/usecases/get_playlist_detail_usecase.dart';
import 'package:wavify/features/playlist/domain/usecases/remove_song_from_playlist_usecase.dart';
import 'package:wavify/features/playlist/domain/usecases/reorder_playlist_songs_usecase.dart';
import 'package:wavify/features/playlist/domain/usecases/update_playlist_usecase.dart';
import 'package:wavify/features/playlist/presentation/bloc/playlist_bloc.dart';
import 'package:wavify/features/playlist/presentation/bloc/playlist_event.dart';
import 'package:wavify/features/playlist/presentation/bloc/playlist_state.dart';
import 'package:wavify/features/playlist/presentation/pages/playlist_detail_page.dart';
import 'package:wavify/features/playlist/presentation/widgets/add_multiple_songs_bottom_sheet.dart';
import 'package:wavify/features/playlist/presentation/widgets/create_edit_playlist_dialog.dart';

class MockHttpAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;
  MockHttpAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

class FakePlaylistRepository implements PlaylistRepository {
  @override
  Future<List<SongEntity>> getAllSongs({int page = 0, int size = 50}) async => const [];

  List<PlaylistEntity> playlists = [
    const PlaylistEntity(
      id: 'pl-1',
      name: 'Chill Vibes',
      description: 'Relaxing songs',
      visibility: 'PUBLIC',
      songCount: 2,
      songs: [
        SongEntity(
          id: 'song-1',
          title: 'Night Sky',
          artist: 'Luna',
          fileUrl: 'https://example.com/audio1.mp3',
          coverUrl: 'https://example.com/cover1.jpg',
          durationSec: 210,
        ),
        SongEntity(
          id: 'song-2',
          title: 'Ocean Breeze',
          artist: 'Wave',
          fileUrl: 'https://example.com/audio2.mp3',
          coverUrl: 'https://example.com/cover2.jpg',
          durationSec: 180,
        ),
      ],
    ),
  ];

  @override
  Future<List<PlaylistEntity>> getMyPlaylists() async => playlists;

  @override
  Future<PlaylistEntity> getPlaylistById(String playlistId) async {
    return playlists.firstWhere((p) => p.id == playlistId);
  }

  @override
  Future<PlaylistEntity> createPlaylist({
    required String name,
    String? description,
    String? coverUrl,
    String visibility = 'PUBLIC',
  }) async {
    final newPl = PlaylistEntity(
      id: 'pl-${playlists.length + 1}',
      name: name,
      description: description,
      coverUrl: coverUrl,
      visibility: visibility,
      songCount: 0,
      songs: const [],
    );
    playlists.add(newPl);
    return newPl;
  }

  @override
  Future<PlaylistEntity> updatePlaylist({
    required String playlistId,
    required String name,
    String? description,
    String? coverUrl,
    String? visibility,
  }) async {
    final idx = playlists.indexWhere((p) => p.id == playlistId);
    final updated = playlists[idx].copyWith(
      name: name,
      description: description,
      coverUrl: coverUrl,
      visibility: visibility,
    );
    playlists[idx] = updated;
    return updated;
  }

  @override
  Future<void> deletePlaylist(String playlistId) async {
    playlists.removeWhere((p) => p.id == playlistId);
  }

  @override
  Future<PlaylistEntity> addSongToPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    return await addSongsToPlaylist(playlistId: playlistId, songIds: [songId]);
  }

  @override
  Future<PlaylistEntity> addSongsToPlaylist({
    required String playlistId,
    required List<String> songIds,
  }) async {
    final idx = playlists.indexWhere((p) => p.id == playlistId);
    final pl = playlists[idx];
    final songsToAdd = songIds.take(100).map((id) => SongEntity(
      id: id,
      title: 'Added Song $id',
      artist: 'Artist',
      fileUrl: 'https://example.com/song_$id.mp3',
      coverUrl: 'https://example.com/cover.jpg',
      durationSec: 200,
    )).toList();
    final updatedSongs = [...pl.songs, ...songsToAdd];
    final updated = pl.copyWith(songs: updatedSongs, songCount: updatedSongs.length);
    playlists[idx] = updated;
    return updated;
  }

  @override
  Future<PlaylistEntity> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    final idx = playlists.indexWhere((p) => p.id == playlistId);
    final pl = playlists[idx];
    final updatedSongs = pl.songs.where((s) => s.id != songId).toList();
    final updated = pl.copyWith(songs: updatedSongs, songCount: updatedSongs.length);
    playlists[idx] = updated;
    return updated;
  }

  @override
  Future<PlaylistEntity> reorderPlaylistSongs({
    required String playlistId,
    required List<String> songIds,
  }) async {
    final idx = playlists.indexWhere((p) => p.id == playlistId);
    final pl = playlists[idx];
    final songMap = {for (final s in pl.songs) s.id: s};
    final reordered = songIds.map((id) => songMap[id]!).toList();
    final updated = pl.copyWith(songs: reordered);
    playlists[idx] = updated;
    return updated;
  }
}

void main() {
  group('Playlist Models & Entities Tests', () {
    test('PlaylistModel parses Spring Boot ApiResponse result map', () {
      final json = {
        'code': 1000,
        'result': {
          'id': 'pl-99',
          'name': 'Acoustic Morning',
          'description': 'Warm and gentle tunes',
          'coverUrl': 'https://res.cloudinary.com/cover.jpg',
          'visibility': 'PUBLIC',
          'songCount': 1,
          'songs': [
            {
              'id': 'song-88',
              'title': 'Morning Light',
              'artist': 'Sun',
              'fileUrl': 'https://res.cloudinary.com/audio.mp3',
              'coverUrl': 'https://res.cloudinary.com/cover.jpg',
              'durationSec': 195,
            }
          ]
        }
      };

      final model = PlaylistModel.fromJson(json);
      expect(model.id, 'pl-99');
      expect(model.name, 'Acoustic Morning');
      expect(model.description, 'Warm and gentle tunes');
      expect(model.coverUrl, 'https://res.cloudinary.com/cover.jpg');
      expect(model.isPublic, isTrue);
      expect(model.songCount, 1);
      expect(model.songs.length, 1);
      expect(model.songs.first.title, 'Morning Light');
    });

    test('PlaylistModel toAlbumModel converts for FavouriteAlbumsSection', () {
      const pl = PlaylistEntity(
        id: 'pl-1',
        name: 'Top Hits',
        coverUrl: 'https://example.com/art.jpg',
        songCount: 3,
      );

      final album = pl.toAlbumModel();
      expect(album.id, 'pl-1');
      expect(album.title, 'Top Hits');
      expect(album.coverUrl, 'https://example.com/art.jpg');
    });

    test('Request models serialize to JSON correctly', () {
      const createReq = CreatePlaylistRequestModel(
        name: 'My Playlist',
        description: 'Describing playlist',
        visibility: 'PUBLIC',
      );
      expect(createReq.toJson()['name'], 'My Playlist');
      expect(createReq.toJson()['description'], 'Describing playlist');
      expect(createReq.toJson()['visibility'], 'PUBLIC');

      const updateReq = UpdatePlaylistRequestModel(
        name: 'Updated Name',
        visibility: 'PRIVATE',
      );
      expect(updateReq.toJson()['name'], 'Updated Name');
      expect(updateReq.toJson()['visibility'], 'PRIVATE');
      expect(updateReq.toJson().containsKey('description'), isFalse);
    });
  });

  group('PlaylistBloc Tests', () {
    late FakePlaylistRepository repo;
    late PlaylistBloc bloc;

    setUp(() {
      repo = FakePlaylistRepository();
      bloc = PlaylistBloc(
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
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is PlaylistState with initial status', () {
      expect(bloc.state.status, PlaylistStatus.initial);
      expect(bloc.state.playlists, isEmpty);
    });

    test('LoadPlaylistsRequested loads and emits playlists', () async {
      bloc.add(const LoadPlaylistsRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<PlaylistState>((s) => s.isLoading),
          predicate<PlaylistState>((s) => s.status == PlaylistStatus.loaded && s.playlists.length == 1),
        ]),
      );
    });

    test('CreatePlaylistSubmitted adds new playlist to list', () async {
      bloc.add(const CreatePlaylistSubmitted(
        name: 'Work Focus',
        description: 'Lofi beats for work',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<PlaylistState>((s) => s.isMutating),
          predicate<PlaylistState>((s) => s.status == PlaylistStatus.success && s.playlists.length == 1),
          predicate<PlaylistState>((s) => s.status == PlaylistStatus.loaded && s.playlists.first.name == 'Work Focus'),
        ]),
      );
    });

    test('ReorderPlaylistSongsRequested optimistically reorders songs', () async {
      final initialPlaylist = repo.playlists.first;
      bloc.emit(PlaylistState(
        playlists: [initialPlaylist],
        selectedPlaylist: initialPlaylist,
        status: PlaylistStatus.loaded,
      ));

      // Move song at 0 to 1
      bloc.add(ReorderPlaylistSongsRequested(
        playlistId: initialPlaylist.id,
        oldIndex: 0,
        newIndex: 2, // In flutter ReorderableListView newIndex after oldIndex is +1
      ));

      await expectLater(
        bloc.stream,
        emits(
          predicate<PlaylistState>((s) => s.selectedPlaylist!.songs.first.id == 'song-2'),
        ),
      );
    });

    test('AddSongsToPlaylistRequested batches and adds up to 100 songs to playlist', () async {
      final initialPlaylist = repo.playlists.first;
      bloc.emit(PlaylistState(
        playlists: [initialPlaylist],
        selectedPlaylist: initialPlaylist,
        status: PlaylistStatus.loaded,
      ));

      final songIdsToAdd = List.generate(5, (i) => 'batch-song-$i');
      bloc.add(AddSongsToPlaylistRequested(
        playlistId: initialPlaylist.id,
        songIds: songIdsToAdd,
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<PlaylistState>((s) => s.isMutating),
          predicate<PlaylistState>((s) => s.status == PlaylistStatus.success && s.selectedPlaylist!.songCount == 7),
          predicate<PlaylistState>((s) => s.status == PlaylistStatus.loaded && s.selectedPlaylist!.songCount == 7),
        ]),
      );
    });

    test('RemoveSongFromPlaylistRequested immediately removes song and refreshes playlist', () async {
      final initialPlaylist = repo.playlists.first;
      bloc.emit(PlaylistState(
        playlists: [initialPlaylist],
        selectedPlaylist: initialPlaylist,
        status: PlaylistStatus.loaded,
      ));

      bloc.add(RemoveSongFromPlaylistRequested(
        playlistId: initialPlaylist.id,
        songId: 'song-1',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          // Immediate optimistic removal state
          predicate<PlaylistState>((s) =>
              s.isMutating &&
              s.selectedPlaylist!.songs.length == 1 &&
              !s.selectedPlaylist!.songs.any((song) => song.id == 'song-1')),
          // Success state
          predicate<PlaylistState>((s) => s.status == PlaylistStatus.success),
          // Loaded state
          predicate<PlaylistState>((s) =>
              s.status == PlaylistStatus.loaded &&
              !s.selectedPlaylist!.songs.any((song) => song.id == 'song-1')),
        ]),
      );
    });
  });

  group('Playlist UI Widget Tests', () {
    testWidgets('PlaylistDetailPage displays header, play button and songs', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = FakePlaylistRepository();
      final bloc = PlaylistBloc(
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

      bloc.emit(PlaylistState(
        playlists: repo.playlists,
        selectedPlaylist: repo.playlists.first,
        status: PlaylistStatus.loaded,
      ));

      await tester.pumpWidget(
        BlocProvider<PlaylistBloc>.value(
          value: bloc,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const PlaylistDetailPage(playlistId: 'pl-1'),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Chill Vibes'), findsOneWidget);
      expect(find.text('Relaxing songs'), findsOneWidget);
      expect(find.text('Phát tất cả'), findsOneWidget);
      expect(find.text('Thêm bài'), findsOneWidget);
      expect(find.text('Night Sky'), findsOneWidget);
      expect(find.text('Ocean Breeze'), findsOneWidget);
    });

    testWidgets('CreateEditPlaylistDialog shows text fields and triggers submit', (tester) async {
      final repo = FakePlaylistRepository();
      final bloc = PlaylistBloc(
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

      await tester.pumpWidget(
        BlocProvider<PlaylistBloc>.value(
          value: bloc,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: CreateEditPlaylistDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tạo Playlist mới'), findsOneWidget);
      expect(find.text('Tên playlist *'), findsOneWidget);
      expect(find.text('Tạo mới'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'My Awesome Mix');
      await tester.tap(find.text('Tạo mới'));
      await tester.pumpAndSettle();

      expect(repo.playlists.any((p) => p.name == 'My Awesome Mix'), isTrue);
    });

    testWidgets('AddMultipleSongsBottomSheet allows multi-selecting songs up to 100 and confirms batch add', (tester) async {
      final repo = FakePlaylistRepository();
      final bloc = PlaylistBloc(
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

      final librarySongs = [
        const SongEntity(
          id: 'song-3',
          title: 'Sunset Boulevard',
          artist: 'Summer Beats',
          fileUrl: 'https://example.com/audio3.mp3',
          coverUrl: 'https://example.com/cover3.jpg',
          durationSec: 190,
        ),
        const SongEntity(
          id: 'song-4',
          title: 'Crystal Waters',
          artist: 'Ambient World',
          fileUrl: 'https://example.com/audio4.mp3',
          coverUrl: 'https://example.com/cover4.jpg',
          durationSec: 220,
        ),
      ];

      await tester.pumpWidget(
        BlocProvider<PlaylistBloc>.value(
          value: bloc,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: AddMultipleSongsBottomSheet(
                playlist: repo.playlists.first,
                availableSongs: librarySongs,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Thêm bài hát vào playlist'), findsOneWidget);
      expect(find.text('Sunset Boulevard'), findsOneWidget);
      expect(find.text('Crystal Waters'), findsOneWidget);
      expect(find.text('Chọn tất cả'), findsOneWidget);

      // Tap "Chọn tất cả"
      await tester.tap(find.text('Chọn tất cả'));
      await tester.pumpAndSettle();

      expect(find.text('Thêm 2 bài hát vào playlist'), findsOneWidget);

      // Tap confirm button
      await tester.tap(find.text('Thêm 2 bài hát vào playlist'));
      await tester.pumpAndSettle();

      // Verify that repo has both songs added
      final updatedPl = repo.playlists.first;
      expect(updatedPl.songs.any((s) => s.id == 'song-3'), isTrue);
      expect(updatedPl.songs.any((s) => s.id == 'song-4'), isTrue);
    });
  });
}


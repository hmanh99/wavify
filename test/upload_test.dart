import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavify/core/router/app_router.dart';
import 'package:wavify/core/di/service_locator.dart';
import 'package:wavify/core/theme/app_theme.dart';
import 'package:wavify/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wavify/features/upload/data/models/song_creation_request_model.dart';
import 'package:wavify/features/upload/data/models/song_response_model.dart';
import 'package:wavify/features/upload/data/models/song_update_request_model.dart';
import 'package:wavify/features/upload/domain/entities/song_entity.dart';
import 'package:wavify/features/upload/domain/repositories/song_repository.dart';
import 'package:wavify/features/upload/domain/usecases/delete_song_usecase.dart';
import 'package:wavify/features/upload/domain/usecases/get_my_songs_usecase.dart';
import 'package:wavify/features/upload/domain/usecases/update_song_usecase.dart';
import 'package:wavify/features/upload/domain/usecases/upload_song_usecase.dart';
import 'package:wavify/features/upload/presentation/bloc/upload_bloc.dart';
import 'package:wavify/features/upload/presentation/bloc/upload_event.dart';
import 'package:wavify/features/upload/presentation/bloc/upload_state.dart';
import 'package:wavify/features/upload/presentation/pages/upload_music_page.dart';

class MockSongRepository implements SongRepository {
  final List<SongEntity> storedSongs = [
    const SongEntity(
      id: 'song-1',
      title: 'Echoes of Dawn',
      artist: 'Sarwar Jahan',
      album: 'Golden Sky',
      durationSec: 215,
      fileUrl: 'https://cloudinary.com/audio/echoes.mp3',
      coverUrl: 'https://cloudinary.com/image/echoes.jpg',
      visibility: 'PUBLIC',
    ),
  ];

  bool deleteCalled = false;
  bool updateCalled = false;
  bool uploadCalled = false;

  @override
  Future<SongEntity> uploadSong({
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
  }) async {
    uploadCalled = true;
    onSendProgress?.call(100, 100);
    final newSong = SongEntity(
      id: 'song-new-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      artist: artist,
      album: album,
      durationSec: 180,
      fileUrl: 'https://cloudinary.com/audio/new.mp3',
      coverUrl: 'https://cloudinary.com/image/new.jpg',
      visibility: visibility,
    );
    storedSongs.insert(0, newSong);
    return newSong;
  }

  @override
  Future<SongEntity> updateSong({
    required String songId,
    required String title,
    required String artist,
    String? album,
    required String visibility,
  }) async {
    updateCalled = true;
    final index = storedSongs.indexWhere((s) => s.id == songId);
    final updated = SongEntity(
      id: songId,
      title: title,
      artist: artist,
      album: album,
      fileUrl: index != -1 ? storedSongs[index].fileUrl : '',
      coverUrl: index != -1 ? storedSongs[index].coverUrl : '',
      visibility: visibility,
    );
    if (index != -1) {
      storedSongs[index] = updated;
    }
    return updated;
  }

  @override
  Future<void> deleteSong(String songId) async {
    deleteCalled = true;
    storedSongs.removeWhere((s) => s.id == songId);
  }

  @override
  Future<List<SongEntity>> getMySongs() async {
    return List.from(storedSongs);
  }
}

void main() {
  setUp(() async {
    await sl.reset();
    await initAuthDependencies();
    await initUploadDependencies();

    // Use MockSongRepository for testing
    if (sl.isRegistered<SongRepository>()) {
      sl.unregister<SongRepository>();
    }
    sl.registerLazySingleton<SongRepository>(() => MockSongRepository());

    if (sl.isRegistered<UploadBloc>()) {
      sl.unregister<UploadBloc>();
    }
    sl.registerFactory<UploadBloc>(
      () => UploadBloc(
        uploadSongUseCase: sl<UploadSongUseCase>(),
        updateSongUseCase: sl<UpdateSongUseCase>(),
        deleteSongUseCase: sl<DeleteSongUseCase>(),
        getMySongsUseCase: sl<GetMySongsUseCase>(),
      ),
    );
  });

  group('Song Models & Requests Serialization Tests', () {
    test('SongResponseModel parses Spring Boot ApiResponse result map', () {
      final json = {
        'code': 200,
        'message': 'Upload song success',
        'result': {
          'id': 'uuid-1234',
          'title': 'Neon Nights',
          'artist': 'Cyberpunk Artist',
          'album': 'Future 2077',
          'durationSec': 240,
          'fileUrl': 'https://cloudinary.com/wavify/songs/neon.mp3',
          'coverUrl': 'https://cloudinary.com/wavify/covers/neon.jpg',
          'uploaderId': 'user-999',
          'visibility': 'PUBLIC',
          'status': 'READY',
          'createdAt': '2026-11-08T10:00:00Z',
        }
      };

      final song = SongResponseModel.fromJson(json);
      expect(song.id, 'uuid-1234');
      expect(song.title, 'Neon Nights');
      expect(song.artist, 'Cyberpunk Artist');
      expect(song.album, 'Future 2077');
      expect(song.durationSec, 240);
      expect(song.fileUrl, contains('neon.mp3'));
      expect(song.coverUrl, contains('neon.jpg'));
      expect(song.visibility, 'PUBLIC');
      expect(song.isPublic, isTrue);
      expect(song.status, 'READY');
      expect(song.createdAt, isNotNull);
    });

    test('SongCreationRequestModel and SongUpdateRequestModel toJson format correctly', () {
      const createReq = SongCreationRequestModel(
        title: 'Track A',
        artist: 'Artist A',
        album: 'Album A',
        visibility: 'PUBLIC',
      );
      final createJson = createReq.toJson();
      expect(createJson['title'], 'Track A');
      expect(createJson['artist'], 'Artist A');
      expect(createJson['album'], 'Album A');
      expect(createJson['visibility'], 'PUBLIC');

      const updateReq = SongUpdateRequestModel(
        title: 'Track Updated',
        artist: 'Artist Updated',
        visibility: 'PRIVATE',
      );
      final updateJson = updateReq.toJson();
      expect(updateJson['title'], 'Track Updated');
      expect(updateJson['artist'], 'Artist Updated');
      expect(updateJson['visibility'], 'PRIVATE');
      expect(updateJson.containsKey('album'), isFalse);
    });
  });

  group('UploadBloc Unit Tests (Upload, Update, Delete, MySongs)', () {
    late MockSongRepository mockRepo;
    late UploadSongUseCase uploadUseCase;
    late UpdateSongUseCase updateUseCase;
    late DeleteSongUseCase deleteUseCase;
    late GetMySongsUseCase getMySongsUseCase;
    late UploadBloc bloc;

    setUp(() {
      mockRepo = MockSongRepository();
      uploadUseCase = UploadSongUseCase(mockRepo);
      updateUseCase = UpdateSongUseCase(mockRepo);
      deleteUseCase = DeleteSongUseCase(mockRepo);
      getMySongsUseCase = GetMySongsUseCase(mockRepo);

      bloc = UploadBloc(
        uploadSongUseCase: uploadUseCase,
        updateSongUseCase: updateUseCase,
        deleteSongUseCase: deleteUseCase,
        getMySongsUseCase: getMySongsUseCase,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('LoadMySongsRequested fetches songs from repository', () async {
      bloc.add(const LoadMySongsRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const MySongsLoading(),
          MySongsLoaded(mockRepo.storedSongs),
        ]),
      );
    });

    test('UploadSongSubmitted validates empty title', () async {
      bloc.add(
        const UploadSongSubmitted(
          title: '',
          artist: 'Sarwar',
          visibility: 'PUBLIC',
          audioPath: '/dummy/song.mp3',
        ),
      );

      await expectLater(
        bloc.stream,
        emits(const UploadFailure('Tiêu đề bài hát không được để trống')),
      );
    });

    test('UploadSongSubmitted successfully uploads and prepends song', () async {
      bloc.add(
        UploadSongSubmitted(
          title: 'New Track 2026',
          artist: 'Sarwar',
          album: 'Single',
          visibility: 'PUBLIC',
          audioBytes: Uint8List.fromList([1, 2, 3]),
          audioFileName: 'track.mp3',
        ),
      );

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<UploadState>((s) => s is UploadInProgress),
          predicate<UploadState>((s) => s is UploadSuccess && s.song.title == 'New Track 2026'),
          predicate<UploadState>((s) => s is MySongsLoaded && s.songs.first.title == 'New Track 2026'),
        ]),
      );
      expect(mockRepo.uploadCalled, isTrue);
    });

    test('UpdateSongSubmitted calls updateSong and updates list', () async {
      bloc.emit(MySongsLoaded(List.from(mockRepo.storedSongs)));
      bloc.add(
        const UpdateSongSubmitted(
          songId: 'song-1',
          title: 'Echoes of Dawn (Remastered)',
          artist: 'Sarwar Jahan',
          visibility: 'PRIVATE',
        ),
      );

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<UploadState>((s) => s is MySongsLoading),
          predicate<UploadState>((s) => s is SongOperationSuccess),
          predicate<UploadState>((s) =>
              s is MySongsLoaded && s.songs.any((s) => s.title == 'Echoes of Dawn (Remastered)')),
        ]),
      );
      expect(mockRepo.updateCalled, isTrue);
    });

    test('DeleteSongRequested calls deleteSong and removes from list', () async {
      bloc.add(const DeleteSongRequested('song-1'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<UploadState>((s) => s is MySongsLoading),
          predicate<UploadState>((s) => s is SongOperationSuccess && s.message.contains('Đã xóa')),
          predicate<UploadState>((s) => s is MySongsLoaded && s.songs.isEmpty),
        ]),
      );
      expect(mockRepo.deleteCalled, isTrue);
    });
  });

  group('Upload Music Route & Page Widget Tests', () {
    test('AppRouter contains upload route constant', () {
      expect(AppRouter.upload, '/upload');
    });

    testWidgets('UploadMusicPage renders audio picker, inputs and submit button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const UploadMusicPage(),
        ),
      );
      await tester.pump();

      expect(find.text('Đăng tải bài hát'), findsOneWidget);
      expect(find.text('Audio File'), findsOneWidget);
      expect(find.text('Nhấn để chọn file'), findsOneWidget);
      expect(find.text('Thông tin bài hát'), findsOneWidget);
      expect(find.text('Tiêu đề'), findsOneWidget);
      expect(find.text('Nghệ sĩ'), findsOneWidget);
      expect(find.text('Hiển thị'), findsOneWidget);
      expect(find.text('Public'), findsOneWidget);
      expect(find.text('Private'), findsOneWidget);
      expect(find.text('Đăng bài hát'), findsOneWidget);
    });

    testWidgets('AppRouter can navigate to /upload via router', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
          child: MaterialApp.router(
            routerConfig: AppRouter.router,
          ),
        ),
      );
      await tester.pump();

      AppRouter.router.go(AppRouter.upload);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(UploadMusicPage), findsOneWidget);
    });
  });
}

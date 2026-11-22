import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavify/core/di/service_locator.dart';
import 'package:wavify/core/services/playback_bridge.dart';
import 'package:wavify/core/theme/app_theme.dart';
import 'package:wavify/features/listen/presentation/bloc/player_bloc.dart';
import 'package:wavify/features/listen/presentation/bloc/player_event.dart';
import 'package:wavify/features/history/data/datasources/history_local_data_source.dart';
import 'package:wavify/features/history/data/datasources/history_remote_data_source.dart';
import 'package:wavify/features/history/data/models/history_model.dart';
import 'package:wavify/features/history/data/models/history_song_model.dart';
import 'package:wavify/features/history/data/repositories/history_repository_impl.dart';
import 'package:wavify/features/history/domain/repositories/history_repository.dart';
import 'package:wavify/features/history/domain/usecases/clear_history_usecase.dart';
import 'package:wavify/features/history/domain/usecases/delete_history_item_usecase.dart';
import 'package:wavify/features/history/domain/usecases/get_history_usecase.dart';
import 'package:wavify/features/history/domain/usecases/record_history_usecase.dart';
import 'package:wavify/features/history/presentation/bloc/history_bloc.dart';
import 'package:wavify/features/history/presentation/bloc/history_event.dart';
import 'package:wavify/features/history/presentation/bloc/history_state.dart';
import 'package:wavify/features/history/presentation/pages/history_page.dart';
import 'listen_playback_test.dart';

class MockHistoryRemoteDataSource implements HistoryRemoteDataSource {
  final List<String> recordedSongIds = [];
  final List<String> deletedHistoryIds = [];
  List<HistoryModel> mockList = [];
  bool shouldThrow = false;

  @override
  Future<void> recordHistory(String songId) async {
    if (shouldThrow) throw Exception('Network error');
    recordedSongIds.add(songId);
  }

  @override
  Future<List<HistoryModel>> getHistory({int page = 0, int size = 20}) async {
    if (shouldThrow) throw Exception('Network error');
    return mockList;
  }

  @override
  Future<void> clearHistory() async {
    mockList.clear();
    recordedSongIds.clear();
  }

  @override
  Future<void> deleteHistoryItem(String historyId) async {
    if (shouldThrow) throw Exception('Network error');
    deletedHistoryIds.add(historyId);
    mockList.removeWhere((h) => h.id == historyId);
  }
}

class FakeHistoryLocalDataSource implements HistoryLocalDataSource {
  List<HistoryModel> list = [];

  @override
  Future<List<HistoryModel>> getCachedHistory() async => List<HistoryModel>.from(list);

  @override
  Future<void> cacheHistory(List<HistoryModel> history) async {
    list = List<HistoryModel>.from(history);
  }

  @override
  Future<void> addHistoryItem(HistoryModel item) async {
    list.removeWhere((h) => h.song.id == item.song.id);
    list.insert(0, item);
  }

  @override
  Future<void> deleteHistoryItem(String historyId) async {
    list.removeWhere((h) => h.id == historyId);
  }

  @override
  Future<void> clearHistory() async {
    list.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testHistorySong1 = HistorySongModel(
    id: 'song-1',
    title: 'Midnight City',
    artist: 'M83',
    album: 'Hurry Up',
    duration: Duration(seconds: 243),
    fileUrl: 'https://example.com/audio1.mp3',
  );

  const testHistorySong2 = HistorySongModel(
    id: 'song-2',
    title: 'Starboy',
    artist: 'The Weeknd',
    duration: Duration(seconds: 230),
    fileUrl: 'https://example.com/audio2.mp3',
  );

  final testHistory1 = HistoryModel(
    id: 'hist-1',
    song: testHistorySong1,
    playedAt: DateTime.now().subtract(const Duration(minutes: 5)),
  );

  final testHistory2 = HistoryModel(
    id: 'hist-2',
    song: testHistorySong2,
    playedAt: DateTime.now().subtract(const Duration(hours: 1)),
  );

  group('History Models & Entities Tests', () {
    test('HistoryModel.fromJson parses nested song format accurately', () {
      final json = {
        'id': 'h-100',
        'playedAt': '2026-11-14T10:00:00.000Z',
        'song': {
          'id': 's-1',
          'title': 'Solar Echoes',
          'artist': 'Cosmic Sound',
          'durationSec': 210,
          'fileUrl': 'https://example.com/audio.mp3',
          'coverUrl': 'https://example.com/cover.jpg',
        }
      };

      final model = HistoryModel.fromJson(json);
      expect(model.id, 'h-100');
      expect(model.song.id, 's-1');
      expect(model.song.title, 'Solar Echoes');
      expect(model.song.artist, 'Cosmic Sound');
      expect(model.playedAt.year, 2026);
    });

    test('HistoryModel.fromJson parses flat song format accurately', () {
      final json = {
        'id': 'h-101',
        'songId': 's-2',
        'title': 'Neon Lights',
        'artist': 'Synth',
        'fileUrl': 'https://example.com/neon.mp3',
        'playedAt': '2026-11-14T10:30:00.000Z',
      };

      final model = HistoryModel.fromJson(json);
      expect(model.id, 'h-101');
      expect(model.song.title, 'Neon Lights');
      expect(model.song.artist, 'Synth');
    });

    test('HistoryModel.fromJson parses backend PlayHistoryResponse accurately', () {
      final backendJson = {
        'id': 'b883015f-d227-4c70-8bfa-2ecdc9426f37',
        'userId': '68cb8fa2-63ea-4ee3-be04-14b53c7df47e',
        'song': {
          'id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
          'title': 'Blinding Lights',
          'artist': 'The Weeknd',
          'album': 'After Hours',
          'durationSec': 200,
          'fileUrl': 'https://res.cloudinary.com/demo/audio.mp3',
          'coverUrl': 'https://res.cloudinary.com/demo/cover.jpg',
          'uploaderId': '68cb8fa2-63ea-4ee3-be04-14b53c7df47e',
          'visibility': 'PUBLIC',
          'status': 'READY',
          'createdAt': '2026-11-14T06:00:00Z',
        },
        'playedAt': '2026-11-14T06:45:00Z',
      };

      final model = HistoryModel.fromJson(backendJson);
      expect(model.id, 'b883015f-d227-4c70-8bfa-2ecdc9426f37');
      expect(model.userId, '68cb8fa2-63ea-4ee3-be04-14b53c7df47e');
      expect(model.song.id, '3fa85f64-5717-4562-b3fc-2c963f66afa6');
      expect(model.song.title, 'Blinding Lights');
      expect(model.song.artist, 'The Weeknd');
      expect(model.song.duration.inSeconds, 200);
      expect(model.playedAt.toIso8601String(), contains('2026-11-14T06:45:00'));
    });

    test('HistoryModel.toJson serializes correctly', () {
      final json = testHistory1.toJson();
      expect(json['id'], 'hist-1');
      expect(json['song']['title'], 'Midnight City');
      expect(json['playedAt'], isNotNull);
    });
  });

  group('History Repository & Data Source Tests', () {
    late MockHistoryRemoteDataSource mockRemote;
    late HistoryLocalDataSource localDataSource;
    late HistoryRepositoryImpl repository;

    setUp(() {
      mockRemote = MockHistoryRemoteDataSource();
      localDataSource = FakeHistoryLocalDataSource();
      repository = HistoryRepositoryImpl(
        remoteDataSource: mockRemote,
        localDataSource: localDataSource,
      );
    });

    test('recordHistory calls remote POST /history and records songId', () async {
      await repository.recordHistory('song-123');
      expect(mockRemote.recordedSongIds, contains('song-123'));
    });

    test('getHistory fetches from remote and caches locally', () async {
      mockRemote.mockList = [testHistory1, testHistory2];
      final result = await repository.getHistory();

      expect(result.length, 2);
      expect(result.first.song.title, 'Midnight City');

      // Verify cached locally
      final cached = await localDataSource.getCachedHistory();
      expect(cached.length, 2);
    });

    test('getHistory returns cached history on remote failure', () async {
      await localDataSource.cacheHistory([testHistory1]);
      mockRemote.shouldThrow = true;

      final result = await repository.getHistory();
      expect(result.length, 1);
      expect(result.first.song.id, 'song-1');
    });

    test('clearHistory clears both remote and local history', () async {
      mockRemote.mockList = [testHistory1];
      await localDataSource.cacheHistory([testHistory1]);

      await repository.clearHistory();
      expect(mockRemote.mockList, isEmpty);
      final cached = await localDataSource.getCachedHistory();
      expect(cached, isEmpty);
    });

    test('deleteHistoryItem deletes from both remote and local history', () async {
      mockRemote.mockList = [testHistory1, testHistory2];
      await localDataSource.cacheHistory([testHistory1, testHistory2]);

      await repository.deleteHistoryItem('hist-1');
      expect(mockRemote.deletedHistoryIds, contains('hist-1'));
      final cached = await localDataSource.getCachedHistory();
      expect(cached.length, 1);
      expect(cached.first.id, 'hist-2');
    });
  });

  group('HistoryBloc Tests', () {
    late MockHistoryRemoteDataSource mockRemote;
    late HistoryRepository repository;
    late HistoryBloc historyBloc;

    setUp(() {
      mockRemote = MockHistoryRemoteDataSource();
      repository = HistoryRepositoryImpl(
        remoteDataSource: mockRemote,
        localDataSource: FakeHistoryLocalDataSource(),
      );
      historyBloc = HistoryBloc(
        getHistoryUseCase: GetHistoryUseCase(repository),
        recordHistoryUseCase: RecordHistoryUseCase(repository),
        clearHistoryUseCase: ClearHistoryUseCase(repository),
        deleteHistoryItemUseCase: DeleteHistoryItemUseCase(repository),
      );
    });

    tearDown(() async {
      await historyBloc.close();
    });

    test('Initial state is HistoryInitial', () {
      expect(historyBloc.state, const HistoryInitial());
    });

    test('HistoryLoadRequested loads history and emits HistoryLoaded', () async {
      mockRemote.mockList = [testHistory1, testHistory2];

      historyBloc.add(const HistoryLoadRequested());
      await pumpEventQueue();

      expect(historyBloc.state, isA<HistoryLoaded>());
      final loaded = historyBloc.state as HistoryLoaded;
      expect(loaded.history.length, 2);
      expect(loaded.history.first.song.title, 'Midnight City');
    });

    test('HistoryClearRequested clears history and emits empty HistoryLoaded', () async {
      mockRemote.mockList = [testHistory1];
      historyBloc.add(const HistoryLoadRequested());
      await pumpEventQueue();

      historyBloc.add(const HistoryClearRequested());
      await pumpEventQueue();

      expect(historyBloc.state, isA<HistoryLoaded>());
      final loaded = historyBloc.state as HistoryLoaded;
      expect(loaded.history, isEmpty);
    });

    test('HistoryDeleteItemRequested removes single item and emits updated HistoryLoaded', () async {
      mockRemote.mockList = [testHistory1, testHistory2];
      historyBloc.add(const HistoryLoadRequested());
      await pumpEventQueue();

      historyBloc.add(const HistoryDeleteItemRequested('hist-1'));
      await pumpEventQueue();

      final loaded = historyBloc.state as HistoryLoaded;
      expect(loaded.history.length, 1);
      expect(loaded.history.first.id, 'hist-2');
    });
  });

  group('PlayerBloc 15-Second Minimum Listening History Tracking Tests', () {
    late FakeAudioPlayerService fakeAudioPlayerService;
    late MockHistoryRemoteDataSource mockRemote;
    late HistoryRepository repository;
    late RecordHistoryUseCase recordHistoryUseCase;
    late PlayerBloc playerBloc;

    setUp(() {
      fakeAudioPlayerService = FakeAudioPlayerService();
      mockRemote = MockHistoryRemoteDataSource();
      repository = HistoryRepositoryImpl(
        remoteDataSource: mockRemote,
        localDataSource: FakeHistoryLocalDataSource(),
      );
      recordHistoryUseCase = RecordHistoryUseCase(repository);

      playerBloc = PlayerBloc(
        audioPlayerService: fakeAudioPlayerService,
        onRecordHistory: recordHistoryUseCase.call,
      );
    });

    tearDown(() async {
      await playerBloc.close();
    });

    test('Listening under 15 seconds does NOT trigger /history recording', () async {
      playerBloc.add(PlayerPlayPlaylistRequested(
        playlist: [testHistorySong1.toPlaybackMap(), testHistorySong2.toPlaybackMap()],
        initialIndex: 0,
      ));
      await pumpEventQueue();

      // Position advances to 5 seconds
      fakeAudioPlayerService.emitPosition(const Duration(seconds: 5));
      await pumpEventQueue();

      // Position advances to 14 seconds
      fakeAudioPlayerService.emitPosition(const Duration(seconds: 14));
      await pumpEventQueue();

      expect(mockRemote.recordedSongIds, isEmpty);
    });

    test('Listening for >= 15 seconds automatically records history endpoint /history', () async {
      playerBloc.add(PlayerPlayPlaylistRequested(
        playlist: [testHistorySong1.toPlaybackMap(), testHistorySong2.toPlaybackMap()],
        initialIndex: 0,
      ));
      await pumpEventQueue();

      // Position reaches 15 seconds threshold
      fakeAudioPlayerService.emitPosition(const Duration(seconds: 15));
      await pumpEventQueue();

      // Verify song-1 was recorded
      expect(mockRemote.recordedSongIds, contains('song-1'));
      expect(mockRemote.recordedSongIds.length, 1);

      // Advancing to 16s, 20s, 30s does NOT record again for the same song
      fakeAudioPlayerService.emitPosition(const Duration(seconds: 16));
      fakeAudioPlayerService.emitPosition(const Duration(seconds: 25));
      await pumpEventQueue();

      expect(mockRemote.recordedSongIds.length, 1);
    });

    test('Switching to another song records the new song once it reaches 15 seconds', () async {
      playerBloc.add(PlayerPlayPlaylistRequested(
        playlist: [testHistorySong1.toPlaybackMap(), testHistorySong2.toPlaybackMap()],
        initialIndex: 0,
      ));
      await pumpEventQueue();

      // Song 1 reaches 15s
      fakeAudioPlayerService.emitPosition(const Duration(seconds: 15));
      await pumpEventQueue();
      expect(mockRemote.recordedSongIds, ['song-1']);

      // Switch to Song 2
      playerBloc.add(const PlayerNextRequested());
      await pumpEventQueue();
      expect(playerBloc.state.currentSong?.id, 'song-2');

      // Song 2 plays for 8s (under threshold)
      fakeAudioPlayerService.emitPosition(const Duration(seconds: 8));
      await pumpEventQueue();
      expect(mockRemote.recordedSongIds.length, 1);

      // Song 2 reaches 15s
      fakeAudioPlayerService.emitPosition(const Duration(seconds: 15));
      await pumpEventQueue();
      expect(mockRemote.recordedSongIds, ['song-1', 'song-2']);
    });
  });

  group('HistoryPage Widget Tests', () {
    late MockHistoryRemoteDataSource mockRemote;
    late HistoryBloc historyBloc;
    late FakeAudioPlayerService fakePlayerService;
    late PlayerBloc playerBloc;

    setUp(() {
      mockRemote = MockHistoryRemoteDataSource();
      final repo = HistoryRepositoryImpl(
        remoteDataSource: mockRemote,
        localDataSource: FakeHistoryLocalDataSource(),
      );
      historyBloc = HistoryBloc(
        getHistoryUseCase: GetHistoryUseCase(repo),
        recordHistoryUseCase: RecordHistoryUseCase(repo),
        clearHistoryUseCase: ClearHistoryUseCase(repo),
        deleteHistoryItemUseCase: DeleteHistoryItemUseCase(repo),
      );
      fakePlayerService = FakeAudioPlayerService();
      playerBloc = PlayerBloc(audioPlayerService: fakePlayerService);
      if (!sl.isRegistered<PlaybackBridge>()) {
        sl.registerLazySingleton<PlaybackBridge>(() => playerBloc);
      }
    });

    tearDown(() async {
      await historyBloc.close();
      await playerBloc.close();
      if (sl.isRegistered<PlaybackBridge>()) {
        sl.unregister<PlaybackBridge>();
      }
    });

    testWidgets('HistoryPage displays empty state when no history exists', (tester) async {
      mockRemote.mockList = [];

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<HistoryBloc>.value(value: historyBloc),
            BlocProvider<PlayerBloc>.value(value: playerBloc),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const HistoryPage(),
          ),
        ),
      );
      await tester.pump();
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(find.text('Lịch sử phát nhạc'), findsOneWidget);
      expect(find.text('Chưa có lịch sử phát nhạc'), findsOneWidget);
      expect(find.text('Các bài hát bạn nghe tối thiểu 15 giây sẽ tự động được ghi nhận tại đây.'), findsOneWidget);
    });

    testWidgets('HistoryPage renders list of played songs and supports playback on tap', (tester) async {
      mockRemote.mockList = [testHistory1, testHistory2];

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<HistoryBloc>.value(value: historyBloc),
            BlocProvider<PlayerBloc>.value(value: playerBloc),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const HistoryPage(),
          ),
        ),
      );
      await tester.pump();
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(find.text('Midnight City'), findsOneWidget);
      expect(find.text('Starboy'), findsOneWidget);

      // Tap on first song to play
      await tester.tap(find.text('Midnight City'));
      await tester.pump();

      expect(playerBloc.state.currentSong?.title, 'Midnight City');
      expect(fakePlayerService.playCallCount, 1);
    });
  });
}

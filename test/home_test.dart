import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavify/core/di/service_locator.dart';
import 'package:wavify/core/theme/app_theme.dart';
import 'package:wavify/features/history/data/models/history_model.dart';
import 'package:wavify/features/history/data/models/history_song_model.dart';
import 'package:wavify/features/history/domain/entities/history_entity.dart';
import 'package:wavify/features/history/domain/repositories/history_repository.dart';
import 'package:wavify/features/history/domain/usecases/clear_history_usecase.dart';
import 'package:wavify/features/history/domain/usecases/delete_history_item_usecase.dart';
import 'package:wavify/features/history/domain/usecases/get_history_usecase.dart';
import 'package:wavify/features/history/domain/usecases/record_history_usecase.dart';
import 'package:wavify/features/history/presentation/bloc/history_bloc.dart';
import 'package:wavify/features/history/presentation/bloc/history_event.dart';
import 'package:wavify/features/home/data/datasources/home_remote_data_source.dart';
import 'package:wavify/features/home/domain/repositories/home_repository.dart';
import 'package:wavify/features/home/domain/usecases/get_all_songs_usecase.dart';
import 'package:wavify/features/home/presentation/bloc/home_bloc.dart';
import 'package:wavify/features/home/presentation/bloc/home_event.dart';
import 'package:wavify/features/home/presentation/bloc/home_state.dart';
import 'package:wavify/features/home/presentation/pages/home_page.dart';
import 'package:wavify/features/home/presentation/widgets/recently_played_section.dart';
import 'package:wavify/features/home/presentation/widgets/recommend_songs_section.dart';
import 'package:wavify/features/home/presentation/widgets/home_search_bar.dart';
import 'package:wavify/features/home/domain/entities/song_entity.dart';

class MockHomeRepository implements HomeRepository {
  List<SongEntity> songs = [
    const SongEntity(
      id: 'song-1',
      title: 'Midnight Serenade',
      artist: 'Acoustic Dreams',
      album: 'Nightfall',
      durationSec: 210,
      fileUrl: 'https://cloudinary.com/audio/midnight.mp3',
      coverUrl: 'https://cloudinary.com/images/midnight.jpg',
      visibility: 'PUBLIC',
      status: 'READY',
    ),
    const SongEntity(
      id: 'song-2',
      title: 'Neon Skyline',
      artist: 'Synthwave Boy',
      album: 'Retro 80s',
      durationSec: 185,
      fileUrl: 'https://cloudinary.com/audio/neon.mp3',
      coverUrl: 'https://cloudinary.com/images/neon.jpg',
      visibility: 'PUBLIC',
      status: 'READY',
    ),
  ];

  bool shouldThrow = false;

  @override
  Future<List<SongEntity>> getAllSongs({int page = 0, int size = 50}) async {
    if (shouldThrow) {
      throw Exception('Không thể kết nối đến máy chủ');
    }
    return songs;
  }
}

class _FakeHomeHistoryRepository implements HistoryRepository {
  List<HistoryEntity> items = [];
  int getHistoryCallCount = 0;

  @override
  Future<List<HistoryEntity>> getHistory({int page = 0, int size = 20}) async {
    getHistoryCallCount++;
    return List<HistoryEntity>.from(items);
  }

  @override
  Future<void> recordHistory(String songId) async {}

  @override
  Future<void> clearHistory() async {
    items.clear();
  }

  @override
  Future<void> deleteHistoryItem(String historyId) async {
    items.removeWhere((h) => h.id == historyId);
  }
}

class MockHttpClientAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;

  MockHttpClientAdapter(this.handler);

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

void main() {
  setUp(() async {
    await sl.reset();
    await initAuthDependencies();
    await initHomeDependencies();
  });

  group('HomeRemoteDataSource Tests', () {
    test('getAllSongs successfully parses Spring Boot ApiResponse with Page content', () async {
      final dio = Dio();
      final pageResponse = {
        'code': 200,
        'message': 'Get songs success',
        'result': {
          'content': [
            {
              'id': 'uuid-1',
              'title': 'Starlight Echoes',
              'artist': 'Lunar Path',
              'album': 'Cosmos',
              'durationSec': 225,
              'fileUrl': 'https://res.cloudinary.com/audio.mp3',
              'coverUrl': 'https://res.cloudinary.com/cover.jpg',
              'uploaderId': 'user-1',
              'visibility': 'PUBLIC',
              'status': 'READY',
              'createdAt': '2026-11-09T10:00:00Z',
            }
          ],
          'totalPages': 1,
          'totalElements': 1,
          'last': true,
          'size': 20,
          'number': 0,
        }
      };

      String? capturedPath;
      dio.httpClientAdapter = MockHttpClientAdapter((options) async {
        capturedPath = options.path;
        return ResponseBody.fromString(
          jsonEncode(pageResponse),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final dataSource = HomeRemoteDataSourceImpl(dio: dio);
      final songs = await dataSource.getAllSongs();

      expect(capturedPath, '/api/v1/songs');
      expect(songs.length, 1);
      expect(songs.first.id, 'uuid-1');
      expect(songs.first.title, 'Starlight Echoes');
      expect(songs.first.artist, 'Lunar Path');
      expect(songs.first.album, 'Cosmos');
      expect(songs.first.durationSec, 225);
    });
  });

  group('HomeBloc Tests', () {
    late MockHomeRepository mockRepo;
    late GetAllSongsUseCase getAllSongsUseCase;
    late HomeBloc bloc;

    setUp(() {
      mockRepo = MockHomeRepository();
      getAllSongsUseCase = GetAllSongsUseCase(mockRepo);
      bloc = HomeBloc(getAllSongsUseCase: getAllSongsUseCase);
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is HomeInitial', () {
      expect(bloc.state, const HomeInitial());
    });

    test('HomeLoadSongsRequested emits HomeLoading then HomeLoaded with all songs', () async {
      bloc.add(const HomeLoadSongsRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const HomeLoading(),
          predicate<HomeState>((s) =>
              s is HomeLoaded &&
              s.allSongs.length == 2 &&
              s.filteredSongs.length == 2 &&
              !s.isSearching),
        ]),
      );
    });

    test('HomeSearchQueryChanged filters songs by query', () async {
      bloc.emit(HomeLoaded(
        allSongs: mockRepo.songs,
        filteredSongs: mockRepo.songs,
      ));

      bloc.add(const HomeSearchQueryChanged('Neon'));

      await expectLater(
        bloc.stream,
        emits(
          predicate<HomeState>((s) =>
              s is HomeLoaded &&
              s.filteredSongs.length == 1 &&
              s.filteredSongs.first.title == 'Neon Skyline' &&
              s.isSearching),
        ),
      );
    });

    test('HomeSearchQueryChanged with empty string restores all songs', () async {
      bloc.emit(HomeLoaded(
        allSongs: mockRepo.songs,
        filteredSongs: [mockRepo.songs.last],
        searchQuery: 'Neon',
      ));

      bloc.add(const HomeSearchQueryChanged(''));

      await expectLater(
        bloc.stream,
        emits(
          predicate<HomeState>((s) =>
              s is HomeLoaded &&
              s.filteredSongs.length == 2 &&
              !s.isSearching),
        ),
      );
    });

    test('HomeRefreshRequested updates HomeLoaded songs without emitting HomeLoading', () async {
      bloc.emit(HomeLoaded(
        allSongs: [mockRepo.songs.first],
        filteredSongs: [mockRepo.songs.first],
      ));

      bloc.add(const HomeRefreshRequested());

      await expectLater(
        bloc.stream,
        emits(
          predicate<HomeState>((s) =>
              s is HomeLoaded && s.allSongs.length == 2),
        ),
      );
    });

    test('HomeLoadSongsRequested emits HomeFailure when repository fails', () async {
      mockRepo.shouldThrow = true;
      bloc.add(const HomeLoadSongsRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const HomeLoading(),
          predicate<HomeState>((s) => s is HomeFailure && s.message.contains('Không thể kết nối')),
        ]),
      );
    });

    test('HomeShuffleRecommendationsRequested shuffles recommendedSongs into a new order', () async {
      bloc.emit(HomeLoaded(
        allSongs: mockRepo.songs,
        filteredSongs: mockRepo.songs,
        recommendedSongs: mockRepo.songs,
      ));

      bloc.add(const HomeShuffleRecommendationsRequested());

      await expectLater(
        bloc.stream,
        emits(
          predicate<HomeState>((s) =>
              s is HomeLoaded &&
              s.recommendedSongs.length == 2 &&
              s.recommendedSongs.first.id != mockRepo.songs.first.id),
        ),
      );
    });
  });

  group('HomePage Widget Tests', () {
    testWidgets('HomePage displays header, search bar, and recommended songs with shuffle', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockRepo = MockHomeRepository();
      final testBloc = HomeBloc(getAllSongsUseCase: GetAllSongsUseCase(mockRepo))
        ..add(const HomeLoadSongsRequested());

      await tester.pumpWidget(
        BlocProvider<HomeBloc>.value(
          value: testBloc,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const HomePage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(HomeSearchBar), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byType(RecommendSongsSection), findsOneWidget);
      expect(find.text('Đề xuất cho bạn'), findsOneWidget);
      expect(find.text('Đổi bài'), findsOneWidget);
      expect(find.text('Midnight Serenade'), findsWidgets);
      expect(find.text('Neon Skyline'), findsWidgets);

      final beforeOrder = (testBloc.state as HomeLoaded)
          .recommendedSongs
          .map((s) => s.id)
          .toList();
      await tester.tap(find.text('Đổi bài'));
      await tester.pump();
      final afterOrder = (testBloc.state as HomeLoaded)
          .recommendedSongs
          .map((s) => s.id)
          .toList();
      expect(afterOrder, isNot(equals(beforeOrder)));
    });

    testWidgets('HomePage displays RecentlyPlayedSection from HistoryBloc, auto-updates and refreshes', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockHomeRepo = MockHomeRepository();
      final fakeHistoryRepo = _FakeHomeHistoryRepository();
      final homeBloc = HomeBloc(getAllSongsUseCase: GetAllSongsUseCase(mockHomeRepo))
        ..add(const HomeLoadSongsRequested());
      final historyBloc = HistoryBloc(
        getHistoryUseCase: GetHistoryUseCase(fakeHistoryRepo),
        recordHistoryUseCase: RecordHistoryUseCase(fakeHistoryRepo),
        clearHistoryUseCase: ClearHistoryUseCase(fakeHistoryRepo),
        deleteHistoryItemUseCase: DeleteHistoryItemUseCase(fakeHistoryRepo),
      );
      addTearDown(() async {
        await homeBloc.close();
        await historyBloc.close();
      });

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<HomeBloc>.value(value: homeBloc),
            BlocProvider<HistoryBloc>.value(value: historyBloc),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const HomePage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Empty history -> RecentlyPlayedSection should NOT be rendered
      expect(find.byType(RecentlyPlayedSection), findsNothing);
      expect(fakeHistoryRepo.getHistoryCallCount, 1);

      // Simulate a song listened past threshold and history refreshed
      fakeHistoryRepo.items = [
        HistoryModel(
          id: 'h-1',
          song: const HistorySongModel(
            id: 'recent-1',
            title: 'Recently Listened Track',
            artist: 'History Artist',
            duration: Duration(seconds: 200),
            fileUrl: 'https://example.com/recent1.mp3',
          ),
          playedAt: DateTime(2026, 11, 27, 10, 0),
        ),
        // Duplicate song id should be deduplicated
        HistoryModel(
          id: 'h-0',
          song: const HistorySongModel(
            id: 'recent-1',
            title: 'Recently Listened Track',
            artist: 'History Artist',
            duration: Duration(seconds: 200),
            fileUrl: 'https://example.com/recent1.mp3',
          ),
          playedAt: DateTime(2026, 11, 27, 9, 0),
        ),
      ];
      // Trigger auto-update on the provided HistoryBloc
      historyBloc.add(const HistoryLoadRequested(isRefresh: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(RecentlyPlayedSection), findsOneWidget);
      expect(find.text('Recently Listened Track'), findsOneWidget);

      // Pull-to-refresh should reload both HomeBloc and HistoryBloc
      fakeHistoryRepo.items = [
        HistoryModel(
          id: 'h-2',
          song: const HistorySongModel(
            id: 'recent-2',
            title: 'Refreshed Recent Song',
            artist: 'New Artist',
            duration: Duration(seconds: 180),
            fileUrl: 'https://example.com/recent2.mp3',
          ),
          playedAt: DateTime(2026, 11, 27, 11, 0),
        ),
        ...fakeHistoryRepo.items,
      ];

      await tester.fling(
        find.byType(SingleChildScrollView).first,
        const Offset(0, 300),
        1000,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(fakeHistoryRepo.getHistoryCallCount, greaterThanOrEqualTo(3));
      expect(find.text('Refreshed Recent Song'), findsOneWidget);
    });
  });
}


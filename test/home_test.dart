import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavify/core/di/service_locator.dart';
import 'package:wavify/core/theme/app_theme.dart';
import 'package:wavify/features/home/data/datasources/home_remote_data_source.dart';
import 'package:wavify/features/home/domain/repositories/home_repository.dart';
import 'package:wavify/features/home/domain/usecases/get_all_songs_usecase.dart';
import 'package:wavify/features/home/presentation/bloc/home_bloc.dart';
import 'package:wavify/features/home/presentation/bloc/home_event.dart';
import 'package:wavify/features/home/presentation/bloc/home_state.dart';
import 'package:wavify/features/home/presentation/pages/home_page.dart';
import 'package:wavify/features/home/presentation/widgets/all_songs_section.dart';
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
  });

  group('HomePage Widget Tests', () {
    testWidgets('HomePage displays header, search bar, and all songs', (WidgetTester tester) async {
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
      expect(find.byType(AllSongsSection), findsOneWidget);
      expect(find.text('Midnight Serenade'), findsWidgets);
      expect(find.text('Neon Skyline'), findsWidgets);
    });
  });
}


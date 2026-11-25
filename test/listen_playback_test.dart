import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavify/core/di/service_locator.dart';
import 'package:wavify/core/theme/app_theme.dart';
import 'package:wavify/features/listen/data/models/song_model.dart';
import 'package:wavify/features/listen/data/datasources/audio_player_service.dart';
import 'package:wavify/features/listen/domain/entities/playback_argument.dart';
import 'package:wavify/features/listen/presentation/bloc/player_bloc.dart';
import 'package:wavify/features/listen/presentation/bloc/player_event.dart';
import 'package:wavify/features/listen/presentation/pages/listen_page.dart';

class FakeAudioPlayerService implements AudioPlayerService {
  final _statusCtrl = StreamController<AudioPlayerStatus>.broadcast(sync: true);
  final _posCtrl = StreamController<Duration>.broadcast(sync: true);
  final _durCtrl = StreamController<Duration>.broadcast(sync: true);
  final _compCtrl = StreamController<void>.broadcast(sync: true);

  AudioPlayerStatus status = AudioPlayerStatus.initial;
  Duration position = Duration.zero;
  Duration duration = const Duration(minutes: 3, seconds: 15);

  String? lastPlayedUrl;
  int playCallCount = 0;
  int pauseCallCount = 0;
  int resumeCallCount = 0;
  int stopCallCount = 0;
  Duration? lastSeekPosition;

  @override
  Stream<AudioPlayerStatus> get statusStream => _statusCtrl.stream;

  @override
  Stream<Duration> get positionStream => _posCtrl.stream;

  @override
  Stream<Duration> get durationStream => _durCtrl.stream;

  @override
  Stream<void> get completeStream => _compCtrl.stream;

  @override
  AudioPlayerStatus get currentStatus => status;

  @override
  Duration get currentPosition => position;

  @override
  Duration get currentDuration => duration;

  @override
  Future<void> play(String? url, {Duration? fallbackDuration}) async {
    playCallCount++;
    lastPlayedUrl = url;
    if (fallbackDuration != null) {
      duration = fallbackDuration;
      _durCtrl.add(fallbackDuration);
    }
    position = Duration.zero;
    _posCtrl.add(Duration.zero);
    status = AudioPlayerStatus.playing;
    _statusCtrl.add(AudioPlayerStatus.playing);
  }

  @override
  Future<void> pause() async {
    pauseCallCount++;
    status = AudioPlayerStatus.paused;
    _statusCtrl.add(AudioPlayerStatus.paused);
  }

  @override
  Future<void> resume() async {
    resumeCallCount++;
    status = AudioPlayerStatus.playing;
    _statusCtrl.add(AudioPlayerStatus.playing);
  }

  @override
  Future<void> stop() async {
    stopCallCount++;
    position = Duration.zero;
    _posCtrl.add(Duration.zero);
    status = AudioPlayerStatus.stopped;
    _statusCtrl.add(AudioPlayerStatus.stopped);
  }

  @override
  Future<void> seek(Duration newPosition) async {
    lastSeekPosition = newPosition;
    position = newPosition;
    _posCtrl.add(newPosition);
  }

  @override
  Future<void> setVolume(double volume) async {}

  void emitPosition(Duration pos) {
    position = pos;
    _posCtrl.add(pos);
  }

  void simulateComplete() {
    status = AudioPlayerStatus.completed;
    _statusCtrl.add(AudioPlayerStatus.completed);
    _compCtrl.add(null);
  }

  @override
  Future<void> dispose() async {
    await _statusCtrl.close();
    await _posCtrl.close();
    await _durCtrl.close();
    await _compCtrl.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const song1 = SongModel(
    id: 'song_1',
    title: 'Solar Echoes',
    artist: 'Cosmic Sound',
    album: 'Deep Space',
    coverUrl: '',
    duration: Duration(minutes: 3, seconds: 30),
    fileUrl: 'https://res.cloudinary.com/demo/solar_echoes.mp3',
  );

  const song2 = SongModel(
    id: 'song_2',
    title: 'Starlight Dream',
    artist: 'Luna Ray',
    album: 'Constellations',
    coverUrl: '',
    duration: Duration(minutes: 4, seconds: 10),
    fileUrl: 'https://res.cloudinary.com/demo/starlight.mp3',
  );

  const song3 = SongModel(
    id: 'song_3',
    title: 'Electric Beats',
    artist: 'Neon Wave',
    coverUrl: '',
    duration: Duration(minutes: 2, seconds: 50),
    fileUrl: 'https://res.cloudinary.com/demo/electric.mp3',
  );

  final testPlaylist = [song1, song2, song3];

  group('PlayerBloc Unit Tests', () {
    late FakeAudioPlayerService fakeService;
    late PlayerBloc playerBloc;

    setUp(() {
      fakeService = FakeAudioPlayerService();
      playerBloc = PlayerBloc(audioPlayerService: fakeService);
    });

    tearDown(() async {
      await playerBloc.close();
    });

    test('Initial state is empty/default', () {
      expect(playerBloc.state.playlist, isEmpty);
      expect(playerBloc.state.currentIndex, 0);
      expect(playerBloc.state.isPlaying, isFalse);
    });

    test('PlayerInitQueueRequested initializes playlist', () async {
      playerBloc.add(PlayerInitQueueRequested(playlist: testPlaylist, initialIndex: 1));
      await pumpEventQueue();

      expect(playerBloc.state.playlist.length, 3);
      expect(playerBloc.state.currentIndex, 1);
      expect(playerBloc.state.currentSong?.title, 'Starlight Dream');
      expect(fakeService.playCallCount, 0);
    });

    test('PlayerPlayPlaylistRequested loads playlist and immediately starts playback', () async {
      playerBloc.add(PlayerPlayPlaylistRequested(playlist: testPlaylist, initialIndex: 0));
      await pumpEventQueue();

      expect(playerBloc.state.playlist.length, 3);
      expect(playerBloc.state.currentIndex, 0);
      expect(playerBloc.state.currentSong?.title, 'Solar Echoes');
      expect(fakeService.playCallCount, 1);
      expect(fakeService.lastPlayedUrl, 'https://res.cloudinary.com/demo/solar_echoes.mp3');
      expect(playerBloc.state.isPlaying, isTrue);
    });

    test('PlayerPlayPauseToggled pauses and resumes audio correctly', () async {
      playerBloc.add(PlayerPlayPlaylistRequested(playlist: testPlaylist, initialIndex: 0));
      await pumpEventQueue();
      expect(playerBloc.state.isPlaying, isTrue);

      // Toggle Pause
      playerBloc.add(const PlayerPlayPauseToggled());
      await pumpEventQueue();
      expect(fakeService.pauseCallCount, 1);
      expect(playerBloc.state.isPlaying, isFalse);

      // Toggle Resume
      playerBloc.add(const PlayerPlayPauseToggled());
      await pumpEventQueue();
      expect(fakeService.resumeCallCount, 1);
      expect(playerBloc.state.isPlaying, isTrue);
    });

    test('PlayerNextRequested advances to next track and plays it', () async {
      playerBloc.add(PlayerPlayPlaylistRequested(playlist: testPlaylist, initialIndex: 0));
      await pumpEventQueue();

      playerBloc.add(const PlayerNextRequested());
      await pumpEventQueue();

      expect(playerBloc.state.currentIndex, 1);
      expect(playerBloc.state.currentSong?.title, 'Starlight Dream');
      expect(fakeService.lastPlayedUrl, 'https://res.cloudinary.com/demo/starlight.mp3');
    });

    test('PlayerPreviousRequested returns to previous track and plays it', () async {
      playerBloc.add(PlayerPlayPlaylistRequested(playlist: testPlaylist, initialIndex: 2));
      await pumpEventQueue();

      playerBloc.add(const PlayerPreviousRequested());
      await pumpEventQueue();

      expect(playerBloc.state.currentIndex, 1);
      expect(playerBloc.state.currentSong?.title, 'Starlight Dream');
    });

    test('PlayerSeekRequested updates position', () async {
      playerBloc.add(PlayerPlayPlaylistRequested(playlist: testPlaylist, initialIndex: 0));
      await pumpEventQueue();

      playerBloc.add(const PlayerSeekRequested(Duration(seconds: 45)));
      await pumpEventQueue();

      expect(fakeService.lastSeekPosition, const Duration(seconds: 45));
      expect(playerBloc.state.currentPosition, const Duration(seconds: 45));
    });

    test('PlayerSelectIndexRequested switches song directly from Queue', () async {
      playerBloc.add(PlayerPlayPlaylistRequested(playlist: testPlaylist, initialIndex: 0));
      await pumpEventQueue();

      playerBloc.add(const PlayerSelectIndexRequested(2));
      await pumpEventQueue();

      expect(playerBloc.state.currentIndex, 2);
      expect(playerBloc.state.currentSong?.title, 'Electric Beats');
      expect(fakeService.lastPlayedUrl, 'https://res.cloudinary.com/demo/electric.mp3');
    });

    test('PlayerFavoriteToggled toggles favorite status for current song', () async {
      playerBloc.add(PlayerPlayPlaylistRequested(playlist: testPlaylist, initialIndex: 0));
      await pumpEventQueue();
      expect(playerBloc.state.isFavourite, isFalse);

      playerBloc.add(const PlayerFavoriteToggled());
      await pumpEventQueue();
      expect(playerBloc.state.isFavourite, isTrue);

      playerBloc.add(const PlayerFavoriteToggled());
      await pumpEventQueue();
      expect(playerBloc.state.isFavourite, isFalse);
    });

    test('Auto-advances to next track when track completes', () async {
      playerBloc.add(PlayerPlayPlaylistRequested(playlist: testPlaylist, initialIndex: 0));
      await pumpEventQueue();
      expect(playerBloc.state.currentIndex, 0);

      // Simulate audio player track completion event
      fakeService.simulateComplete();
      await pumpEventQueue();

      expect(playerBloc.state.currentIndex, 1);
      expect(playerBloc.state.currentSong?.title, 'Starlight Dream');
      expect(playerBloc.state.isPlaying, isTrue);
    });

    test('Wraps around to track 0 when last track in playlist completes', () async {
      playerBloc.add(PlayerPlayPlaylistRequested(playlist: testPlaylist, initialIndex: 2));
      await pumpEventQueue();
      expect(playerBloc.state.currentIndex, 2);

      // Simulate track 2 completion
      fakeService.simulateComplete();
      await pumpEventQueue();

      expect(playerBloc.state.currentIndex, 0);
      expect(playerBloc.state.currentSong?.title, 'Solar Echoes');
      expect(playerBloc.state.isPlaying, isTrue);
    });

    test('Repeat mode: replays the current song when track completes', () async {
      playerBloc.add(PlayerPlayPlaylistRequested(playlist: testPlaylist, initialIndex: 1));
      await pumpEventQueue();
      expect(playerBloc.state.currentIndex, 1);

      // Enable repeat
      playerBloc.add(const PlayerRepeatToggled());
      await pumpEventQueue();
      expect(playerBloc.state.isRepeat, isTrue);

      final prevPlayCount = fakeService.playCallCount;

      // Simulate track completion
      fakeService.simulateComplete();
      await pumpEventQueue();

      // Should replay index 1 (same song)
      expect(playerBloc.state.currentIndex, 1);
      expect(playerBloc.state.currentSong?.title, 'Starlight Dream');
      expect(playerBloc.state.isPlaying, isTrue);
      expect(fakeService.playCallCount, prevPlayCount + 1);
    });

    test('Shuffle mode: picks a different random track when track completes', () async {
      playerBloc.add(PlayerPlayPlaylistRequested(playlist: testPlaylist, initialIndex: 0));
      await pumpEventQueue();
      expect(playerBloc.state.currentIndex, 0);

      // Enable shuffle
      playerBloc.add(const PlayerShuffleToggled());
      await pumpEventQueue();
      expect(playerBloc.state.isShuffle, isTrue);

      // Simulate track completion
      fakeService.simulateComplete();
      await pumpEventQueue();

      // Should advance to a different song (index 1 or 2)
      expect(playerBloc.state.currentIndex, isNot(0));
      expect(playerBloc.state.isPlaying, isTrue);
    });

    test('Fallback: position reaching totalDuration auto-advances to next song', () async {
      playerBloc.add(PlayerPlayPlaylistRequested(playlist: testPlaylist, initialIndex: 0));
      await pumpEventQueue();
      expect(playerBloc.state.currentIndex, 0);

      // Total duration of song 1 is 3:30 (210s)
      fakeService.emitPosition(const Duration(minutes: 3, seconds: 30));
      await pumpEventQueue();

      expect(playerBloc.state.currentIndex, 1);
      expect(playerBloc.state.currentSong?.title, 'Starlight Dream');
      expect(playerBloc.state.isPlaying, isTrue);
    });
  });

  group('ListenPage Widget Tests', () {
    late FakeAudioPlayerService fakeService;
    late PlayerBloc playerBloc;

    setUp(() {
      fakeService = FakeAudioPlayerService();
      playerBloc = PlayerBloc(audioPlayerService: fakeService);
      if (sl.isRegistered<PlayerBloc>()) {
        sl.unregister<PlayerBloc>();
      }
      sl.registerSingleton<PlayerBloc>(playerBloc);
    });

    tearDown(() async {
      if (sl.isRegistered<PlayerBloc>()) {
        sl.unregister<PlayerBloc>();
      }
      await playerBloc.close();
    });

    testWidgets('ListenPage renders song title, artist, progress and controls', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      playerBloc.add(PlayerPlayPlaylistRequested(playlist: testPlaylist, initialIndex: 0));

      await tester.pumpWidget(
        BlocProvider<PlayerBloc>.value(
          value: playerBloc,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ListenPage(),
          ),
        ),
      );
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(find.text('Solar Echoes'), findsOneWidget);
      expect(find.text('Cosmic Sound'), findsOneWidget);
      expect(find.byIcon(Icons.skip_previous_rounded), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
      expect(find.byIcon(Icons.queue_music_rounded), findsOneWidget);
      expect(find.text('Queue (3 tracks)'), findsOneWidget);
    });

    testWidgets('Tapping Play/Pause button toggles audio playback', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      playerBloc.add(PlayerPlayPlaylistRequested(playlist: testPlaylist, initialIndex: 0));

      await tester.pumpWidget(
        BlocProvider<PlayerBloc>.value(
          value: playerBloc,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ListenPage(),
          ),
        ),
      );
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      // Tap pause button
      await tester.tap(find.byIcon(Icons.pause_rounded));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(fakeService.pauseCallCount, 1);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      // Tap play button
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(fakeService.resumeCallCount, 1);
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    });

    testWidgets('Tapping Next button skips to next song and starts playing', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      playerBloc.add(PlayerPlayPlaylistRequested(playlist: testPlaylist, initialIndex: 0));

      await tester.pumpWidget(
        BlocProvider<PlayerBloc>.value(
          value: playerBloc,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ListenPage(),
          ),
        ),
      );
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      await tester.tap(find.byIcon(Icons.skip_next_rounded));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(find.text('Starlight Dream'), findsOneWidget);
      expect(find.text('Luna Ray'), findsOneWidget);
    });

    testWidgets('Opening queue and selecting a song immediately plays it', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      playerBloc.add(PlayerPlayPlaylistRequested(playlist: testPlaylist, initialIndex: 0));

      await tester.pumpWidget(
        BlocProvider<PlayerBloc>.value(
          value: playerBloc,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ListenPage(),
          ),
        ),
      );
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      // Tap Queue button to open bottom sheet
      await tester.tap(find.text('Queue (3 tracks)'));
      await tester.pumpAndSettle();

      expect(find.text('Playing Queue'), findsOneWidget);
      expect(find.text('Electric Beats'), findsOneWidget);

      // Tap on third track 'Electric Beats' in queue sheet
      await tester.tap(find.text('Electric Beats'));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();

      expect(find.text('Electric Beats'), findsOneWidget);
      expect(find.text('Neon Wave'), findsOneWidget);
      expect(fakeService.lastPlayedUrl, 'https://res.cloudinary.com/demo/electric.mp3');
    });

    testWidgets('ListenPage handles PlaybackArgument upon mounting', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        BlocProvider<PlayerBloc>.value(
          value: playerBloc,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: ListenPage(
              argument: PlaybackArgument.playlist(testPlaylist, initialIndex: 1),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(find.text('Starlight Dream'), findsOneWidget);
      expect(find.text('Luna Ray'), findsOneWidget);
      expect(fakeService.playCallCount, 1);
    });

    testWidgets('Tapping Shuffle button toggles shuffle mode in UI', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      playerBloc.add(PlayerPlayPlaylistRequested(playlist: testPlaylist, initialIndex: 0));

      await tester.pumpWidget(
        BlocProvider<PlayerBloc>.value(
          value: playerBloc,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ListenPage(),
          ),
        ),
      );
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(playerBloc.state.isShuffle, isFalse);

      await tester.tap(find.byIcon(Icons.shuffle_rounded));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(playerBloc.state.isShuffle, isTrue);
    });

    testWidgets('Tapping Repeat button toggles repeat mode in UI', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      playerBloc.add(PlayerPlayPlaylistRequested(playlist: testPlaylist, initialIndex: 0));

      await tester.pumpWidget(
        BlocProvider<PlayerBloc>.value(
          value: playerBloc,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ListenPage(),
          ),
        ),
      );
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(playerBloc.state.isRepeat, isFalse);

      await tester.tap(find.byIcon(Icons.repeat_rounded));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(playerBloc.state.isRepeat, isTrue);
    });

    testWidgets('ListenPage renders coverUrl background when valid and falls back to theme background when absent', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const songWithCover = SongModel(
        id: 'song_cover',
        title: 'Covered Track',
        artist: 'Cover Artist',
        coverUrl: 'https://example.com/cover.jpg',
        fileUrl: 'https://res.cloudinary.com/demo/solar_echoes.mp3',
      );

      playerBloc.add(const PlayerPlaySongRequested(songWithCover));

      await tester.pumpWidget(
        BlocProvider<PlayerBloc>.value(
          value: playerBloc,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ListenPage(),
          ),
        ),
      );
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      // One Image for the background + one Image inside MusicArtwork
      expect(find.byType(Image), findsNWidgets(2));

      playerBloc.add(PlayerPlayPlaylistRequested(playlist: testPlaylist, initialIndex: 0));
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      // testPlaylist song1 has empty coverUrl -> no Image widgets rendered
      expect(find.byType(Image), findsNothing);
    });
  });
}

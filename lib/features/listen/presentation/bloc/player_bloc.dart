import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/playback_bridge.dart';
import '../../data/datasources/audio_player_service.dart';
import '../../data/models/song_model.dart';
import '../../data/repositories/listen_repository_impl.dart';
import '../../domain/repositories/listen_repository.dart';
import '../../domain/usecases/pause_song_usecase.dart';
import '../../domain/usecases/play_song_usecase.dart';
import '../../domain/usecases/record_listen_history_usecase.dart';
import '../../domain/usecases/resume_song_usecase.dart';
import '../../domain/usecases/seek_song_usecase.dart';
import '../../domain/usecases/stop_song_usecase.dart';
import 'player_event.dart';
import 'player_state.dart';

export '../../../../core/services/playback_bridge.dart' show TrackListenCallback;

class _PlayerStatusUpdated extends PlayerEvent {
  final AudioPlayerStatus status;
  const _PlayerStatusUpdated(this.status);

  @override
  List<Object?> get props => [status];
}

class _PlayerPositionUpdated extends PlayerEvent {
  final Duration position;
  const _PlayerPositionUpdated(this.position);

  @override
  List<Object?> get props => [position];
}

class _PlayerDurationUpdated extends PlayerEvent {
  final Duration duration;
  const _PlayerDurationUpdated(this.duration);

  @override
  List<Object?> get props => [duration];
}

class _PlayerTrackCompleted extends PlayerEvent {
  const _PlayerTrackCompleted();
}

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> implements PlaybackBridge {
  final ListenRepository repository;
  final PlaySongUseCase playSongUseCase;
  final PauseSongUseCase pauseSongUseCase;
  final ResumeSongUseCase resumeSongUseCase;
  final StopSongUseCase stopSongUseCase;
  final SeekSongUseCase seekSongUseCase;
  final RecordListenHistoryUseCase recordListenHistoryUseCase;
  final AudioPlayerService? audioPlayerService;
  final TrackListenCallback? onRecordHistory;
  final Random _random = Random();
  final ValueNotifier<Set<String>> _favouriteSongIdsNotifier = ValueNotifier(const {});

  StreamSubscription<AudioPlayerStatus>? _statusSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<void>? _completeSub;

  bool _hasRecordedCurrentTrack = false;
  bool _advancedForCurrentTrack = false;

  PlayerBloc._({
    required this.repository,
    required this.playSongUseCase,
    required this.pauseSongUseCase,
    required this.resumeSongUseCase,
    required this.stopSongUseCase,
    required this.seekSongUseCase,
    required this.recordListenHistoryUseCase,
    this.audioPlayerService,
    this.onRecordHistory,
  }) : super(const PlayerState()) {
    _registerEventHandlers();
    _initSubscriptions();
  }

  factory PlayerBloc({
    ListenRepository? repository,
    PlaySongUseCase? playSongUseCase,
    PauseSongUseCase? pauseSongUseCase,
    ResumeSongUseCase? resumeSongUseCase,
    StopSongUseCase? stopSongUseCase,
    SeekSongUseCase? seekSongUseCase,
    RecordListenHistoryUseCase? recordListenHistoryUseCase,
    AudioPlayerService? audioPlayerService,
    TrackListenCallback? onRecordHistory,
  }) {
    final ListenRepository resolvedRepo = repository ??
        (audioPlayerService != null
            ? ListenRepositoryImpl(
                audioPlayerService: audioPlayerService,
                onRecordHistory: onRecordHistory,
              )
            : throw ArgumentError('Either repository or audioPlayerService must be provided'));

    return PlayerBloc._(
      repository: resolvedRepo,
      playSongUseCase: playSongUseCase ?? PlaySongUseCase(resolvedRepo),
      pauseSongUseCase: pauseSongUseCase ?? PauseSongUseCase(resolvedRepo),
      resumeSongUseCase: resumeSongUseCase ?? ResumeSongUseCase(resolvedRepo),
      stopSongUseCase: stopSongUseCase ?? StopSongUseCase(resolvedRepo),
      seekSongUseCase: seekSongUseCase ?? SeekSongUseCase(resolvedRepo),
      recordListenHistoryUseCase:
          recordListenHistoryUseCase ?? RecordListenHistoryUseCase(resolvedRepo),
      audioPlayerService: audioPlayerService,
      onRecordHistory: onRecordHistory,
    );
  }

  @override
  Set<String> get favouriteSongIds => state.favouriteSongIds;

  @override
  ValueListenable<Set<String>> get favouriteSongIdsListenable => _favouriteSongIdsNotifier;

  @override
  void playPlaylist(List<Map<String, dynamic>> playlist, {int initialIndex = 0}) {
    add(PlayerPlayPlaylistRequested(playlist: playlist, initialIndex: initialIndex));
  }

  void _registerEventHandlers() {
    on<PlayerInitQueueRequested>(_onInitQueue);
    on<PlayerPlaySongRequested>(_onPlaySong);
    on<PlayerPlayPlaylistRequested>(_onPlayPlaylist);
    on<PlayerPlayPauseToggled>(_onPlayPauseToggled);
    on<PlayerNextRequested>(_onNextRequested);
    on<PlayerPreviousRequested>(_onPreviousRequested);
    on<PlayerSeekRequested>(_onSeekRequested);
    on<PlayerSelectIndexRequested>(_onSelectIndexRequested);
    on<PlayerShuffleToggled>(_onShuffleToggled);
    on<PlayerRepeatToggled>(_onRepeatToggled);
    on<PlayerFavoriteToggled>(_onFavoriteToggled);

    on<_PlayerStatusUpdated>(_onStatusUpdated);
    on<_PlayerPositionUpdated>(_onPositionUpdated);
    on<_PlayerDurationUpdated>(_onDurationUpdated);
    on<_PlayerTrackCompleted>(_onTrackCompleted);
  }

  void _initSubscriptions() {
    _statusSub = repository.statusStream.listen((status) {
      add(_PlayerStatusUpdated(status));
    });
    _positionSub = repository.positionStream.listen((position) {
      add(_PlayerPositionUpdated(position));
    });
    _durationSub = repository.durationStream.listen((duration) {
      add(_PlayerDurationUpdated(duration));
    });
    _completeSub = repository.completeStream.listen((_) {
      add(const _PlayerTrackCompleted());
    });
  }

  Future<void> _onInitQueue(
    PlayerInitQueueRequested event,
    Emitter<PlayerState> emit,
  ) async {
    final songs = event.playlist.map(SongModel.fromPayload).toList();
    if (songs.isEmpty) {
      emit(state.copyWith(
        playlist: const [],
        currentIndex: 0,
        currentPosition: Duration.zero,
        totalDuration: Duration.zero,
        isPlaying: false,
      ));
      return;
    }

    final targetIndex = event.initialIndex.clamp(0, songs.length - 1);
    final favIds = Set<String>.from(state.favouriteSongIds)
      ..addAll(songs.where((s) => s.isFavourite).map((s) => s.id));

    _favouriteSongIdsNotifier.value = favIds;

    emit(state.copyWith(
      playlist: songs,
      currentIndex: targetIndex,
      currentPosition: Duration.zero,
      totalDuration: songs[targetIndex].duration,
      isPlaying: false,
      favouriteSongIds: favIds,
    ));
  }

  Future<void> _onPlaySong(
    PlayerPlaySongRequested event,
    Emitter<PlayerState> emit,
  ) async {
    final song = SongModel.fromPayload(event.song);
    final existingIdx = state.playlist.indexWhere((s) => s.id == song.id);
    if (existingIdx >= 0) {
      await _playAtIndex(state.playlist, existingIdx, emit);
    } else {
      await _playAtIndex([song], 0, emit);
    }
  }

  Future<void> _onPlayPlaylist(
    PlayerPlayPlaylistRequested event,
    Emitter<PlayerState> emit,
  ) async {
    final songs = event.playlist.map(SongModel.fromPayload).toList();
    if (songs.isEmpty) return;

    final targetIndex = event.initialIndex.clamp(0, songs.length - 1);
    await _playAtIndex(songs, targetIndex, emit);
  }

  Future<void> _playAtIndex(
    List<SongModel> playlist,
    int index,
    Emitter<PlayerState> emit,
  ) async {
    if (playlist.isEmpty || index < 0 || index >= playlist.length) return;

    _hasRecordedCurrentTrack = false;
    _advancedForCurrentTrack = false;

    final song = playlist[index];
    final favIds = Set<String>.from(state.favouriteSongIds)
      ..addAll(playlist.where((s) => s.isFavourite).map((s) => s.id));

    _favouriteSongIdsNotifier.value = favIds;

    emit(state.copyWith(
      playlist: playlist,
      currentIndex: index,
      currentPosition: Duration.zero,
      totalDuration: song.duration,
      isPlaying: true,
      status: AudioPlayerStatus.playing,
      favouriteSongIds: favIds,
    ));

    await playSongUseCase(
      song.fileUrl,
      fallbackDuration: song.duration,
    );
  }

  Future<void> _onPlayPauseToggled(
    PlayerPlayPauseToggled event,
    Emitter<PlayerState> emit,
  ) async {
    if (state.currentSong == null) return;

    if (state.isPlaying) {
      await pauseSongUseCase();
      emit(state.copyWith(
        isPlaying: false,
        status: AudioPlayerStatus.paused,
      ));
    } else {
      if (repository.currentStatus == AudioPlayerStatus.paused) {
        await resumeSongUseCase();
        emit(state.copyWith(
          isPlaying: true,
          status: AudioPlayerStatus.playing,
        ));
      } else {
        await _playAtIndex(state.playlist, state.currentIndex, emit);
      }
    }
  }

  int _resolveNextIndex() {
    if (state.playlist.length <= 1) return 0;
    if (state.isShuffle) {
      int next = _random.nextInt(state.playlist.length);
      while (next == state.currentIndex) {
        next = _random.nextInt(state.playlist.length);
      }
      return next;
    }
    return (state.currentIndex + 1) % state.playlist.length;
  }

  Future<void> _onNextRequested(
    PlayerNextRequested event,
    Emitter<PlayerState> emit,
  ) async {
    if (state.playlist.isEmpty) return;
    final nextIndex = _resolveNextIndex();
    await _playAtIndex(state.playlist, nextIndex, emit);
  }

  Future<void> _onPreviousRequested(
    PlayerPreviousRequested event,
    Emitter<PlayerState> emit,
  ) async {
    if (state.playlist.isEmpty) return;
    final prevIndex =
        (state.currentIndex - 1 + state.playlist.length) % state.playlist.length;
    await _playAtIndex(state.playlist, prevIndex, emit);
  }

  Future<void> _onSeekRequested(
    PlayerSeekRequested event,
    Emitter<PlayerState> emit,
  ) async {
    await seekSongUseCase(event.position);
    emit(state.copyWith(currentPosition: event.position));
  }

  Future<void> _onSelectIndexRequested(
    PlayerSelectIndexRequested event,
    Emitter<PlayerState> emit,
  ) async {
    if (event.index < 0 || event.index >= state.playlist.length) return;
    await _playAtIndex(state.playlist, event.index, emit);
  }

  void _onShuffleToggled(
    PlayerShuffleToggled event,
    Emitter<PlayerState> emit,
  ) {
    emit(state.copyWith(isShuffle: !state.isShuffle));
  }

  void _onRepeatToggled(
    PlayerRepeatToggled event,
    Emitter<PlayerState> emit,
  ) {
    emit(state.copyWith(isRepeat: !state.isRepeat));
  }

  void _onFavoriteToggled(
    PlayerFavoriteToggled event,
    Emitter<PlayerState> emit,
  ) {
    final song = state.currentSong;
    if (song == null) return;

    final updatedFavs = Set<String>.from(state.favouriteSongIds);
    if (updatedFavs.contains(song.id)) {
      updatedFavs.remove(song.id);
    } else {
      updatedFavs.add(song.id);
    }

    _favouriteSongIdsNotifier.value = updatedFavs;
    emit(state.copyWith(favouriteSongIds: updatedFavs));
  }

  void _onStatusUpdated(
    _PlayerStatusUpdated event,
    Emitter<PlayerState> emit,
  ) {
    emit(state.copyWith(
      status: event.status,
      isPlaying: event.status == AudioPlayerStatus.playing,
    ));
  }

  Future<void> _onPositionUpdated(
    _PlayerPositionUpdated event,
    Emitter<PlayerState> emit,
  ) async {
    final pos = event.position;
    emit(state.copyWith(currentPosition: pos));

    final currentSong = state.currentSong;
    if (!_hasRecordedCurrentTrack &&
        pos.inSeconds >= 15 &&
        currentSong != null &&
        currentSong.id.isNotEmpty) {
      _hasRecordedCurrentTrack = true;
      unawaited(recordListenHistoryUseCase(currentSong.id).catchError((_) {}));
    }

    if (state.isPlaying &&
        state.totalDuration > Duration.zero &&
        pos >= state.totalDuration &&
        !_advancedForCurrentTrack) {
      _advancedForCurrentTrack = true;
      await _advanceOnComplete(emit);
    }
  }

  void _onDurationUpdated(
    _PlayerDurationUpdated event,
    Emitter<PlayerState> emit,
  ) {
    if (event.duration > Duration.zero) {
      emit(state.copyWith(totalDuration: event.duration));
    }
  }

  Future<void> _onTrackCompleted(
    _PlayerTrackCompleted event,
    Emitter<PlayerState> emit,
  ) async {
    if (_advancedForCurrentTrack) return;
    _advancedForCurrentTrack = true;
    await _advanceOnComplete(emit);
  }

  Future<void> _advanceOnComplete(Emitter<PlayerState> emit) async {
    if (state.playlist.isEmpty) return;
    if (state.isRepeat) {
      await _playAtIndex(state.playlist, state.currentIndex, emit);
    } else {
      final nextIndex = _resolveNextIndex();
      await _playAtIndex(state.playlist, nextIndex, emit);
    }
  }

  @override
  Future<void> close() async {
    await _statusSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _completeSub?.cancel();
    _favouriteSongIdsNotifier.dispose();
    return super.close();
  }
}

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'audio_player_service.dart';

class AudioPlayerServiceImpl implements AudioPlayerService {
  final AudioPlayer _audioPlayer;

  final _statusController = StreamController<AudioPlayerStatus>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _completeController = StreamController<void>.broadcast();

  AudioPlayerStatus _currentStatus = AudioPlayerStatus.initial;
  Duration _currentPosition = Duration.zero;
  Duration _currentDuration = const Duration(minutes: 3, seconds: 15);

  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<void>? _compSub;

  AudioPlayerServiceImpl({AudioPlayer? audioPlayer})
      : _audioPlayer = audioPlayer ?? AudioPlayer() {
    _stateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      switch (state) {
        case PlayerState.playing:
          _emitStatus(AudioPlayerStatus.playing);
          break;
        case PlayerState.paused:
          _emitStatus(AudioPlayerStatus.paused);
          break;
        case PlayerState.stopped:
          _emitStatus(AudioPlayerStatus.stopped);
          break;
        case PlayerState.completed:
          _emitStatus(AudioPlayerStatus.completed);
          break;
        case PlayerState.disposed:
          _emitStatus(AudioPlayerStatus.stopped);
          break;
      }
    });

    _posSub = _audioPlayer.onPositionChanged.listen((pos) {
      _currentPosition = pos;
      if (!_positionController.isClosed) {
        _positionController.add(pos);
      }
    });

    _durSub = _audioPlayer.onDurationChanged.listen((dur) {
      if (dur > Duration.zero) {
        _currentDuration = dur;
        if (!_durationController.isClosed) {
          _durationController.add(dur);
        }
      }
    });

    _compSub = _audioPlayer.onPlayerComplete.listen((_) {
      _emitStatus(AudioPlayerStatus.completed);
      if (!_completeController.isClosed) {
        _completeController.add(null);
      }
    });
  }

  void _emitStatus(AudioPlayerStatus status) {
    _currentStatus = status;
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  @override
  Stream<AudioPlayerStatus> get statusStream => _statusController.stream;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<Duration> get durationStream => _durationController.stream;

  @override
  Stream<void> get completeStream => _completeController.stream;

  @override
  AudioPlayerStatus get currentStatus => _currentStatus;

  @override
  Duration get currentPosition => _currentPosition;

  @override
  Duration get currentDuration => _currentDuration;

  @override
  Future<void> play(String? url, {Duration? fallbackDuration}) async {
    if (fallbackDuration != null && fallbackDuration > Duration.zero) {
      _currentDuration = fallbackDuration;
      if (!_durationController.isClosed) {
        _durationController.add(fallbackDuration);
      }
    }

    _currentPosition = Duration.zero;
    if (!_positionController.isClosed) {
      _positionController.add(Duration.zero);
    }

    if (url == null || url.trim().isEmpty) {
      _emitStatus(AudioPlayerStatus.error);
      return;
    }

    _emitStatus(AudioPlayerStatus.loading);
    try {
      final trimmed = url.trim();
      final Source source = (trimmed.startsWith('http://') || trimmed.startsWith('https://'))
          ? UrlSource(trimmed)
          : DeviceFileSource(trimmed);
      await _audioPlayer.play(source);
      _emitStatus(AudioPlayerStatus.playing);
    } catch (_) {
      _emitStatus(AudioPlayerStatus.error);
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      _emitStatus(AudioPlayerStatus.paused);
    } catch (_) {}
  }

  @override
  Future<void> resume() async {
    try {
      await _audioPlayer.resume();
      _emitStatus(AudioPlayerStatus.playing);
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    _currentPosition = Duration.zero;
    if (!_positionController.isClosed) {
      _positionController.add(Duration.zero);
    }
    _emitStatus(AudioPlayerStatus.stopped);
  }

  @override
  Future<void> seek(Duration newPosition) async {
    try {
      await _audioPlayer.seek(newPosition);
      _currentPosition = newPosition;
      if (!_positionController.isClosed) {
        _positionController.add(newPosition);
      }
    } catch (_) {}
  }

  @override
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {
    await _stateSub?.cancel();
    await _posSub?.cancel();
    await _durSub?.cancel();
    await _compSub?.cancel();
    await _audioPlayer.dispose();
    await _statusController.close();
    await _positionController.close();
    await _durationController.close();
    await _completeController.close();
  }
}

import '../../domain/entities/audio_player_status.dart';

export '../../domain/entities/audio_player_status.dart';

abstract class AudioPlayerService {
  Stream<AudioPlayerStatus> get statusStream;
  Stream<Duration> get positionStream;
  Stream<Duration> get durationStream;
  Stream<void> get completeStream;

  AudioPlayerStatus get currentStatus;
  Duration get currentPosition;
  Duration get currentDuration;

  Future<void> play(String? url, {Duration? fallbackDuration});
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> seek(Duration newPosition);
  Future<void> setVolume(double volume);
  Future<void> dispose();
}

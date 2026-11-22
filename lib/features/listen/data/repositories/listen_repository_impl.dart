import '../../../../core/services/playback_bridge.dart';
import '../../domain/repositories/listen_repository.dart';
import '../datasources/audio_player_service.dart';

class ListenRepositoryImpl implements ListenRepository {
  final AudioPlayerService audioPlayerService;
  final TrackListenCallback? onRecordHistory;

  ListenRepositoryImpl({
    required this.audioPlayerService,
    this.onRecordHistory,
  });

  @override
  Stream<AudioPlayerStatus> get statusStream => audioPlayerService.statusStream;

  @override
  Stream<Duration> get positionStream => audioPlayerService.positionStream;

  @override
  Stream<Duration> get durationStream => audioPlayerService.durationStream;

  @override
  Stream<void> get completeStream => audioPlayerService.completeStream;

  @override
  AudioPlayerStatus get currentStatus => audioPlayerService.currentStatus;

  @override
  Duration get currentPosition => audioPlayerService.currentPosition;

  @override
  Duration get currentDuration => audioPlayerService.currentDuration;

  @override
  Future<void> play(String? url, {Duration? fallbackDuration}) {
    return audioPlayerService.play(url, fallbackDuration: fallbackDuration);
  }

  @override
  Future<void> pause() => audioPlayerService.pause();

  @override
  Future<void> resume() => audioPlayerService.resume();

  @override
  Future<void> stop() => audioPlayerService.stop();

  @override
  Future<void> seek(Duration newPosition) => audioPlayerService.seek(newPosition);

  @override
  Future<void> setVolume(double volume) => audioPlayerService.setVolume(volume);

  @override
  Future<void> recordListenHistory(String songId) async {
    if (onRecordHistory != null) {
      await onRecordHistory!(songId);
    }
  }

  @override
  Future<void> dispose() => audioPlayerService.dispose();
}

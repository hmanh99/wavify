import '../services/playback_bridge.dart';
import '../../features/listen/data/datasources/audio_player_service.dart';
import '../../features/listen/data/datasources/audio_player_service_impl.dart';
import '../../features/listen/data/repositories/listen_repository_impl.dart';
import '../../features/listen/domain/repositories/listen_repository.dart';
import '../../features/listen/domain/usecases/pause_song_usecase.dart';
import '../../features/listen/domain/usecases/play_song_usecase.dart';
import '../../features/listen/domain/usecases/record_listen_history_usecase.dart';
import '../../features/listen/domain/usecases/resume_song_usecase.dart';
import '../../features/listen/domain/usecases/seek_song_usecase.dart';
import '../../features/listen/domain/usecases/set_volume_usecase.dart';
import '../../features/listen/domain/usecases/stop_song_usecase.dart';
import '../../features/listen/presentation/bloc/player_bloc.dart';
import 'service_locator.dart';

Future<void> initListenDependencies({
  AudioPlayerService? customAudioPlayerService,
  TrackListenCallback? onRecordHistory,
}) async {
  // 1. Data Source
  if (!sl.isRegistered<AudioPlayerService>()) {
    sl.registerLazySingleton<AudioPlayerService>(
      () => customAudioPlayerService ?? AudioPlayerServiceImpl(),
    );
  }

  // 2. Repository
  if (!sl.isRegistered<ListenRepository>()) {
    sl.registerLazySingleton<ListenRepository>(
      () => ListenRepositoryImpl(
        audioPlayerService: sl<AudioPlayerService>(),
        onRecordHistory: onRecordHistory ??
            (sl.isRegistered<TrackListenCallback>()
                ? sl<TrackListenCallback>()
                : null),
      ),
    );
  }

  // 3. Use Cases
  if (!sl.isRegistered<PlaySongUseCase>()) {
    sl.registerLazySingleton(() => PlaySongUseCase(sl<ListenRepository>()));
  }
  if (!sl.isRegistered<PauseSongUseCase>()) {
    sl.registerLazySingleton(() => PauseSongUseCase(sl<ListenRepository>()));
  }
  if (!sl.isRegistered<ResumeSongUseCase>()) {
    sl.registerLazySingleton(() => ResumeSongUseCase(sl<ListenRepository>()));
  }
  if (!sl.isRegistered<StopSongUseCase>()) {
    sl.registerLazySingleton(() => StopSongUseCase(sl<ListenRepository>()));
  }
  if (!sl.isRegistered<SeekSongUseCase>()) {
    sl.registerLazySingleton(() => SeekSongUseCase(sl<ListenRepository>()));
  }
  if (!sl.isRegistered<SetVolumeUseCase>()) {
    sl.registerLazySingleton(() => SetVolumeUseCase(sl<ListenRepository>()));
  }
  if (!sl.isRegistered<RecordListenHistoryUseCase>()) {
    sl.registerLazySingleton(
      () => RecordListenHistoryUseCase(sl<ListenRepository>()),
    );
  }

  // 4. PlayerBloc (singleton so audio state persists across tabs and navigation)
  if (!sl.isRegistered<PlayerBloc>()) {
    sl.registerLazySingleton<PlayerBloc>(
      () => PlayerBloc(
        repository: sl<ListenRepository>(),
        playSongUseCase: sl<PlaySongUseCase>(),
        pauseSongUseCase: sl<PauseSongUseCase>(),
        resumeSongUseCase: sl<ResumeSongUseCase>(),
        stopSongUseCase: sl<StopSongUseCase>(),
        seekSongUseCase: sl<SeekSongUseCase>(),
        recordListenHistoryUseCase: sl<RecordListenHistoryUseCase>(),
        audioPlayerService: sl<AudioPlayerService>(),
        onRecordHistory: onRecordHistory ??
            (sl.isRegistered<TrackListenCallback>()
                ? sl<TrackListenCallback>()
                : null),
      ),
    );
  }

  // 5. PlaybackBridge (interface in core for cross-feature playback without cross-feature imports)
  if (!sl.isRegistered<PlaybackBridge>()) {
    sl.registerLazySingleton<PlaybackBridge>(() => sl<PlayerBloc>());
  }
}

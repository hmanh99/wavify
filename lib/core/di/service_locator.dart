import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../services/playback_bridge.dart';
import '../../features/listen/data/datasources/audio_player_service.dart';
import 'auth_injection.dart';
import 'dio_injection.dart';
import 'favorite_injection.dart';
import 'history_injection.dart';
import 'home_injection.dart';
import 'listen_injection.dart';
import 'profile_injection.dart';
import 'upload_injection.dart';

export 'auth_injection.dart';
export 'dio_injection.dart';
export 'favorite_injection.dart';
export 'history_injection.dart';
export 'home_injection.dart';
export 'listen_injection.dart';
export 'profile_injection.dart';
export 'upload_injection.dart';

/// Global single instance of GetIt Service Locator
final sl = GetIt.instance;

/// Alias for [sl] to support getIt naming convention
final getIt = sl;

/// Unified Service Locator manager
class ServiceLocator {
  ServiceLocator._();

  /// The underlying [GetIt] instance
  static GetIt get instance => sl;

  /// Single call to initialize all application dependencies
  static Future<void> init({
    String? baseUrl,
    Dio? customDio,
    AudioPlayerService? customAudioPlayerService,
    TrackListenCallback? onRecordHistory,
  }) =>
      initDependencies(
        baseUrl: baseUrl,
        customDio: customDio,
        customAudioPlayerService: customAudioPlayerService,
        onRecordHistory: onRecordHistory,
      );

  /// Resolve a dependency instance by type [T]
  static T get<T extends Object>({String? instanceName}) =>
      sl<T>(instanceName: instanceName);

  /// Check if a dependency is registered
  static bool isRegistered<T extends Object>({String? instanceName}) =>
      sl.isRegistered<T>(instanceName: instanceName);

  /// Reset all registrations (e.g. between tests)
  static Future<void> reset({bool dispose = true}) =>
      sl.reset(dispose: dispose);
}

/// Unified initialization function that sets up all feature dependencies
Future<void> initDependencies({
  String? baseUrl,
  Dio? customDio,
  AudioPlayerService? customAudioPlayerService,
  TrackListenCallback? onRecordHistory,
}) async {
  await initDioDependencies(baseUrl: baseUrl, customDio: customDio);
  await initAuthDependencies(baseUrl: baseUrl, customDio: customDio);
  await initProfileDependencies(baseUrl: baseUrl, customDio: customDio);
  await initHistoryDependencies(baseUrl: baseUrl, customDio: customDio);
  await initUploadDependencies(baseUrl: baseUrl, customDio: customDio);
  await initHomeDependencies(baseUrl: baseUrl, customDio: customDio);
  await initFavoriteDependencies(baseUrl: baseUrl, customDio: customDio);
  await initListenDependencies(
    customAudioPlayerService: customAudioPlayerService,
    onRecordHistory: onRecordHistory,
  );
}

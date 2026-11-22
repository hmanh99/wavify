import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavify/core/constants/api_constants.dart';
import 'package:wavify/core/di/service_locator.dart';
import 'package:wavify/core/services/playback_bridge.dart';
import 'package:wavify/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wavify/features/history/presentation/bloc/history_bloc.dart';
import 'package:wavify/features/home/presentation/bloc/home_bloc.dart';
import 'package:wavify/features/listen/data/datasources/audio_player_service.dart';
import 'package:wavify/features/listen/presentation/bloc/player_bloc.dart';
import 'package:wavify/features/playlist/presentation/bloc/playlist_bloc.dart';
import 'package:wavify/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:wavify/features/upload/presentation/bloc/upload_bloc.dart';
import 'listen_playback_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await ServiceLocator.reset();
  });

  group('ServiceLocator & initDependencies Tests', () {
    test('ServiceLocator.init registers all feature dependencies with a single call', () async {
      expect(ServiceLocator.isRegistered<AuthBloc>(), isFalse);
      expect(ServiceLocator.isRegistered<HomeBloc>(), isFalse);
      expect(ServiceLocator.isRegistered<ProfileBloc>(), isFalse);
      expect(ServiceLocator.isRegistered<UploadBloc>(), isFalse);
      expect(ServiceLocator.isRegistered<PlaylistBloc>(), isFalse);
      expect(ServiceLocator.isRegistered<HistoryBloc>(), isFalse);
      expect(ServiceLocator.isRegistered<PlayerBloc>(), isFalse);
      expect(ServiceLocator.isRegistered<PlaybackBridge>(), isFalse);
      expect(ServiceLocator.isRegistered<FlutterSecureStorage>(), isFalse);

      // Single call to initialize all DI dependencies
      await ServiceLocator.init(
        customAudioPlayerService: FakeAudioPlayerService(),
      );

      // Verify all BLoCs, services, Dio and bridges are available via ServiceLocator and sl
      expect(ServiceLocator.isRegistered<Dio>(), isTrue);
      expect(ServiceLocator.isRegistered<Dio>(instanceName: 'refreshDio'), isTrue);
      expect(sl<Dio>().options.baseUrl, ApiConstants.baseUrl);
      expect(sl<Dio>().options.baseUrl, 'http://32.236.168.191:8080');
      expect(
        sl<Dio>(instanceName: 'refreshDio').options.baseUrl,
        'http://32.236.168.191:8080',
      );
      expect(ServiceLocator.isRegistered<AuthBloc>(), isTrue);
      expect(ServiceLocator.isRegistered<HomeBloc>(), isTrue);
      expect(ServiceLocator.isRegistered<ProfileBloc>(), isTrue);
      expect(ServiceLocator.isRegistered<UploadBloc>(), isTrue);
      expect(ServiceLocator.isRegistered<PlaylistBloc>(), isTrue);
      expect(ServiceLocator.isRegistered<HistoryBloc>(), isTrue);
      expect(ServiceLocator.isRegistered<PlayerBloc>(), isTrue);
      expect(ServiceLocator.isRegistered<PlaybackBridge>(), isTrue);
      expect(ServiceLocator.isRegistered<FlutterSecureStorage>(), isTrue);

      // Verify resolution via sl and ServiceLocator.get
      expect(sl<AuthBloc>(), isA<AuthBloc>());
      expect(ServiceLocator.get<HomeBloc>(), isA<HomeBloc>());
      expect(ServiceLocator.get<PlayerBloc>(), isA<PlayerBloc>());
      expect(sl<PlaybackBridge>(), isA<PlaybackBridge>());
      expect(sl<AudioPlayerService>(), isA<AudioPlayerService>());
    });

    test('Calling initDependencies multiple times is idempotent and safe', () async {
      await initDependencies(customAudioPlayerService: FakeAudioPlayerService());
      // Should not throw duplicate registration error
      await initDependencies(customAudioPlayerService: FakeAudioPlayerService());

      expect(ServiceLocator.isRegistered<AuthBloc>(), isTrue);
      expect(ServiceLocator.isRegistered<PlaylistBloc>(), isTrue);
    });

    test('sl and getIt reference the exact same GetIt instance', () {
      expect(identical(sl, getIt), isTrue);
      expect(identical(ServiceLocator.instance, sl), isTrue);
    });

    test('ServiceLocator.init supports overriding Dio baseUrl', () async {
      await ServiceLocator.init(
        baseUrl: 'http://192.168.1.10:8080/',
        customAudioPlayerService: FakeAudioPlayerService(),
      );

      expect(sl<Dio>().options.baseUrl, 'http://192.168.1.10:8080');
      expect(
        sl<Dio>(instanceName: 'refreshDio').options.baseUrl,
        'http://192.168.1.10:8080',
      );
    });
  });
}

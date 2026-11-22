import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/interceptors/auth_interceptor.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/refresh_token_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import 'service_locator.dart';

Future<void> initAuthDependencies({
  String? baseUrl,
  Dio? customDio,
}) async {
  await initDioDependencies(baseUrl: baseUrl, customDio: customDio);

  // 1. External & Storage
  if (!sl.isRegistered<FlutterSecureStorage>()) {
    sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    );
  }

  final mainDio = sl<Dio>();

  // 2. Data Sources
  if (!sl.isRegistered<AuthLocalDataSource>()) {
    sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(secureStorage: sl()),
    );
  }

  if (!sl.isRegistered<AuthRemoteDataSource>()) {
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(dio: sl<Dio>()),
    );
  }

  AuthBloc? activeAuthBloc;

  // 3. Interceptors (Refresh Token Rotation)
  final hasAuthInterceptor = mainDio.interceptors.any((i) => i is AuthInterceptor);
  if (!hasAuthInterceptor) {
    final authInterceptor = AuthInterceptor(
      localDataSource: sl(),
      refreshDio: sl(instanceName: 'refreshDio'),
      refreshEndpoint: '/api/v1/auth/refresh',
      onTokenExpired: () {
        if (activeAuthBloc != null && !activeAuthBloc!.isClosed) {
          activeAuthBloc!.add(const AuthSessionExpired());
        }
      },
    );
    mainDio.interceptors.add(authInterceptor);
  }

  // 4. Repositories
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
      ),
    );
  }

  // 5. Use Cases
  if (!sl.isRegistered<LoginUseCase>()) {
    sl.registerLazySingleton(() => LoginUseCase(sl()));
  }
  if (!sl.isRegistered<RegisterUseCase>()) {
    sl.registerLazySingleton(() => RegisterUseCase(sl()));
  }
  if (!sl.isRegistered<RefreshTokenUseCase>()) {
    sl.registerLazySingleton(() => RefreshTokenUseCase(sl()));
  }
  if (!sl.isRegistered<LogoutUseCase>()) {
    sl.registerLazySingleton(() => LogoutUseCase(sl()));
  }
  if (!sl.isRegistered<CheckAuthStatusUseCase>()) {
    sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  }

  // 6. Presentation BLoC
  if (!sl.isRegistered<AuthBloc>()) {
    sl.registerFactory(
      () {
        final bloc = AuthBloc(
          loginUseCase: sl(),
          registerUseCase: sl(),
          logoutUseCase: sl(),
          checkAuthStatusUseCase: sl(),
          authRepository: sl(),
        );
        activeAuthBloc = bloc;
        return bloc;
      },
    );
  }
}

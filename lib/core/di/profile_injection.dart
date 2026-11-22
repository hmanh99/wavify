import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import 'service_locator.dart';

Future<void> initProfileDependencies({String? baseUrl, Dio? customDio}) async {
  await initDioDependencies(baseUrl: baseUrl, customDio: customDio);

  // 1. Data Sources
  if (!sl.isRegistered<ProfileLocalDataSource>()) {
    sl.registerLazySingleton<ProfileLocalDataSource>(
      () => ProfileLocalDataSourceImpl(
        secureStorage: sl<FlutterSecureStorage>(),
      ),
    );
  }

  if (!sl.isRegistered<ProfileRemoteDataSource>()) {
    sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(
        dio: sl<Dio>(),
      ),
    );
  }

  // 2. Repository
  if (!sl.isRegistered<ProfileRepository>()) {
    sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        remoteDataSource: sl<ProfileRemoteDataSource>(),
        localDataSource: sl<ProfileLocalDataSource>(),
      ),
    );
  }

  // 3. Use Cases
  if (!sl.isRegistered<GetProfileUseCase>()) {
    sl.registerLazySingleton<GetProfileUseCase>(
      () => GetProfileUseCase(sl<ProfileRepository>()),
    );
  }

  if (!sl.isRegistered<UpdateProfileUseCase>()) {
    sl.registerLazySingleton<UpdateProfileUseCase>(
      () => UpdateProfileUseCase(sl<ProfileRepository>()),
    );
  }

  // 4. BLoC
  if (!sl.isRegistered<ProfileBloc>()) {
    sl.registerFactory<ProfileBloc>(
      () => ProfileBloc(
        getProfileUseCase: sl<GetProfileUseCase>(),
        updateProfileUseCase: sl<UpdateProfileUseCase>(),
        profileRepository: sl<ProfileRepository>(),
      ),
    );
  }
}

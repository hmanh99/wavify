import 'package:dio/dio.dart';

import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_all_songs_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import 'service_locator.dart';

Future<void> initHomeDependencies({String? baseUrl, Dio? customDio}) async {
  await initDioDependencies(baseUrl: baseUrl, customDio: customDio);

  // 1. Data Source
  if (!sl.isRegistered<HomeRemoteDataSource>()) {
    sl.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(
        dio: sl<Dio>(),
      ),
    );
  }

  // 2. Repository
  if (!sl.isRegistered<HomeRepository>()) {
    sl.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(
        remoteDataSource: sl<HomeRemoteDataSource>(),
      ),
    );
  }

  // 3. Use Case
  if (!sl.isRegistered<GetAllSongsUseCase>()) {
    sl.registerLazySingleton(() => GetAllSongsUseCase(sl<HomeRepository>()));
  }

  // 4. BLoC
  if (!sl.isRegistered<HomeBloc>()) {
    sl.registerFactory<HomeBloc>(
      () => HomeBloc(getAllSongsUseCase: sl<GetAllSongsUseCase>()),
    );
  }
}

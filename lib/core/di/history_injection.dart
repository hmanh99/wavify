import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/playback_bridge.dart';
import '../../features/history/data/datasources/history_local_data_source.dart';
import '../../features/history/data/datasources/history_remote_data_source.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/clear_history_usecase.dart';
import '../../features/history/domain/usecases/delete_history_item_usecase.dart';
import '../../features/history/domain/usecases/get_history_usecase.dart';
import '../../features/history/domain/usecases/record_history_usecase.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';
import 'service_locator.dart';

Future<void> initHistoryDependencies({String? baseUrl, Dio? customDio}) async {
  await initDioDependencies(baseUrl: baseUrl, customDio: customDio);

  // 1. Data Sources
  if (!sl.isRegistered<HistoryLocalDataSource>()) {
    sl.registerLazySingleton<HistoryLocalDataSource>(
      () => HistoryLocalDataSourceImpl(
        secureStorage: sl<FlutterSecureStorage>(),
      ),
    );
  }

  if (!sl.isRegistered<HistoryRemoteDataSource>()) {
    sl.registerLazySingleton<HistoryRemoteDataSource>(
      () => HistoryRemoteDataSourceImpl(
        dio: sl<Dio>(),
      ),
    );
  }

  // 2. Repository
  if (!sl.isRegistered<HistoryRepository>()) {
    sl.registerLazySingleton<HistoryRepository>(
      () => HistoryRepositoryImpl(
        remoteDataSource: sl<HistoryRemoteDataSource>(),
        localDataSource: sl<HistoryLocalDataSource>(),
      ),
    );
  }

  // 3. Use Cases
  if (!sl.isRegistered<RecordHistoryUseCase>()) {
    sl.registerLazySingleton<RecordHistoryUseCase>(
      () => RecordHistoryUseCase(sl<HistoryRepository>()),
    );
  }

  if (!sl.isRegistered<TrackListenCallback>()) {
    sl.registerLazySingleton<TrackListenCallback>(
      () => sl<RecordHistoryUseCase>().call,
    );
  }

  if (!sl.isRegistered<GetHistoryUseCase>()) {
    sl.registerLazySingleton<GetHistoryUseCase>(
      () => GetHistoryUseCase(sl<HistoryRepository>()),
    );
  }

  if (!sl.isRegistered<ClearHistoryUseCase>()) {
    sl.registerLazySingleton<ClearHistoryUseCase>(
      () => ClearHistoryUseCase(sl<HistoryRepository>()),
    );
  }

  if (!sl.isRegistered<DeleteHistoryItemUseCase>()) {
    sl.registerLazySingleton<DeleteHistoryItemUseCase>(
      () => DeleteHistoryItemUseCase(sl<HistoryRepository>()),
    );
  }

  // 4. Presentation BLoC
  if (!sl.isRegistered<HistoryBloc>()) {
    sl.registerFactory<HistoryBloc>(
      () => HistoryBloc(
        getHistoryUseCase: sl<GetHistoryUseCase>(),
        recordHistoryUseCase: sl<RecordHistoryUseCase>(),
        clearHistoryUseCase: sl<ClearHistoryUseCase>(),
        deleteHistoryItemUseCase: sl<DeleteHistoryItemUseCase>(),
      ),
    );
  }
}

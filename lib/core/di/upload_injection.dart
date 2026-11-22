import 'package:dio/dio.dart';

import '../../features/upload/data/datasources/song_remote_data_source.dart';
import '../../features/upload/data/repositories/song_repository_impl.dart';
import '../../features/upload/domain/repositories/song_repository.dart';
import '../../features/upload/domain/usecases/delete_song_usecase.dart';
import '../../features/upload/domain/usecases/get_my_songs_usecase.dart';
import '../../features/upload/domain/usecases/update_song_usecase.dart';
import '../../features/upload/domain/usecases/upload_song_usecase.dart';
import '../../features/upload/presentation/bloc/upload_bloc.dart';
import 'service_locator.dart';

Future<void> initUploadDependencies({String? baseUrl, Dio? customDio}) async {
  await initDioDependencies(baseUrl: baseUrl, customDio: customDio);

  // 1. Remote Data Source
  if (!sl.isRegistered<SongRemoteDataSource>()) {
    sl.registerLazySingleton<SongRemoteDataSource>(
      () => SongRemoteDataSourceImpl(
        dio: sl<Dio>(),
      ),
    );
  }

  // 2. Repository
  if (!sl.isRegistered<SongRepository>()) {
    sl.registerLazySingleton<SongRepository>(
      () => SongRepositoryImpl(
        remoteDataSource: sl<SongRemoteDataSource>(),
      ),
    );
  }

  // 3. Use Cases
  if (!sl.isRegistered<UploadSongUseCase>()) {
    sl.registerLazySingleton(() => UploadSongUseCase(sl<SongRepository>()));
  }
  if (!sl.isRegistered<UpdateSongUseCase>()) {
    sl.registerLazySingleton(() => UpdateSongUseCase(sl<SongRepository>()));
  }
  if (!sl.isRegistered<DeleteSongUseCase>()) {
    sl.registerLazySingleton(() => DeleteSongUseCase(sl<SongRepository>()));
  }
  if (!sl.isRegistered<GetMySongsUseCase>()) {
    sl.registerLazySingleton(() => GetMySongsUseCase(sl<SongRepository>()));
  }

  // 4. BLoC
  if (!sl.isRegistered<UploadBloc>()) {
    sl.registerFactory<UploadBloc>(
      () => UploadBloc(
        uploadSongUseCase: sl<UploadSongUseCase>(),
        updateSongUseCase: sl<UpdateSongUseCase>(),
        deleteSongUseCase: sl<DeleteSongUseCase>(),
        getMySongsUseCase: sl<GetMySongsUseCase>(),
      ),
    );
  }
}

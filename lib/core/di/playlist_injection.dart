import 'package:dio/dio.dart';

import '../../features/playlist/data/datasources/playlist_remote_data_source.dart';
import '../../features/playlist/data/repositories/playlist_repository_impl.dart';
import '../../features/playlist/domain/repositories/playlist_repository.dart';
import '../../features/playlist/domain/usecases/add_song_to_playlist_usecase.dart';
import '../../features/playlist/domain/usecases/add_songs_to_playlist_usecase.dart';
import '../../features/playlist/domain/usecases/create_playlist_usecase.dart';
import '../../features/playlist/domain/usecases/delete_playlist_usecase.dart';
import '../../features/playlist/domain/usecases/get_available_songs_usecase.dart';
import '../../features/playlist/domain/usecases/get_my_playlists_usecase.dart';
import '../../features/playlist/domain/usecases/get_playlist_detail_usecase.dart';
import '../../features/playlist/domain/usecases/remove_song_from_playlist_usecase.dart';
import '../../features/playlist/domain/usecases/reorder_playlist_songs_usecase.dart';
import '../../features/playlist/domain/usecases/update_playlist_usecase.dart';
import '../../features/playlist/presentation/bloc/playlist_bloc.dart';
import 'service_locator.dart';

Future<void> initPlaylistDependencies({String? baseUrl, Dio? customDio}) async {
  await initDioDependencies(baseUrl: baseUrl, customDio: customDio);

  // 1. Remote Data Source
  if (!sl.isRegistered<PlaylistRemoteDataSource>()) {
    sl.registerLazySingleton<PlaylistRemoteDataSource>(
      () => PlaylistRemoteDataSourceImpl(
        dio: sl<Dio>(),
      ),
    );
  }

  // 2. Repository
  if (!sl.isRegistered<PlaylistRepository>()) {
    sl.registerLazySingleton<PlaylistRepository>(
      () => PlaylistRepositoryImpl(
        remoteDataSource: sl<PlaylistRemoteDataSource>(),
      ),
    );
  }

  // 3. Use Cases
  if (!sl.isRegistered<GetMyPlaylistsUseCase>()) {
    sl.registerLazySingleton(() => GetMyPlaylistsUseCase(sl<PlaylistRepository>()));
  }
  if (!sl.isRegistered<GetAvailableSongsUseCase>()) {
    sl.registerLazySingleton(() => GetAvailableSongsUseCase(sl<PlaylistRepository>()));
  }
  if (!sl.isRegistered<GetPlaylistDetailUseCase>()) {
    sl.registerLazySingleton(() => GetPlaylistDetailUseCase(sl<PlaylistRepository>()));
  }
  if (!sl.isRegistered<CreatePlaylistUseCase>()) {
    sl.registerLazySingleton(() => CreatePlaylistUseCase(sl<PlaylistRepository>()));
  }
  if (!sl.isRegistered<UpdatePlaylistUseCase>()) {
    sl.registerLazySingleton(() => UpdatePlaylistUseCase(sl<PlaylistRepository>()));
  }
  if (!sl.isRegistered<DeletePlaylistUseCase>()) {
    sl.registerLazySingleton(() => DeletePlaylistUseCase(sl<PlaylistRepository>()));
  }
  if (!sl.isRegistered<AddSongToPlaylistUseCase>()) {
    sl.registerLazySingleton(() => AddSongToPlaylistUseCase(sl<PlaylistRepository>()));
  }
  if (!sl.isRegistered<AddSongsToPlaylistUseCase>()) {
    sl.registerLazySingleton(() => AddSongsToPlaylistUseCase(sl<PlaylistRepository>()));
  }
  if (!sl.isRegistered<RemoveSongFromPlaylistUseCase>()) {
    sl.registerLazySingleton(() => RemoveSongFromPlaylistUseCase(sl<PlaylistRepository>()));
  }
  if (!sl.isRegistered<ReorderPlaylistSongsUseCase>()) {
    sl.registerLazySingleton(() => ReorderPlaylistSongsUseCase(sl<PlaylistRepository>()));
  }

  // 4. BLoC (LazySingleton so it maintains the playlists cache and state across tabs)
  if (!sl.isRegistered<PlaylistBloc>()) {
    sl.registerLazySingleton<PlaylistBloc>(
      () => PlaylistBloc(
        getMyPlaylistsUseCase: sl<GetMyPlaylistsUseCase>(),
        getPlaylistDetailUseCase: sl<GetPlaylistDetailUseCase>(),
        createPlaylistUseCase: sl<CreatePlaylistUseCase>(),
        updatePlaylistUseCase: sl<UpdatePlaylistUseCase>(),
        deletePlaylistUseCase: sl<DeletePlaylistUseCase>(),
        addSongToPlaylistUseCase: sl<AddSongToPlaylistUseCase>(),
        addSongsToPlaylistUseCase: sl<AddSongsToPlaylistUseCase>(),
        removeSongFromPlaylistUseCase: sl<RemoveSongFromPlaylistUseCase>(),
        reorderPlaylistSongsUseCase: sl<ReorderPlaylistSongsUseCase>(),
      ),
    );
  }
}

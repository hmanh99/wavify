import 'package:dio/dio.dart';

import '../../features/favorite/data/datasources/favorite_remote_data_source.dart';
import '../../features/favorite/data/datasources/playlist_remote_data_source.dart';
import '../../features/favorite/data/repositories/favorite_repository_impl.dart';
import '../../features/favorite/data/repositories/playlist_repository_impl.dart';
import '../../features/favorite/domain/repositories/favorite_repository.dart';
import '../../features/favorite/domain/repositories/playlist_repository.dart';
import '../../features/favorite/domain/usecases/add_favorite_playlist_usecase.dart';
import '../../features/favorite/domain/usecases/add_favorite_song_usecase.dart';
import '../../features/favorite/domain/usecases/add_song_to_playlist_usecase.dart';
import '../../features/favorite/domain/usecases/add_songs_to_playlist_usecase.dart';
import '../../features/favorite/domain/usecases/check_favorite_playlists_usecase.dart';
import '../../features/favorite/domain/usecases/check_favorite_songs_usecase.dart';
import '../../features/favorite/domain/usecases/create_playlist_usecase.dart';
import '../../features/favorite/domain/usecases/delete_playlist_usecase.dart';
import '../../features/favorite/domain/usecases/get_available_songs_usecase.dart';
import '../../features/favorite/domain/usecases/get_favorite_playlists_usecase.dart';
import '../../features/favorite/domain/usecases/get_favorite_songs_usecase.dart';
import '../../features/favorite/domain/usecases/get_my_playlists_usecase.dart';
import '../../features/favorite/domain/usecases/get_playlist_detail_usecase.dart';
import '../../features/favorite/domain/usecases/remove_favorite_playlist_usecase.dart';
import '../../features/favorite/domain/usecases/remove_favorite_song_usecase.dart';
import '../../features/favorite/domain/usecases/remove_song_from_playlist_usecase.dart';
import '../../features/favorite/domain/usecases/reorder_playlist_songs_usecase.dart';
import '../../features/favorite/domain/usecases/search_public_playlists_usecase.dart';
import '../../features/favorite/domain/usecases/update_playlist_usecase.dart';
import '../../features/favorite/presentation/bloc/favorite_bloc.dart';
import '../../features/favorite/presentation/bloc/favorite_event.dart';
import '../../features/favorite/presentation/bloc/playlist_bloc.dart';
import '../../features/listen/presentation/bloc/player_bloc.dart';
import '../../features/listen/presentation/bloc/player_event.dart';
import 'service_locator.dart';

Future<void> initFavoriteDependencies({
  String? baseUrl,
  Dio? customDio,
}) async {
  await initDioDependencies(baseUrl: baseUrl, customDio: customDio);

  // 1. Remote Data Sources
  if (!sl.isRegistered<FavoriteRemoteDataSource>()) {
    sl.registerLazySingleton<FavoriteRemoteDataSource>(
      () => FavoriteRemoteDataSourceImpl(dio: sl<Dio>()),
    );
  }
  if (!sl.isRegistered<PlaylistRemoteDataSource>()) {
    sl.registerLazySingleton<PlaylistRemoteDataSource>(
      () => PlaylistRemoteDataSourceImpl(dio: sl<Dio>()),
    );
  }

  // 2. Repositories
  if (!sl.isRegistered<FavoriteRepository>()) {
    sl.registerLazySingleton<FavoriteRepository>(
      () => FavoriteRepositoryImpl(
        remoteDataSource: sl<FavoriteRemoteDataSource>(),
      ),
    );
  }
  if (!sl.isRegistered<PlaylistRepository>()) {
    sl.registerLazySingleton<PlaylistRepository>(
      () => PlaylistRepositoryImpl(
        remoteDataSource: sl<PlaylistRemoteDataSource>(),
      ),
    );
  }

  // 3. Use Cases - Favorite
  if (!sl.isRegistered<GetFavoriteSongsUseCase>()) {
    sl.registerLazySingleton(
      () => GetFavoriteSongsUseCase(sl<FavoriteRepository>()),
    );
  }
  if (!sl.isRegistered<AddFavoriteSongUseCase>()) {
    sl.registerLazySingleton(
      () => AddFavoriteSongUseCase(sl<FavoriteRepository>()),
    );
  }
  if (!sl.isRegistered<RemoveFavoriteSongUseCase>()) {
    sl.registerLazySingleton(
      () => RemoveFavoriteSongUseCase(sl<FavoriteRepository>()),
    );
  }
  if (!sl.isRegistered<CheckFavoriteSongsUseCase>()) {
    sl.registerLazySingleton(
      () => CheckFavoriteSongsUseCase(sl<FavoriteRepository>()),
    );
  }
  if (!sl.isRegistered<GetFavoritePlaylistsUseCase>()) {
    sl.registerLazySingleton(
      () => GetFavoritePlaylistsUseCase(sl<FavoriteRepository>()),
    );
  }
  if (!sl.isRegistered<AddFavoritePlaylistUseCase>()) {
    sl.registerLazySingleton(
      () => AddFavoritePlaylistUseCase(sl<FavoriteRepository>()),
    );
  }
  if (!sl.isRegistered<RemoveFavoritePlaylistUseCase>()) {
    sl.registerLazySingleton(
      () => RemoveFavoritePlaylistUseCase(sl<FavoriteRepository>()),
    );
  }
  if (!sl.isRegistered<CheckFavoritePlaylistsUseCase>()) {
    sl.registerLazySingleton(
      () => CheckFavoritePlaylistsUseCase(sl<FavoriteRepository>()),
    );
  }

  // 3b. Use Cases - Playlist
  if (!sl.isRegistered<GetMyPlaylistsUseCase>()) {
    sl.registerLazySingleton(
      () => GetMyPlaylistsUseCase(sl<PlaylistRepository>()),
    );
  }
  if (!sl.isRegistered<SearchPublicPlaylistsUseCase>()) {
    sl.registerLazySingleton(
      () => SearchPublicPlaylistsUseCase(sl<PlaylistRepository>()),
    );
  }
  if (!sl.isRegistered<GetAvailableSongsUseCase>()) {
    sl.registerLazySingleton(
      () => GetAvailableSongsUseCase(sl<PlaylistRepository>()),
    );
  }
  if (!sl.isRegistered<GetPlaylistDetailUseCase>()) {
    sl.registerLazySingleton(
      () => GetPlaylistDetailUseCase(sl<PlaylistRepository>()),
    );
  }
  if (!sl.isRegistered<CreatePlaylistUseCase>()) {
    sl.registerLazySingleton(
      () => CreatePlaylistUseCase(sl<PlaylistRepository>()),
    );
  }
  if (!sl.isRegistered<UpdatePlaylistUseCase>()) {
    sl.registerLazySingleton(
      () => UpdatePlaylistUseCase(sl<PlaylistRepository>()),
    );
  }
  if (!sl.isRegistered<DeletePlaylistUseCase>()) {
    sl.registerLazySingleton(
      () => DeletePlaylistUseCase(sl<PlaylistRepository>()),
    );
  }
  if (!sl.isRegistered<AddSongToPlaylistUseCase>()) {
    sl.registerLazySingleton(
      () => AddSongToPlaylistUseCase(sl<PlaylistRepository>()),
    );
  }
  if (!sl.isRegistered<AddSongsToPlaylistUseCase>()) {
    sl.registerLazySingleton(
      () => AddSongsToPlaylistUseCase(sl<PlaylistRepository>()),
    );
  }
  if (!sl.isRegistered<RemoveSongFromPlaylistUseCase>()) {
    sl.registerLazySingleton(
      () => RemoveSongFromPlaylistUseCase(sl<PlaylistRepository>()),
    );
  }
  if (!sl.isRegistered<ReorderPlaylistSongsUseCase>()) {
    sl.registerLazySingleton(
      () => ReorderPlaylistSongsUseCase(sl<PlaylistRepository>()),
    );
  }

  // 4. BLoCs (Singletons so state is shared and synced across all tabs)
  if (!sl.isRegistered<FavoriteBloc>()) {
    sl.registerLazySingleton<FavoriteBloc>(
      () => FavoriteBloc(
        getFavoriteSongsUseCase: sl<GetFavoriteSongsUseCase>(),
        addFavoriteSongUseCase: sl<AddFavoriteSongUseCase>(),
        removeFavoriteSongUseCase: sl<RemoveFavoriteSongUseCase>(),
        checkFavoriteSongsUseCase: sl<CheckFavoriteSongsUseCase>(),
        getFavoritePlaylistsUseCase: sl<GetFavoritePlaylistsUseCase>(),
        addFavoritePlaylistUseCase: sl<AddFavoritePlaylistUseCase>(),
        removeFavoritePlaylistUseCase: sl<RemoveFavoritePlaylistUseCase>(),
        checkFavoritePlaylistsUseCase: sl<CheckFavoritePlaylistsUseCase>(),
        onSongFavoritesChanged: (songIds) {
          if (sl.isRegistered<PlayerBloc>()) {
            sl<PlayerBloc>().add(PlayerFavoritesSynced(songIds));
          }
        },
      ),
    );
  }
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
        onPlaylistDeleted: (playlistId) {
          if (sl.isRegistered<FavoriteBloc>()) {
            sl<FavoriteBloc>().add(
              FavoritePlaylistDeletedExternally(playlistId),
            );
          }
        },
      ),
    );
  }
}

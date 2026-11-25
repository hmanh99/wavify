import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/favorite_remote_data_source.dart';
import '../../domain/entities/favorite_playlist_item.dart';
import '../../domain/entities/favorite_song_item.dart';
import '../../domain/usecases/add_favorite_playlist_usecase.dart';
import '../../domain/usecases/add_favorite_song_usecase.dart';
import '../../domain/usecases/check_favorite_playlists_usecase.dart';
import '../../domain/usecases/check_favorite_songs_usecase.dart';
import '../../domain/usecases/get_favorite_playlists_usecase.dart';
import '../../domain/usecases/get_favorite_songs_usecase.dart';
import '../../domain/usecases/remove_favorite_playlist_usecase.dart';
import '../../domain/usecases/remove_favorite_song_usecase.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final GetFavoriteSongsUseCase getFavoriteSongsUseCase;
  final AddFavoriteSongUseCase addFavoriteSongUseCase;
  final RemoveFavoriteSongUseCase removeFavoriteSongUseCase;
  final CheckFavoriteSongsUseCase checkFavoriteSongsUseCase;
  final GetFavoritePlaylistsUseCase getFavoritePlaylistsUseCase;
  final AddFavoritePlaylistUseCase addFavoritePlaylistUseCase;
  final RemoveFavoritePlaylistUseCase removeFavoritePlaylistUseCase;
  final CheckFavoritePlaylistsUseCase checkFavoritePlaylistsUseCase;
  final void Function(Set<String> songIds)? onSongFavoritesChanged;

  FavoriteBloc({
    required this.getFavoriteSongsUseCase,
    required this.addFavoriteSongUseCase,
    required this.removeFavoriteSongUseCase,
    required this.checkFavoriteSongsUseCase,
    required this.getFavoritePlaylistsUseCase,
    required this.addFavoritePlaylistUseCase,
    required this.removeFavoritePlaylistUseCase,
    required this.checkFavoritePlaylistsUseCase,
    this.onSongFavoritesChanged,
  }) : super(const FavoriteState()) {
    on<LoadFavoritesRequested>(_onLoadFavorites);
    on<RefreshFavoritesRequested>(_onRefreshFavorites);
    on<ToggleFavoriteSongRequested>(_onToggleFavoriteSong);
    on<ToggleFavoritePlaylistRequested>(_onToggleFavoritePlaylist);
    on<CheckFavoriteSongsRequested>(_onCheckFavoriteSongs);
    on<CheckFavoritePlaylistsRequested>(_onCheckFavoritePlaylists);
    on<FavoritePlaylistDeletedExternally>(_onPlaylistDeletedExternally);
    on<ClearFavoritesRequested>(_onClearFavorites);
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesRequested event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(state.copyWith(status: FavoriteStatus.loading));
    await _fetchAll(emit);
  }

  Future<void> _onRefreshFavorites(
    RefreshFavoritesRequested event,
    Emitter<FavoriteState> emit,
  ) async {
    await _fetchAll(emit);
  }

  Future<void> _fetchAll(Emitter<FavoriteState> emit) async {
    try {
      final results = await Future.wait([
        getFavoriteSongsUseCase(),
        getFavoritePlaylistsUseCase(),
      ]);

      final songs = results[0] as List<FavoriteSongItem>;
      final playlists = results[1] as List<FavoritePlaylistItem>;
      final songIds = songs.map((e) => e.song.id).toSet();
      final playlistIds = playlists.map((e) => e.playlist.id).toSet();

      onSongFavoritesChanged?.call(songIds);

      emit(
        state.copyWith(
          favoriteSongs: songs,
          favoritePlaylists: playlists,
          favoriteSongIds: songIds,
          favoritePlaylistIds: playlistIds,
          status: FavoriteStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FavoriteStatus.failure,
          errorMessage: _cleanError(e),
        ),
      );
    }
  }

  Future<void> _onToggleFavoriteSong(
    ToggleFavoriteSongRequested event,
    Emitter<FavoriteState> emit,
  ) async {
    if (event.songId.trim().isEmpty) return;
    if (state.pendingSongIds.contains(event.songId)) return;

    final previousSongs = state.favoriteSongs;
    final previousIds = state.favoriteSongIds;
    final currentlyFav = previousIds.contains(event.songId);
    final targetFav = event.desiredState ?? !currentlyFav;

    if (targetFav == currentlyFav) {
      return;
    }

    final optimisticIds = Set<String>.from(previousIds);
    final optimisticSongs = List<FavoriteSongItem>.from(previousSongs);

    if (targetFav) {
      optimisticIds.add(event.songId);
      if (event.song != null) {
        optimisticSongs.removeWhere((item) => item.song.id == event.songId);
        optimisticSongs.insert(
          0,
          FavoriteSongItem(song: event.song!, favoritedAt: DateTime.now()),
        );
      }
    } else {
      optimisticIds.remove(event.songId);
      optimisticSongs.removeWhere((item) => item.song.id == event.songId);
    }

    onSongFavoritesChanged?.call(optimisticIds);

    emit(
      state.copyWith(
        favoriteSongs: optimisticSongs,
        favoriteSongIds: optimisticIds,
        pendingSongIds: {...state.pendingSongIds, event.songId},
      ),
    );

    try {
      if (targetFav) {
        final added = await addFavoriteSongUseCase(event.songId);
        final refreshedList = List<FavoriteSongItem>.from(state.favoriteSongs)
          ..removeWhere((item) => item.song.id == added.song.id)
          ..insert(0, added);
        emit(
          state.copyWith(
            favoriteSongs: refreshedList,
            favoriteSongIds: {...state.favoriteSongIds, added.song.id},
            pendingSongIds: {...state.pendingSongIds}..remove(event.songId),
            status: FavoriteStatus.loaded,
          ),
        );
      } else {
        await removeFavoriteSongUseCase(event.songId);
        emit(
          state.copyWith(
            pendingSongIds: {...state.pendingSongIds}..remove(event.songId),
            status: FavoriteStatus.loaded,
          ),
        );
      }
    } catch (e) {
      if (e is FavoriteApiException) {
        // Handle idempotent server conflicts cleanly
        if (targetFav && e.statusCode == 409) {
          emit(
            state.copyWith(
              pendingSongIds: {...state.pendingSongIds}..remove(event.songId),
              status: FavoriteStatus.loaded,
            ),
          );
          if (event.song == null) {
            add(const RefreshFavoritesRequested());
          }
          return;
        }
        if (!targetFav && e.statusCode == 404) {
          emit(
            state.copyWith(
              pendingSongIds: {...state.pendingSongIds}..remove(event.songId),
              status: FavoriteStatus.loaded,
            ),
          );
          return;
        }
      }

      // Rollback on real error
      onSongFavoritesChanged?.call(previousIds);
      emit(
        state.copyWith(
          favoriteSongs: previousSongs,
          favoriteSongIds: previousIds,
          pendingSongIds: {...state.pendingSongIds}..remove(event.songId),
          status: FavoriteStatus.failure,
          errorMessage: _cleanError(e),
        ),
      );
      emit(state.copyWith(status: FavoriteStatus.loaded));
    }
  }

  Future<void> _onToggleFavoritePlaylist(
    ToggleFavoritePlaylistRequested event,
    Emitter<FavoriteState> emit,
  ) async {
    if (event.playlistId.trim().isEmpty) return;
    if (state.pendingPlaylistIds.contains(event.playlistId)) return;

    final previousPlaylists = state.favoritePlaylists;
    final previousIds = state.favoritePlaylistIds;
    final currentlyFav = previousIds.contains(event.playlistId);
    final targetFav = event.desiredState ?? !currentlyFav;

    if (targetFav == currentlyFav) {
      return;
    }

    final optimisticIds = Set<String>.from(previousIds);
    final optimisticPlaylists = List<FavoritePlaylistItem>.from(
      previousPlaylists,
    );

    if (targetFav) {
      optimisticIds.add(event.playlistId);
      if (event.playlist != null) {
        optimisticPlaylists.removeWhere(
          (item) => item.playlist.id == event.playlistId,
        );
        optimisticPlaylists.insert(
          0,
          FavoritePlaylistItem(
            playlist: event.playlist!,
            favoritedAt: DateTime.now(),
          ),
        );
      }
    } else {
      optimisticIds.remove(event.playlistId);
      optimisticPlaylists.removeWhere(
        (item) => item.playlist.id == event.playlistId,
      );
    }

    emit(
      state.copyWith(
        favoritePlaylists: optimisticPlaylists,
        favoritePlaylistIds: optimisticIds,
        pendingPlaylistIds: {...state.pendingPlaylistIds, event.playlistId},
      ),
    );

    try {
      if (targetFav) {
        final added = await addFavoritePlaylistUseCase(event.playlistId);
        final refreshedList = List<FavoritePlaylistItem>.from(
          state.favoritePlaylists,
        )
          ..removeWhere((item) => item.playlist.id == added.playlist.id)
          ..insert(0, added);
        emit(
          state.copyWith(
            favoritePlaylists: refreshedList,
            favoritePlaylistIds: {
              ...state.favoritePlaylistIds,
              added.playlist.id,
            },
            pendingPlaylistIds: {...state.pendingPlaylistIds}
              ..remove(event.playlistId),
            status: FavoriteStatus.loaded,
          ),
        );
      } else {
        await removeFavoritePlaylistUseCase(event.playlistId);
        emit(
          state.copyWith(
            pendingPlaylistIds: {...state.pendingPlaylistIds}
              ..remove(event.playlistId),
            status: FavoriteStatus.loaded,
          ),
        );
      }
    } catch (e) {
      if (e is FavoriteApiException) {
        if (targetFav && e.statusCode == 409) {
          emit(
            state.copyWith(
              pendingPlaylistIds: {...state.pendingPlaylistIds}
                ..remove(event.playlistId),
              status: FavoriteStatus.loaded,
            ),
          );
          if (event.playlist == null) {
            add(const RefreshFavoritesRequested());
          }
          return;
        }
        if (!targetFav && e.statusCode == 404) {
          emit(
            state.copyWith(
              pendingPlaylistIds: {...state.pendingPlaylistIds}
                ..remove(event.playlistId),
              status: FavoriteStatus.loaded,
            ),
          );
          return;
        }
      }

      // Rollback on real error
      emit(
        state.copyWith(
          favoritePlaylists: previousPlaylists,
          favoritePlaylistIds: previousIds,
          pendingPlaylistIds: {...state.pendingPlaylistIds}
            ..remove(event.playlistId),
          status: FavoriteStatus.failure,
          errorMessage: _cleanError(e),
        ),
      );
      emit(state.copyWith(status: FavoriteStatus.loaded));
    }
  }

  Future<void> _onCheckFavoriteSongs(
    CheckFavoriteSongsRequested event,
    Emitter<FavoriteState> emit,
  ) async {
    if (event.songIds.isEmpty) return;
    try {
      final resultMap = await checkFavoriteSongsUseCase(event.songIds);
      final updatedIds = Set<String>.from(state.favoriteSongIds);
      for (final entry in resultMap.entries) {
        if (entry.value) {
          updatedIds.add(entry.key);
        } else {
          updatedIds.remove(entry.key);
        }
      }
      onSongFavoritesChanged?.call(updatedIds);
      emit(state.copyWith(favoriteSongIds: updatedIds));
    } catch (_) {
      // Non-fatal check failure (e.g., unauthenticated)
    }
  }

  Future<void> _onCheckFavoritePlaylists(
    CheckFavoritePlaylistsRequested event,
    Emitter<FavoriteState> emit,
  ) async {
    if (event.playlistIds.isEmpty) return;
    try {
      final resultMap = await checkFavoritePlaylistsUseCase(event.playlistIds);
      final updatedIds = Set<String>.from(state.favoritePlaylistIds);
      for (final entry in resultMap.entries) {
        if (entry.value) {
          updatedIds.add(entry.key);
        } else {
          updatedIds.remove(entry.key);
        }
      }
      emit(state.copyWith(favoritePlaylistIds: updatedIds));
    } catch (_) {
      // Non-fatal check failure
    }
  }

  void _onPlaylistDeletedExternally(
    FavoritePlaylistDeletedExternally event,
    Emitter<FavoriteState> emit,
  ) {
    if (!state.favoritePlaylistIds.contains(event.playlistId)) return;
    final updatedPlaylists = state.favoritePlaylists
        .where((item) => item.playlist.id != event.playlistId)
        .toList();
    final updatedIds = Set<String>.from(state.favoritePlaylistIds)
      ..remove(event.playlistId);
    emit(
      state.copyWith(
        favoritePlaylists: updatedPlaylists,
        favoritePlaylistIds: updatedIds,
      ),
    );
  }

  void _onClearFavorites(
    ClearFavoritesRequested event,
    Emitter<FavoriteState> emit,
  ) {
    onSongFavoritesChanged?.call(const {});
    emit(const FavoriteState());
  }

  String _cleanError(dynamic error) {
    if (error == null) return 'Có lỗi xảy ra, vui lòng thử lại';
    final str = error.toString();
    if (str.startsWith('Exception: ')) {
      return str.substring('Exception: '.length);
    }
    return str;
  }
}

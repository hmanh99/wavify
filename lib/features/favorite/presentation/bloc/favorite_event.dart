import 'package:equatable/equatable.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/song_entity.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavoritesRequested extends FavoriteEvent {
  const LoadFavoritesRequested();
}

class RefreshFavoritesRequested extends FavoriteEvent {
  const RefreshFavoritesRequested();
}

class ToggleFavoriteSongRequested extends FavoriteEvent {
  final String songId;
  final SongEntity? song;
  final bool? desiredState;

  const ToggleFavoriteSongRequested({
    required this.songId,
    this.song,
    this.desiredState,
  });

  @override
  List<Object?> get props => [songId, song, desiredState];
}

class ToggleFavoritePlaylistRequested extends FavoriteEvent {
  final String playlistId;
  final PlaylistEntity? playlist;
  final bool? desiredState;

  const ToggleFavoritePlaylistRequested({
    required this.playlistId,
    this.playlist,
    this.desiredState,
  });

  @override
  List<Object?> get props => [playlistId, playlist, desiredState];
}

class CheckFavoriteSongsRequested extends FavoriteEvent {
  final List<String> songIds;

  const CheckFavoriteSongsRequested(this.songIds);

  @override
  List<Object?> get props => [songIds];
}

class CheckFavoritePlaylistsRequested extends FavoriteEvent {
  final List<String> playlistIds;

  const CheckFavoritePlaylistsRequested(this.playlistIds);

  @override
  List<Object?> get props => [playlistIds];
}

class FavoritePlaylistDeletedExternally extends FavoriteEvent {
  final String playlistId;

  const FavoritePlaylistDeletedExternally(this.playlistId);

  @override
  List<Object?> get props => [playlistId];
}

class ClearFavoritesRequested extends FavoriteEvent {
  const ClearFavoritesRequested();
}

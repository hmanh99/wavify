import 'package:equatable/equatable.dart';
import '../../domain/entities/favorite_playlist_item.dart';
import '../../domain/entities/favorite_song_item.dart';

enum FavoriteStatus { initial, loading, loaded, failure }

class FavoriteState extends Equatable {
  final List<FavoriteSongItem> favoriteSongs;
  final List<FavoritePlaylistItem> favoritePlaylists;
  final Set<String> favoriteSongIds;
  final Set<String> favoritePlaylistIds;
  final Set<String> pendingSongIds;
  final Set<String> pendingPlaylistIds;
  final FavoriteStatus status;
  final String? message;
  final String? errorMessage;

  const FavoriteState({
    this.favoriteSongs = const [],
    this.favoritePlaylists = const [],
    this.favoriteSongIds = const {},
    this.favoritePlaylistIds = const {},
    this.pendingSongIds = const {},
    this.pendingPlaylistIds = const {},
    this.status = FavoriteStatus.initial,
    this.message,
    this.errorMessage,
  });

  bool get isLoading => status == FavoriteStatus.loading;

  bool isSongFavorite(String songId) => favoriteSongIds.contains(songId);

  bool isPlaylistFavorite(String playlistId) =>
      favoritePlaylistIds.contains(playlistId);

  FavoriteState copyWith({
    List<FavoriteSongItem>? favoriteSongs,
    List<FavoritePlaylistItem>? favoritePlaylists,
    Set<String>? favoriteSongIds,
    Set<String>? favoritePlaylistIds,
    Set<String>? pendingSongIds,
    Set<String>? pendingPlaylistIds,
    FavoriteStatus? status,
    String? message,
    String? errorMessage,
  }) {
    return FavoriteState(
      favoriteSongs: favoriteSongs ?? this.favoriteSongs,
      favoritePlaylists: favoritePlaylists ?? this.favoritePlaylists,
      favoriteSongIds: favoriteSongIds ?? this.favoriteSongIds,
      favoritePlaylistIds: favoritePlaylistIds ?? this.favoritePlaylistIds,
      pendingSongIds: pendingSongIds ?? this.pendingSongIds,
      pendingPlaylistIds: pendingPlaylistIds ?? this.pendingPlaylistIds,
      status: status ?? this.status,
      message: message,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        favoriteSongs,
        favoritePlaylists,
        favoriteSongIds,
        favoritePlaylistIds,
        pendingSongIds,
        pendingPlaylistIds,
        status,
        message,
        errorMessage,
      ];
}

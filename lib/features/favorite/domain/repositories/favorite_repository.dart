import '../entities/favorite_playlist_item.dart';
import '../entities/favorite_song_item.dart';

abstract class FavoriteRepository {
  Future<List<FavoriteSongItem>> getFavoriteSongs({int page = 0, int size = 50});

  Future<FavoriteSongItem> addFavoriteSong(String songId);

  Future<void> removeFavoriteSong(String songId);

  Future<bool> checkFavoriteSong(String songId);

  Future<Map<String, bool>> checkFavoriteSongs(List<String> songIds);

  Future<List<FavoritePlaylistItem>> getFavoritePlaylists({
    int page = 0,
    int size = 50,
  });

  Future<FavoritePlaylistItem> addFavoritePlaylist(String playlistId);

  Future<void> removeFavoritePlaylist(String playlistId);

  Future<bool> checkFavoritePlaylist(String playlistId);

  Future<Map<String, bool>> checkFavoritePlaylists(List<String> playlistIds);
}

import '../../domain/entities/favorite_playlist_item.dart';
import '../../domain/entities/favorite_song_item.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_remote_data_source.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteRemoteDataSource remoteDataSource;

  FavoriteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<FavoriteSongItem>> getFavoriteSongs({
    int page = 0,
    int size = 50,
  }) {
    return remoteDataSource.getFavoriteSongs(page: page, size: size);
  }

  @override
  Future<FavoriteSongItem> addFavoriteSong(String songId) {
    return remoteDataSource.addFavoriteSong(songId);
  }

  @override
  Future<void> removeFavoriteSong(String songId) {
    return remoteDataSource.removeFavoriteSong(songId);
  }

  @override
  Future<bool> checkFavoriteSong(String songId) {
    return remoteDataSource.checkFavoriteSong(songId);
  }

  @override
  Future<Map<String, bool>> checkFavoriteSongs(List<String> songIds) {
    return remoteDataSource.checkFavoriteSongs(songIds);
  }

  @override
  Future<List<FavoritePlaylistItem>> getFavoritePlaylists({
    int page = 0,
    int size = 50,
  }) {
    return remoteDataSource.getFavoritePlaylists(page: page, size: size);
  }

  @override
  Future<FavoritePlaylistItem> addFavoritePlaylist(String playlistId) {
    return remoteDataSource.addFavoritePlaylist(playlistId);
  }

  @override
  Future<void> removeFavoritePlaylist(String playlistId) {
    return remoteDataSource.removeFavoritePlaylist(playlistId);
  }

  @override
  Future<bool> checkFavoritePlaylist(String playlistId) {
    return remoteDataSource.checkFavoritePlaylist(playlistId);
  }

  @override
  Future<Map<String, bool>> checkFavoritePlaylists(List<String> playlistIds) {
    return remoteDataSource.checkFavoritePlaylists(playlistIds);
  }
}

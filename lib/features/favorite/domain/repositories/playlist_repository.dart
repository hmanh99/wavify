import '../entities/playlist_entity.dart';
import '../entities/song_entity.dart';

abstract class PlaylistRepository {
  Future<List<PlaylistEntity>> getMyPlaylists();

  Future<List<PlaylistEntity>> searchPublicPlaylists({
    String? keyword,
    int page = 0,
    int size = 20,
  });

  Future<List<SongEntity>> getAllSongs({int page = 0, int size = 50});

  Future<PlaylistEntity> getPlaylistById(String playlistId);

  Future<PlaylistEntity> createPlaylist({
    required String name,
    String? description,
    String? coverUrl,
    String visibility = 'PUBLIC',
  });

  Future<PlaylistEntity> updatePlaylist({
    required String playlistId,
    required String name,
    String? description,
    String? coverUrl,
    String? visibility,
  });

  Future<void> deletePlaylist(String playlistId);

  Future<PlaylistEntity> addSongToPlaylist({
    required String playlistId,
    required String songId,
  });

  Future<PlaylistEntity> addSongsToPlaylist({
    required String playlistId,
    required List<String> songIds,
  });

  Future<PlaylistEntity> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  });

  Future<PlaylistEntity> reorderPlaylistSongs({
    required String playlistId,
    required List<String> songIds,
  });
}


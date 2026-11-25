import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/song_entity.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../datasources/playlist_remote_data_source.dart';
import '../models/create_playlist_request_model.dart';
import '../models/update_playlist_request_model.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistRemoteDataSource remoteDataSource;

  PlaylistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PlaylistEntity>> getMyPlaylists() async {
    return await remoteDataSource.getMyPlaylists();
  }

  @override
  Future<List<PlaylistEntity>> searchPublicPlaylists({
    String? keyword,
    int page = 0,
    int size = 20,
  }) async {
    return await remoteDataSource.searchPublicPlaylists(
      keyword: keyword,
      page: page,
      size: size,
    );
  }

  @override
  Future<List<SongEntity>> getAllSongs({int page = 0, int size = 50}) async {
    return await remoteDataSource.getAllSongs(page: page, size: size);
  }

  @override
  Future<PlaylistEntity> getPlaylistById(String playlistId) async {
    return await remoteDataSource.getPlaylistById(playlistId);
  }

  @override
  Future<PlaylistEntity> createPlaylist({
    required String name,
    String? description,
    String? coverUrl,
    String visibility = 'PUBLIC',
  }) async {
    final request = CreatePlaylistRequestModel(
      name: name,
      description: description,
      coverUrl: coverUrl,
      visibility: visibility,
    );
    return await remoteDataSource.createPlaylist(request);
  }

  @override
  Future<PlaylistEntity> updatePlaylist({
    required String playlistId,
    required String name,
    String? description,
    String? coverUrl,
    String? visibility,
  }) async {
    final request = UpdatePlaylistRequestModel(
      name: name,
      description: description,
      coverUrl: coverUrl,
      visibility: visibility,
    );
    return await remoteDataSource.updatePlaylist(playlistId, request);
  }

  @override
  Future<void> deletePlaylist(String playlistId) async {
    return await remoteDataSource.deletePlaylist(playlistId);
  }

  @override
  Future<PlaylistEntity> addSongToPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    return await remoteDataSource.addSongToPlaylist(playlistId, songId);
  }

  @override
  Future<PlaylistEntity> addSongsToPlaylist({
    required String playlistId,
    required List<String> songIds,
  }) async {
    return await remoteDataSource.addSongsToPlaylist(playlistId, songIds);
  }

  @override
  Future<PlaylistEntity> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    return await remoteDataSource.removeSongFromPlaylist(playlistId, songId);
  }

  @override
  Future<PlaylistEntity> reorderPlaylistSongs({
    required String playlistId,
    required List<String> songIds,
  }) async {
    return await remoteDataSource.reorderPlaylistSongs(playlistId, songIds);
  }
}


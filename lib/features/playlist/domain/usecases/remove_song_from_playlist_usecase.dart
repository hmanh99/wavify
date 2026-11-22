import '../entities/playlist_entity.dart';
import '../repositories/playlist_repository.dart';

class RemoveSongFromPlaylistUseCase {
  final PlaylistRepository repository;

  RemoveSongFromPlaylistUseCase(this.repository);

  Future<PlaylistEntity> call({
    required String playlistId,
    required String songId,
  }) async {
    return await repository.removeSongFromPlaylist(
      playlistId: playlistId,
      songId: songId,
    );
  }
}


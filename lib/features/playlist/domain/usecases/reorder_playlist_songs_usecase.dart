import '../entities/playlist_entity.dart';
import '../repositories/playlist_repository.dart';

class ReorderPlaylistSongsUseCase {
  final PlaylistRepository repository;

  ReorderPlaylistSongsUseCase(this.repository);

  Future<PlaylistEntity> call({
    required String playlistId,
    required List<String> songIds,
  }) async {
    return await repository.reorderPlaylistSongs(
      playlistId: playlistId,
      songIds: songIds,
    );
  }
}


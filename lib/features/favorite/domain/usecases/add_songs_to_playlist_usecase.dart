import '../entities/playlist_entity.dart';
import '../repositories/playlist_repository.dart';

class AddSongsToPlaylistUseCase {
  final PlaylistRepository repository;

  AddSongsToPlaylistUseCase(this.repository);

  Future<PlaylistEntity> call({
    required String playlistId,
    required List<String> songIds,
  }) async {
    return await repository.addSongsToPlaylist(
      playlistId: playlistId,
      songIds: songIds,
    );
  }
}


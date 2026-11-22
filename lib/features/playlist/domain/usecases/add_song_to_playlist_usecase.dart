import '../entities/playlist_entity.dart';
import '../repositories/playlist_repository.dart';

class AddSongToPlaylistUseCase {
  final PlaylistRepository repository;

  AddSongToPlaylistUseCase(this.repository);

  Future<PlaylistEntity> call({
    required String playlistId,
    required String songId,
  }) async {
    return await repository.addSongToPlaylist(
      playlistId: playlistId,
      songId: songId,
    );
  }
}


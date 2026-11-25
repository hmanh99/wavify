import '../repositories/playlist_repository.dart';

class DeletePlaylistUseCase {
  final PlaylistRepository repository;

  DeletePlaylistUseCase(this.repository);

  Future<void> call(String playlistId) async {
    return await repository.deletePlaylist(playlistId);
  }
}


import '../entities/playlist_entity.dart';
import '../repositories/playlist_repository.dart';

class UpdatePlaylistUseCase {
  final PlaylistRepository repository;

  UpdatePlaylistUseCase(this.repository);

  Future<PlaylistEntity> call({
    required String playlistId,
    required String name,
    String? description,
    String? coverUrl,
    String? visibility,
  }) async {
    return await repository.updatePlaylist(
      playlistId: playlistId,
      name: name,
      description: description,
      coverUrl: coverUrl,
      visibility: visibility,
    );
  }
}


import '../entities/playlist_entity.dart';
import '../repositories/playlist_repository.dart';

class CreatePlaylistUseCase {
  final PlaylistRepository repository;

  CreatePlaylistUseCase(this.repository);

  Future<PlaylistEntity> call({
    required String name,
    String? description,
    String? coverUrl,
    String visibility = 'PUBLIC',
  }) async {
    return await repository.createPlaylist(
      name: name,
      description: description,
      coverUrl: coverUrl,
      visibility: visibility,
    );
  }
}


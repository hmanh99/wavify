import '../entities/playlist_entity.dart';
import '../repositories/playlist_repository.dart';

class GetMyPlaylistsUseCase {
  final PlaylistRepository repository;

  GetMyPlaylistsUseCase(this.repository);

  Future<List<PlaylistEntity>> call() async {
    return await repository.getMyPlaylists();
  }
}


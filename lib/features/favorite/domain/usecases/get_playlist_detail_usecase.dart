import '../entities/playlist_entity.dart';
import '../repositories/playlist_repository.dart';

class GetPlaylistDetailUseCase {
  final PlaylistRepository repository;

  GetPlaylistDetailUseCase(this.repository);

  Future<PlaylistEntity> call(String playlistId) async {
    return await repository.getPlaylistById(playlistId);
  }
}


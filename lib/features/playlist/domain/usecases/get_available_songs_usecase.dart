import '../entities/song_entity.dart';
import '../repositories/playlist_repository.dart';

class GetAvailableSongsUseCase {
  final PlaylistRepository repository;

  GetAvailableSongsUseCase(this.repository);

  Future<List<SongEntity>> call({int page = 0, int size = 50}) {
    return repository.getAllSongs(page: page, size: size);
  }
}

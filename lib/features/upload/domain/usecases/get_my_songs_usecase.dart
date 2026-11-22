import '../entities/song_entity.dart';
import '../repositories/song_repository.dart';

class GetMySongsUseCase {
  final SongRepository repository;

  GetMySongsUseCase(this.repository);

  Future<List<SongEntity>> call() {
    return repository.getMySongs();
  }
}


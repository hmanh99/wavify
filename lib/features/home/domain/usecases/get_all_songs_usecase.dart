import '../entities/song_entity.dart';
import '../repositories/home_repository.dart';

class GetAllSongsUseCase {
  final HomeRepository repository;

  GetAllSongsUseCase(this.repository);

  Future<List<SongEntity>> call({int page = 0, int size = 50}) {
    return repository.getAllSongs(page: page, size: size);
  }
}


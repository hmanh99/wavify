import '../repositories/song_repository.dart';

class DeleteSongUseCase {
  final SongRepository repository;

  DeleteSongUseCase(this.repository);

  Future<void> call(String songId) {
    return repository.deleteSong(songId);
  }
}


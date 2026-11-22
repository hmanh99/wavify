import '../entities/song_entity.dart';
import '../repositories/song_repository.dart';

class UpdateSongUseCase {
  final SongRepository repository;

  UpdateSongUseCase(this.repository);

  Future<SongEntity> call({
    required String songId,
    required String title,
    required String artist,
    String? album,
    required String visibility,
  }) {
    return repository.updateSong(
      songId: songId,
      title: title,
      artist: artist,
      album: album,
      visibility: visibility,
    );
  }
}


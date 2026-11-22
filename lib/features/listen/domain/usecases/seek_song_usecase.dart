import '../repositories/listen_repository.dart';

class SeekSongUseCase {
  final ListenRepository repository;

  SeekSongUseCase(this.repository);

  Future<void> call(Duration position) => repository.seek(position);
}

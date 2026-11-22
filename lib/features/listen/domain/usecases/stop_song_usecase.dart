import '../repositories/listen_repository.dart';

class StopSongUseCase {
  final ListenRepository repository;

  StopSongUseCase(this.repository);

  Future<void> call() => repository.stop();
}

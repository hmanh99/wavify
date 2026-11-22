import '../repositories/listen_repository.dart';

class PauseSongUseCase {
  final ListenRepository repository;

  PauseSongUseCase(this.repository);

  Future<void> call() => repository.pause();
}

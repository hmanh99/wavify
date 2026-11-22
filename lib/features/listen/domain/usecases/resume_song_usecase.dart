import '../repositories/listen_repository.dart';

class ResumeSongUseCase {
  final ListenRepository repository;

  ResumeSongUseCase(this.repository);

  Future<void> call() => repository.resume();
}

import '../repositories/listen_repository.dart';

class PlaySongUseCase {
  final ListenRepository repository;

  PlaySongUseCase(this.repository);

  Future<void> call(String? url, {Duration? fallbackDuration}) {
    return repository.play(url, fallbackDuration: fallbackDuration);
  }
}

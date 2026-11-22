import '../repositories/listen_repository.dart';

class SetVolumeUseCase {
  final ListenRepository repository;

  SetVolumeUseCase(this.repository);

  Future<void> call(double volume) => repository.setVolume(volume);
}

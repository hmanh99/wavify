import '../repositories/favorite_repository.dart';

class RemoveFavoriteSongUseCase {
  final FavoriteRepository repository;

  RemoveFavoriteSongUseCase(this.repository);

  Future<void> call(String songId) {
    return repository.removeFavoriteSong(songId);
  }
}

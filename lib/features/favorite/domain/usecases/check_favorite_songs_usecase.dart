import '../repositories/favorite_repository.dart';

class CheckFavoriteSongsUseCase {
  final FavoriteRepository repository;

  CheckFavoriteSongsUseCase(this.repository);

  Future<Map<String, bool>> call(List<String> songIds) {
    return repository.checkFavoriteSongs(songIds);
  }
}

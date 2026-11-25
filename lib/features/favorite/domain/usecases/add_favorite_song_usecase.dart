import '../entities/favorite_song_item.dart';
import '../repositories/favorite_repository.dart';

class AddFavoriteSongUseCase {
  final FavoriteRepository repository;

  AddFavoriteSongUseCase(this.repository);

  Future<FavoriteSongItem> call(String songId) {
    return repository.addFavoriteSong(songId);
  }
}

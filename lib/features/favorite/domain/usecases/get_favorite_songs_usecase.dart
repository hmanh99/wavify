import '../entities/favorite_song_item.dart';
import '../repositories/favorite_repository.dart';

class GetFavoriteSongsUseCase {
  final FavoriteRepository repository;

  GetFavoriteSongsUseCase(this.repository);

  Future<List<FavoriteSongItem>> call({int page = 0, int size = 50}) {
    return repository.getFavoriteSongs(page: page, size: size);
  }
}

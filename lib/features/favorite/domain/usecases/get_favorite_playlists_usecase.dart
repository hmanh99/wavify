import '../entities/favorite_playlist_item.dart';
import '../repositories/favorite_repository.dart';

class GetFavoritePlaylistsUseCase {
  final FavoriteRepository repository;

  GetFavoritePlaylistsUseCase(this.repository);

  Future<List<FavoritePlaylistItem>> call({int page = 0, int size = 50}) {
    return repository.getFavoritePlaylists(page: page, size: size);
  }
}

import '../entities/favorite_playlist_item.dart';
import '../repositories/favorite_repository.dart';

class AddFavoritePlaylistUseCase {
  final FavoriteRepository repository;

  AddFavoritePlaylistUseCase(this.repository);

  Future<FavoritePlaylistItem> call(String playlistId) {
    return repository.addFavoritePlaylist(playlistId);
  }
}

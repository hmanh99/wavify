import '../repositories/favorite_repository.dart';

class RemoveFavoritePlaylistUseCase {
  final FavoriteRepository repository;

  RemoveFavoritePlaylistUseCase(this.repository);

  Future<void> call(String playlistId) {
    return repository.removeFavoritePlaylist(playlistId);
  }
}

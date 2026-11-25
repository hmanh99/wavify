import '../repositories/favorite_repository.dart';

class CheckFavoritePlaylistsUseCase {
  final FavoriteRepository repository;

  CheckFavoritePlaylistsUseCase(this.repository);

  Future<Map<String, bool>> call(List<String> playlistIds) {
    return repository.checkFavoritePlaylists(playlistIds);
  }
}

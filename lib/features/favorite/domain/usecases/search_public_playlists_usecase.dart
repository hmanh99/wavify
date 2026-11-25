import '../entities/playlist_entity.dart';
import '../repositories/playlist_repository.dart';

class SearchPublicPlaylistsUseCase {
  final PlaylistRepository repository;

  SearchPublicPlaylistsUseCase(this.repository);

  Future<List<PlaylistEntity>> call({
    String? keyword,
    int page = 0,
    int size = 20,
  }) {
    return repository.searchPublicPlaylists(
      keyword: keyword,
      page: page,
      size: size,
    );
  }
}

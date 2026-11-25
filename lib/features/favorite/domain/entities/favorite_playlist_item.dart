import 'package:equatable/equatable.dart';
import 'playlist_entity.dart';

class FavoritePlaylistItem extends Equatable {
  final PlaylistEntity playlist;
  final DateTime? favoritedAt;

  const FavoritePlaylistItem({
    required this.playlist,
    this.favoritedAt,
  });

  @override
  List<Object?> get props => [playlist, favoritedAt];
}

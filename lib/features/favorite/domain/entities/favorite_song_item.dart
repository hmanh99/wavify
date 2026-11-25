import 'package:equatable/equatable.dart';
import 'song_entity.dart';

class FavoriteSongItem extends Equatable {
  final SongEntity song;
  final DateTime? favoritedAt;

  const FavoriteSongItem({required this.song, this.favoritedAt});

  @override
  List<Object?> get props => [song, favoritedAt];
}

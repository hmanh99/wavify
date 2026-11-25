import 'package:equatable/equatable.dart';
import 'favourite_song_entity.dart';

class AlbumEntity extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String? coverUrl;
  final List<FavouriteSongEntity> songs;

  const AlbumEntity({
    required this.id,
    required this.title,
    required this.artist,
    this.coverUrl,
    this.songs = const [],
  });

  @override
  List<Object?> get props => [id, title, artist, coverUrl, songs];
}


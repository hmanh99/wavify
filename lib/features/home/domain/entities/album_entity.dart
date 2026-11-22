import 'package:equatable/equatable.dart';
import '../../data/models/song_model.dart';

class AlbumEntity extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String? coverUrl;
  final List<SongModel> songs;

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

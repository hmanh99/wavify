import 'package:equatable/equatable.dart';
import '../models/song_model.dart';

class AlbumModel extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String? coverUrl;
  final List<SongModel> songs;

  const AlbumModel({
    required this.id,
    required this.title,
    required this.artist,
    this.coverUrl,
    this.songs = const [],
  });

  @override
  List<Object?> get props => [id, title, artist, coverUrl, songs];
}

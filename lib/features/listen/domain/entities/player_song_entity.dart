import 'package:equatable/equatable.dart';

class PlayerSongEntity extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? coverUrl;
  final Duration duration;
  final String? streams;
  final bool isFavourite;
  final String? fileUrl;

  const PlayerSongEntity({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.coverUrl,
    this.duration = const Duration(minutes: 3, seconds: 15),
    this.streams,
    this.isFavourite = false,
    this.fileUrl,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        album,
        coverUrl,
        duration,
        streams,
        isFavourite,
        fileUrl,
      ];
}

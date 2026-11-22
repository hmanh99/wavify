import '../../domain/entities/favourite_song_entity.dart';

class SongModel extends FavouriteSongEntity {
  const SongModel({
    required super.id,
    required super.title,
    required super.artist,
    super.album,
    super.coverUrl,
    super.duration = const Duration(minutes: 3, seconds: 15),
    super.streams,
    super.isFavourite = false,
    super.fileUrl,
  });

  SongModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? coverUrl,
    Duration? duration,
    String? streams,
    bool? isFavourite,
    String? fileUrl,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      coverUrl: coverUrl ?? this.coverUrl,
      duration: duration ?? this.duration,
      streams: streams ?? this.streams,
      isFavourite: isFavourite ?? this.isFavourite,
      fileUrl: fileUrl ?? this.fileUrl,
    );
  }
}

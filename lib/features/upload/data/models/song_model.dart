import 'package:equatable/equatable.dart';

class SongModel extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? coverUrl;
  final Duration duration;
  final String? streams;
  final bool isFavourite;
  final String? fileUrl;

  const SongModel({
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

  Map<String, dynamic> toPlaybackMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'coverUrl': coverUrl,
      'durationSec': duration.inSeconds,
      'streams': streams,
      'isFavourite': isFavourite,
      'fileUrl': fileUrl,
    };
  }

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

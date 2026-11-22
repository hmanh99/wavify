import 'package:equatable/equatable.dart';

class HistorySongEntity extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? coverUrl;
  final Duration duration;
  final String? fileUrl;

  const HistorySongEntity({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.coverUrl,
    this.duration = const Duration(minutes: 3, seconds: 15),
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
      'fileUrl': fileUrl,
    };
  }

  @override
  List<Object?> get props => [id, title, artist, album, coverUrl, duration, fileUrl];
}

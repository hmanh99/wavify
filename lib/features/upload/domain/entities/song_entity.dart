import 'package:equatable/equatable.dart';
import '../../data/models/song_model.dart';

class SongEntity extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final int durationSec;
  final String fileUrl;
  final String? coverUrl;
  final String? uploaderId;
  final String visibility; // 'PUBLIC' or 'PRIVATE'
  final String status; // 'READY', 'PROCESSING', 'FAIL'.
  final DateTime? createdAt;

  const SongEntity({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.durationSec = 0,
    required this.fileUrl,
    this.coverUrl,
    this.uploaderId,
    this.visibility = 'PUBLIC',
    this.status = 'READY',
    this.createdAt,
  });

  bool get isPublic => visibility.toUpperCase() == 'PUBLIC';

  SongModel toSongModel() {
    final cleanCover = (coverUrl != null &&
            coverUrl!.trim().isNotEmpty &&
            coverUrl != 'null' &&
            coverUrl != 'undefined')
        ? coverUrl!.trim()
        : null;
    return SongModel(
      id: id,
      title: title,
      artist: artist,
      album: album,
      coverUrl: cleanCover,
      duration: Duration(seconds: durationSec > 0 ? durationSec : 195),
      streams: status == 'READY' ? 'Ready' : status,
      fileUrl: fileUrl,
    );
  }

  SongEntity copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    int? durationSec,
    String? fileUrl,
    String? coverUrl,
    String? uploaderId,
    String? visibility,
    String? status,
    DateTime? createdAt,
  }) {
    return SongEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationSec: durationSec ?? this.durationSec,
      fileUrl: fileUrl ?? this.fileUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      uploaderId: uploaderId ?? this.uploaderId,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        album,
        durationSec,
        fileUrl,
        coverUrl,
        uploaderId,
        visibility,
        status,
        createdAt,
      ];
}


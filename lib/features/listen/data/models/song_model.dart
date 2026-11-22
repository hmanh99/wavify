import '../../domain/entities/player_song_entity.dart';

class SongModel extends PlayerSongEntity {
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

  factory SongModel.fromEntity(PlayerSongEntity entity) {
    if (entity is SongModel) return entity;
    return SongModel(
      id: entity.id,
      title: entity.title,
      artist: entity.artist,
      album: entity.album,
      coverUrl: entity.coverUrl,
      duration: entity.duration,
      streams: entity.streams,
      isFavourite: entity.isFavourite,
      fileUrl: entity.fileUrl,
    );
  }

  factory SongModel.fromMap(Map<String, dynamic> map) {
    final rawCover = (map['coverUrl'] ?? map['cover_url'])?.toString().trim();
    final String? cleanCover = (rawCover != null &&
            rawCover.isNotEmpty &&
            rawCover != 'null' &&
            rawCover != 'undefined')
        ? rawCover
        : null;

    Duration resolvedDuration = const Duration(minutes: 3, seconds: 15);
    final rawDuration = map['duration'];
    final rawDurationSec = map['durationSec'] ?? map['duration_sec'];
    if (rawDuration is Duration) {
      if (rawDuration.inSeconds > 0) {
        resolvedDuration = rawDuration;
      }
    } else if (rawDuration is num && rawDuration > 0) {
      resolvedDuration = Duration(seconds: rawDuration.toInt());
    } else if (rawDurationSec is num && rawDurationSec > 0) {
      resolvedDuration = Duration(seconds: rawDurationSec.toInt());
    }

    return SongModel(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? 'Untitled').toString(),
      artist: (map['artist'] ?? 'Unknown Artist').toString(),
      album: map['album']?.toString(),
      coverUrl: cleanCover,
      duration: resolvedDuration,
      streams: map['streams']?.toString(),
      isFavourite: map['isFavourite'] == true,
      fileUrl: (map['fileUrl'] ?? map['file_url'])?.toString(),
    );
  }

  /// Normalizes a song payload ([SongModel], [PlayerSongEntity], or a Map)
  /// into [listen]'s own [SongModel] without importing other features' models.
  factory SongModel.fromPayload(Object? payload) {
    if (payload is SongModel) return payload;
    if (payload is PlayerSongEntity) return SongModel.fromEntity(payload);
    if (payload is Map<String, dynamic>) return SongModel.fromMap(payload);
    if (payload is Map) {
      return SongModel.fromMap(
        payload.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    throw ArgumentError('Unsupported song payload type: ${payload.runtimeType}');
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
}

import '../../domain/entities/song_entity.dart';

class SongResponseModel extends SongEntity {
  const SongResponseModel({
    required super.id,
    required super.title,
    required super.artist,
    super.album,
    super.durationSec = 0,
    required super.fileUrl,
    super.coverUrl,
    super.uploaderId,
    super.visibility = 'PUBLIC',
    super.status = 'READY',
    super.createdAt,
  });

  factory SongResponseModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json;
    if (json.containsKey('result') && json['result'] is Map<String, dynamic>) {
      data = json['result'] as Map<String, dynamic>;
    } else if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      data = json['data'] as Map<String, dynamic>;
    }

    DateTime? createdAt;
    final rawDate = data['createdAt'] ?? data['created_at'];
    if (rawDate != null) {
      if (rawDate is String) {
        createdAt = DateTime.tryParse(rawDate);
      } else if (rawDate is int) {
        createdAt = DateTime.fromMillisecondsSinceEpoch(rawDate);
      }
    }

    int duration = 0;
    final rawDuration = data['durationSec'] ?? data['duration_sec'] ?? data['duration'];
    if (rawDuration != null) {
      if (rawDuration is num) {
        duration = rawDuration.toInt();
      } else if (rawDuration is String) {
        duration = int.tryParse(rawDuration) ?? 0;
      }
    }

    final rawCover = (data['coverUrl'] ?? data['cover_url'])?.toString().trim();
    final String? coverUrl = (rawCover != null &&
            rawCover.isNotEmpty &&
            rawCover != 'null' &&
            rawCover != 'undefined')
        ? rawCover
        : null;

    return SongResponseModel(
      id: (data['id'] ?? data['_id'] ?? data['songId'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      artist: (data['artist'] ?? '').toString(),
      album: data['album']?.toString(),
      durationSec: duration,
      fileUrl: (data['fileUrl'] ?? data['file_url'] ?? data['audioUrl'] ?? '').toString(),
      coverUrl: coverUrl,
      uploaderId: data['uploaderId']?.toString() ?? data['uploader_id']?.toString(),
      visibility: (data['visibility'] ?? 'PUBLIC').toString().toUpperCase(),
      status: (data['status'] ?? 'READY').toString().toUpperCase(),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'durationSec': durationSec,
      'fileUrl': fileUrl,
      'coverUrl': coverUrl,
      'uploaderId': uploaderId,
      'visibility': visibility,
      'status': status,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}


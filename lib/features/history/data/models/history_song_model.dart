import '../../domain/entities/history_song_entity.dart';

class HistorySongModel extends HistorySongEntity {
  const HistorySongModel({
    required super.id,
    required super.title,
    required super.artist,
    super.album,
    super.coverUrl,
    super.duration,
    super.fileUrl,
  });

  factory HistorySongModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json;
    if (json.containsKey('result') && json['result'] is Map<String, dynamic>) {
      data = json['result'] as Map<String, dynamic>;
    } else if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      data = json['data'] as Map<String, dynamic>;
    }

    int durationSec = 195;
    final rawDuration = data['durationSec'] ?? data['duration_sec'] ?? data['duration'];
    if (rawDuration != null) {
      if (rawDuration is num) {
        durationSec = rawDuration.toInt();
      } else if (rawDuration is String) {
        durationSec = int.tryParse(rawDuration) ?? 195;
      }
    }

    final rawCover = (data['coverUrl'] ?? data['cover_url'])?.toString().trim();
    final String? coverUrl = (rawCover != null &&
            rawCover.isNotEmpty &&
            rawCover != 'null' &&
            rawCover != 'undefined')
        ? rawCover
        : null;

    return HistorySongModel(
      id: (data['id'] ?? data['_id'] ?? data['songId'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      artist: (data['artist'] ?? '').toString(),
      album: data['album']?.toString(),
      coverUrl: coverUrl,
      duration: Duration(seconds: durationSec > 0 ? durationSec : 195),
      fileUrl: (data['fileUrl'] ?? data['file_url'] ?? data['audioUrl'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
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
}

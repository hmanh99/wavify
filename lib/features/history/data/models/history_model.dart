import '../../domain/entities/history_entity.dart';
import 'history_song_model.dart';

class HistoryModel extends HistoryEntity {
  const HistoryModel({
    required super.id,
    super.userId,
    required super.song,
    required super.playedAt,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json;
    if (json.containsKey('result') && json['result'] is Map<String, dynamic>) {
      data = json['result'] as Map<String, dynamic>;
    } else if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      data = json['data'] as Map<String, dynamic>;
    }

    // 1. Resolve History ID
    final id = (data['id'] ?? data['_id'] ?? data['historyId'] ?? DateTime.now().millisecondsSinceEpoch.toString()).toString();

    // 2. Resolve User ID
    final userId = (data['userId'] ?? data['user_id'])?.toString();

    // 3. Resolve Played At
    DateTime playedAt = DateTime.now();
    final rawDate = data['playedAt'] ??
        data['played_at'] ??
        data['createdAt'] ??
        data['created_at'] ??
        data['listenedAt'] ??
        data['listened_at'] ??
        data['timestamp'];
    if (rawDate != null) {
      if (rawDate is String) {
        playedAt = DateTime.tryParse(rawDate) ?? DateTime.now();
      } else if (rawDate is int) {
        playedAt = DateTime.fromMillisecondsSinceEpoch(rawDate);
      }
    }

    // 4. Resolve Song
    HistorySongModel song;
    if (data['song'] != null && data['song'] is Map<String, dynamic>) {
      song = HistorySongModel.fromJson(data['song'] as Map<String, dynamic>);
    } else {
      song = HistorySongModel.fromJson(data);
    }

    return HistoryModel(
      id: id,
      userId: userId,
      song: song,
      playedAt: playedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
      'song': (song is HistorySongModel)
          ? (song as HistorySongModel).toJson()
          : {
              'id': song.id,
              'title': song.title,
              'artist': song.artist,
              'album': song.album,
              'coverUrl': song.coverUrl,
              'fileUrl': song.fileUrl,
              'durationSec': song.duration.inSeconds,
            },
      'playedAt': playedAt.toIso8601String(),
    };
  }
}

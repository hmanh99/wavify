import 'song_response_model.dart';
import '../../domain/entities/favorite_song_item.dart';

class FavoriteSongResponseModel extends FavoriteSongItem {
  const FavoriteSongResponseModel({
    required super.song,
    super.favoritedAt,
  });

  factory FavoriteSongResponseModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json;
    if (json.containsKey('result') && json['result'] is Map<String, dynamic>) {
      data = json['result'] as Map<String, dynamic>;
    } else if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      data = json['data'] as Map<String, dynamic>;
    }

    final rawSong = data['song'];
    final songJson = rawSong is Map<String, dynamic> ? rawSong : data;
    final song = SongResponseModel.fromJson(songJson);

    DateTime? favoritedAt;
    final rawDate = data['favoritedAt'] ?? data['favorited_at'] ?? data['createdAt'];
    if (rawDate is String) {
      favoritedAt = DateTime.tryParse(rawDate);
    } else if (rawDate is int) {
      favoritedAt = DateTime.fromMillisecondsSinceEpoch(rawDate);
    }

    return FavoriteSongResponseModel(
      song: song,
      favoritedAt: favoritedAt,
    );
  }
}

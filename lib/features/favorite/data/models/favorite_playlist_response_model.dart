import 'playlist_model.dart';
import '../../domain/entities/favorite_playlist_item.dart';

class FavoritePlaylistResponseModel extends FavoritePlaylistItem {
  const FavoritePlaylistResponseModel({
    required super.playlist,
    super.favoritedAt,
  });

  factory FavoritePlaylistResponseModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json;
    if (json.containsKey('result') && json['result'] is Map<String, dynamic>) {
      data = json['result'] as Map<String, dynamic>;
    } else if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      data = json['data'] as Map<String, dynamic>;
    }

    final rawPlaylist = data['playlist'];
    final playlistJson = rawPlaylist is Map<String, dynamic> ? rawPlaylist : data;
    final playlist = PlaylistModel.fromJson(playlistJson);

    DateTime? favoritedAt;
    final rawDate = data['favoritedAt'] ?? data['favorited_at'] ?? data['createdAt'];
    if (rawDate is String) {
      favoritedAt = DateTime.tryParse(rawDate);
    } else if (rawDate is int) {
      favoritedAt = DateTime.fromMillisecondsSinceEpoch(rawDate);
    }

    return FavoritePlaylistResponseModel(
      playlist: playlist,
      favoritedAt: favoritedAt,
    );
  }
}

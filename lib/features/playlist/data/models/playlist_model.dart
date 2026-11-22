import 'song_response_model.dart';
import '../../domain/entities/song_entity.dart';
import '../../domain/entities/playlist_entity.dart';

class PlaylistModel extends PlaylistEntity {
  const PlaylistModel({
    required super.id,
    required super.name,
    super.description,
    super.coverUrl,
    super.ownerId,
    super.visibility = 'PUBLIC',
    super.songCount = 0,
    super.songs = const [],
    super.createdAt,
    super.updatedAt,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = json;
    if (json.containsKey('result') && json['result'] is Map<String, dynamic>) {
      data = json['result'] as Map<String, dynamic>;
    } else if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      data = json['data'] as Map<String, dynamic>;
    }

    // Parse created / updated dates
    DateTime? createdAt;
    final rawCreated = data['createdAt'] ?? data['created_at'];
    if (rawCreated != null) {
      if (rawCreated is String) {
        createdAt = DateTime.tryParse(rawCreated);
      } else if (rawCreated is int) {
        createdAt = DateTime.fromMillisecondsSinceEpoch(rawCreated);
      }
    }

    DateTime? updatedAt;
    final rawUpdated = data['updatedAt'] ?? data['updated_at'];
    if (rawUpdated != null) {
      if (rawUpdated is String) {
        updatedAt = DateTime.tryParse(rawUpdated);
      } else if (rawUpdated is int) {
        updatedAt = DateTime.fromMillisecondsSinceEpoch(rawUpdated);
      }
    }

    // Parse songs list
    List<SongEntity> songsList = [];
    final rawSongs = data['songs'] ?? data['songList'] ?? data['items'] ?? data['content'];
    if (rawSongs is List) {
      for (final item in rawSongs) {
        if (item is Map<String, dynamic>) {
          if (item.containsKey('song') && item['song'] is Map<String, dynamic>) {
            songsList.add(SongResponseModel.fromJson(item['song'] as Map<String, dynamic>));
          } else {
            songsList.add(SongResponseModel.fromJson(item));
          }
        }
      }
    }

    int count = songsList.length;
    final rawCount = data['songCount'] ?? data['song_count'] ?? data['totalSongs'];
    if (rawCount != null) {
      if (rawCount is num) {
        count = rawCount.toInt();
      } else if (rawCount is String) {
        count = int.tryParse(rawCount) ?? count;
      }
    }

    final id = (data['id'] ?? data['_id'] ?? data['playlistId'] ?? '').toString();
    final name = (data['name'] ?? data['title'] ?? 'Playlist $id').toString();
    final description = data['description']?.toString();
    final coverUrl = (data['coverUrl'] ?? data['cover_url'] ?? data['artworkUrl'] ?? '').toString();
    final ownerId = data['ownerId']?.toString() ?? data['owner_id']?.toString() ?? data['userId']?.toString();
    final visibility = (data['visibility'] ?? 'PUBLIC').toString().toUpperCase();

    return PlaylistModel(
      id: id,
      name: name,
      description: description,
      coverUrl: coverUrl.isNotEmpty ? coverUrl : null,
      ownerId: ownerId,
      visibility: visibility,
      songCount: count,
      songs: songsList,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverUrl': coverUrl,
      'ownerId': ownerId,
      'visibility': visibility,
      'songCount': songCount,
      'songs': songs.map((s) {
        if (s is SongResponseModel) {
          return s.toJson();
        }
        return {
          'id': s.id,
          'title': s.title,
          'artist': s.artist,
          'album': s.album,
          'durationSec': s.durationSec,
          'fileUrl': s.fileUrl,
          'coverUrl': s.coverUrl,
          'visibility': s.visibility,
          'status': s.status,
        };
      }).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}


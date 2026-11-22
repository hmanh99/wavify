import 'package:equatable/equatable.dart';
import 'song_entity.dart';
import '../../data/models/album_model.dart';

class PlaylistEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final String? ownerId;
  final String visibility; // 'PUBLIC' or 'PRIVATE'
  final int songCount;
  final List<SongEntity> songs;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PlaylistEntity({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    this.ownerId,
    this.visibility = 'PUBLIC',
    this.songCount = 0,
    this.songs = const [],
    this.createdAt,
    this.updatedAt,
  });

  bool get isPublic => visibility.toUpperCase() == 'PUBLIC';

  String? get displayCoverUrl {
    if (coverUrl != null && coverUrl!.trim().isNotEmpty && coverUrl != 'null') {
      return coverUrl!.trim();
    }
    return null;
  }

  // Convert to AlbumModel so existing widgets (e.g. FavouriteAlbumsSection) can consume seamlessly
  AlbumModel toAlbumModel() {
    return AlbumModel(
      id: id,
      title: name,
      artist: description != null && description!.isNotEmpty
          ? description!
          : '$songCount bài hát',
      coverUrl: displayCoverUrl,
      songs: songs.map((s) => s.toSongModel()).toList(),
    );
  }

  PlaylistEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? coverUrl,
    String? ownerId,
    String? visibility,
    int? songCount,
    List<SongEntity>? songs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlaylistEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      ownerId: ownerId ?? this.ownerId,
      visibility: visibility ?? this.visibility,
      songCount: songCount ?? this.songCount,
      songs: songs ?? this.songs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        coverUrl,
        ownerId,
        visibility,
        songCount,
        songs,
        createdAt,
        updatedAt,
      ];
}


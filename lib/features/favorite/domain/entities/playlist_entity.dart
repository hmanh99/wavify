import 'package:equatable/equatable.dart';
import 'song_entity.dart';
import '../../data/models/album_model.dart';

class PlaylistEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final String? ownerId;
  final String? ownerName;
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
    this.ownerName,
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
    final subtitle = (description != null && description!.isNotEmpty)
        ? description!
        : (ownerName != null && ownerName!.isNotEmpty)
        ? ownerName!
        : '$songCount bài hát';
    return AlbumModel(
      id: id,
      title: name,
      artist: subtitle,
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
    String? ownerName,
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
      ownerName: ownerName ?? this.ownerName,
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
        ownerName,
        visibility,
        songCount,
        songs,
        createdAt,
        updatedAt,
      ];
}


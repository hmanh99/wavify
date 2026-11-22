import 'package:equatable/equatable.dart';
import '../../domain/entities/song_entity.dart';

abstract class PlaylistEvent extends Equatable {
  const PlaylistEvent();

  @override
  List<Object?> get props => [];
}

class LoadPlaylistsRequested extends PlaylistEvent {
  const LoadPlaylistsRequested();
}

class RefreshPlaylistsRequested extends PlaylistEvent {
  const RefreshPlaylistsRequested();
}

class LoadPlaylistDetailRequested extends PlaylistEvent {
  final String playlistId;

  const LoadPlaylistDetailRequested(this.playlistId);

  @override
  List<Object?> get props => [playlistId];
}

class CreatePlaylistSubmitted extends PlaylistEvent {
  final String name;
  final String? description;
  final String? coverUrl;
  final String visibility;

  const CreatePlaylistSubmitted({
    required this.name,
    this.description,
    this.coverUrl,
    this.visibility = 'PUBLIC',
  });

  @override
  List<Object?> get props => [name, description, coverUrl, visibility];
}

class UpdatePlaylistSubmitted extends PlaylistEvent {
  final String playlistId;
  final String name;
  final String? description;
  final String? coverUrl;
  final String? visibility;

  const UpdatePlaylistSubmitted({
    required this.playlistId,
    required this.name,
    this.description,
    this.coverUrl,
    this.visibility,
  });

  @override
  List<Object?> get props => [playlistId, name, description, coverUrl, visibility];
}

class DeletePlaylistRequested extends PlaylistEvent {
  final String playlistId;

  const DeletePlaylistRequested(this.playlistId);

  @override
  List<Object?> get props => [playlistId];
}

class AddSongToPlaylistRequested extends PlaylistEvent {
  final String playlistId;
  final String songId;
  final SongEntity? song;

  const AddSongToPlaylistRequested({
    required this.playlistId,
    required this.songId,
    this.song,
  });

  @override
  List<Object?> get props => [playlistId, songId, song];
}

class AddSongsToPlaylistRequested extends PlaylistEvent {
  final String playlistId;
  final List<String> songIds;
  final List<SongEntity>? songs;

  const AddSongsToPlaylistRequested({
    required this.playlistId,
    required this.songIds,
    this.songs,
  });

  @override
  List<Object?> get props => [playlistId, songIds, songs];
}

class RemoveSongFromPlaylistRequested extends PlaylistEvent {
  final String playlistId;
  final String songId;

  const RemoveSongFromPlaylistRequested({
    required this.playlistId,
    required this.songId,
  });

  @override
  List<Object?> get props => [playlistId, songId];
}

class ReorderPlaylistSongsRequested extends PlaylistEvent {
  final String playlistId;
  final int oldIndex;
  final int newIndex;

  const ReorderPlaylistSongsRequested({
    required this.playlistId,
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [playlistId, oldIndex, newIndex];
}


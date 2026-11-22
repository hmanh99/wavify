import 'package:equatable/equatable.dart';
import '../../data/models/song_model.dart';

class PlaybackArgument extends Equatable {
  final List<SongModel> playlist;
  final int initialIndex;

  const PlaybackArgument({
    required this.playlist,
    this.initialIndex = 0,
  });

  factory PlaybackArgument.single(Object? song) {
    return PlaybackArgument(
      playlist: [SongModel.fromPayload(song)],
      initialIndex: 0,
    );
  }

  factory PlaybackArgument.playlist(
    List<Object?> songs, {
    int initialIndex = 0,
  }) {
    return PlaybackArgument(
      playlist: songs.map(SongModel.fromPayload).toList(),
      initialIndex: initialIndex,
    );
  }

  @override
  List<Object?> get props => [playlist, initialIndex];
}

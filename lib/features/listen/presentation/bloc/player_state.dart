import 'package:equatable/equatable.dart';

import '../../data/datasources/audio_player_service.dart';
import '../../data/models/song_model.dart';

class PlayerState extends Equatable {
  final List<SongModel> playlist;
  final int currentIndex;
  final AudioPlayerStatus status;
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isPlaying;
  final bool isShuffle;
  final bool isRepeat;
  final Set<String> favouriteSongIds;

  const PlayerState({
    this.playlist = const [],
    this.currentIndex = 0,
    this.status = AudioPlayerStatus.initial,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.isPlaying = false,
    this.isShuffle = false,
    this.isRepeat = false,
    this.favouriteSongIds = const {},
  });

  SongModel? get currentSong {
    if (playlist.isEmpty || currentIndex < 0 || currentIndex >= playlist.length) {
      return null;
    }
    return playlist[currentIndex];
  }

  bool get isFavourite {
    final song = currentSong;
    if (song == null) return false;
    return favouriteSongIds.contains(song.id);
  }

  PlayerState copyWith({
    List<SongModel>? playlist,
    int? currentIndex,
    AudioPlayerStatus? status,
    Duration? currentPosition,
    Duration? totalDuration,
    bool? isPlaying,
    bool? isShuffle,
    bool? isRepeat,
    Set<String>? favouriteSongIds,
  }) {
    return PlayerState(
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      status: status ?? this.status,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      isPlaying: isPlaying ?? this.isPlaying,
      isShuffle: isShuffle ?? this.isShuffle,
      isRepeat: isRepeat ?? this.isRepeat,
      favouriteSongIds: favouriteSongIds ?? this.favouriteSongIds,
    );
  }

  @override
  List<Object?> get props => [
        playlist,
        currentIndex,
        status,
        currentPosition,
        totalDuration,
        isPlaying,
        isShuffle,
        isRepeat,
        favouriteSongIds,
      ];
}

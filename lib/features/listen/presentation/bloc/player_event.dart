import 'package:equatable/equatable.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayerInitQueueRequested extends PlayerEvent {
  final List<Object?> playlist;
  final int initialIndex;

  const PlayerInitQueueRequested({
    this.playlist = const [],
    this.initialIndex = 0,
  });

  @override
  List<Object?> get props => [playlist, initialIndex];
}

class PlayerPlaySongRequested extends PlayerEvent {
  final Object song;

  const PlayerPlaySongRequested(this.song);

  @override
  List<Object?> get props => [song];
}

class PlayerPlayPlaylistRequested extends PlayerEvent {
  final List<Object?> playlist;
  final int initialIndex;

  const PlayerPlayPlaylistRequested({
    required this.playlist,
    this.initialIndex = 0,
  });

  @override
  List<Object?> get props => [playlist, initialIndex];
}

class PlayerPlayPauseToggled extends PlayerEvent {
  const PlayerPlayPauseToggled();
}

class PlayerNextRequested extends PlayerEvent {
  const PlayerNextRequested();
}

class PlayerPreviousRequested extends PlayerEvent {
  const PlayerPreviousRequested();
}

class PlayerSeekRequested extends PlayerEvent {
  final Duration position;

  const PlayerSeekRequested(this.position);

  @override
  List<Object?> get props => [position];
}

class PlayerSelectIndexRequested extends PlayerEvent {
  final int index;

  const PlayerSelectIndexRequested(this.index);

  @override
  List<Object?> get props => [index];
}

class PlayerShuffleToggled extends PlayerEvent {
  const PlayerShuffleToggled();
}

class PlayerRepeatToggled extends PlayerEvent {
  const PlayerRepeatToggled();
}

class PlayerFavoriteToggled extends PlayerEvent {
  const PlayerFavoriteToggled();
}

class PlayerFavoritesSynced extends PlayerEvent {
  final Set<String> favouriteSongIds;

  const PlayerFavoritesSynced(this.favouriteSongIds);

  @override
  List<Object?> get props => [favouriteSongIds];
}

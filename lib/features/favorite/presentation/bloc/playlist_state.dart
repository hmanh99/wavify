import 'package:equatable/equatable.dart';
import '../../domain/entities/playlist_entity.dart';

enum PlaylistStatus {
  initial,
  loading,
  loaded,
  mutating,
  success,
  failure,
}

class PlaylistState extends Equatable {
  final List<PlaylistEntity> playlists;
  final PlaylistEntity? selectedPlaylist;
  final PlaylistStatus status;
  final String? message;
  final String? errorMessage;

  const PlaylistState({
    this.playlists = const [],
    this.selectedPlaylist,
    this.status = PlaylistStatus.initial,
    this.message,
    this.errorMessage,
  });

  bool get isLoading => status == PlaylistStatus.loading;
  bool get isMutating => status == PlaylistStatus.mutating;

  PlaylistState copyWith({
    List<PlaylistEntity>? playlists,
    PlaylistEntity? selectedPlaylist,
    bool clearSelectedPlaylist = false,
    PlaylistStatus? status,
    String? message,
    String? errorMessage,
  }) {
    return PlaylistState(
      playlists: playlists ?? this.playlists,
      selectedPlaylist: clearSelectedPlaylist ? null : (selectedPlaylist ?? this.selectedPlaylist),
      status: status ?? this.status,
      message: message,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        playlists,
        selectedPlaylist,
        status,
        message,
        errorMessage,
      ];
}


import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/song_entity.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/usecases/add_song_to_playlist_usecase.dart';
import '../../domain/usecases/add_songs_to_playlist_usecase.dart';
import '../../domain/usecases/create_playlist_usecase.dart';
import '../../domain/usecases/delete_playlist_usecase.dart';
import '../../domain/usecases/get_my_playlists_usecase.dart';
import '../../domain/usecases/get_playlist_detail_usecase.dart';
import '../../domain/usecases/remove_song_from_playlist_usecase.dart';
import '../../domain/usecases/reorder_playlist_songs_usecase.dart';
import '../../domain/usecases/update_playlist_usecase.dart';
import 'playlist_event.dart';
import 'playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final GetMyPlaylistsUseCase getMyPlaylistsUseCase;
  final GetPlaylistDetailUseCase getPlaylistDetailUseCase;
  final CreatePlaylistUseCase createPlaylistUseCase;
  final UpdatePlaylistUseCase updatePlaylistUseCase;
  final DeletePlaylistUseCase deletePlaylistUseCase;
  final AddSongToPlaylistUseCase addSongToPlaylistUseCase;
  final AddSongsToPlaylistUseCase addSongsToPlaylistUseCase;
  final RemoveSongFromPlaylistUseCase removeSongFromPlaylistUseCase;
  final ReorderPlaylistSongsUseCase reorderPlaylistSongsUseCase;

  PlaylistBloc({
    required this.getMyPlaylistsUseCase,
    required this.getPlaylistDetailUseCase,
    required this.createPlaylistUseCase,
    required this.updatePlaylistUseCase,
    required this.deletePlaylistUseCase,
    required this.addSongToPlaylistUseCase,
    required this.addSongsToPlaylistUseCase,
    required this.removeSongFromPlaylistUseCase,
    required this.reorderPlaylistSongsUseCase,
  }) : super(const PlaylistState()) {
    on<LoadPlaylistsRequested>(_onLoadPlaylists);
    on<RefreshPlaylistsRequested>(_onRefreshPlaylists);
    on<LoadPlaylistDetailRequested>(_onLoadPlaylistDetail);
    on<CreatePlaylistSubmitted>(_onCreatePlaylist);
    on<UpdatePlaylistSubmitted>(_onUpdatePlaylist);
    on<DeletePlaylistRequested>(_onDeletePlaylist);
    on<AddSongToPlaylistRequested>(_onAddSongToPlaylist);
    on<AddSongsToPlaylistRequested>(_onAddSongsToPlaylist);
    on<RemoveSongFromPlaylistRequested>(_onRemoveSongFromPlaylist);
    on<ReorderPlaylistSongsRequested>(_onReorderPlaylistSongs);
  }

  Future<void> _onLoadPlaylists(
    LoadPlaylistsRequested event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(state.copyWith(status: PlaylistStatus.loading));
    try {
      final list = await getMyPlaylistsUseCase();
      emit(state.copyWith(
        playlists: list,
        status: PlaylistStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PlaylistStatus.failure,
        errorMessage: _cleanError(e),
      ));
    }
  }

  Future<void> _onRefreshPlaylists(
    RefreshPlaylistsRequested event,
    Emitter<PlaylistState> emit,
  ) async {
    try {
      final list = await getMyPlaylistsUseCase();
      PlaylistEntity? refreshedDetail = state.selectedPlaylist;

      if (refreshedDetail != null) {
        try {
          refreshedDetail = await getPlaylistDetailUseCase(refreshedDetail.id);
        } catch (_) {}
      }

      emit(state.copyWith(
        playlists: list,
        selectedPlaylist: refreshedDetail,
        status: PlaylistStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PlaylistStatus.failure,
        errorMessage: _cleanError(e),
      ));
    }
  }

  Future<void> _onLoadPlaylistDetail(
    LoadPlaylistDetailRequested event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(state.copyWith(status: PlaylistStatus.loading));
    try {
      final detail = await getPlaylistDetailUseCase(event.playlistId);
      final updatedPlaylists = state.playlists.map((p) => p.id == detail.id ? detail : p).toList();

      emit(state.copyWith(
        playlists: updatedPlaylists,
        selectedPlaylist: detail,
        status: PlaylistStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PlaylistStatus.failure,
        errorMessage: _cleanError(e),
      ));
    }
  }

  Future<void> _onCreatePlaylist(
    CreatePlaylistSubmitted event,
    Emitter<PlaylistState> emit,
  ) async {
    if (event.name.trim().isEmpty) {
      emit(state.copyWith(
        status: PlaylistStatus.failure,
        errorMessage: 'Tên playlist không được để trống',
      ));
      return;
    }

    emit(state.copyWith(status: PlaylistStatus.mutating));
    try {
      final created = await createPlaylistUseCase(
        name: event.name.trim(),
        description: event.description?.trim(),
        coverUrl: event.coverUrl?.trim(),
        visibility: event.visibility,
      );

      final updatedList = [created, ...state.playlists.where((p) => p.id != created.id)];
      emit(state.copyWith(
        playlists: updatedList,
        selectedPlaylist: created,
        status: PlaylistStatus.success,
        message: 'Tạo playlist thành công!',
      ));
      emit(state.copyWith(status: PlaylistStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: PlaylistStatus.failure,
        errorMessage: _cleanError(e),
      ));
    }
  }

  Future<void> _onUpdatePlaylist(
    UpdatePlaylistSubmitted event,
    Emitter<PlaylistState> emit,
  ) async {
    if (event.name.trim().isEmpty) {
      emit(state.copyWith(
        status: PlaylistStatus.failure,
        errorMessage: 'Tên playlist không được để trống',
      ));
      return;
    }

    emit(state.copyWith(status: PlaylistStatus.mutating));
    try {
      final updated = await updatePlaylistUseCase(
        playlistId: event.playlistId,
        name: event.name.trim(),
        description: event.description?.trim(),
        coverUrl: event.coverUrl?.trim(),
        visibility: event.visibility,
      );

      final updatedList = state.playlists.map((p) => p.id == updated.id ? updated : p).toList();
      emit(state.copyWith(
        playlists: updatedList,
        selectedPlaylist: state.selectedPlaylist?.id == updated.id ? updated : state.selectedPlaylist,
        status: PlaylistStatus.success,
        message: 'Cập nhật playlist thành công!',
      ));
      emit(state.copyWith(status: PlaylistStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: PlaylistStatus.failure,
        errorMessage: _cleanError(e),
      ));
    }
  }

  Future<void> _onDeletePlaylist(
    DeletePlaylistRequested event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(state.copyWith(status: PlaylistStatus.mutating));
    try {
      await deletePlaylistUseCase(event.playlistId);

      final updatedList = state.playlists.where((p) => p.id != event.playlistId).toList();
      final bool clearSelected = state.selectedPlaylist?.id == event.playlistId;

      emit(state.copyWith(
        playlists: updatedList,
        clearSelectedPlaylist: clearSelected,
        status: PlaylistStatus.success,
        message: 'Đã xóa playlist',
      ));
      emit(state.copyWith(status: PlaylistStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: PlaylistStatus.failure,
        errorMessage: _cleanError(e),
      ));
    }
  }

  Future<void> _onAddSongToPlaylist(
    AddSongToPlaylistRequested event,
    Emitter<PlaylistState> emit,
  ) async {
    await _onAddSongsToPlaylist(
      AddSongsToPlaylistRequested(
        playlistId: event.playlistId,
        songIds: [event.songId],
        songs: event.song != null ? [event.song!] : null,
      ),
      emit,
    );
  }

  Future<void> _onAddSongsToPlaylist(
    AddSongsToPlaylistRequested event,
    Emitter<PlaylistState> emit,
  ) async {
    if (event.songIds.isEmpty) return;

    // Cap at 100 songs
    final targetIds = event.songIds.take(100).toList();

    final currentSelected = state.selectedPlaylist;
    final currentPlaylists = state.playlists;

    // 1. Optimistic append & immediate UI refresh
    if (currentSelected != null &&
        currentSelected.id == event.playlistId &&
        event.songs != null &&
        event.songs!.isNotEmpty) {
      final existingIds = currentSelected.songs.map((s) => s.id).toSet();
      final newSongsToAdd = event.songs!
          .where((s) => targetIds.contains(s.id) && !existingIds.contains(s.id))
          .toList();
      final optimisticSongs = [...currentSelected.songs, ...newSongsToAdd];
      final optimisticSelected = currentSelected.copyWith(
        songs: optimisticSongs,
        songCount: optimisticSongs.length,
      );
      final optimisticPlaylists = currentPlaylists
          .map((p) => p.id == event.playlistId ? optimisticSelected : p)
          .toList();

      emit(state.copyWith(
        selectedPlaylist: optimisticSelected,
        playlists: optimisticPlaylists,
        status: PlaylistStatus.mutating,
      ));
    } else {
      emit(state.copyWith(status: PlaylistStatus.mutating));
    }

    try {
      final updated = await addSongsToPlaylistUseCase(
        playlistId: event.playlistId,
        songIds: targetIds,
      );

      final updatedList = state.playlists.map((p) => p.id == updated.id ? updated : p).toList();

      emit(state.copyWith(
        playlists: updatedList,
        selectedPlaylist: state.selectedPlaylist?.id == updated.id ? updated : state.selectedPlaylist,
        status: PlaylistStatus.success,
        message: targetIds.length > 1
            ? 'Đã thêm ${targetIds.length} bài hát vào playlist!'
            : 'Đã thêm bài hát vào playlist!',
      ));
      emit(state.copyWith(status: PlaylistStatus.loaded));
    } catch (e) {
      // Rollback on error
      emit(state.copyWith(
        playlists: currentPlaylists,
        selectedPlaylist: currentSelected,
        status: PlaylistStatus.failure,
        errorMessage: _cleanError(e),
      ));
    }
  }

  Future<void> _onRemoveSongFromPlaylist(
    RemoveSongFromPlaylistRequested event,
    Emitter<PlaylistState> emit,
  ) async {
    final currentSelected = state.selectedPlaylist;
    final currentPlaylists = state.playlists;

    // 1. Optimistic removal & immediate UI refresh
    if (currentSelected != null && currentSelected.id == event.playlistId) {
      final remainingSongs = currentSelected.songs.where((s) => s.id != event.songId).toList();
      final optimisticSelected = currentSelected.copyWith(
        songs: remainingSongs,
        songCount: remainingSongs.length,
      );
      final optimisticPlaylists = currentPlaylists
          .map((p) => p.id == event.playlistId ? optimisticSelected : p)
          .toList();

      emit(state.copyWith(
        selectedPlaylist: optimisticSelected,
        playlists: optimisticPlaylists,
        status: PlaylistStatus.mutating,
      ));
    } else {
      emit(state.copyWith(status: PlaylistStatus.mutating));
    }

    try {
      final updated = await removeSongFromPlaylistUseCase(
        playlistId: event.playlistId,
        songId: event.songId,
      );

      final updatedList = state.playlists.map((p) => p.id == updated.id ? updated : p).toList();

      emit(state.copyWith(
        playlists: updatedList,
        selectedPlaylist: state.selectedPlaylist?.id == updated.id ? updated : state.selectedPlaylist,
        status: PlaylistStatus.success,
        message: 'Đã xóa bài hát khỏi playlist',
      ));
      emit(state.copyWith(status: PlaylistStatus.loaded));
    } catch (e) {
      // Rollback on error
      emit(state.copyWith(
        playlists: currentPlaylists,
        selectedPlaylist: currentSelected,
        status: PlaylistStatus.failure,
        errorMessage: _cleanError(e),
      ));
    }
  }

  Future<void> _onReorderPlaylistSongs(
    ReorderPlaylistSongsRequested event,
    Emitter<PlaylistState> emit,
  ) async {
    final current = state.selectedPlaylist;
    if (current == null || current.id != event.playlistId) return;

    final songs = List<SongEntity>.from(current.songs);
    if (event.oldIndex < 0 || event.oldIndex >= songs.length) return;

    int newIndex = event.newIndex;
    if (newIndex > event.oldIndex) {
      newIndex -= 1;
    }
    if (newIndex < 0 || newIndex >= songs.length) return;

    // Optimistic reorder
    final movedSong = songs.removeAt(event.oldIndex);
    songs.insert(newIndex, movedSong);

    final optimisticPlaylist = current.copyWith(songs: songs);
    final optimisticList = state.playlists.map((p) => p.id == current.id ? optimisticPlaylist : p).toList();

    emit(state.copyWith(
      selectedPlaylist: optimisticPlaylist,
      playlists: optimisticList,
    ));

    try {
      final songIds = songs.map((s) => s.id).toList();
      final updated = await reorderPlaylistSongsUseCase(
        playlistId: event.playlistId,
        songIds: songIds,
      );

      final finalList = state.playlists.map((p) => p.id == updated.id ? updated : p).toList();
      emit(state.copyWith(
        playlists: finalList,
        selectedPlaylist: updated,
        status: PlaylistStatus.loaded,
      ));
    } catch (e) {
      // Rollback on error
      final rollbackList = state.playlists.map((p) => p.id == current.id ? current : p).toList();
      emit(state.copyWith(
        playlists: rollbackList,
        selectedPlaylist: current,
        status: PlaylistStatus.failure,
        errorMessage: _cleanError(e),
      ));
    }
  }

  String _cleanError(dynamic error) {
    if (error == null) return 'Có lỗi xảy ra, vui lòng thử lại';
    final str = error.toString();
    if (str.startsWith('Exception: ')) {
      return str.substring('Exception: '.length);
    }
    return str;
  }
}


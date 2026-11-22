import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/delete_song_usecase.dart';
import '../../domain/usecases/get_my_songs_usecase.dart';
import '../../domain/usecases/update_song_usecase.dart';
import '../../domain/usecases/upload_song_usecase.dart';
import 'upload_event.dart';
import 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final UploadSongUseCase uploadSongUseCase;
  final UpdateSongUseCase updateSongUseCase;
  final DeleteSongUseCase deleteSongUseCase;
  final GetMySongsUseCase getMySongsUseCase;

  UploadBloc({
    required this.uploadSongUseCase,
    required this.updateSongUseCase,
    required this.deleteSongUseCase,
    required this.getMySongsUseCase,
  }) : super(const UploadInitial()) {
    on<UploadSongSubmitted>(_onUploadSong);
    on<UploadProgressUpdated>(_onUploadProgress);
    on<LoadMySongsRequested>(_onLoadMySongs);
    on<UpdateSongSubmitted>(_onUpdateSong);
    on<DeleteSongRequested>(_onDeleteSong);
  }

  Future<void> _onUploadSong(
    UploadSongSubmitted event,
    Emitter<UploadState> emit,
  ) async {
    if (event.title.trim().isEmpty) {
      emit(UploadFailure('Tiêu đề bài hát không được để trống', songs: state.songs));
      return;
    }

    if ((event.audioPath == null || event.audioPath!.isEmpty) &&
        (event.audioBytes == null || event.audioBytes!.isEmpty)) {
      emit(UploadFailure('Vui lòng chọn tệp âm thanh (MP3/WAV)', songs: state.songs));
      return;
    }

    emit(UploadInProgress(0.05, songs: state.songs));

    try {
      final uploadedSong = await uploadSongUseCase(
        title: event.title.trim(),
        artist: event.artist.trim(),
        album: event.album?.trim(),
        visibility: event.visibility,
        audioPath: event.audioPath,
        audioBytes: event.audioBytes,
        audioFileName: event.audioFileName,
        coverPath: event.coverPath,
        coverBytes: event.coverBytes,
        coverFileName: event.coverFileName,
        onSendProgress: (sent, total) {
          if (total > 0 && !isClosed) {
            add(UploadProgressUpdated((sent / total).clamp(0.0, 1.0)));
          }
        },
      );

      final updatedList = [uploadedSong, ...state.songs.where((s) => s.id != uploadedSong.id)];
      emit(UploadSuccess(uploadedSong, 'Tải lên bài hát thành công!', songs: updatedList));
      emit(MySongsLoaded(updatedList));
    } catch (e) {
      emit(UploadFailure(_cleanError(e), songs: state.songs));
    }
  }

  void _onUploadProgress(
    UploadProgressUpdated event,
    Emitter<UploadState> emit,
  ) {
    if (state is UploadInProgress) {
      emit(UploadInProgress(event.progress, songs: state.songs));
    }
  }

  Future<void> _onLoadMySongs(
    LoadMySongsRequested event,
    Emitter<UploadState> emit,
  ) async {
    emit(MySongsLoading(songs: state.songs));
    try {
      final songs = await getMySongsUseCase();
      emit(MySongsLoaded(songs));
    } catch (e) {
      emit(UploadFailure(_cleanError(e), songs: state.songs));
    }
  }

  Future<void> _onUpdateSong(
    UpdateSongSubmitted event,
    Emitter<UploadState> emit,
  ) async {
    if (event.title.trim().isEmpty) {
      emit(UploadFailure('Tiêu đề bài hát không được để trống', songs: state.songs));
      return;
    }

    emit(MySongsLoading(songs: state.songs));

    try {
      final updated = await updateSongUseCase(
        songId: event.songId,
        title: event.title.trim(),
        artist: event.artist.trim(),
        album: event.album?.trim(),
        visibility: event.visibility,
      );

      final hasSong = state.songs.any((s) => s.id == updated.id);
      final updatedList = hasSong
          ? state.songs.map((s) => s.id == updated.id ? updated : s).toList()
          : [updated, ...state.songs];
      emit(SongOperationSuccess('Cập nhật bài hát thành công!', songs: updatedList));
      emit(MySongsLoaded(updatedList));
    } catch (e) {
      emit(UploadFailure(_cleanError(e), songs: state.songs));
    }
  }

  Future<void> _onDeleteSong(
    DeleteSongRequested event,
    Emitter<UploadState> emit,
  ) async {
    emit(MySongsLoading(songs: state.songs));

    try {
      await deleteSongUseCase(event.songId);
      final updatedList = state.songs.where((s) => s.id != event.songId).toList();
      emit(SongOperationSuccess('Đã xóa bài hát thành công!', songs: updatedList));
      emit(MySongsLoaded(updatedList));
    } catch (e) {
      emit(UploadFailure(_cleanError(e), songs: state.songs));
    }
  }

  String _cleanError(dynamic error) {
    final str = error.toString();
    if (str.startsWith('Exception: ')) {
      return str.substring('Exception: '.length);
    }
    return str;
  }
}

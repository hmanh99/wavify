import 'package:equatable/equatable.dart';
import '../../domain/entities/song_entity.dart';

abstract class UploadState extends Equatable {
  final List<SongEntity> songs;

  const UploadState({this.songs = const []});

  @override
  List<Object?> get props => [songs];
}

class UploadInitial extends UploadState {
  const UploadInitial({super.songs});
}

class UploadInProgress extends UploadState {
  final double progress;

  const UploadInProgress(this.progress, {super.songs});

  @override
  List<Object?> get props => [progress, songs];
}

class UploadSuccess extends UploadState {
  final SongEntity song;
  final String message;

  const UploadSuccess(this.song, this.message, {super.songs});

  @override
  List<Object?> get props => [song, message, songs];
}

class MySongsLoading extends UploadState {
  const MySongsLoading({super.songs});
}

class MySongsLoaded extends UploadState {
  const MySongsLoaded(List<SongEntity> songs) : super(songs: songs);
}

class SongOperationSuccess extends UploadState {
  final String message;

  const SongOperationSuccess(this.message, {super.songs});

  @override
  List<Object?> get props => [message, songs];
}

class UploadFailure extends UploadState {
  final String message;

  const UploadFailure(this.message, {super.songs});

  @override
  List<Object?> get props => [message, songs];
}


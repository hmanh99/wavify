import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object?> get props => [];
}

class UploadSongSubmitted extends UploadEvent {
  final String title;
  final String artist;
  final String? album;
  final String visibility;
  final String? audioPath;
  final Uint8List? audioBytes;
  final String? audioFileName;
  final String? coverPath;
  final Uint8List? coverBytes;
  final String? coverFileName;

  const UploadSongSubmitted({
    required this.title,
    required this.artist,
    this.album,
    required this.visibility,
    this.audioPath,
    this.audioBytes,
    this.audioFileName,
    this.coverPath,
    this.coverBytes,
    this.coverFileName,
  });

  @override
  List<Object?> get props => [
        title,
        artist,
        album,
        visibility,
        audioPath,
        audioFileName,
        coverPath,
        coverFileName,
      ];
}

class UploadProgressUpdated extends UploadEvent {
  final double progress;

  const UploadProgressUpdated(this.progress);

  @override
  List<Object?> get props => [progress];
}

class LoadMySongsRequested extends UploadEvent {
  const LoadMySongsRequested();
}

class UpdateSongSubmitted extends UploadEvent {
  final String songId;
  final String title;
  final String artist;
  final String? album;
  final String visibility;

  const UpdateSongSubmitted({
    required this.songId,
    required this.title,
    required this.artist,
    this.album,
    required this.visibility,
  });

  @override
  List<Object?> get props => [songId, title, artist, album, visibility];
}

class DeleteSongRequested extends UploadEvent {
  final String songId;

  const DeleteSongRequested(this.songId);

  @override
  List<Object?> get props => [songId];
}


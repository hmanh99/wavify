import 'dart:typed_data';
import '../entities/song_entity.dart';
import '../repositories/song_repository.dart';

class UploadSongUseCase {
  final SongRepository repository;

  UploadSongUseCase(this.repository);

  Future<SongEntity> call({
    required String title,
    required String artist,
    String? album,
    required String visibility,
    String? audioPath,
    Uint8List? audioBytes,
    String? audioFileName,
    String? coverPath,
    Uint8List? coverBytes,
    String? coverFileName,
    void Function(int sent, int total)? onSendProgress,
  }) {
    return repository.uploadSong(
      title: title,
      artist: artist,
      album: album,
      visibility: visibility,
      audioPath: audioPath,
      audioBytes: audioBytes,
      audioFileName: audioFileName,
      coverPath: coverPath,
      coverBytes: coverBytes,
      coverFileName: coverFileName,
      onSendProgress: onSendProgress,
    );
  }
}


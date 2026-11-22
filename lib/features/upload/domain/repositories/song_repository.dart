import 'dart:typed_data';
import '../entities/song_entity.dart';

abstract class SongRepository {
  Future<SongEntity> uploadSong({
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
  });

  Future<SongEntity> updateSong({
    required String songId,
    required String title,
    required String artist,
    String? album,
    required String visibility,
  });

  Future<void> deleteSong(String songId);

  Future<List<SongEntity>> getMySongs();
}


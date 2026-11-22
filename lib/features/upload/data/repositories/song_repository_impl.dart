import 'dart:typed_data';

import '../../domain/entities/song_entity.dart';
import '../../domain/repositories/song_repository.dart';
import '../datasources/song_remote_data_source.dart';
import '../models/song_creation_request_model.dart';
import '../models/song_update_request_model.dart';

class SongRepositoryImpl implements SongRepository {
  final SongRemoteDataSource remoteDataSource;

  SongRepositoryImpl({required this.remoteDataSource});

  @override
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
  }) async {
    final request = SongCreationRequestModel(
      title: title,
      artist: artist,
      album: album,
      visibility: visibility,
    );

    return remoteDataSource.uploadSong(
      request: request,
      audioPath: audioPath,
      audioBytes: audioBytes,
      audioFileName: audioFileName,
      coverPath: coverPath,
      coverBytes: coverBytes,
      coverFileName: coverFileName,
      onSendProgress: onSendProgress,
    );
  }

  @override
  Future<SongEntity> updateSong({
    required String songId,
    required String title,
    required String artist,
    String? album,
    required String visibility,
  }) async {
    final request = SongUpdateRequestModel(
      title: title,
      artist: artist,
      album: album,
      visibility: visibility,
    );

    return remoteDataSource.updateSong(songId, request);
  }

  @override
  Future<void> deleteSong(String songId) {
    return remoteDataSource.deleteSong(songId);
  }

  @override
  Future<List<SongEntity>> getMySongs() {
    return remoteDataSource.getMySongs();
  }
}


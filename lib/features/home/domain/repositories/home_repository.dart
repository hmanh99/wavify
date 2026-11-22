import '../entities/song_entity.dart';

abstract class HomeRepository {
  Future<List<SongEntity>> getAllSongs({int page = 0, int size = 50});
}


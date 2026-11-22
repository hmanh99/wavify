import '../../domain/entities/song_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SongEntity>> getAllSongs({int page = 0, int size = 50}) {
    return remoteDataSource.getAllSongs(page: page, size: size);
  }
}


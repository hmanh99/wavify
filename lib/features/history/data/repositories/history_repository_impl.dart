import '../../domain/entities/history_entity.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_data_source.dart';
import '../datasources/history_remote_data_source.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;
  final HistoryLocalDataSource localDataSource;

  HistoryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<void> recordHistory(String songId) async {
    try {
      await remoteDataSource.recordHistory(songId);
    } catch (_) {
      // Allow fallback recording or silent fail on connection loss
      rethrow;
    }
  }

  @override
  Future<List<HistoryEntity>> getHistory({int page = 0, int size = 20}) async {
    try {
      final remoteList = await remoteDataSource.getHistory(page: page, size: size);
      if (remoteList.isNotEmpty) {
        await localDataSource.cacheHistory(remoteList);
      }
      return remoteList;
    } catch (_) {
      final cached = await localDataSource.getCachedHistory();
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      await remoteDataSource.clearHistory();
    } catch (_) {}
    await localDataSource.clearHistory();
  }

  @override
  Future<void> deleteHistoryItem(String historyId) async {
    try {
      await remoteDataSource.deleteHistoryItem(historyId);
    } catch (_) {}
    await localDataSource.deleteHistoryItem(historyId);
  }
}

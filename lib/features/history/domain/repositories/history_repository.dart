import '../entities/history_entity.dart';

abstract class HistoryRepository {
  Future<void> recordHistory(String songId);
  Future<List<HistoryEntity>> getHistory({int page = 0, int size = 20});
  Future<void> clearHistory();
  Future<void> deleteHistoryItem(String historyId);
}

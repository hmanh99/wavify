import '../repositories/history_repository.dart';

class RecordHistoryUseCase {
  final HistoryRepository repository;

  RecordHistoryUseCase(this.repository);

  Future<void> call(String songId) => repository.recordHistory(songId);
}

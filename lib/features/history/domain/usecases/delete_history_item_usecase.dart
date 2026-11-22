import '../repositories/history_repository.dart';

class DeleteHistoryItemUseCase {
  final HistoryRepository repository;

  DeleteHistoryItemUseCase(this.repository);

  Future<void> call(String historyId) => repository.deleteHistoryItem(historyId);
}

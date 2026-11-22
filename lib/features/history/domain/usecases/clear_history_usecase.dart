import '../repositories/history_repository.dart';

class ClearHistoryUseCase {
  final HistoryRepository repository;

  ClearHistoryUseCase(this.repository);

  Future<void> call() => repository.clearHistory();
}

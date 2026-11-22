import '../entities/history_entity.dart';
import '../repositories/history_repository.dart';

class GetHistoryUseCase {
  final HistoryRepository repository;

  GetHistoryUseCase(this.repository);

  Future<List<HistoryEntity>> call({int page = 0, int size = 20}) =>
      repository.getHistory(page: page, size: size);
}

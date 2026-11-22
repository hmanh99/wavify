import '../repositories/listen_repository.dart';

class RecordListenHistoryUseCase {
  final ListenRepository repository;

  RecordListenHistoryUseCase(this.repository);

  Future<void> call(String songId) => repository.recordListenHistory(songId);
}

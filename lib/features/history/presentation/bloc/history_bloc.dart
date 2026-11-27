import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/clear_history_usecase.dart';
import '../../domain/usecases/delete_history_item_usecase.dart';
import '../../domain/usecases/get_history_usecase.dart';
import '../../domain/usecases/record_history_usecase.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistoryUseCase getHistoryUseCase;
  final RecordHistoryUseCase recordHistoryUseCase;
  final ClearHistoryUseCase clearHistoryUseCase;
  final DeleteHistoryItemUseCase? deleteHistoryItemUseCase;

  HistoryBloc({
    required this.getHistoryUseCase,
    required this.recordHistoryUseCase,
    required this.clearHistoryUseCase,
    this.deleteHistoryItemUseCase,
  }) : super(const HistoryInitial()) {
    on<HistoryLoadRequested>(_onLoadRequested);
    on<HistoryRecordRequested>(_onRecordRequested);
    on<HistoryClearRequested>(_onClearRequested);
    on<HistorySessionCleared>(_onSessionCleared);
    on<HistoryDeleteItemRequested>(_onDeleteItemRequested);
  }

  Future<void> _onLoadRequested(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const HistoryLoading());
    }

    try {
      final list = await getHistoryUseCase();
      emit(HistoryLoaded(list));
    } catch (e) {
      if (!(event.isRefresh && state is HistoryLoaded)) {
        emit(HistoryFailure(e.toString().replaceAll('Exception: ', '')));
      }
    } finally {
      if (event.completer != null && !event.completer!.isCompleted) {
        event.completer!.complete();
      }
    }
  }

  Future<void> _onRecordRequested(
    HistoryRecordRequested event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await recordHistoryUseCase(event.songId);
    } catch (_) {}
  }

  Future<void> _onClearRequested(
    HistoryClearRequested event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await clearHistoryUseCase();
      emit(const HistoryLoaded([]));
    } catch (e) {
      emit(HistoryFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onSessionCleared(
    HistorySessionCleared event,
    Emitter<HistoryState> emit,
  ) {
    emit(const HistoryInitial());
  }

  Future<void> _onDeleteItemRequested(
    HistoryDeleteItemRequested event,
    Emitter<HistoryState> emit,
  ) async {
    if (state is! HistoryLoaded) return;
    final currentList = (state as HistoryLoaded).history;
    final updatedList = currentList.where((h) => h.id != event.historyId).toList();
    emit(HistoryLoaded(updatedList));

    try {
      if (deleteHistoryItemUseCase != null) {
        await deleteHistoryItemUseCase!(event.historyId);
      }
    } catch (_) {}
  }
}

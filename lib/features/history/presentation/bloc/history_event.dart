import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class HistoryLoadRequested extends HistoryEvent {
  final bool isRefresh;

  const HistoryLoadRequested({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class HistoryRecordRequested extends HistoryEvent {
  final String songId;

  const HistoryRecordRequested(this.songId);

  @override
  List<Object?> get props => [songId];
}

class HistoryClearRequested extends HistoryEvent {
  const HistoryClearRequested();
}

class HistoryDeleteItemRequested extends HistoryEvent {
  final String historyId;

  const HistoryDeleteItemRequested(this.historyId);

  @override
  List<Object?> get props => [historyId];
}

import 'package:equatable/equatable.dart';
import 'history_song_entity.dart';

class HistoryEntity extends Equatable {
  final String id;
  final String? userId;
  final HistorySongEntity song;
  final DateTime playedAt;

  const HistoryEntity({
    required this.id,
    this.userId,
    required this.song,
    required this.playedAt,
  });

  @override
  List<Object?> get props => [id, userId, song, playedAt];
}

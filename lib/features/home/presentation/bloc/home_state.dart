import 'package:equatable/equatable.dart';
import '../../domain/entities/song_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<SongEntity> allSongs;
  final List<SongEntity> filteredSongs;
  final List<SongEntity> recommendedSongs;
  final String searchQuery;

  const HomeLoaded({
    required this.allSongs,
    required this.filteredSongs,
    List<SongEntity>? recommendedSongs,
    this.searchQuery = '',
  }) : recommendedSongs = recommendedSongs ?? allSongs;

  bool get isSearching => searchQuery.trim().isNotEmpty;

  @override
  List<Object?> get props => [
    allSongs,
    filteredSongs,
    recommendedSongs,
    searchQuery,
  ];
}

class HomeFailure extends HomeState {
  final String message;
  final List<SongEntity>? cachedSongs;

  const HomeFailure(this.message, {this.cachedSongs});

  @override
  List<Object?> get props => [message, cachedSongs];
}

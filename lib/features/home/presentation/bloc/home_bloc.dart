import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/song_entity.dart';
import '../../domain/usecases/get_all_songs_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  static const int maxRecommendations = 10;

  final GetAllSongsUseCase getAllSongsUseCase;
  final math.Random _random;

  HomeBloc({required this.getAllSongsUseCase, math.Random? random})
    : _random = random ?? math.Random(),
      super(const HomeInitial()) {
    on<HomeLoadSongsRequested>(_onLoadSongs);
    on<HomeRefreshRequested>(_onRefreshSongs);
    on<HomeSearchQueryChanged>(_onSearchQueryChanged);
    on<HomeShuffleRecommendationsRequested>(_onShuffleRecommendations);
  }

  Future<void> _onLoadSongs(
    HomeLoadSongsRequested event,
    Emitter<HomeState> emit,
  ) async {
    final currentSongs = state is HomeLoaded
        ? (state as HomeLoaded).allSongs
        : null;
    if (state is! HomeLoaded) {
      emit(const HomeLoading());
    }

    try {
      final songs = await getAllSongsUseCase();
      final currentQuery = state is HomeLoaded
          ? (state as HomeLoaded).searchQuery
          : '';
      final filtered = _filterSongs(songs, currentQuery);
      emit(
        HomeLoaded(
          allSongs: songs,
          filteredSongs: filtered,
          recommendedSongs: _buildRecommendations(songs),
          searchQuery: currentQuery,
        ),
      );
    } catch (e) {
      emit(HomeFailure(_cleanError(e), cachedSongs: currentSongs));
    }
  }

  Future<void> _onRefreshSongs(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final songs = await getAllSongsUseCase();
      final currentQuery = state is HomeLoaded
          ? (state as HomeLoaded).searchQuery
          : '';
      final filtered = _filterSongs(songs, currentQuery);
      emit(
        HomeLoaded(
          allSongs: songs,
          filteredSongs: filtered,
          recommendedSongs: _buildRecommendations(songs),
          searchQuery: currentQuery,
        ),
      );
    } catch (e) {
      final currentSongs = state is HomeLoaded
          ? (state as HomeLoaded).allSongs
          : null;
      emit(HomeFailure(_cleanError(e), cachedSongs: currentSongs));
    }
  }

  void _onSearchQueryChanged(
    HomeSearchQueryChanged event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final loaded = state as HomeLoaded;
      final filtered = _filterSongs(loaded.allSongs, event.query);
      emit(
        HomeLoaded(
          allSongs: loaded.allSongs,
          filteredSongs: filtered,
          recommendedSongs: loaded.recommendedSongs,
          searchQuery: event.query,
        ),
      );
    }
  }

  void _onShuffleRecommendations(
    HomeShuffleRecommendationsRequested event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final loaded = state as HomeLoaded;
      emit(
        HomeLoaded(
          allSongs: loaded.allSongs,
          filteredSongs: loaded.filteredSongs,
          recommendedSongs: _buildRecommendations(
            loaded.allSongs,
            previous: loaded.recommendedSongs,
          ),
          searchQuery: loaded.searchQuery,
        ),
      );
    }
  }

  List<SongEntity> _buildRecommendations(
    List<SongEntity> songs, {
    List<SongEntity>? previous,
  }) {
    if (songs.length <= 1) {
      return List<SongEntity>.unmodifiable(songs);
    }

    final shuffled = List<SongEntity>.of(songs)..shuffle(_random);
    var candidate = shuffled.take(maxRecommendations).toList(growable: false);

    if (previous != null &&
        previous.length > 1 &&
        candidate.length == previous.length) {
      final sameOrder = List.generate(
        candidate.length,
        (i) => candidate[i].id == previous[i].id,
      ).every((matched) => matched);
      if (sameOrder) {
        final swapped = shuffled[0];
        shuffled[0] = shuffled[1];
        shuffled[1] = swapped;
        candidate = shuffled.take(maxRecommendations).toList(growable: false);
      }
    }

    return candidate;
  }

  List<SongEntity> _filterSongs(List<SongEntity> songs, String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return songs;

    return songs.where((s) {
      final title = s.title.toLowerCase();
      final artist = s.artist.toLowerCase();
      final album = s.album?.toLowerCase() ?? '';
      return title.contains(trimmed) ||
          artist.contains(trimmed) ||
          album.contains(trimmed);
    }).toList();
  }

  String _cleanError(dynamic error) {
    final str = error.toString();
    if (str.startsWith('Exception: ')) {
      return str.substring('Exception: '.length);
    }
    return str;
  }
}

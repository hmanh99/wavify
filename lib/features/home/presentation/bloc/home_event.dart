import 'dart:async';

import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLoadSongsRequested extends HomeEvent {
  const HomeLoadSongsRequested();
}

class HomeRefreshRequested extends HomeEvent {
  final Completer<void>? completer;

  const HomeRefreshRequested({this.completer});
}

class HomeSearchQueryChanged extends HomeEvent {
  final String query;

  const HomeSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class HomeShuffleRecommendationsRequested extends HomeEvent {
  const HomeShuffleRecommendationsRequested();
}

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ThemeLoadRequested extends ThemeEvent {
  const ThemeLoadRequested();
}

class ThemeChangeRequested extends ThemeEvent {
  final ThemeMode themeMode;

  const ThemeChangeRequested(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class ThemeToggleRequested extends ThemeEvent {
  const ThemeToggleRequested();
}

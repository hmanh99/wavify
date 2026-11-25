import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'theme_event.dart';
import 'theme_state.dart';

export 'theme_event.dart';
export 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final FlutterSecureStorage? secureStorage;
  static const String _storageKey = 'app_theme_mode';

  ThemeBloc({this.secureStorage}) : super(const ThemeState(ThemeMode.system)) {
    on<ThemeLoadRequested>(_onLoadRequested);
    on<ThemeChangeRequested>(_onChangeRequested);
    on<ThemeToggleRequested>(_onToggleRequested);
  }

  Future<void> _onLoadRequested(
    ThemeLoadRequested event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final raw = await secureStorage?.read(key: _storageKey);
      final mode = _parseThemeMode(raw);
      if (mode != null) {
        emit(ThemeState(mode));
      }
    } catch (_) {}
  }

  Future<void> _onChangeRequested(
    ThemeChangeRequested event,
    Emitter<ThemeState> emit,
  ) async {
    if (state.themeMode == event.themeMode) return;
    emit(ThemeState(event.themeMode));
    try {
      await secureStorage?.write(
        key: _storageKey,
        value: _serializeThemeMode(event.themeMode),
      );
    } catch (_) {}
  }

  void _onToggleRequested(
    ThemeToggleRequested event,
    Emitter<ThemeState> emit,
  ) {
    final nextMode =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    add(ThemeChangeRequested(nextMode));
  }

  void setThemeMode(ThemeMode mode) => add(ThemeChangeRequested(mode));
  void toggleTheme() => add(const ThemeToggleRequested());

  static ThemeMode? _parseThemeMode(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }

  static String _serializeThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }
}

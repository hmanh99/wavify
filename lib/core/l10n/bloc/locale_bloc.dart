import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'locale_event.dart';
import 'locale_state.dart';

export 'locale_event.dart';
export 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final FlutterSecureStorage? secureStorage;
  static const String _storageKey = 'app_locale_code';

  LocaleBloc({this.secureStorage}) : super(const LocaleState(Locale('vi'))) {
    on<LocaleLoadRequested>(_onLoadRequested);
    on<LocaleChangeRequested>(_onChangeRequested);
    on<LocaleToggleRequested>(_onToggleRequested);
  }

  Future<void> _onLoadRequested(
    LocaleLoadRequested event,
    Emitter<LocaleState> emit,
  ) async {
    try {
      final code = await secureStorage?.read(key: _storageKey);
      if (code != null && (code == 'en' || code == 'vi')) {
        emit(LocaleState(Locale(code)));
      }
    } catch (_) {}
  }

  Future<void> _onChangeRequested(
    LocaleChangeRequested event,
    Emitter<LocaleState> emit,
  ) async {
    if (state.locale == event.locale) return;
    emit(LocaleState(event.locale));
    try {
      await secureStorage?.write(key: _storageKey, value: event.locale.languageCode);
    } catch (_) {}
  }

  void _onToggleRequested(
    LocaleToggleRequested event,
    Emitter<LocaleState> emit,
  ) {
    final nextLocale =
        state.locale.languageCode == 'vi' ? const Locale('en') : const Locale('vi');
    add(LocaleChangeRequested(nextLocale));
  }

  void setLocale(Locale locale) => add(LocaleChangeRequested(locale));
  void toggleLocale() => add(const LocaleToggleRequested());
}

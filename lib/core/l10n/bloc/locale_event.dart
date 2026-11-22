import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LocaleEvent extends Equatable {
  const LocaleEvent();

  @override
  List<Object?> get props => [];
}

class LocaleLoadRequested extends LocaleEvent {
  const LocaleLoadRequested();
}

class LocaleChangeRequested extends LocaleEvent {
  final Locale locale;

  const LocaleChangeRequested(this.locale);

  @override
  List<Object?> get props => [locale];
}

class LocaleToggleRequested extends LocaleEvent {
  const LocaleToggleRequested();
}

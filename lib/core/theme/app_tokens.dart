import 'package:flutter/material.dart';

/// Spacing scale following a strict 4dp grid (4 / 8 / 12 / 16 / 24 / 32).
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

/// Border radius tokens for consistent geometry across surfaces and controls.
class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double hundred = 100.0;
}

/// Minimalist elevation tokens (flat-first design).
class AppElevation {
  AppElevation._();

  static const double none = 0.0;
  static const double subtle = 1.0;
}

/// Subtle, brisk motion durations (150–300ms).
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 300);
}

/// Semantic and surface tokens exposed via [ThemeExtension] for Light & Dark modes.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color cardSurface;
  final Color inputFill;
  final Color subtleBorder;
  final Color navBackground;
  final Color textMuted;
  final Color overlay;

  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.cardSurface,
    required this.inputFill,
    required this.subtleBorder,
    required this.navBackground,
    required this.textMuted,
    required this.overlay,
  });

  static const AppSemanticColors dark = AppSemanticColors(
    success: Color(0xFF34D399),
    onSuccess: Color(0xFF052E16),
    warning: Color(0xFFFBBF24),
    onWarning: Color(0xFF1C1917),
    cardSurface: Color(0xFF161619),
    inputFill: Color(0xFF1F1F24),
    subtleBorder: Color(0xFF2A2A30),
    navBackground: Color(0xFF0E0E10),
    textMuted: Color(0xFFA1A1AA),
    overlay: Color(0xB8000000),
  );

  static const AppSemanticColors light = AppSemanticColors(
    success: Color(0xFF15803D),
    onSuccess: Color(0xFFFFFFFF),
    warning: Color(0xFFB45309),
    onWarning: Color(0xFFFFFFFF),
    cardSurface: Color(0xFFFFFFFF),
    inputFill: Color(0xFFEFEFF3),
    subtleBorder: Color(0xFFE2E2E8),
    navBackground: Color(0xFFFFFFFF),
    textMuted: Color(0xFF52525B),
    overlay: Color(0xA6000000),
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? cardSurface,
    Color? inputFill,
    Color? subtleBorder,
    Color? navBackground,
    Color? textMuted,
    Color? overlay,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      cardSurface: cardSurface ?? this.cardSurface,
      inputFill: inputFill ?? this.inputFill,
      subtleBorder: subtleBorder ?? this.subtleBorder,
      navBackground: navBackground ?? this.navBackground,
      textMuted: textMuted ?? this.textMuted,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  AppSemanticColors lerp(
    covariant ThemeExtension<AppSemanticColors>? other,
    double t,
  ) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t) ?? success,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t) ?? onSuccess,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      onWarning: Color.lerp(onWarning, other.onWarning, t) ?? onWarning,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t) ?? cardSurface,
      inputFill: Color.lerp(inputFill, other.inputFill, t) ?? inputFill,
      subtleBorder:
          Color.lerp(subtleBorder, other.subtleBorder, t) ?? subtleBorder,
      navBackground:
          Color.lerp(navBackground, other.navBackground, t) ?? navBackground,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      overlay: Color.lerp(overlay, other.overlay, t) ?? overlay,
    );
  }
}

/// Ergonomic theme accessors on [BuildContext].
extension AppThemeContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  AppSemanticColors get appColors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.dark;
}

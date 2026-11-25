import 'package:flutter/material.dart';
import '../constants/colors_constant.dart';

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

/// Crisp architectural border radius tokens for Utilitarian Minimalism.
class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 6.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
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
    success: ColorsConstant.success,
    onSuccess: Color(0xFF052E16),
    warning: ColorsConstant.warning,
    onWarning: Color(0xFF1C1917),
    cardSurface: ColorsConstant.cardBackground,
    inputFill: ColorsConstant.inputBackground,
    subtleBorder: ColorsConstant.border,
    navBackground: ColorsConstant.bottomNavBackground,
    textMuted: ColorsConstant.textSecondary,
    overlay: ColorsConstant.overlay,
  );

  static const AppSemanticColors light = AppSemanticColors(
    success: ColorsConstant.lightSuccess,
    onSuccess: ColorsConstant.lightOnError,
    warning: ColorsConstant.lightWarning,
    onWarning: ColorsConstant.lightOnError,
    cardSurface: ColorsConstant.lightCardBackground,
    inputFill: ColorsConstant.lightInputBackground,
    subtleBorder: ColorsConstant.lightBorder,
    navBackground: ColorsConstant.lightCardBackground,
    textMuted: ColorsConstant.lightTextSecondary,
    overlay: Color(0xB80B0B0C),
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

import 'package:flutter/material.dart';

/// Monochrome & semantic color palette meeting WCAG AA contrast (>= 4.5:1).
class ColorsConstant {
  ColorsConstant._();

  // Monochrome Base
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // Dark Mode Primary & Contrast
  static const Color primary = Color(0xFFF5F5F7);
  static const Color onPrimary = Color(0xFF0E0E10);
  static const Color primaryLight = Color(0xFFF5F5F7);
  static const Color primaryDisabled = Color(0xFF3F3F46);

  // Dark Mode Surfaces
  static const Color scaffoldBackground = Color(0xFF0E0E10);
  static const Color cardBackground = Color(0xFF161619);
  static const Color inputBackground = Color(0xFF1F1F24);
  static const Color surface = Color(0xFF161619);
  static const Color searchBackground = Color(0xFF1F1F24);
  static const Color bottomNavBackground = Color(0xFF0E0E10);
  static const Color bottomNavBorder = Color(0xFF2A2A30);

  // Light Mode Palette
  static const Color lightScaffoldBackground = Color(0xFFF8F8FA);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightInputBackground = Color(0xFFEFEFF3);
  static const Color lightPrimary = Color(0xFF111114);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E2E8);
  static const Color lightTextPrimary = Color(0xFF111114);
  static const Color lightTextSecondary = Color(0xFF52525B);

  // Borders & Dividers
  static const Color border = Color(0xFF2A2A30);
  static const Color divider = Color(0xFF2A2A30);

  // Overlays
  static const Color shadow = Color(0x33000000);
  static const Color overlay = Color(0xB8000000);

  // Text & Neutral Shades (WCAG AA on dark surfaces)
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textHint = Color(0xFF8E8E98);

  // Player Slider & Controls
  static const Color playerSliderActive = Color(0xFFF5F5F7);
  static const Color playerSliderInactive = Color(0xFF3F3F46);

  // Status Colors (WCAG AA paired)
  static const Color error = Color(0xFFF87171);
  static const Color onError = Color(0xFF0E0E10);
  static const Color lightError = Color(0xFFB91C1C);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF34D399);
  static const Color lightSuccess = Color(0xFF15803D);
  static const Color warning = Color(0xFFFBBF24);
  static const Color lightWarning = Color(0xFFB45309);
}

typedef AppColors = ColorsConstant;

import 'package:flutter/material.dart';

/// Monochrome & semantic color palette meeting WCAG AA contrast (>= 4.5:1).
class ColorsConstant {
  ColorsConstant._();

  // Monochrome Base
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // Dark Mode Primary & Contrast (Pitch Obsidian Canvas + Elevated Graphite)
  static const Color primary = Color(0xFFF5F4F0);
  static const Color onPrimary = Color(0xFF09090B);
  static const Color primaryLight = Color(0xFFF5F4F0);
  static const Color primaryDisabled = Color(0xFF3A3A40);

  // Dark Mode Surfaces
  static const Color scaffoldBackground = Color(0xFF09090B);
  static const Color cardBackground = Color(0xFF18181C);
  static const Color inputBackground = Color(0xFF232329);
  static const Color surface = Color(0xFF18181C);
  static const Color searchBackground = Color(0xFF232329);
  static const Color bottomNavBackground = Color(0xFF121215);
  static const Color bottomNavBorder = Color(0xFF2E2E36);

  // Light Mode Palette (Warm Architectural Stone Canvas + Pure Paper White)
  static const Color lightScaffoldBackground = Color(0xFFF1F0EC);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightInputBackground = Color(0xFFE6E4DE);
  static const Color lightPrimary = Color(0xFF111110);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFD4D1C8);
  static const Color lightTextPrimary = Color(0xFF111110);
  static const Color lightTextSecondary = Color(0xFF4A4843);

  // Borders & Dividers
  static const Color border = Color(0xFF2E2E36);
  static const Color divider = Color(0xFF2E2E36);

  // Overlays
  static const Color shadow = Color(0x26000000);
  static const Color overlay = Color(0xC809090B);

  // Text & Neutral Shades (WCAG AA/AAA on elevated & recessed surfaces)
  static const Color textPrimary = Color(0xFFF5F4F0);
  static const Color textSecondary = Color(0xFFAEACA6);
  static const Color textHint = Color(0xFF908E88);

  // Player Slider & Controls
  static const Color playerSliderActive = Color(0xFFF5F4F0);
  static const Color playerSliderInactive = Color(0xFF2E2E36);

  // Status Colors (WCAG AA paired)
  static const Color error = Color(0xFFF87171);
  static const Color onError = Color(0xFF09090B);
  static const Color lightError = Color(0xFFB91C1C);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF34D399);
  static const Color lightSuccess = Color(0xFF15803D);
  static const Color warning = Color(0xFFFBBF24);
  static const Color lightWarning = Color(0xFFB45309);
}

typedef AppColors = ColorsConstant;

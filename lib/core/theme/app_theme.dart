import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors_constant.dart';
import 'app_tokens.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(Color primaryText, Color secondaryText) {
    // Strictly 2 font weights: w400 (regular) and w600 (semibold) for calm visual hierarchy.
    return TextTheme(
      headlineLarge: TextStyle(
        color: primaryText,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.7,
        height: 1.18,
      ),
      headlineSmall: TextStyle(
        color: primaryText,
        fontSize: 21,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.45,
        height: 1.22,
      ),
      titleLarge: TextStyle(
        color: primaryText,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        height: 1.28,
      ),
      titleMedium: TextStyle(
        color: primaryText,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.15,
        height: 1.32,
      ),
      bodyLarge: TextStyle(
        color: primaryText,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        color: secondaryText,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        color: secondaryText,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.38,
      ),
      labelLarge: TextStyle(
        color: primaryText,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.25,
      ),
      labelSmall: TextStyle(
        color: secondaryText,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.2,
      ),
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required AppSemanticColors semanticColors,
    required Color scaffoldBackground,
  }) {
    final textTheme = _buildTextTheme(
      colorScheme.onSurface,
      semanticColors.textMuted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBackground,
      primaryColor: colorScheme.primary,
      colorScheme: colorScheme,
      textTheme: textTheme,
      extensions: [semanticColors],
      dividerColor: semanticColors.subtleBorder,
      dividerTheme: DividerThemeData(
        color: semanticColors.subtleBorder,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: colorScheme.onSurface,
        elevation: AppElevation.none,
        scrolledUnderElevation: AppElevation.none,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: colorScheme.onSurface, size: 22),
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: semanticColors.cardSurface,
        elevation: AppElevation.none,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.onSurface.withValues(
            alpha: 0.12,
          ),
          disabledForegroundColor: colorScheme.onSurface.withValues(
            alpha: 0.45,
          ),
          elevation: AppElevation.none,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: semanticColors.subtleBorder, width: 1),
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: colorScheme.onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: semanticColors.inputFill,
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: semanticColors.textMuted,
        ),
        labelStyle: textTheme.bodySmall?.copyWith(
          color: semanticColors.textMuted,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: colorScheme.error),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: semanticColors.subtleBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: semanticColors.subtleBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: semanticColors.cardSurface,
        elevation: AppElevation.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: semanticColors.subtleBorder),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: semanticColors.cardSurface,
        elevation: AppElevation.none,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: semanticColors.cardSurface,
        elevation: AppElevation.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: semanticColors.subtleBorder),
        ),
        textStyle: textTheme.bodyLarge,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: semanticColors.cardSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: semanticColors.subtleBorder),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: colorScheme.onSurface,
        unselectedLabelColor: semanticColors.textMuted,
        dividerColor: semanticColors.subtleBorder,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.bodyMedium,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
        side: BorderSide(color: semanticColors.textMuted, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return semanticColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return semanticColors.inputFill;
        }),
        trackOutlineColor: WidgetStateProperty.all(semanticColors.subtleBorder),
      ),
    );
  }

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: ColorsConstant.primary,
      onPrimary: ColorsConstant.onPrimary,
      secondary: ColorsConstant.primary,
      onSecondary: ColorsConstant.onPrimary,
      surface: ColorsConstant.cardBackground,
      onSurface: ColorsConstant.textPrimary,
      onSurfaceVariant: ColorsConstant.textSecondary,
      outline: ColorsConstant.border,
      outlineVariant: ColorsConstant.border,
      error: ColorsConstant.error,
      onError: ColorsConstant.onError,
    );

    return _buildTheme(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      semanticColors: AppSemanticColors.dark,
      scaffoldBackground: ColorsConstant.scaffoldBackground,
    );
  }

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: ColorsConstant.lightPrimary,
      onPrimary: ColorsConstant.lightOnPrimary,
      secondary: ColorsConstant.lightPrimary,
      onSecondary: ColorsConstant.lightOnPrimary,
      surface: ColorsConstant.lightCardBackground,
      onSurface: ColorsConstant.lightTextPrimary,
      onSurfaceVariant: ColorsConstant.lightTextSecondary,
      outline: ColorsConstant.lightBorder,
      outlineVariant: ColorsConstant.lightBorder,
      error: ColorsConstant.lightError,
      onError: ColorsConstant.lightOnError,
    );

    return _buildTheme(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      semanticColors: AppSemanticColors.light,
      scaffoldBackground: ColorsConstant.lightScaffoldBackground,
    );
  }
}

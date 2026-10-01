import 'package:flutter/material.dart';

/// Semantic color tokens designed for high outdoor visibility under direct sunlight
/// for Indian farmers on entry-level Android and iOS screens.
class AppColors {
  AppColors._();

  // Primary Agriculture Brand Tokens (High-contrast foliage & crop tones)
  static const Color primary = Color(0xFF135826); // Deep Lush Green
  static const Color primaryDark = Color(0xFF0C3818);
  static const Color primaryLight = Color(0xFF2E7D32);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color primaryContainer = Color(0xFFE8F5E9);
  static const Color onPrimaryContainer = Color(0xFF092911);

  // Secondary Harvest Tokens (Golden Mustard & Ripened Wheat)
  static const Color secondary = Color(0xFFB45309); // Deep Harvest Amber
  static const Color secondaryLight = Color(0xFFD97706);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFEF3C7);
  static const Color onSecondaryContainer = Color(0xFF451A03);

  // Background & Surfaces (Glare-reducing daylight tones)
  static const Color background = Color(0xFFF6F8F6); // Soft outdoor anti-glare
  static const Color surface = Color(0xFFFFFFFF); // Clean crisp card surface
  static const Color surfaceSubtle = Color(0xFFEEF2EE);
  static const Color cardSurface = Color(0xFFFFFFFF);

  // High-Contrast Typography (Exceeds WCAG AAA outdoor visibility)
  static const Color textPrimary = Color(0xFF0F1A12); // Near-black leaf tint
  static const Color textSecondary = Color(0xFF37473D); // Dark slate green
  static const Color textMuted = Color(0xFF5D6E63); // Muted neutral
  static const Color textOnInverse = Color(0xFFFFFFFF);

  // Borders & Dividers
  static const Color border = Color(0xFFC7D4CA);
  static const Color borderSubtle = Color(0xFFE0E7E2);
  static const Color divider = Color(0xFFE2E9E3);

  // Feedback & Alert Tokens
  static const Color success = Color(0xFF1E7E34);
  static const Color successContainer = Color(0xFFE8F8EC);
  static const Color onSuccessContainer = Color(0xFF0D4A1B);

  static const Color warning = Color(0xFFB45309);
  static const Color warningContainer = Color(0xFFFFF7ED);
  static const Color onWarningContainer = Color(0xFF78350F);

  static const Color alert = Color(0xFFB91C1C);
  static const Color alertContainer = Color(0xFFFEF2F2);
  static const Color onAlertContainer = Color(0xFF7F1D1D);

  static const Color info = Color(0xFF0369A1);
  static const Color infoContainer = Color(0xFFE0F2FE);
  static const Color onInfoContainer = Color(0xFF0C4A6E);

  // Shimmer Tokens for Low-End Smooth Perceived Performance
  static const Color shimmerBase = Color(0xFFE2E8E3);
  static const Color shimmerHighlight = Color(0xFFF4F7F4);

  /// Generates the ThemeData adhering strictly to Light Mode and high contrast
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        error: alert,
        onError: onPrimary,
        errorContainer: alertContainer,
        onErrorContainer: onAlertContainer,
        surface: surface,
        onSurface: textPrimary,
        surfaceContainerHighest: surfaceSubtle,
        outline: border,
        outlineVariant: borderSubtle,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: onPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        iconTheme: IconThemeData(color: onPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0.8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

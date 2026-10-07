import 'package:flutter/material.dart';

/// AERIS design system: a restrained environmental/tech palette —
/// deep neutral blue-green foundation, off-white surfaces, teal accent.
/// Kept intentionally simple: one ColorScheme, a few shared constants.
class AppTheme {
  static const Color _seed = Color(0xFF1F5F58); // deep teal-green
  static const double radius = 14;

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
      surface: const Color(0xFFF7F7F4), // warm off-white
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(height: 1.35),
        labelSmall: TextStyle(letterSpacing: 0.6, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withOpacity(0.12),
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant.withOpacity(0.6)),
    );
  }

  /// Status color for an air-quality category, used consistently across
  /// the dashboard, AirBand, and history screens.
  static Color categoryColor(String category) {
    switch (category) {
      case 'Good':
        return const Color(0xFF2E8B57);
      case 'Moderate':
        return const Color(0xFFB98900);
      case 'Unhealthy (Sensitive)':
        return const Color(0xFFD2691E);
      default:
        return const Color(0xFFC0392B);
    }
  }
}

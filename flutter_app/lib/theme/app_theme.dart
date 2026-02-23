import 'package:flutter/material.dart';

class AppTheme {
  // ===== Light Mode - Fresh Indigo/Violet Palette =====
  static const Color primary = Color(0xFF6366F1);       // Indigo 500
  static const Color primaryLight = Color(0xFF818CF8);   // Indigo 400
  static const Color primaryDark = Color(0xFF4338CA);    // Indigo 700
  static const Color accent = Color(0xFF8B5CF6);         // Violet 500
  static const Color accentLight = Color(0xFFA78BFA);    // Violet 400
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F3FF);     // Very light violet
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color gradientStart = Color(0xFF6366F1);
  static const Color gradientEnd = Color(0xFF8B5CF6);
  static const Color gradientAccent = Color(0xFFEC4899); // Pink accent

  // ===== Dark Mode =====
  static const Color dPrimary = Color(0xFF818CF8);
  static const Color dAccent = Color(0xFFA78BFA);
  static const Color dSurface = Color(0xFF1F2937);
  static const Color dBackground = Color(0xFF111827);
  static const Color dCardBg = Color(0xFF1F2937);
  static const Color dDivider = Color(0xFF374151);
  static const Color dTextPrimary = Color(0xFFF9FAFB);
  static const Color dTextSecondary = Color(0xFF9CA3AF);
  static const Color dTextTertiary = Color(0xFF6B7280);

  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    primary: primary, accent: accent, surface: surface, background: background,
    cardBg: cardBg, dividerColor: divider,
    textPrimary: textPrimary, textSecondary: textSecondary, textTertiary: textTertiary,
  );

  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    primary: dPrimary, accent: dAccent, surface: dSurface, background: dBackground,
    cardBg: dCardBg, dividerColor: dDivider,
    textPrimary: dTextPrimary, textSecondary: dTextSecondary, textTertiary: dTextTertiary,
  );

  static ThemeData get theme => lightTheme;

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary, required Color accent, required Color surface,
    required Color background, required Color cardBg, required Color dividerColor,
    required Color textPrimary, required Color textSecondary, required Color textTertiary,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Pretendard',
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTheme.primary,
        brightness: brightness,
        surface: surface,
        primary: primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700,
          letterSpacing: -0.5, fontFamily: 'Pretendard',
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg, elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: dividerColor.withValues(alpha: 0.5), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? dBackground : const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: dividerColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: dividerColor.withValues(alpha: 0.6))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: TextStyle(color: textTertiary, fontSize: 14),
        labelStyle: TextStyle(color: textSecondary, fontSize: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),
      dividerTheme: DividerThemeData(color: dividerColor, thickness: 1, space: 0),
      chipTheme: ChipThemeData(
        backgroundColor: background,
        selectedColor: primary.withValues(alpha: 0.12),
        labelStyle: TextStyle(fontSize: 13, color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: dividerColor.withValues(alpha: 0.5))),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.white : textTertiary),
        trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? primary : dividerColor),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textTertiary,
        indicatorColor: primary,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 14),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFF1F2937),
      ),
    );
  }

  // Gradient helpers
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  static LinearGradient get heroGradient => const LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static LinearGradient softGradient(ColorScheme cs) => LinearGradient(
    colors: [cs.primary.withValues(alpha: 0.06), cs.primary.withValues(alpha: 0.01)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
}

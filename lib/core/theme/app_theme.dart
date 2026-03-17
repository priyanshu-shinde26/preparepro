import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);

  // Card Gradients
  static const List<List<Color>> cardGradients = [
    [Color(0xFF2563EB), Color(0xFF7C3AED)],
    [Color(0xFF7C3AED), Color(0xFFEC4899)],
    [Color(0xFF06B6D4), Color(0xFF2563EB)],
    [Color(0xFF10B981), Color(0xFF06B6D4)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    [Color(0xFFEC4899), Color(0xFF7C3AED)],
  ];

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      primary: primaryBlue,
      secondary: primaryPurple,
      tertiary: accentCyan,
      surface: const Color(0xFFF8FAFF),
      background: const Color(0xFFF1F5FF),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.sora(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        surfaceTintColor: Colors.transparent,
        color: const Color(0xFFFFFFFF),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.sora(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        labelStyle: GoogleFonts.sora(color: Colors.grey.shade600),
        hintStyle: GoogleFonts.sora(color: Colors.grey.shade400),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Color(0xFF94A3B8),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      scaffoldBackgroundColor: const Color(0xFFF1F5FF),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
      primary: const Color(0xFF60A5FA),
      secondary: const Color(0xFFA78BFA),
      tertiary: accentCyan,
      surface: const Color(0xFF1E293B),
      background: const Color(0xFF0F172A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.sora(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        surfaceTintColor: Colors.transparent,
        color: const Color(0xFF1E293B),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF60A5FA),
          foregroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.sora(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF60A5FA), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        labelStyle: GoogleFonts.sora(color: const Color(0xFF94A3B8)),
        hintStyle: GoogleFonts.sora(color: const Color(0xFF475569)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E293B),
        selectedItemColor: Color(0xFF60A5FA),
        unselectedItemColor: Color(0xFF475569),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: GoogleFonts.sora(fontSize: 36, fontWeight: FontWeight.w700, color: colorScheme.onBackground),
      displayMedium: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w700, color: colorScheme.onBackground),
      displaySmall: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w700, color: colorScheme.onBackground),
      headlineLarge: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700, color: colorScheme.onBackground),
      headlineMedium: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onBackground),
      headlineSmall: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onBackground),
      titleLarge: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onBackground),
      titleMedium: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onBackground),
      titleSmall: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w500, color: colorScheme.onBackground),
      bodyLarge: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w400, color: colorScheme.onBackground),
      bodyMedium: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w400, color: colorScheme.onBackground),
      bodySmall: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w400, color: colorScheme.onSurfaceVariant),
      labelLarge: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.primary),
      labelMedium: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w500, color: colorScheme.primary),
      labelSmall: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w500, color: colorScheme.primary),
    );
  }
}
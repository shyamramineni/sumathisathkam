import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final Color _seedColor = Colors.indigo;
  static const Color _scaffoldBackgroundColor =
      Color(0xFFFDFCF4); // Warm off-white

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      surface: const Color(
          0xFFFDFCF4), // Match background for consistency or slightly different
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _scaffoldBackgroundColor,

      // Typography
      textTheme: GoogleFonts.ntrTextTheme().copyWith(
        displayLarge: GoogleFonts.ntr(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary),
        displayMedium: GoogleFonts.ntr(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface),
        headlineLarge: GoogleFonts.ntr(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface),
        titleLarge: GoogleFonts.ntr(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface),
        bodyLarge: GoogleFonts.ntr(
            fontSize: 20,
            height: 1.5,
            color: colorScheme.onSurface), // Poem body
        bodyMedium: GoogleFonts.ntr(
            fontSize: 18,
            height: 1.4,
            color: colorScheme.onSurfaceVariant), // General text
        labelLarge: GoogleFonts.ntr(fontSize: 16, fontWeight: FontWeight.w600),
      ),

      // Component Themes
      appBarTheme: AppBarTheme(
        backgroundColor: _scaffoldBackgroundColor,
        foregroundColor: colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.ntr(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary),
      ),

      cardTheme: CardTheme(
        elevation: 2,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.ntr(fontSize: 18, fontWeight: FontWeight.w600),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
    );
  }
}

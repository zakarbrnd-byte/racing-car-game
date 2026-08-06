import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color asphalt = Color(0xFF1A1F2E);
  static const Color asphaltLight = Color(0xFF2A3142);
  static const Color roadMark = Color(0xFFFFF3C4);
  static const Color grass = Color(0xFF1B4D3E);
  static const Color danger = Color(0xFFFF6B4A);
  static const Color cream = Color(0xFFF7F0E0);

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: asphalt,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE8B84A),
        brightness: Brightness.dark,
        surface: asphalt,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor: cream,
        displayColor: cream,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.bebasNeue(
          fontSize: 28,
          letterSpacing: 2,
          color: cream,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: asphalt,
          backgroundColor: const Color(0xFFE8B84A),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

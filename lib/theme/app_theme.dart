import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Colores (idénticos al CSS) ──────────────────────────
  static const Color bg        = Color(0xFFF0EDE8);
  static const Color white     = Color(0xFFFFFFFF);
  static const Color surface   = Color(0xFFF7F5F2);
  static const Color border    = Color(0xFFE2DDD7);
  static const Color textColor = Color(0xFF1A1814);
  static const Color muted     = Color(0xFF8A8075);
  static const Color accent    = Color(0xFF1A47D6);
  static const Color accentL   = Color(0xFFEEF1FC);
  static const Color green     = Color(0xFF1A7A4A);
  static const Color greenL    = Color(0xFFE8F5EE);
  static const Color red       = Color(0xFFC0392B);
  static const Color redL      = Color(0xFFFDECEA);
  static const Color yellow    = Color(0xFFB07D00);
  static const Color yellowL   = Color(0xFFFFF8E0);

  // Avatar colors
  static const List<Color> avBg = [
    Color(0xFFDDE8FB), Color(0xFFD9F0E6),
    Color(0xFFFDE5E5), Color(0xFFEDE5FD), Color(0xFFD5F5F0),
  ];
  static const List<Color> avFg = [
    Color(0xFF1A47D6), Color(0xFF1A7A4A),
    Color(0xFFC0392B), Color(0xFF6D28D9), Color(0xFF0F7A6E),
  ];

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      background: bg,
    ),
    textTheme: GoogleFonts.nunitoTextTheme().copyWith(
      bodyLarge:  GoogleFonts.nunito(color: textColor),
      bodyMedium: GoogleFonts.nunito(color: textColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(double.infinity, 48),
        textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    cardTheme: CardThemeData(
      color: white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: border),
      ),
    ),
  );
}

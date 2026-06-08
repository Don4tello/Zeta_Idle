import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color darkBg = Color(0xFF0a0e27);
  static const Color cardBg = Color(0xFF1a1f3a);
  static const Color cardBorder = Color(0xFF3d2817);
  static const Color accentGold = Color(0xFFd4af37);
  static const Color accentRed = Color(0xFF8b0000);
  static const Color accentGreen = Color(0xFF2d5016);
  static const Color textLight = Color(0xFFe8dcc8);
  static const Color textMuted = Color(0xFF9a8b7d);
  static const Color pixelBorder = Color(0xFF4a3828);
  static const Color pixelBorderBright = Color(0xFF6a5840);

  // Called from widget build() methods — safe to call GoogleFonts here.
  static TextStyle pixelHeading({
    double fontSize = 14,
    Color color = accentGold,
    double letterSpacing = 2,
    FontWeight weight = FontWeight.bold,
  }) =>
      GoogleFonts.pixelifySans(
        fontSize: fontSize,
        color: color,
        letterSpacing: letterSpacing,
        fontWeight: weight,
      );

  static ThemeData darkMedievalTheme() {
    final base = ThemeData.dark();
    // Safe: apply font via textTheme only, no inline GoogleFonts calls below.
    final pixelText = GoogleFonts.pixelifySansTextTheme(base.textTheme).apply(
      bodyColor: textLight,
      displayColor: accentGold,
    );
    return base.copyWith(
      textTheme: pixelText,
      scaffoldBackgroundColor: darkBg,
      primaryColor: accentGold,
      appBarTheme: const AppBarTheme(
        backgroundColor: cardBg,
        foregroundColor: accentGold,
        elevation: 0,
        centerTitle: true,
        // titleTextStyle intentionally omitted — inherits pixelifySans from textTheme
      ),
      cardColor: cardBg,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: darkBg,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentGold,
          side: const BorderSide(color: accentGold, width: 2),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        linearTrackColor: Color(0xFF2a2f42),
        linearMinHeight: 8,
      ),
    );
  }
}

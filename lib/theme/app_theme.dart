import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Medieval Idle RPG — Design Token Reference
//
// Palette direction: torch-lit dungeon · worn leather · iron & stone · muted gold
//
// Backgrounds (darkest → lightest)
//   darkBg      #1B1A17   scaffold / page bg     charcoal-brown, almost black
//   bgSecondary #2A2623   sections, layer above bg dark leather / wood tone
//   cardBg      #2A2623   nav bars, bottom bars   same tone, slightly lifted
//   panelBg     #332F2B   cards, modals, menus    raised surface
//
// Accents
//   accentGold      #C9A35A   primary CTA · XP bars · coins · active tabs
//   accentGoldBright#E6C97A   hover / selected / glow / premium emphasis
//   accentRed       #7A2E2E   combat · danger · attack · enemy UI
//   accentBlue      #3A5F73   magic · mana · arcane abilities
//   accentGreen     #3E5A3C   healing · nature · ranger / alchemy
//
// Text
//   textLight    #E8E3D9   primary readable text — parchment off-white
//   textMuted    #B7AE9F   descriptions, labels, secondary detail
//   textDisabled #6F675E   disabled / placeholder
//
// Borders
//   cardBorder       #4A3929   card / container borders
//   pixelBorder      #4A3C2E   pixel-art style thick border
//   pixelBorderBright#6B5540   pixel-art bright / highlight border
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  // ── Backgrounds ─────────────────────────────────────────────────────────────
  static const Color darkBg      = Color(0xFF1B1A17);
  static const Color bgSecondary = Color(0xFF2A2623);
  static const Color cardBg      = Color(0xFF2A2623);
  static const Color panelBg     = Color(0xFF332F2B);

  // ── Borders ──────────────────────────────────────────────────────────────────
  static const Color cardBorder        = Color(0xFF4A3929);
  static const Color pixelBorder       = Color(0xFF4A3C2E);
  static const Color pixelBorderBright = Color(0xFF6B5540);

  // ── Accents ──────────────────────────────────────────────────────────────────
  static const Color accentGold       = Color(0xFFC9A35A);
  static const Color accentGoldBright = Color(0xFFE6C97A);
  static const Color accentRed        = Color(0xFF7A2E2E);
  static const Color accentBlue       = Color(0xFF3A5F73);
  static const Color accentGreen      = Color(0xFF3E5A3C);

  // ── Text ─────────────────────────────────────────────────────────────────────
  static const Color textLight    = Color(0xFFE8E3D9);
  static const Color textMuted    = Color(0xFFB7AE9F);
  static const Color textDisabled = Color(0xFF6F675E);

  // ── Typography helper ────────────────────────────────────────────────────────
  static TextStyle pixelHeading({
    double fontSize = 15,
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

  // ── Full theme ───────────────────────────────────────────────────────────────
  static ThemeData darkMedievalTheme() {
    final base = ThemeData.dark();
    final pixelText = GoogleFonts.pixelifySansTextTheme(base.textTheme).apply(
      bodyColor: textLight,
      displayColor: accentGold,
      fontSizeDelta: 1.0,
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
      ),
      cardColor: panelBg,
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
        linearTrackColor: Color(0xFF2E2A26),
        linearMinHeight: 8,
      ),
      dividerColor: cardBorder,
      dialogBackgroundColor: panelBg,
    );
  }
}

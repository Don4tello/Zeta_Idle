import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.accentColor,
  });

  final String title;
  final Widget child;
  /// Optional accent color for the left bar and title. Defaults to accentGold.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppTheme.accentGold;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border(
          top:    BorderSide(color: accent.withValues(alpha: 0.55), width: 2),
          left:   BorderSide(color: accent.withValues(alpha: 0.55), width: 2),
          right:  BorderSide(color: AppTheme.pixelBorder, width: 2),
          bottom: BorderSide(color: AppTheme.pixelBorder, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // â”€â”€ Header row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF201A10),
                  const Color(0xFF1A1510),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              border: const Border(
                bottom: BorderSide(color: AppTheme.pixelBorder, width: 2),
              ),
            ),
            child: Row(
              children: [
                // Left accent pillar
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: accent,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.only(right: 10),
                ),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: accent,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: accent.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // â”€â”€ Body â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Padding(
            padding: const EdgeInsets.all(14),
            child: DefaultTextStyle(
              style: const TextStyle(color: AppTheme.textLight),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

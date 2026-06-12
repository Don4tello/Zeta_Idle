import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: AppTheme.cardBg,
        border: Border(
          top: BorderSide(color: AppTheme.pixelBorderBright, width: 2),
          left: BorderSide(color: AppTheme.pixelBorderBright, width: 2),
          right: BorderSide(color: AppTheme.pixelBorder, width: 2),
          bottom: BorderSide(color: AppTheme.pixelBorder, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF1e2440),
              border: Border(
                bottom: BorderSide(color: AppTheme.pixelBorder, width: 2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  color: AppTheme.accentGold,
                  margin: const EdgeInsets.only(right: 8),
                ),
                Text(
                  title.toUpperCase(),
                  style: GoogleFonts.pixelifySans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
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

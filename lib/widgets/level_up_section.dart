import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class LevelUpSection extends StatelessWidget {
  const LevelUpSection({super.key, required this.event});
  final LevelUpEvent event;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('â¬†', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              'LEVEL UP!  Lv ${event.fromLevel} â†’ ${event.toLevel}',
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentGold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'HP: ${event.hpBefore} â†’ ${event.hpAfter}',
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            color: const Color(0xFF66cc44),
            letterSpacing: 1,
          ),
        ),
        if (event.statGains.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: event.statGains
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.12),
                        border: Border.all(
                            color: AppTheme.accentGold.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        '$s +1',
                        style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentGold,
                          letterSpacing: 1,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}

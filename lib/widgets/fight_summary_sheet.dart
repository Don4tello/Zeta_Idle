import 'package:flutter/material.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

/// Post-fight summary — the stat breakdown (abilities used, max/avg/total
/// damage, rounds) with the full battle log below. Reusable across every mode
/// that produces a [FightSummary]; opened as a modal bottom sheet.
void showFightSummary(BuildContext context, FightSummary summary) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF1B1A17),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.8,
      child: FightSummarySheet(summary: summary),
    ),
  );
}

class FightSummarySheet extends StatelessWidget {
  const FightSummarySheet({super.key, required this.summary});
  final FightSummary summary;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final resultColor = s.victory ? const Color(0xFF44cc88) : const Color(0xFFff5555);
    // Bottom SafeArea keeps the battle log clear of the Android nav bar/gesture area.
    return SafeArea(
      top: false,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grab handle + header
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(children: [
            Text(s.victory ? '🏆' : '☠', style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.victory ? 'VICTORY' : 'DEFEAT',
                    style: AppTheme.pixelHeading(
                        fontSize: 13, letterSpacing: 2, color: resultColor)),
                Text('vs ${s.enemyName}  ·  ${s.rounds} rounds',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              ]),
            ),
          ]),
        ),
        const Divider(color: AppTheme.cardBorder, height: 16),
        // Stat grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            _stat('TOTAL DMG', AppTheme.fmtNumber(s.totalDamage), const Color(0xFFff6644)),
            _stat('MAX HIT',   AppTheme.fmtNumber(s.maxHit),      const Color(0xFFffcc44)),
            _stat('AVG HIT',   AppTheme.fmtNumber(s.avgHit),      const Color(0xFF66aaff)),
            _stat('HITS',      '${s.hitCount}',                   const Color(0xFF88ddaa)),
          ]),
        ),
        const SizedBox(height: 12),
        // Abilities used
        if (s.abilitiesUsed.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('ABILITIES USED',
                style: AppTheme.pixelHeading(
                    fontSize: 10, letterSpacing: 1.5, color: AppTheme.textMuted)),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 6, runSpacing: 6,
              children: s.abilitiesUsed.entries
                  .map((e) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF231F1B),
                          border: Border.all(color: AppTheme.cardBorder),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text('${e.key} ×${e.value}',
                            style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],
        // Full battle log
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('BATTLE LOG',
              style: AppTheme.pixelHeading(
                  fontSize: 10, letterSpacing: 1.5, color: AppTheme.textMuted)),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: s.log.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(s.log[i],
                  style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.3)),
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF231F1B),
            border: Border.all(color: color.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(children: [
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 8, letterSpacing: 0.5)),
          ]),
        ),
      );
}

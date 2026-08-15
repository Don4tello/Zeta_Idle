import 'package:flutter/material.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../utils/format_number.dart';

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
          child: Builder(builder: (_) {
            // Collapse consecutive identical lines into "line  ×N".
            final folded = <({String text, int count})>[];
            for (final line in s.log) {
              if (folded.isNotEmpty && folded.last.text == line) {
                folded[folded.length - 1] = (text: line, count: folded.last.count + 1);
              } else {
                folded.add((text: line, count: 1));
              }
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: folded.length,
              itemBuilder: (_, i) =>
                  _LogLine(text: folded[i].text, count: folded[i].count),
            );
          }),
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

/// A single battle-log line, colour-coded + icon-tagged by category so the log
/// is scannable at a glance (damage / crit / heal / buff / mitigated / …).
class _LogLine extends StatelessWidget {
  const _LogLine({required this.text, this.count = 1});
  final String text;
  final int count;

  // Matches integers (optionally comma-grouped) so we can trim + highlight them.
  static final _numRe = RegExp(r'\d[\d,]*');

  static ({Color color, String icon}) _classify(String line) {
    final l = line.toLowerCase();
    if (l.contains('crit')) return (color: const Color(0xFFffcc44), icon: '💥');
    if (l.contains('resist') || l.contains('immune') || l.contains('misses') ||
        l.contains('negat') || l.contains('block') || l.contains('dodge')) {
      return (color: const Color(0xFF8a8a8a), icon: '🛡');
    }
    if (l.contains('heal') || l.contains('restored') || l.contains('regenerat') ||
        l.contains('hp/round') || l.contains('lifesteal') || l.contains('lifedrain')) {
      return (color: const Color(0xFF44cc88), icon: '➕');
    }
    if (l.contains('stun') || l.contains('weaken') || l.contains('vulnerab') ||
        l.contains('reduced') || l.contains('primed') || l.contains('surge') ||
        l.contains('buff') || l.contains('wall') || l.contains('shield') ||
        l.contains('bless') || l.contains('aura')) {
      return (color: const Color(0xFF66aaff), icon: '✦');
    }
    if (l.contains('gold') || l.contains('loot') || l.contains('drop') ||
        l.contains('shard') || l.contains('mythril')) {
      return (color: const Color(0xFFC9A35A), icon: '💰');
    }
    if (l.contains('fallen') || l.contains('defeated!') || l.contains('has died')) {
      return (color: const Color(0xFFff5555), icon: '☠');
    }
    if (l.contains('advances') || l.contains('victory') || l.contains('falls') ||
        l.contains('defeated') || l.contains('slain')) {
      return (color: const Color(0xFF88dd88), icon: '🏆');
    }
    if (l.contains('damage') || l.contains(' dmg') || l.contains('takes') ||
        l.contains('hit!')) {
      return (color: const Color(0xFFff8866), icon: '⚔');
    }
    return (color: Colors.white60, icon: '');
  }

  bool get _startsWithEmoji =>
      text.isNotEmpty && text.runes.first > 0x2000;

  @override
  Widget build(BuildContext context) {
    final c = _classify(text);
    final showIcon = c.icon.isNotEmpty && !_startsWithEmoji;

    // Split the line into text + number spans. Numbers >= 1000 are trimmed
    // (2.0K / 1.9M) and every number is brightened + bold so values pop.
    final numStyle = TextStyle(
        color: _brighten(c.color), fontSize: 12, height: 1.3,
        fontWeight: FontWeight.bold);
    final baseStyle = TextStyle(color: c.color, fontSize: 12, height: 1.3);
    final spans = <TextSpan>[];
    var last = 0;
    for (final m in _numRe.allMatches(text)) {
      if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start)));
      final n = int.tryParse(m.group(0)!.replaceAll(',', '')) ?? 0;
      spans.add(TextSpan(text: n >= 1000 ? fmtNum(n) : m.group(0)!, style: numStyle));
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    if (count > 1) {
      spans.add(TextSpan(
          text: '  ×$count',
          style: TextStyle(
              color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon) ...[
            Text(c.icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text.rich(TextSpan(style: baseStyle, children: spans)),
          ),
        ],
      ),
    );
  }

  /// Lighten a category colour a touch so highlighted numbers stand out.
  static Color _brighten(Color c) =>
      Color.lerp(c, Colors.white, 0.35) ?? c;
}

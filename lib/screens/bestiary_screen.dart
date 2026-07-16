import 'package:flutter/material.dart';
import '../data/bestiary_data.dart';
import '../models/bestiary_entry.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart' show TutorialTip;

class BestiaryScreen extends StatelessWidget {
  const BestiaryScreen({super.key});

  static const _weaknessIcons = <BestiaryWeakness, String>{
    BestiaryWeakness.undead:    '☩',
    BestiaryWeakness.beast:     '🐺',
    BestiaryWeakness.arcane:    '✦',
    BestiaryWeakness.demonic:   '🔥',
    BestiaryWeakness.construct: '⚙',
  };

  static const _weaknessColors = <BestiaryWeakness, Color>{
    BestiaryWeakness.undead:    Color(0xFF8888ff),
    BestiaryWeakness.beast:     Color(0xFF88cc44),
    BestiaryWeakness.arcane:    Color(0xFFcc44ff),
    BestiaryWeakness.demonic:   Color(0xFFff4444),
    BestiaryWeakness.construct: Color(0xFFff9922),
  };

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final zones = kBestiaryEntries.map((e) => e.category).toSet().toList();

    final totalDiscovered = kBestiaryEntries
        .where((e) => game.bestiaryDiscovered(e.enemyId))
        .length;
    final totalEntries = kBestiaryEntries.length;
    final atkBonus = game.bestiaryChapterBonus;

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('BESTIARY',
            style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TutorialTip(
            tutorialKey: 'bestiary',
            game: game,
            text: 'Your Bestiary is filling up! 🐉 Each enemy type unlocks lore and '
                'permanent damage bonuses against that creature. More kills = stronger you.',
          ),
          // ── Summary header ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF231F1B),
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(children: [
              Expanded(child: _Stat(
                  'DISCOVERED',
                  '$totalDiscovered / $totalEntries',
                  AppTheme.accentGold)),
              Expanded(child: _Stat(
                  'ZONES',
                  '${zones.where((z) => game.isBestiaryChapterComplete(z)).length} / ${zones.length}',
                  const Color(0xFF66aaff))),
              Expanded(child: _Stat(
                  'ATK BONUS',
                  '+$atkBonus',
                  const Color(0xFFff6633))),
              Expanded(child: _Stat(
                  'MASTERY',
                  game.bestiaryMasteryAtkBonus > 0 ? '+${game.bestiaryMasteryAtkBonus} ATK' : '—',
                  const Color(0xFFffaaff))),
            ]),
          ),

          // ── Bonus explanation ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              border: Border.all(color: AppTheme.cardBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Each discovered enemy grants +1 permanent ATK.\n'
              'Kill milestones reward gold, shards & essence — and at 250+ kills, '
              'permanent ATK bonuses.\nKill count also boosts gold from that enemy: '
              '+2% at 50 kills → +15% at 500 kills.',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.5),
            ),
          ),

          // ── Zone sections ─────────────────────────────────────────────────
          for (final zone in zones) ...[
            _ZoneHeader(
              zone: zone,
              complete: game.isBestiaryChapterComplete(zone),
              canClaim: game.canClaimChapterReward(zone),
              onClaim: () => game.claimBestiaryChapterReward(zone),
              discovered: kBestiaryEntries
                  .where((e) => e.category == zone && game.bestiaryDiscovered(e.enemyId))
                  .length,
              total: kBestiaryEntries.where((e) => e.category == zone).length,
            ),
            ...kBestiaryEntries
                .where((e) => e.category == zone)
                .map((entry) => _BestiaryCard(
                      entry: entry,
                      kills: game.bestiaryKillCount(entry.enemyId),
                      weaknessColor: _weaknessColors[entry.weakness]!,
                      weaknessIcon: _weaknessIcons[entry.weakness]!,
                    )),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.color);
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: AppTheme.pixelHeading(
                fontSize: 10, color: AppTheme.textMuted, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value,
            style: AppTheme.pixelHeading(fontSize: 15, color: color)),
      ],
    );
  }
}

class _ZoneHeader extends StatelessWidget {
  const _ZoneHeader({
    required this.zone,
    required this.complete,
    required this.discovered,
    required this.total,
    this.canClaim = false,
    this.onClaim,
  });
  final String zone;
  final bool complete;
  final bool canClaim;
  final VoidCallback? onClaim;
  final int discovered, total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: canClaim
            ? const Color(0xFFffcc33).withValues(alpha: 0.10)
            : complete
                ? const Color(0xFF44cc66).withValues(alpha: 0.08)
                : const Color(0xFF0d1020),
        border: Border.all(
            color: canClaim
                ? const Color(0xFFffcc33).withValues(alpha: 0.6)
                : complete
                    ? const Color(0xFF44cc66).withValues(alpha: 0.4)
                    : AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        children: [
          Row(children: [
            Expanded(
              child: Text(zone.toUpperCase(),
                  style: AppTheme.pixelHeading(
                      fontSize: 11,
                      color: complete ? const Color(0xFF44cc66) : AppTheme.accentGold,
                      letterSpacing: 2)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFff6633).withValues(alpha: 0.10),
                border: Border.all(color: const Color(0xFFff6633).withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '+$discovered ATK',
                style: AppTheme.pixelHeading(fontSize: 9, color: const Color(0xFFff6633)),
              ),
            ),
            const SizedBox(width: 8),
            Text('$discovered/$total',
                style: TextStyle(
                    fontSize: 12,
                    color: complete ? const Color(0xFF44cc66) : AppTheme.textMuted)),
            if (complete && !canClaim) ...[
              const SizedBox(width: 6),
              const Icon(Icons.star, color: Color(0xFF44cc66), size: 14),
            ],
          ]),
          if (canClaim) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: onClaim,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFffcc33).withValues(alpha: 0.15),
                  border: Border.all(color: const Color(0xFFffcc33).withValues(alpha: 0.6)),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'CLAIM REWARD  •  +500g  +15✦  +5🪙',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.bold,
                    color: Color(0xFFffcc33), letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BestiaryCard extends StatelessWidget {
  const _BestiaryCard({
    required this.entry,
    required this.kills,
    required this.weaknessColor,
    required this.weaknessIcon,
  });
  final BestiaryEntry entry;
  final int kills;
  final Color weaknessColor;
  final String weaknessIcon;

  @override
  Widget build(BuildContext context) {
    final discovered = kills > 0;
    final dmgPct = discovered ? (kills ~/ 10).clamp(0, 10) : 0;
    final dmgMaxed = dmgPct >= 10;
    // Next meaningful threshold: dmg caps at 100, then gold bonus tiers at 250 / 500
    final nextThreshold = discovered
        ? (kills < 100 ? ((kills ~/ 10) + 1) * 10
           : kills < 250 ? 250
           : kills < 500 ? 500
           : 500)
        : 10;
    final fullyMaxed = kills >= 500;
    // Gold bonus pct for display
    final goldBonusPct = kills >= 500 ? 15 : kills >= 250 ? 10 : kills >= 100 ? 5 : kills >= 50 ? 2 : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: discovered ? const Color(0xFF231F1B) : const Color(0xFF080a18),
          border: Border.all(
              color: discovered
                  ? AppTheme.cardBorder
                  : AppTheme.cardBorder.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Weakness icon
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: weaknessColor.withValues(alpha: discovered ? 0.12 : 0.04),
              border: Border.all(
                  color: weaknessColor.withValues(alpha: discovered ? 0.6 : 0.2)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              discovered ? weaknessIcon : '?',
              style: TextStyle(
                  fontSize: 19,
                  color: weaknessColor.withValues(alpha: discovered ? 1.0 : 0.3)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name row
                Row(children: [
                  Text(
                    discovered ? entry.name : '???',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: discovered ? Colors.white : Colors.white24,
                    ),
                  ),
                  if (discovered) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: weaknessColor.withValues(alpha: 0.12),
                        border: Border.all(color: weaknessColor.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        entry.weakness.displayName,
                        style: TextStyle(
                            fontSize: 9,
                            color: weaknessColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dmgMaxed ? '+10% dmg ✓' : '+$dmgPct% dmg',
                      style: TextStyle(
                          fontSize: 9,
                          color: dmgMaxed
                              ? const Color(0xFFffcc44)
                              : weaknessColor.withValues(alpha: 0.7)),
                    ),
                    // Gold bonus badge
                    if (goldBonusPct > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFffdd44).withValues(alpha: 0.12),
                          border: Border.all(color: const Color(0xFFffdd44).withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '+$goldBonusPct% 💰',
                          style: const TextStyle(fontSize: 8, color: Color(0xFFffdd44), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ]),
                const SizedBox(height: 4),
                // Flavor text
                Text(
                  discovered
                      ? entry.flavorText
                      : 'Kill this creature to reveal its secrets.',
                  style: TextStyle(
                    fontSize: 11,
                    color: discovered ? AppTheme.textMuted : Colors.white24,
                    fontStyle: discovered ? FontStyle.italic : FontStyle.normal,
                    height: 1.4,
                  ),
                ),
                // Kill progress bar (hidden only when fully maxed at 500)
                if (discovered && !fullyMaxed) ...[
                  const SizedBox(height: 6),
                  _KillProgress(kills: kills, nextAt: nextThreshold, color: weaknessColor),
                ],
                // Kill milestones
                if (discovered) ...[
                  const SizedBox(height: 4),
                  Builder(builder: (ctx) {
                    final game = GameStateProvider.of(ctx);
                    return Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: GameState.bestiaryMilestones.map((m) {
                        final reached  = kills >= m;
                        final claimed  = game.isBestiaryMilestoneClaimed(entry.enemyId, m);
                        final canClaim = reached && !claimed;
                        final label    = _milestoneLabel(m);
                        return GestureDetector(
                          onTap: canClaim ? () => game.claimBestiaryMilestone(entry.enemyId, m) : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: canClaim
                                  ? const Color(0xFFffcc33).withValues(alpha: 0.15)
                                  : reached
                                      ? weaknessColor.withValues(alpha: 0.08)
                                      : Colors.transparent,
                              border: Border.all(
                                color: canClaim
                                    ? const Color(0xFFffcc33).withValues(alpha: 0.7)
                                    : reached
                                        ? weaknessColor.withValues(alpha: 0.3)
                                        : Colors.white12,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              claimed ? '$m ✓' : canClaim ? '$m ★ $label' : '$m',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: canClaim ? FontWeight.bold : FontWeight.normal,
                                color: canClaim
                                    ? const Color(0xFFffcc33)
                                    : reached ? weaknessColor : Colors.white24,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Kill count
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                discovered ? '×$kills' : '×0',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: discovered ? AppTheme.accentGold : Colors.white24),
              ),
              Text('killed',
                  style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
              if (discovered) ...[
                const SizedBox(height: 2),
                Text(
                  fullyMaxed ? '⭐ MAX' : '→$nextThreshold',
                  style: TextStyle(
                      fontSize: 9,
                      color: fullyMaxed
                          ? const Color(0xFFffcc44)
                          : AppTheme.textMuted.withValues(alpha: 0.6)),
                ),
              ],
            ],
          ),
        ]),
      ),
    );
  }
}

String _milestoneLabel(int m) => switch (m) {
  10  => '+100g',
  50  => '+300g +5◆',
  100 => '+800g +10◆ +5✦',
  250 => '+1500g +20◆ +10✦ +1ATK',
  500 => '+3000g +30◆ +20✦ +2ATK',
  _   => '',
};

class _KillProgress extends StatelessWidget {
  const _KillProgress({required this.kills, required this.nextAt, required this.color});
  final int kills;
  final int nextAt;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final prevThreshold = (kills ~/ 10) * 10;
    final progress = (kills - prevThreshold) / 10.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('next +1% dmg at $nextAt kills',
                style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.5))),
            Text('${kills % 10}/10',
                style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.5))),
          ],
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 3,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color.withValues(alpha: 0.5)),
          ),
        ),
      ],
    );
  }
}

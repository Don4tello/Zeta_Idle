import 'package:flutter/material.dart';
import '../data/bestiary_data.dart';
import '../models/bestiary_entry.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart' show TutorialTip;

// ── Type metadata ──────────────────────────────────────────────────────────────

const _typeOrder = [
  BestiaryWeakness.undead,
  BestiaryWeakness.beast,
  BestiaryWeakness.arcane,
  BestiaryWeakness.demonic,
  BestiaryWeakness.construct,
];

const _typeIcons = <BestiaryWeakness, IconData>{
  BestiaryWeakness.undead:    Icons.nights_stay,
  BestiaryWeakness.beast:     Icons.pets,
  BestiaryWeakness.arcane:    Icons.auto_fix_high,
  BestiaryWeakness.demonic:   Icons.local_fire_department,
  BestiaryWeakness.construct: Icons.settings,
};

const _typeColors = <BestiaryWeakness, Color>{
  BestiaryWeakness.undead:    Color(0xFF8888ff),
  BestiaryWeakness.beast:     Color(0xFF88cc44),
  BestiaryWeakness.arcane:    Color(0xFFcc44ff),
  BestiaryWeakness.demonic:   Color(0xFFff4444),
  BestiaryWeakness.construct: Color(0xFFff9922),
};

// ── Screen ────────────────────────────────────────────────────────────────────

class BestiaryScreen extends StatelessWidget {
  const BestiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);

    final totalDiscovered = kBestiaryEntries
        .where((e) => game.bestiaryDiscovered(e.enemyId))
        .length;
    final totalEntries = kBestiaryEntries.length;

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
            text: 'Kill enemies to fill the Bestiary. Each enemy type grants '
                'permanent damage bonuses — the more of that type you defeat, '
                'the stronger the bonus.',
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
                  'TYPES',
                  '${_typeOrder.length}',
                  const Color(0xFF66aaff))),
              Expanded(child: _Stat(
                  'ATK BONUS',
                  '+${game.bestiaryChapterBonus}',
                  const Color(0xFFff6633))),
              Expanded(child: _Stat(
                  'MASTERY',
                  game.bestiaryMasteryAtkBonus > 0
                      ? '+${game.bestiaryMasteryAtkBonus} ATK'
                      : '—',
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
              'Discovering an enemy grants +1 permanent ATK.\n'
              'Accumulate kills in each enemy type to unlock type-wide '
              'damage bonuses (+1% per 100 type kills, cap +25%).\n'
              'Individual kill milestones reward gold, shards & essence.',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.5),
            ),
          ),

          // ── Type sections ─────────────────────────────────────────────────
          for (final type in _typeOrder) ...[
            _TypeSection(game: game, type: type),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

// ── Type section (header + enemy cards) ───────────────────────────────────────

class _TypeSection extends StatefulWidget {
  const _TypeSection({required this.game, required this.type});
  final GameState game;
  final BestiaryWeakness type;

  @override
  State<_TypeSection> createState() => _TypeSectionState();
}

class _TypeSectionState extends State<_TypeSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final game  = widget.game;
    final type  = widget.type;
    final color = _typeColors[type]!;
    final icon  = _typeIcons[type]!;

    final entries = kBestiaryEntries.where((e) => e.weakness == type).toList();
    final totalKills   = game.typeKillCount(type);
    final typePct      = game.bestiaryTypeDamagePct(type);
    final discovered   = entries.where((e) => game.bestiaryDiscovered(e.enemyId)).length;
    final allFound     = discovered == entries.length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Type header ──────────────────────────────────────────────────────
      GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            border: Border.all(color: color.withValues(alpha: allFound ? 0.5 : 0.25)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(type.displayName.toUpperCase(),
                      style: AppTheme.pixelHeading(
                          fontSize: 12, letterSpacing: 2, color: color)),
                  const SizedBox(width: 8),
                  if (allFound)
                    const Icon(Icons.star, size: 13, color: Color(0xFF44cc66)),
                  const Spacer(),
                  Text('$discovered / ${entries.length}',
                      style: TextStyle(
                          fontSize: 12,
                          color: allFound
                              ? const Color(0xFF44cc66)
                              : AppTheme.textMuted)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      typePct > 0
                          ? '+$typePct% dmg vs ${type.displayName}'
                          : '0% type bonus',
                      style: TextStyle(
                          fontSize: 10,
                          color: typePct > 0 ? color : AppTheme.textMuted,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$totalKills total kills',
                      style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                  const Spacer(),
                  if (typePct < 25)
                    Text(
                      'next +1% at ${(((totalKills ~/ 100) + 1) * 100)} kills',
                      style: TextStyle(
                          fontSize: 9,
                          color: color.withValues(alpha: 0.5)),
                    )
                  else
                    Text('TYPE MAXED',
                        style: TextStyle(
                            fontSize: 9,
                            color: const Color(0xFFffdd44),
                            fontWeight: FontWeight.bold)),
                ]),
              ]),
            ),
            const SizedBox(width: 8),
            Icon(
              _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 18,
              color: color.withValues(alpha: 0.6),
            ),
          ]),
        ),
      ),

      // ── Enemy cards ──────────────────────────────────────────────────────
      if (_expanded) ...[
        const SizedBox(height: 6),
        ...entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _BestiaryCard(
                entry: entry,
                kills: game.bestiaryKillCount(entry.enemyId),
                color: color,
                icon: icon,
                game: game,
              ),
            )),
      ],
    ]);
  }
}

// ── Individual enemy card ──────────────────────────────────────────────────────

class _BestiaryCard extends StatelessWidget {
  const _BestiaryCard({
    required this.entry,
    required this.kills,
    required this.color,
    required this.icon,
    required this.game,
  });
  final BestiaryEntry entry;
  final int kills;
  final Color color;
  final IconData icon;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final discovered = kills > 0;
    final dmgPct     = discovered ? (kills ~/ 10).clamp(0, 10) : 0;
    final dmgMaxed   = dmgPct >= 10;
    final fullyMaxed = kills >= 500;
    final goldPct    = kills >= 500 ? 15 : kills >= 250 ? 10 : kills >= 100 ? 5 : kills >= 50 ? 2 : 0;
    final nextThreshold = discovered
        ? (kills < 100 ? ((kills ~/ 10) + 1) * 10
           : kills < 250 ? 250
           : kills < 500 ? 500
           : 500)
        : 10;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: discovered ? const Color(0xFF231F1B) : const Color(0xFF080a18),
        border: Border.all(
            color: discovered
                ? color.withValues(alpha: 0.2)
                : AppTheme.cardBorder.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Type icon
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: discovered ? 0.10 : 0.04),
            border: Border.all(
                color: color.withValues(alpha: discovered ? 0.5 : 0.15)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            discovered ? icon : Icons.help_outline,
            size: 18,
            color: color.withValues(alpha: discovered ? 1.0 : 0.3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Name + badges
            Row(children: [
              Text(
                discovered ? entry.name : '???',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: discovered ? Colors.white : Colors.white24,
                ),
              ),
              if (discovered) ...[
                const SizedBox(width: 6),
                // Zone label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(entry.category,
                      style: const TextStyle(
                          fontSize: 8, color: AppTheme.textMuted)),
                ),
                const SizedBox(width: 4),
                // Per-enemy dmg bonus
                Text(
                  dmgMaxed ? '+10% dmg ✓' : '+$dmgPct% dmg',
                  style: TextStyle(
                      fontSize: 9,
                      color: dmgMaxed
                          ? const Color(0xFFffcc44)
                          : color.withValues(alpha: 0.7)),
                ),
                if (goldPct > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFffdd44).withValues(alpha: 0.10),
                      border: Border.all(
                          color: const Color(0xFFffdd44).withValues(alpha: 0.45)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text('+$goldPct% gold',
                        style: const TextStyle(
                            fontSize: 8,
                            color: Color(0xFFffdd44),
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ]),
            const SizedBox(height: 3),
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
            // Kill progress bar
            if (discovered && !fullyMaxed) ...[
              const SizedBox(height: 6),
              _KillProgress(kills: kills, nextAt: nextThreshold, color: color),
            ],
            // Milestones
            if (discovered) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: GameState.bestiaryMilestones.map((m) {
                  final reached  = kills >= m;
                  final claimed  = game.isBestiaryMilestoneClaimed(entry.enemyId, m);
                  final canClaim = reached && !claimed;
                  return GestureDetector(
                    onTap: canClaim
                        ? () {
                            game.claimBestiaryMilestone(entry.enemyId, m);
                            game.audioService.playClaim();
                          }
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: canClaim
                            ? const Color(0xFFffcc33).withValues(alpha: 0.15)
                            : reached
                                ? color.withValues(alpha: 0.08)
                                : Colors.transparent,
                        border: Border.all(
                          color: canClaim
                              ? const Color(0xFFffcc33).withValues(alpha: 0.7)
                              : reached
                                  ? color.withValues(alpha: 0.3)
                                  : Colors.white12,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        claimed ? '$m ✓' : canClaim ? '$m ★ ${_milestoneLabel(m)}' : '$m',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: canClaim ? FontWeight.bold : FontWeight.normal,
                          color: canClaim
                              ? const Color(0xFFffcc33)
                              : reached ? color : Colors.white24,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ]),
        ),
        const SizedBox(width: 8),
        // Kill count
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            discovered ? '×$kills' : '×0',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: discovered ? AppTheme.accentGold : Colors.white24),
          ),
          const Text('killed',
              style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
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
        ]),
      ]),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.color);
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(label,
          style: AppTheme.pixelHeading(
              fontSize: 10, color: AppTheme.textMuted, letterSpacing: 1)),
      const SizedBox(height: 4),
      Text(value,
          style: AppTheme.pixelHeading(fontSize: 14, color: color)),
    ]);
  }
}

class _KillProgress extends StatelessWidget {
  const _KillProgress(
      {required this.kills, required this.nextAt, required this.color});
  final int kills;
  final int nextAt;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final prevThreshold = (kills ~/ 10) * 10;
    final progress = (kills - prevThreshold) / 10.0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('next +1% dmg at $nextAt kills',
            style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.5))),
        Text('${kills % 10}/10',
            style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.5))),
      ]),
      const SizedBox(height: 2),
      ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 3,
          backgroundColor: color.withValues(alpha: 0.12),
          valueColor:
              AlwaysStoppedAnimation<Color>(color.withValues(alpha: 0.5)),
        ),
      ),
    ]);
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

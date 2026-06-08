import 'package:flutter/material.dart';
import '../data/bestiary_data.dart';
import '../models/bestiary_entry.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

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
    final categories = kBestiaryEntries.map((e) => e.category).toSet().toList();

    final totalDiscovered = kBestiaryEntries
        .where((e) => game.bestiaryDiscovered(e.enemyId))
        .length;
    final completedChapters = categories
        .where((c) => game.isBestiaryChapterComplete(c))
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0e27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1f3a),
        title: Text('BESTIARY',
            style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary header
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0e1225),
              border: Border.all(
                  color: AppTheme.accentGold.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(children: [
              Expanded(child: _Stat(
                  'DISCOVERED',
                  '$totalDiscovered / ${kBestiaryEntries.length}',
                  AppTheme.accentGold)),
              Expanded(child: _Stat(
                  'CHAPTERS',
                  '$completedChapters / ${categories.length}',
                  const Color(0xFF66aaff))),
              Expanded(child: _Stat(
                  'ATK BONUS',
                  '+${game.bestiaryChapterBonus}',
                  const Color(0xFFff6633))),
            ]),
          ),

          // Bonus explanation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              border: Border.all(color: AppTheme.cardBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Discovering an enemy grants +10% damage against its type. '
              'Completing all 5 entries in a chapter grants +1 permanent ATK.',
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textMuted, height: 1.5),
            ),
          ),

          // Category sections
          for (final cat in categories) ...[
            _CategoryHeader(
              category: cat,
              complete: game.isBestiaryChapterComplete(cat),
              discovered: kBestiaryEntries
                  .where((e) => e.category == cat && game.bestiaryDiscovered(e.enemyId))
                  .length,
              total: kBestiaryEntries.where((e) => e.category == cat).length,
            ),
            ...kBestiaryEntries
                .where((e) => e.category == cat)
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
                fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value,
            style: AppTheme.pixelHeading(fontSize: 14, color: color)),
      ],
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.category,
    required this.complete,
    required this.discovered,
    required this.total,
  });
  final String category;
  final bool complete;
  final int discovered, total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: complete
            ? const Color(0xFF44cc66).withValues(alpha: 0.08)
            : const Color(0xFF0d1020),
        border: Border.all(
            color: complete
                ? const Color(0xFF44cc66).withValues(alpha: 0.4)
                : AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(children: [
        Text(category.toUpperCase(),
            style: AppTheme.pixelHeading(
                fontSize: 11,
                color: complete
                    ? const Color(0xFF44cc66)
                    : AppTheme.accentGold,
                letterSpacing: 2)),
        const Spacer(),
        Text('$discovered/$total',
            style: TextStyle(
                fontSize: 11,
                color: complete
                    ? const Color(0xFF44cc66)
                    : AppTheme.textMuted)),
        if (complete) ...[
          const SizedBox(width: 6),
          const Icon(Icons.star, color: Color(0xFF44cc66), size: 14),
          const SizedBox(width: 2),
          Text('+1 ATK',
              style: AppTheme.pixelHeading(
                  fontSize: 9, color: const Color(0xFF44cc66))),
        ],
      ]),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: discovered
              ? const Color(0xFF0e1225)
              : const Color(0xFF080a18),
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
                  color: weaknessColor.withValues(
                      alpha: discovered ? 0.6 : 0.2)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              discovered ? weaknessIcon : '?',
              style: TextStyle(
                  fontSize: 18,
                  color: weaknessColor.withValues(
                      alpha: discovered ? 1.0 : 0.3)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: weaknessColor.withValues(alpha: 0.12),
                        border: Border.all(
                            color: weaknessColor.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        entry.weakness.displayName,
                        style: TextStyle(
                            fontSize: 8,
                            color: weaknessColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('+10% dmg',
                        style: TextStyle(
                            fontSize: 8,
                            color: weaknessColor.withValues(alpha: 0.7))),
                  ],
                ]),
                const SizedBox(height: 4),
                Text(
                  discovered
                      ? entry.flavorText
                      : 'Kill this creature to reveal its secrets.',
                  style: TextStyle(
                    fontSize: 10,
                    color: discovered
                        ? AppTheme.textMuted
                        : Colors.white24,
                    fontStyle: discovered
                        ? FontStyle.italic
                        : FontStyle.normal,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                discovered ? '×$kills' : '×0',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: discovered ? AppTheme.accentGold : Colors.white24),
              ),
              Text('killed',
                  style: const TextStyle(
                      fontSize: 8, color: AppTheme.textMuted)),
            ],
          ),
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/class_mastery_data.dart';
import '../models/class_mastery.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class MasteryScreen extends StatelessWidget {
  const MasteryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final cls = game.hero.heroClass;
    final masteries = masteriesForClass(cls);
    final autoAttacks = masteries.where((m) => m.category == MasteryCategory.autoAttack).toList();
    final autoBuffs   = masteries.where((m) => m.category == MasteryCategory.autoBuff).toList();

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1f3a),
        title: Text('CLASS MASTERIES', style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: _GoldBadge(gold: game.gold),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ClassHeader(game: game),
          const SizedBox(height: 16),
          _SectionHeader(label: 'AUTO ATTACKS', color: const Color(0xFFff8833)),
          const SizedBox(height: 8),
          ...autoAttacks.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _MasteryCard(mastery: m, game: game, color: const Color(0xFFff8833)),
          )),
          const SizedBox(height: 16),
          _SectionHeader(label: 'AUTO BUFFS', color: const Color(0xFF44aaff)),
          const SizedBox(height: 8),
          ...autoBuffs.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _MasteryCard(mastery: m, game: game, color: const Color(0xFF44aaff)),
          )),
          const SizedBox(height: 24),
          _UpgradeCostTable(),
        ],
      ),
    );
  }
}

class _ClassHeader extends StatelessWidget {
  const _ClassHeader({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0e1225),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(game.hero.heroClass.info.icon, size: 28, color: Colors.white70),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(game.hero.heroClass.displayName.toUpperCase(),
                  style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
              const SizedBox(height: 2),
              Text('Lv ${game.hero.level}  ·  ${game.hero.name}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('UNLOCKED',
                  style: const TextStyle(fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1)),
              const SizedBox(height: 2),
              Text(
                '${game.masteryLevels.entries.where((e) => masteriesForClass(game.hero.heroClass).any((m) => m.id == e.key)).length}'
                '/${masteriesForClass(game.hero.heroClass).length}',
                style: AppTheme.pixelHeading(fontSize: 14, color: const Color(0xFFaaff88)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 14, color: color,
            margin: const EdgeInsets.only(right: 8)),
        Text(label, style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: color)),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: color.withValues(alpha: 0.2))),
      ],
    );
  }
}

class _MasteryCard extends StatelessWidget {
  const _MasteryCard({required this.mastery, required this.game, required this.color});
  final ClassMastery mastery;
  final GameState game;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final lvl        = game.masteryLevel(mastery.id);
    final unlocked   = lvl >= 1;
    final canUnlock  = game.canUnlockMastery(mastery);
    final levelMet   = game.hero.level >= mastery.levelRequired;
    final atMax      = lvl >= mastery.maxLevel;
    final upgradeCost = unlocked && !atMax ? ClassMastery.upgradeCostAt(lvl) : 0;
    final canAfford  = game.gold >= upgradeCost;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked ? color.withValues(alpha: 0.06) : const Color(0xFF0d1020),
        border: Border.all(
          color: unlocked ? color.withValues(alpha: 0.6)
              : canUnlock ? color.withValues(alpha: 0.3)
              : const Color(0xFF2a2e3f),
          width: unlocked ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left stripe
          Container(
            width: 3,
            height: 56,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: unlocked ? color : color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(mastery.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: unlocked ? color : levelMet ? Colors.white60 : Colors.white30,
                          )),
                    ),
                    if (!levelMet)
                      _LockBadge(level: mastery.levelRequired),
                    if (unlocked && !atMax)
                      _LevelDots(current: lvl, max: mastery.maxLevel, color: color),
                    if (unlocked && atMax)
                      _MaxBadge(color: color),
                  ],
                ),
                const SizedBox(height: 3),
                Text(mastery.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: unlocked ? Colors.white60 : Colors.white30,
                    )),
                const SizedBox(height: 5),
                if (unlocked)
                  Text(mastery.effectLabel(lvl),
                      style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600))
                else if (levelMet)
                  Text('${mastery.effectLabel(1)} at rank 1',
                      style: const TextStyle(fontSize: 11, color: Colors.white38)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Action button
          if (canUnlock)
            _ActionButton(
              label: 'UNLOCK',
              sublabel: 'FREE',
              color: color,
              enabled: true,
              onTap: () => game.unlockMastery(mastery),
            )
          else if (unlocked && !atMax)
            _ActionButton(
              label: 'UPGRADE',
              sublabel: '💰 $upgradeCost',
              color: color,
              enabled: canAfford,
              onTap: canAfford ? () => game.upgradeMastery(mastery) : null,
            ),
        ],
      ),
    );
  }
}

class _LockBadge extends StatelessWidget {
  const _LockBadge({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.lock_outline, size: 9, color: Colors.white38),
        const SizedBox(width: 3),
        Text('Lv $level', style: const TextStyle(fontSize: 9, color: Colors.white38)),
      ]),
    );
  }
}

class _MaxBadge extends StatelessWidget {
  const _MaxBadge({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text('MAX', style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold)),
    );
  }
}

class _LevelDots extends StatelessWidget {
  const _LevelDots({required this.current, required this.max, required this.color});
  final int current;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) => Container(
        width: 7,
        height: 7,
        margin: const EdgeInsets.only(left: 3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: i < current ? color : Colors.transparent,
          border: Border.all(color: i < current ? color : color.withValues(alpha: 0.3), width: 1),
        ),
      )),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.enabled,
    this.onTap,
  });
  final String label;
  final String sublabel;
  final Color color;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = enabled ? color : Colors.white24;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? color.withValues(alpha: 0.08) : Colors.transparent,
          border: Border.all(color: c),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTheme.pixelHeading(fontSize: 9, color: c)),
            const SizedBox(height: 2),
            Text(sublabel, style: TextStyle(fontSize: 9, color: c)),
          ],
        ),
      ),
    );
  }
}

class _UpgradeCostTable extends StatelessWidget {
  const _UpgradeCostTable();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0e1225),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('UPGRADE COSTS', style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final entry in [('Rank 2', 300), ('Rank 3', 800), ('Rank 4', 2000), ('Rank 5', 5000)])
                Column(children: [
                  Text(entry.$1, style: const TextStyle(fontSize: 10, color: Colors.white54)),
                  const SizedBox(height: 3),
                  Text('💰 ${entry.$2}', style: const TextStyle(fontSize: 11, color: AppTheme.accentGold)),
                ]),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoldBadge extends StatelessWidget {
  const _GoldBadge({required this.gold});
  final int gold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withValues(alpha: 0.08),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('💰', style: TextStyle(fontSize: 13)),
        const SizedBox(width: 5),
        Text(_fmt(gold),
            style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 0, color: AppTheme.accentGold)),
      ]),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

import 'package:flutter/material.dart';
import '../models/npc_ally.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class NpcAllyScreen extends StatelessWidget {
  const NpcAllyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final allies = NpcAllyDef.all;
    final unlockedCount = allies.where((a) => game.allyUnlocked(a.id)).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0e27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1f3a),
        title: Text('MERCENARIES',
            style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              '$unlockedCount / ${allies.length}  recruited',
              style: AppTheme.pixelHeading(
                  fontSize: 11, color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ActiveBonusBar(game: game),
          const SizedBox(height: 16),
          Text('ROSTER',
              style: AppTheme.pixelHeading(
                  fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
          const SizedBox(height: 10),
          ...allies.map((a) => _AllyCard(def: a, game: game)),
          const SizedBox(height: 8),
          Text('SYNERGIES',
              style: AppTheme.pixelHeading(
                  fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
          const SizedBox(height: 10),
          ...SynergyDef.all.map((s) => _SynergyCard(syn: s, game: game)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Active Bonus Summary ──────────────────────────────────────────────────────

class _ActiveBonusBar extends StatelessWidget {
  const _ActiveBonusBar({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final chips = <_Chip>[];

    if (game.allyAtkBonus > 0)
      chips.add(_Chip('+${game.allyAtkBonus} ATK', const Color(0xFFff9944)));
    if (game.allyDmgBonus > 0)
      chips.add(_Chip('+${game.allyDmgBonus} DMG', const Color(0xFFff5555)));
    if (game.allyAcBonus > 0)
      chips.add(_Chip('+${game.allyAcBonus} AC', const Color(0xFF66aaff)));
    if (game.allyGoldMult > 1.0)
      chips.add(_Chip('+${((game.allyGoldMult - 1) * 100).round()}% Gold',
          const Color(0xFFffdd44)));
    if (game.allyXpMult > 1.0)
      chips.add(_Chip('+${((game.allyXpMult - 1) * 100).round()}% XP',
          const Color(0xFF44ccaa)));
    if (game.allyShardMult > 1.0)
      chips.add(_Chip('+${((game.allyShardMult - 1) * 100).round()}% Shards',
          const Color(0xFF88aaff)));
    if (game.allyIdleMult > 1.0)
      chips.add(_Chip('+${((game.allyIdleMult - 1) * 100).round()}% Idle',
          const Color(0xFF88cc44)));
    if (game.allyHpPct > 0)
      chips.add(_Chip('+${game.allyHpPct}% HP', const Color(0xFF44ee88)));

    if (chips.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0e1225),
          border: Border.all(color: AppTheme.cardBorder),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'No mercenaries recruited yet. Fulfill milestones to unlock them.',
          style: TextStyle(fontSize: 10, color: AppTheme.textMuted, height: 1.4),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0e1225),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('TOTAL ACTIVE BONUSES',
            style: AppTheme.pixelHeading(
                fontSize: 9, letterSpacing: 1, color: AppTheme.textMuted)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: chips.map((c) => _chipWidget(c)).toList(),
        ),
      ]),
    );
  }

  Widget _chipWidget(_Chip c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: c.color.withValues(alpha: 0.10),
          border: Border.all(color: c.color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(c.label,
            style: TextStyle(
                fontSize: 10, color: c.color, fontWeight: FontWeight.bold)),
      );
}

class _Chip {
  const _Chip(this.label, this.color);
  final String label;
  final Color color;
}

// ── Ally Card ─────────────────────────────────────────────────────────────────

class _AllyCard extends StatelessWidget {
  const _AllyCard({required this.def, required this.game});
  final NpcAllyDef def;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final level    = game.allyLevel(def.id);
    final unlocked = level >= 1;
    final maxed    = level >= NpcAllyDef.maxLevel;
    final progress = game.allyMilestoneProgress(def);
    final lockPct  = (progress / def.milestoneTarget).clamp(0.0, 1.0);

    final (costS, costC) = unlocked && !maxed
        ? NpcAllyDef.levelUpCost(level + 1)
        : (0, 0);
    final canAfford = costS <= game.shards && costC <= game.crystals;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unlocked
              ? const Color(0xFF0d1e14)
              : const Color(0xFF0e1225),
          border: Border.all(
            color: unlocked
                ? const Color(0xFF3a7a50).withValues(alpha: 0.7)
                : AppTheme.cardBorder,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Header row ─────────────────────────────────────────────────────
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(def.icon,
                style: TextStyle(
                    fontSize: 26,
                    color: unlocked ? null : Colors.white24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(def.name,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: unlocked
                                ? const Color(0xFF77dd99)
                                : Colors.white38)),
                    const SizedBox(width: 8),
                    if (unlocked) _LevelBadge(level: level),
                  ]),
                  Text(def.title,
                      style: TextStyle(
                          fontSize: 10,
                          color: unlocked
                              ? AppTheme.textMuted
                              : AppTheme.textMuted.withValues(alpha: 0.4),
                          fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            // Bonus at current level
            if (unlocked)
              _BonusTag(def: def, level: level),
          ]),

          const SizedBox(height: 10),

          // ── Lore ───────────────────────────────────────────────────────────
          Text(def.lore,
              style: TextStyle(
                  fontSize: 10,
                  color: unlocked ? Colors.white54 : Colors.white24,
                  height: 1.4)),

          const SizedBox(height: 10),

          // ── Locked: milestone progress ────────────────────────────────────
          if (!unlocked) ...[
            Row(children: [
              Expanded(
                child: Text('Unlock: ${def.milestoneLabel}',
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textMuted)),
              ),
              Text('$progress / ${def.milestoneTarget}',
                  style: const TextStyle(
                      fontSize: 10, color: Colors.white38)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: lockPct,
                minHeight: 5,
                backgroundColor:
                    const Color(0xFF44aa66).withValues(alpha: 0.12),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF44aa66)),
              ),
            ),
          ]

          // ── Unlocked: level pips + upgrade button ─────────────────────────
          else ...[
            Row(children: [
              _LevelPips(current: level, max: NpcAllyDef.maxLevel),
              const Spacer(),
              if (maxed)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.10),
                    border: Border.all(
                        color: AppTheme.accentGold.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text('MAX',
                      style: AppTheme.pixelHeading(
                          fontSize: 9, color: AppTheme.accentGold)),
                )
              else
                _UpgradeButton(
                  costShards:   costS,
                  costCrystals: costC,
                  canAfford:    canAfford,
                  onTap:        () => game.upgradeAlly(def.id),
                ),
            ]),
          ],
        ]),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.accentGold.withValues(alpha: 0.12),
          border:
              Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text('LV $level',
            style: AppTheme.pixelHeading(
                fontSize: 9, color: AppTheme.accentGold)),
      );
}

class _LevelPips extends StatelessWidget {
  const _LevelPips({required this.current, required this.max});
  final int current;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) {
        final filled = i < current;
        return Container(
          margin: const EdgeInsets.only(right: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: filled
                ? AppTheme.accentGold
                : AppTheme.accentGold.withValues(alpha: 0.12),
            border: Border.all(
                color: AppTheme.accentGold.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

class _BonusTag extends StatelessWidget {
  const _BonusTag({required this.def, required this.level});
  final NpcAllyDef def;
  final int level;

  String get _label {
    if (def.atkBonus > 0)      return '+${def.atkBonus * level} ATK';
    if (def.dmgBonus > 0)      return '+${def.dmgBonus * level} DMG';
    if (def.acBonus > 0)       return '+${def.acBonus * level} AC';
    if (def.goldPctBonus > 0)  return '+${(def.goldPctBonus * level * 100).round()}% Gold';
    if (def.xpPctBonus > 0)    return '+${(def.xpPctBonus * level * 100).round()}% XP';
    if (def.shardPctBonus > 0) return '+${(def.shardPctBonus * level * 100).round()}% Shards';
    if (def.idlePctBonus > 0)  return '+${(def.idlePctBonus * level * 100).round()}% Idle';
    if (def.hpPctBonus > 0)    return '+${(def.hpPctBonus * level * 100).round()}% HP';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    const c = Color(0xFF66aaff);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.10),
        border: Border.all(color: c.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(_label,
          style: const TextStyle(
              fontSize: 9, color: c, fontWeight: FontWeight.bold)),
    );
  }
}

class _UpgradeButton extends StatelessWidget {
  const _UpgradeButton({
    required this.costShards,
    required this.costCrystals,
    required this.canAfford,
    required this.onTap,
  });
  final int costShards;
  final int costCrystals;
  final bool canAfford;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        canAfford ? AppTheme.accentGold : AppTheme.cardBorder;
    return GestureDetector(
      onTap: canAfford ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: canAfford
              ? AppTheme.accentGold.withValues(alpha: 0.10)
              : Colors.transparent,
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('UPGRADE  ',
              style: AppTheme.pixelHeading(fontSize: 9, color: color)),
          Text('🔷$costShards',
              style: TextStyle(
                  fontSize: 9,
                  color: color,
                  fontWeight: FontWeight.bold)),
          if (costCrystals > 0) ...[
            const SizedBox(width: 4),
            Text('💎$costCrystals',
                style: TextStyle(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.bold)),
          ],
        ]),
      ),
    );
  }
}

// ── Synergy Card ──────────────────────────────────────────────────────────────

class _SynergyCard extends StatelessWidget {
  const _SynergyCard({required this.syn, required this.game});
  final SynergyDef syn;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final active = game.activeSynergies.any((s) => s.id == syn.id);
    final ally1  = NpcAllyDef.all.firstWhere((a) => a.id == syn.ally1Id);
    final ally2  = NpcAllyDef.all.firstWhere((a) => a.id == syn.ally2Id);
    final lv1    = game.allyLevel(syn.ally1Id);
    final lv2    = game.allyLevel(syn.ally2Id);

    final borderColor = active
        ? const Color(0xFFcc99ff).withValues(alpha: 0.7)
        : AppTheme.cardBorder;
    final bgColor = active
        ? const Color(0xFF150e25)
        : const Color(0xFF0a0d1a);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(syn.name,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: active
                        ? const Color(0xFFcc99ff)
                        : Colors.white38)),
            const Spacer(),
            if (active)
              const Icon(Icons.auto_awesome,
                  color: Color(0xFFcc99ff), size: 14),
          ]),
          const SizedBox(height: 4),
          Text(syn.description,
              style: TextStyle(
                  fontSize: 10,
                  color: active ? Colors.white54 : Colors.white24,
                  height: 1.4)),
          const SizedBox(height: 8),
          // Partner display
          Row(children: [
            _PartnerChip(
              icon: ally1.icon,
              name: ally1.name,
              level: lv1,
              needed: syn.minLevel,
            ),
            const SizedBox(width: 4),
            Text('+',
                style: TextStyle(
                    fontSize: 12,
                    color: active
                        ? const Color(0xFFcc99ff)
                        : Colors.white24)),
            const SizedBox(width: 4),
            _PartnerChip(
              icon: ally2.icon,
              name: ally2.name,
              level: lv2,
              needed: syn.minLevel,
            ),
            const Spacer(),
            // Bonus label
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFFcc99ff).withValues(alpha: 0.10)
                    : Colors.transparent,
                border: Border.all(
                    color: active
                        ? const Color(0xFFcc99ff).withValues(alpha: 0.5)
                        : AppTheme.cardBorder),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(syn.bonusSummary,
                  style: TextStyle(
                      fontSize: 9,
                      color: active
                          ? const Color(0xFFcc99ff)
                          : AppTheme.textMuted,
                      fontWeight: FontWeight.bold)),
            ),
          ]),
          if (!active) ...[
            const SizedBox(height: 6),
            Text(
              'Requires both at LV ${syn.minLevel}+  '
              '(${ally1.name} LV$lv1, ${ally2.name} LV$lv2)',
              style: const TextStyle(
                  fontSize: 9,
                  color: AppTheme.textMuted,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ]),
      ),
    );
  }
}

class _PartnerChip extends StatelessWidget {
  const _PartnerChip({
    required this.icon,
    required this.name,
    required this.level,
    required this.needed,
  });
  final String icon;
  final String name;
  final int level;
  final int needed;

  @override
  Widget build(BuildContext context) {
    final met = level >= needed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: met
            ? const Color(0xFF3a2060).withValues(alpha: 0.6)
            : const Color(0xFF151520),
        border: Border.all(
            color: met
                ? const Color(0xFFcc99ff).withValues(alpha: 0.5)
                : AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(name,
            style: TextStyle(
                fontSize: 9,
                color: met ? const Color(0xFFcc99ff) : Colors.white38)),
        const SizedBox(width: 4),
        Text('LV$level',
            style: TextStyle(
                fontSize: 9,
                color: met ? AppTheme.accentGold : AppTheme.textMuted,
                fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

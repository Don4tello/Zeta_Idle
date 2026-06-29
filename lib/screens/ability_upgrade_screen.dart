import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/ability_data.dart';
import '../models/equipment.dart';
import '../models/hero_ability.dart';
import '../models/passive_tree.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart' show TutorialTip;

class AbilityUpgradeScreen extends StatelessWidget {
  const AbilityUpgradeScreen({super.key, this.embedded = false});

  final bool embedded;

  static const _effectColors = <AbilityEffect, Color>{
    AbilityEffect.bonusDamage:      Color(0xFFff6633),
    AbilityEffect.heal:             Color(0xFF44cc66),
    AbilityEffect.attackBonus:      Color(0xFFffcc00),
    AbilityEffect.acBonus:          Color(0xFF66aaff),
    AbilityEffect.stun:             Color(0xFFcc44ff),
    AbilityEffect.dot:              Color(0xFF88dd00),
    AbilityEffect.dodge:            Color(0xFF44ddcc),
    AbilityEffect.aura:             Color(0xFF55eebb),
    AbilityEffect.debuffWeaken:     Color(0xFFff8844),
    AbilityEffect.debuffVulnerable: Color(0xFFdd44aa),
  };

  static const _effectLabel = <AbilityEffect, String>{
    AbilityEffect.bonusDamage:      'Bonus Damage',
    AbilityEffect.heal:             'Heal',
    AbilityEffect.attackBonus:      'Attack Bonus',
    AbilityEffect.acBonus:          'AC Bonus',
    AbilityEffect.stun:             'Stun',
    AbilityEffect.dot:              'Damage Over Time',
    AbilityEffect.dodge:            'Dodge',
    AbilityEffect.aura:             'Aura',
    AbilityEffect.debuffWeaken:     'Weaken',
    AbilityEffect.debuffVulnerable: 'Vulnerable',
  };

  static const _categoryColors = <AbilityCategory, Color>{
    AbilityCategory.damage: Color(0xFFff6633),
    AbilityCategory.buff:   Color(0xFF44cc88),
    AbilityCategory.debuff: Color(0xFFdd44aa),
  };

  static const _categoryLabel = <AbilityCategory, String>{
    AbilityCategory.damage: 'DMG',
    AbilityCategory.buff:   'BUFF',
    AbilityCategory.debuff: 'DEBUFF',
  };

  String _effectSummary(HeroAbility a, GameState game) {
    final sv = game.scaledAbilityValue(a);
    final cd = game.scaledAbilityCooldown(a);
    switch (a.effect) {
      case AbilityEffect.bonusDamage:      return '~$sv dmg  •  ${cd}r cd';
      case AbilityEffect.heal:             return '+${sv}% HP  •  ${cd}r cd';
      case AbilityEffect.attackBonus:      return '+$sv ATK for ${a.duration}r  •  ${cd}r cd';
      case AbilityEffect.acBonus:          return '+$sv AC for ${a.duration}r  •  ${cd}r cd';
      case AbilityEffect.stun:             return 'Stun ${a.duration}r  •  ${cd}r cd';
      case AbilityEffect.dot:              return '$sv dmg/r for ${a.duration}r  •  ${cd}r cd';
      case AbilityEffect.dodge:            return 'Dodge 1 hit  •  ${cd}r cd';
      case AbilityEffect.aura:             return '$sv% max HP/r for ${a.duration}r  •  ${cd}r cd';
      case AbilityEffect.debuffWeaken:     return '−$sv% ATK for ${a.duration}r  •  ${cd}r cd';
      case AbilityEffect.debuffVulnerable: return '+$sv% dmg taken for ${a.duration}r  •  ${cd}r cd';
    }
  }

  String _nextEffectSummary(HeroAbility a, GameState game) {
    final rank = game.abilityRank(a.id);
    if (rank >= 100) return 'MAX RANK';
    final nextRank = rank + 1;
    final nv = a.value == 0 ? 0 : a.value + nextRank * (a.value ~/ 8).clamp(1, 9999);
    final ncd = (a.cooldownRounds - nextRank ~/ 3).clamp(2, 99);
    switch (a.effect) {
      case AbilityEffect.bonusDamage:      return '~$nv dmg  •  ${ncd}r cd';
      case AbilityEffect.heal:             return '+${nv}% HP  •  ${ncd}r cd';
      case AbilityEffect.attackBonus:      return '+${a.value + nextRank} ATK for ${a.duration}r  •  ${ncd}r cd';
      case AbilityEffect.acBonus:          return '+${a.value + nextRank} AC for ${a.duration}r  •  ${ncd}r cd';
      case AbilityEffect.stun:             return 'Stun ${a.duration}r  •  ${ncd}r cd';
      case AbilityEffect.dot:              return '$nv dmg/r for ${a.duration}r  •  ${ncd}r cd';
      case AbilityEffect.dodge:            return 'Dodge 1 hit  •  ${ncd}r cd';
      case AbilityEffect.aura:             return '$nv% max HP/r for ${a.duration}r  •  ${ncd}r cd';
      case AbilityEffect.debuffWeaken:     return '−$nv% ATK for ${a.duration}r  •  ${ncd}r cd';
      case AbilityEffect.debuffVulnerable: return '+$nv% dmg taken for ${a.duration}r  •  ${ncd}r cd';
    }
  }

  // Returns the total Increased % that scales ability damage (allDmg + abilityDmg).
  int _totalAbilityDmgPct(GameState game) =>
      game.passiveTree.totalOf(PassiveEffect.allDamage)
      + game.inventory.totalOf(ItemStat.damagePercent)
      + game.hero.levelBonusDamagePct
      + game.passiveTree.totalOf(PassiveEffect.abilityDamage);

  // "~X–Y dmg" for bonusDamage or "~X dmg/r" for dot, null for non-damage effects.
  String? _scaledDamageSummary(HeroAbility a, GameState game) {
    final pct  = _totalAbilityDmgPct(game);
    if (pct == 0) return null;
    final mult = 1.0 + pct / 100.0;
    final sv   = game.scaledAbilityValue(a);
    final mod  = game.hero.damageMod;
    switch (a.effect) {
      case AbilityEffect.bonusDamage:
        final lo = ((1 + mod) * mult).round().clamp(1, 9999);
        final hi = ((sv + mod) * mult).round().clamp(1, 9999);
        return '~$lo–$hi dmg  (+$pct% bonuses)';
      case AbilityEffect.dot:
        final scaled = (sv * mult).round().clamp(1, 9999);
        return '~$scaled dmg/r  (+$pct% bonuses)';
      default:
        return null;
    }
  }

  String? _scaledNextDamageSummary(HeroAbility a, GameState game) {
    final rank = game.abilityRank(a.id);
    if (rank >= 100) return null;
    final pct  = _totalAbilityDmgPct(game);
    if (pct == 0) return null;
    final mult    = 1.0 + pct / 100.0;
    final nextRank = rank + 1;
    final nv = a.value == 0 ? 0 : a.value + nextRank * (a.value ~/ 8).clamp(1, 9999);
    final mod = game.hero.damageMod;
    switch (a.effect) {
      case AbilityEffect.bonusDamage:
        final lo = ((1 + mod) * mult).round().clamp(1, 9999);
        final hi = ((nv + mod) * mult).round().clamp(1, 9999);
        return '~$lo–$hi dmg';
      case AbilityEffect.dot:
        final scaled = (nv * mult).round().clamp(1, 9999);
        return '~$scaled dmg/r';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final allAbilities = [
      ...AbilityData.forClass(game.hero.heroClass),
      if (AbilityData.ultimateFor(game.hero.heroClass) != null)
        AbilityData.ultimateFor(game.hero.heroClass)!,
    ];

    final shardsRow = Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          const Icon(Icons.diamond_outlined, color: Color(0xFF80d0ff), size: 13),
          const SizedBox(width: 5),
          Text(
            '${game.shards}',
            style: GoogleFonts.pixelifySans(
              color: const Color(0xFF80d0ff),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          const Text('shards', style: TextStyle(color: Colors.white38, fontSize: 12)),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1a1a2e),
                  title: Text('Respec Abilities?', style: AppTheme.pixelHeading(fontSize: 14, color: AppTheme.accentGold)),
                  content: Text(
                    'Reset all ability ranks and milestone choices.\n'
                    'All shards spent will be refunded.\n\n'
                    'Cost: 💎 ${GameState.abilityRespecCost} Crystals',
                    style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.5),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('CANCEL', style: TextStyle(color: AppTheme.textMuted))),
                    TextButton(
                      onPressed: game.crystals >= GameState.abilityRespecCost
                          ? () => Navigator.pop(ctx, true) : null,
                      child: Text('RESPEC (💎 ${GameState.abilityRespecCost})',
                          style: TextStyle(color: game.crystals >= GameState.abilityRespecCost
                              ? AppTheme.accentGold : AppTheme.cardBorder)),
                    ),
                  ],
                ),
              );
              if (ok == true) game.respecAbilities();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('RESPEC', style: AppTheme.pixelHeading(
                  fontSize: 8, color: AppTheme.accentGold.withValues(alpha: 0.7), letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );

    final listBody = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!embedded)
          TutorialTip(
            tutorialKey: 'abilities',
            game: game,
            text: 'Abilities fire automatically during combat. Upgrade them with Shards to increase their power and reduce cooldowns.',
          ),
        Text(
          game.hero.heroClass.displayName.toUpperCase(),
          style: GoogleFonts.cinzel(
            color: AppTheme.accentGold,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Spend shards to empower your abilities. Milestones unlock at ranks 5, 10 and 15.',
          style: TextStyle(color: Colors.white38, fontSize: 14),
        ),
        const SizedBox(height: 16),
        ...allAbilities.map((a) => _AbilityCard(
              ability: a,
              game: game,
              effectSummary: _effectSummary(a, game),
              nextEffectSummary: _nextEffectSummary(a, game),
              scaledDmgSummary: _scaledDamageSummary(a, game),
              scaledNextDmgSummary: _scaledNextDamageSummary(a, game),
              effectColor: _effectColors[a.effect] ?? Colors.grey,
              effectLabel: _effectLabel[a.effect] ?? '',
              categoryColor: _categoryColors[a.category] ?? Colors.grey,
              categoryLabel: _categoryLabel[a.category] ?? '',
            )),
      ],
    );

    if (embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          shardsRow,
          const SizedBox(height: 4),
          Expanded(child: listBody),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('ABILITY UPGRADES'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.diamond_outlined,
                    color: Color(0xFF80d0ff), size: 14),
                const SizedBox(width: 5),
                Text(
                  '${game.shards}',
                  style: GoogleFonts.pixelifySans(
                    color: const Color(0xFF80d0ff),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('shards',
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      body: listBody,
    );
  }
}

// ── Ability card ──────────────────────────────────────────────────────────────

class _AbilityCard extends StatelessWidget {
  const _AbilityCard({
    required this.ability,
    required this.game,
    required this.effectSummary,
    required this.nextEffectSummary,
    required this.scaledDmgSummary,
    required this.scaledNextDmgSummary,
    required this.effectColor,
    required this.effectLabel,
    required this.categoryColor,
    required this.categoryLabel,
  });

  final HeroAbility ability;
  final GameState game;
  final String effectSummary;
  final String nextEffectSummary;
  final String? scaledDmgSummary;
  final String? scaledNextDmgSummary;
  final Color effectColor;
  final String effectLabel;
  final Color categoryColor;
  final String categoryLabel;

  @override
  Widget build(BuildContext context) {
    final rank    = game.abilityRank(ability.id);
    final cost    = game.abilityUpgradeCost(ability.id);
    final locked  = game.hero.level < ability.levelRequired;
    final maxed   = rank >= 100;
    final canAfford = !locked && !maxed && game.shards >= cost;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B1814),
          border: Border.all(
            color: locked
                ? const Color(0xFF2E2A26)
                : effectColor.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  color: categoryColor.withOpacity(0.15),
                  child: Text(categoryLabel,
                    style: TextStyle(color: categoryColor, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
                const SizedBox(width: 4),
                Builder(builder: (_) {
                  final dt = game.abilityEffectiveDamageType(ability);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    color: dt.color.withValues(alpha: 0.15),
                    child: Text('${dt.emoji} ${dt.label.toUpperCase()}',
                        style: TextStyle(color: dt.color, fontSize: 8, fontWeight: FontWeight.bold)),
                  );
                }),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  color: effectColor.withOpacity(0.12),
                  child: Text(
                    effectLabel.toUpperCase(),
                    style: TextStyle(
                      color: effectColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (locked)
                  Text(
                    'UNLOCKS LV ${ability.levelRequired}',
                    style: const TextStyle(color: Colors.white30, fontSize: 10),
                  ),
                const Spacer(),
                Text(
                  '$rank / 15',
                  style: TextStyle(
                    color: maxed ? AppTheme.accentGold : Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Rank pip bar (15 pips, milestone markers at 5/10/15)
            _RankPips(rank: rank, locked: locked, effectColor: effectColor),
            const SizedBox(height: 8),
            Text(
              ability.name,
              style: TextStyle(
                color: locked ? Colors.white30 : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ability.description,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 8),
            _statRow('Current', effectSummary,
                locked ? Colors.white24 : effectColor),
            if (scaledDmgSummary != null && !locked) ...[
              const SizedBox(height: 2),
              _statRow('Scaled', scaledDmgSummary!, const Color(0xFFffaa44)),
            ],
            if (!maxed && !locked) ...[
              const SizedBox(height: 4),
              _statRow('At rank ${rank + 1}', nextEffectSummary, Colors.white54),
              if (scaledNextDmgSummary != null) ...[
                const SizedBox(height: 2),
                _statRow('Scaled', scaledNextDmgSummary!, const Color(0xFFffaa44)),
              ],
            ],
            // Milestone choosers
            for (final ms in ability.milestones)
              if (rank >= ms.rank)
                _MilestoneRow(
                  milestone: ms,
                  abilityId: ability.id,
                  game: game,
                  effectColor: effectColor,
                ),
            if (maxed)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('MAX RANK', style: TextStyle(
                  color: AppTheme.accentGold, fontSize: 11,
                  fontWeight: FontWeight.bold, letterSpacing: 1,
                )),
              ),
            if (!locked && !maxed) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: canAfford
                      ? () => game.upgradeAbility(ability.id)
                      : null,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: canAfford ? effectColor : Colors.white24,
                    ),
                    foregroundColor: canAfford ? effectColor : Colors.white30,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.diamond_outlined, size: 13),
                      const SizedBox(width: 6),
                      Text(
                        'UPGRADE  ($cost shards)',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) => Row(
    children: [
      SizedBox(
        width: 80,
        child: Text(label,
            style: const TextStyle(color: Colors.white30, fontSize: 13)),
      ),
      Expanded(
        child: Text(value,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    ],
  );
}

// ── 15-pip rank bar with milestone markers ────────────────────────────────────

class _RankPips extends StatelessWidget {
  const _RankPips({
    required this.rank,
    required this.locked,
    required this.effectColor,
  });

  final int   rank;
  final bool  locked;
  final Color effectColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(15, (i) {
        final filled    = i < rank;
        final isMilestone = (i == 4) || (i == 9) || (i == 14); // pips 5,10,15
        final pipColor  = locked
            ? Colors.white12
            : filled
                ? (isMilestone ? AppTheme.accentGold : effectColor)
                : Colors.white12;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Container(
              height: isMilestone ? 7 : 5,
              decoration: BoxDecoration(
                color: pipColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Milestone row (shown once rank >= milestone.rank) ─────────────────────────

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({
    required this.milestone,
    required this.abilityId,
    required this.game,
    required this.effectColor,
  });

  final AbilityMilestone milestone;
  final String           abilityId;
  final GameState        game;
  final Color            effectColor;

  @override
  Widget build(BuildContext context) {
    final chosen = game.milestoneChoice(abilityId, milestone.rank);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.call_split, color: effectColor, size: 12),
            const SizedBox(width: 5),
            Text(
              'MILESTONE ${milestone.rank}',
              style: TextStyle(
                  color: effectColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1),
            ),
          ]),
          const SizedBox(height: 6),
          if (chosen == null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _ChoiceOption(
                  choice: milestone.a,
                  effectColor: effectColor,
                  onChoose: () => game.setMilestoneChoice(abilityId, milestone.rank, 'a'),
                )),
                const SizedBox(width: 8),
                Expanded(child: _ChoiceOption(
                  choice: milestone.b,
                  effectColor: effectColor,
                  onChoose: () => game.setMilestoneChoice(abilityId, milestone.rank, 'b'),
                )),
              ],
            )
          else
            _ChosenBadge(
              choice: chosen == 'a' ? milestone.a : milestone.b,
              effectColor: effectColor,
            ),
        ],
      ),
    );
  }
}

class _ChoiceOption extends StatelessWidget {
  const _ChoiceOption({
    required this.choice,
    required this.effectColor,
    required this.onChoose,
  });

  final AbilityChoice  choice;
  final Color          effectColor;
  final VoidCallback   onChoose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(color: effectColor.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(choice.name,
              style: TextStyle(
                  color: effectColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(choice.description,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 12, height: 1.3)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onChoose,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                side: BorderSide(color: effectColor.withOpacity(0.7)),
                foregroundColor: effectColor,
              ),
              child: Text('CHOOSE',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: effectColor,
                      letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChosenBadge extends StatelessWidget {
  const _ChosenBadge({required this.choice, required this.effectColor});

  final AbilityChoice choice;
  final Color         effectColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: effectColor.withOpacity(0.08),
        border: Border.all(color: effectColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(children: [
        Icon(Icons.check_circle_outline, color: effectColor, size: 14),
        const SizedBox(width: 8),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(choice.name,
                style: TextStyle(
                    color: effectColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(choice.description,
                style:
                    const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        )),
      ]),
    );
  }
}

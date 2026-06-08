import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/ability_data.dart';
import '../models/hero_ability.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class AbilityUpgradeScreen extends StatelessWidget {
  const AbilityUpgradeScreen({super.key, this.embedded = false});

  final bool embedded;

  static const _effectColors = <AbilityEffect, Color>{
    AbilityEffect.bonusDamage: Color(0xFFff6633),
    AbilityEffect.heal:        Color(0xFF44cc66),
    AbilityEffect.attackBonus: Color(0xFFffcc00),
    AbilityEffect.acBonus:     Color(0xFF66aaff),
    AbilityEffect.stun:        Color(0xFFcc44ff),
    AbilityEffect.dot:         Color(0xFF88dd00),
    AbilityEffect.dodge:       Color(0xFF44ddcc),
  };

  static const _effectLabel = <AbilityEffect, String>{
    AbilityEffect.bonusDamage: 'Bonus Damage',
    AbilityEffect.heal:        'Heal',
    AbilityEffect.attackBonus: 'Attack Bonus',
    AbilityEffect.acBonus:     'AC Bonus',
    AbilityEffect.stun:        'Stun',
    AbilityEffect.dot:         'Damage Over Time',
    AbilityEffect.dodge:       'Dodge',
  };

  String _effectSummary(HeroAbility a, int rank, GameState game) {
    final sv = game.scaledAbilityValue(a);
    final cd = game.scaledAbilityCooldown(a);
    switch (a.effect) {
      case AbilityEffect.bonusDamage: return '+d$sv dmg  •  ${cd}r cd';
      case AbilityEffect.heal:        return '+${sv}% HP  •  ${cd}r cd';
      case AbilityEffect.attackBonus: return '+$sv ATK for ${a.duration}r  •  ${cd}r cd';
      case AbilityEffect.acBonus:     return '+$sv AC for ${a.duration}r  •  ${cd}r cd';
      case AbilityEffect.stun:        return 'Stun ${a.duration}r  •  ${cd}r cd';
      case AbilityEffect.dot:         return '$sv dmg/r for ${a.duration}r  •  ${cd}r cd';
      case AbilityEffect.dodge:       return 'Dodge 1 hit  •  ${cd}r cd';
    }
  }

  String _nextEffectSummary(HeroAbility a, GameState game) {
    final rank = game.abilityRank(a.id);
    if (rank >= 3) return 'MAX RANK';
    // Temporarily preview at rank+1
    final previewValue = a.value == 0 ? 0 : a.value + (rank + 1) * (a.value ~/ 4).clamp(1, 9999);
    final previewCd = (a.cooldownRounds - (rank + 1)).clamp(2, 99);
    switch (a.effect) {
      case AbilityEffect.bonusDamage: return '+d$previewValue dmg  •  ${previewCd}r cd';
      case AbilityEffect.heal:        return '+${previewValue}% HP  •  ${previewCd}r cd';
      case AbilityEffect.attackBonus: return '+${a.value + rank + 1} ATK for ${a.duration}r  •  ${previewCd}r cd';
      case AbilityEffect.acBonus:     return '+${a.value + rank + 1} AC for ${a.duration}r  •  ${previewCd}r cd';
      case AbilityEffect.stun:        return 'Stun ${a.duration}r  •  ${previewCd}r cd';
      case AbilityEffect.dot:         return '$previewValue dmg/r for ${a.duration}r  •  ${previewCd}r cd';
      case AbilityEffect.dodge:       return 'Dodge 1 hit  •  ${previewCd}r cd';
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final allAbilities = AbilityData.forClass(game.hero.heroClass);

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
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          const Text('shards', style: TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );

    final listBody = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          game.hero.heroClass.displayName.toUpperCase(),
          style: GoogleFonts.cinzel(
            color: AppTheme.accentGold,
            fontSize: 13,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Spend shards to empower your abilities. Upgrades increase effect magnitude and reduce cooldowns.',
          style: TextStyle(color: Colors.white38, fontSize: 11),
        ),
        const SizedBox(height: 16),
        ...allAbilities.map((a) => _AbilityCard(
              ability: a,
              game: game,
              effectSummary: _effectSummary(a, game.abilityRank(a.id), game),
              nextEffectSummary: _nextEffectSummary(a, game),
              effectColor: _effectColors[a.effect] ?? Colors.grey,
              effectLabel: _effectLabel[a.effect] ?? '',
              chosenBranchId: game.abilityBranchChoice(a.id),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('shards',
                    style: TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
      body: listBody,
    );
  }
}

class _AbilityCard extends StatelessWidget {
  const _AbilityCard({
    required this.ability,
    required this.game,
    required this.effectSummary,
    required this.nextEffectSummary,
    required this.effectColor,
    required this.effectLabel,
    this.chosenBranchId,
  });

  final HeroAbility ability;
  final GameState game;
  final String effectSummary;
  final String nextEffectSummary;
  final Color effectColor;
  final String effectLabel;
  final String? chosenBranchId;

  @override
  Widget build(BuildContext context) {
    final rank = game.abilityRank(ability.id);
    final cost = game.abilityUpgradeCost(ability.id);
    final locked = game.hero.level < ability.levelRequired;
    final maxed = rank >= 3;
    final canAfford = !locked && !maxed && game.shards >= cost;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111525),
          border: Border.all(
            color: locked
                ? const Color(0xFF2a2e3f)
                : effectColor.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: effectColor.withOpacity(0.15),
                  child: Text(
                    effectLabel.toUpperCase(),
                    style: TextStyle(
                      color: effectColor,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (locked)
                  Text(
                    'UNLOCKS LV ${ability.levelRequired}',
                    style: const TextStyle(color: Colors.white30, fontSize: 9),
                  ),
                const Spacer(),
                // Rank stars
                Row(
                  children: List.generate(3, (i) => Padding(
                    padding: const EdgeInsets.only(left: 3),
                    child: Icon(
                      i < rank ? Icons.star : Icons.star_border,
                      color: i < rank ? AppTheme.accentGold : Colors.white24,
                      size: 14,
                    ),
                  )),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ability.name,
              style: TextStyle(
                color: locked ? Colors.white30 : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ability.description,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            const SizedBox(height: 8),
            // Current stats
            _statRow('Current', effectSummary, locked ? Colors.white24 : effectColor),
            if (!maxed && !locked) ...[
              const SizedBox(height: 4),
              _statRow('At rank ${rank + 1}', nextEffectSummary, Colors.white54),
            ],
            if (maxed) ...[
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('MAX RANK', style: TextStyle(
                  color: AppTheme.accentGold, fontSize: 10,
                  fontWeight: FontWeight.bold, letterSpacing: 1,
                )),
              ),
              if (ability.branchA != null && ability.branchB != null) ...[
                const SizedBox(height: 12),
                if (chosenBranchId == null)
                  _BranchPicker(ability: ability, effectColor: effectColor, game: game)
                else
                  _ChosenBranchBadge(
                    branch: chosenBranchId == 'a' ? ability.branchA! : ability.branchB!,
                    effectColor: effectColor,
                  ),
              ],
            ],
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
                            fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
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
        width: 70,
        child: Text(label,
            style: const TextStyle(color: Colors.white30, fontSize: 10)),
      ),
      Text(value, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    ],
  );
}

// ── Branch picker (shown when rank 3 and no branch chosen yet) ────────────────

class _BranchPicker extends StatelessWidget {
  const _BranchPicker({
    required this.ability,
    required this.effectColor,
    required this.game,
  });
  final HeroAbility ability;
  final Color effectColor;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: effectColor.withOpacity(0.10),
          child: Row(children: [
            Icon(Icons.call_split, color: effectColor, size: 13),
            const SizedBox(width: 6),
            Text('BRANCH UNLOCKED — choose one path',
                style: TextStyle(color: effectColor, fontSize: 10,
                    fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ]),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _BranchOption(
              branch: ability.branchA!,
              label: 'A',
              effectColor: effectColor,
              onChoose: () => game.chooseBranch(ability.id, 'a'),
            )),
            const SizedBox(width: 8),
            Expanded(child: _BranchOption(
              branch: ability.branchB!,
              label: 'B',
              effectColor: effectColor,
              onChoose: () => game.chooseBranch(ability.id, 'b'),
            )),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text('This choice is permanent until Rebirth.',
              style: TextStyle(color: Colors.white24, fontSize: 9,
                  fontStyle: FontStyle.italic)),
        ),
      ],
    );
  }
}

class _BranchOption extends StatelessWidget {
  const _BranchOption({
    required this.branch,
    required this.label,
    required this.effectColor,
    required this.onChoose,
  });
  final AbilityBranch branch;
  final String label;
  final Color effectColor;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0e1225),
        border: Border.all(color: effectColor.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 18, height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: effectColor.withOpacity(0.15),
                border: Border.all(color: effectColor.withOpacity(0.6)),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(label, style: TextStyle(color: effectColor,
                  fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 6),
            Expanded(child: Text(branch.name,
                style: TextStyle(color: effectColor, fontSize: 11,
                    fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 6),
          Text(branch.description,
              style: const TextStyle(color: Colors.white54, fontSize: 10,
                  height: 1.3)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onChoose,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 6),
                side: BorderSide(color: effectColor.withOpacity(0.7)),
                foregroundColor: effectColor,
              ),
              child: Text('CHOOSE', style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold,
                  color: effectColor, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chosen branch badge ───────────────────────────────────────────────────────

class _ChosenBranchBadge extends StatelessWidget {
  const _ChosenBranchBadge({required this.branch, required this.effectColor});
  final AbilityBranch branch;
  final Color effectColor;

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
            Text('Branch: ${branch.name}',
                style: TextStyle(color: effectColor, fontSize: 11,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(branch.description,
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        )),
      ]),
    );
  }
}

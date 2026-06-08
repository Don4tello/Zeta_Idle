import 'package:flutter/material.dart';
import '../models/hero_ability.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AbilityBar — row of active ability chips for the hero
// Shows unlocked abilities with live cooldown countdown.
// ─────────────────────────────────────────────────────────────────────────────

class AbilityBar extends StatelessWidget {
  const AbilityBar({super.key});

  static const _effectColors = <AbilityEffect, Color>{
    AbilityEffect.bonusDamage: Color(0xFFff6633),
    AbilityEffect.heal:        Color(0xFF44cc66),
    AbilityEffect.attackBonus: Color(0xFFffcc00),
    AbilityEffect.acBonus:     Color(0xFF66aaff),
    AbilityEffect.stun:        Color(0xFFcc44ff),
    AbilityEffect.dot:         Color(0xFF88dd00),
    AbilityEffect.dodge:       Color(0xFF44ddcc),
  };

  static const _effectIcons = <AbilityEffect, IconData>{
    AbilityEffect.bonusDamage: Icons.local_fire_department,
    AbilityEffect.heal:        Icons.favorite,
    AbilityEffect.attackBonus: Icons.add_circle,
    AbilityEffect.acBonus:     Icons.shield,
    AbilityEffect.stun:        Icons.flash_on,
    AbilityEffect.dot:         Icons.bug_report,
    AbilityEffect.dodge:       Icons.directions_run,
  };

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final abilities = game.unlockedAbilities;
    if (abilities.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: const Color(0xFF0a0e1f),
      child: Row(
        children: [
          const Text(
            'ABILITIES',
            style: TextStyle(
              color: AppTheme.accentGold,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: abilities.map((a) {
                final cd = game.cooldownRemaining(a.id);
                final ready = cd == 0;
                return Expanded(child: _AbilityChip(ability: a, cooldown: cd, ready: ready));
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AbilityChip extends StatelessWidget {
  const _AbilityChip({
    required this.ability,
    required this.cooldown,
    required this.ready,
  });

  final HeroAbility ability;
  final int cooldown;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final baseColor = AbilityBar._effectColors[ability.effect] ?? Colors.grey;
    final dimColor  = baseColor.withOpacity(0.25);
    final color     = ready ? baseColor : dimColor;
    final icon      = AbilityBar._effectIcons[ability.effect] ?? Icons.star;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF111525),
          border: Border.all(
            color: ready ? baseColor.withOpacity(0.8) : const Color(0xFF2a2e3f),
            width: ready ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ability.name,
                    style: TextStyle(
                      color: ready ? Colors.white : Colors.white38,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ready ? 'READY' : '$cooldown rounds',
                    style: TextStyle(
                      color: ready ? baseColor : Colors.white30,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

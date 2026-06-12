import 'package:flutter/material.dart';
import '../services/game_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BuffHud — shows active hero buffs and enemy debuffs during battle.
// Place inside a Row or above the ability bar.
// ─────────────────────────────────────────────────────────────────────────────

class BuffHud extends StatelessWidget {
  const BuffHud({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);

    final chips = <_BuffChip>[];

    if (game.buffAttackBonus > 0)
      chips.add(_BuffChip(
        icon: Icons.add_circle,
        color: const Color(0xFFffcc00),
        label: '+${game.buffAttackBonus} ATK',
        rounds: game.buffAttackRounds,
        isHeroBuff: true,
      ));

    if (game.buffAcBonus > 0)
      chips.add(_BuffChip(
        icon: Icons.shield,
        color: const Color(0xFF66aaff),
        label: '+${game.buffAcBonus} AC',
        rounds: game.buffAcRounds,
        isHeroBuff: true,
      ));

    if (game.dodgeNextHit)
      chips.add(const _BuffChip(
        icon: Icons.directions_run,
        color: Color(0xFF44ddcc),
        label: 'DODGE',
        rounds: 1,
        isHeroBuff: true,
      ));

    if (game.dotRoundsLeft > 0)
      chips.add(_BuffChip(
        icon: Icons.local_fire_department,
        color: const Color(0xFF88dd00),
        label: '${game.dotDmg}/rnd',
        rounds: game.dotRoundsLeft,
        isHeroBuff: false,
      ));

    if (game.enemyStunRounds > 0)
      chips.add(_BuffChip(
        icon: Icons.flash_on,
        color: const Color(0xFFcc44ff),
        label: 'STUN',
        rounds: game.enemyStunRounds,
        isHeroBuff: false,
      ));

    if (game.enemyWeakenRounds > 0)
      chips.add(_BuffChip(
        icon: Icons.remove_circle,
        color: const Color(0xFFff4488),
        label: '-${game.enemyWeakenPct}% ATK',
        rounds: game.enemyWeakenRounds,
        isHeroBuff: false,
      ));

    if (game.enemyVulnerableRounds > 0)
      chips.add(_BuffChip(
        icon: Icons.broken_image,
        color: const Color(0xFFff8800),
        label: '+${game.enemyVulnerablePct}% DMG',
        rounds: game.enemyVulnerableRounds,
        isHeroBuff: false,
      ));

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: const Color(0xFF080c1a),
      child: Row(
        children: chips
            .map((c) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: c,
                ))
            .toList(),
      ),
    );
  }
}

class _BuffChip extends StatelessWidget {
  const _BuffChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.rounds,
    required this.isHeroBuff,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int rounds;
  final bool isHeroBuff; // true = hero buff (border top), false = enemy debuff (border bottom)

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border(
          top:    isHeroBuff  ? BorderSide(color: color, width: 1.5) : BorderSide.none,
          bottom: !isHeroBuff ? BorderSide(color: color, width: 1.5) : BorderSide.none,
          left:   BorderSide(color: color.withOpacity(0.3), width: 1),
          right:  BorderSide(color: color.withOpacity(0.3), width: 1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$rounds',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

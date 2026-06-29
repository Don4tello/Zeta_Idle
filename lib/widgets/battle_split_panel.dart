import 'package:flutter/material.dart';
import '../models/equipment.dart' show ItemStat;
import '../models/hero_ability.dart';
import '../models/passive_tree.dart' show PassiveEffect;
import '../services/game_state.dart';

/// Shared ABILITIES + ALLIES + STATUS panel used across all battle screens.
///
/// Pass [localCooldownResolver] for screens that manage their own cooldown
/// counters (Boss Rush, Gauntlet). When null, uses [GameState.cooldownRemaining].
class BattleSplitPanel extends StatelessWidget {
  const BattleSplitPanel({super.key, this.localCooldownResolver});

  final int Function(String abilityId)? localCooldownResolver;

  static const _effectColors = <AbilityEffect, Color>{
    AbilityEffect.bonusDamage:      Color(0xFFff6633),
    AbilityEffect.heal:             Color(0xFF44cc66),
    AbilityEffect.attackBonus:      Color(0xFFffcc00),
    AbilityEffect.acBonus:          Color(0xFF66aaff),
    AbilityEffect.stun:             Color(0xFFcc44ff),
    AbilityEffect.dot:              Color(0xFF88dd00),
    AbilityEffect.dodge:            Color(0xFF44ddcc),
    AbilityEffect.aura:             Color(0xFF55ee88),
    AbilityEffect.debuffWeaken:     Color(0xFFff4488),
    AbilityEffect.debuffVulnerable: Color(0xFFff8800),
  };

  static const _effectIcons = <AbilityEffect, IconData>{
    AbilityEffect.bonusDamage:      Icons.local_fire_department,
    AbilityEffect.heal:             Icons.favorite,
    AbilityEffect.attackBonus:      Icons.add_circle,
    AbilityEffect.acBonus:          Icons.shield,
    AbilityEffect.stun:             Icons.flash_on,
    AbilityEffect.dot:              Icons.bug_report,
    AbilityEffect.dodge:            Icons.directions_run,
    AbilityEffect.aura:             Icons.healing,
    AbilityEffect.debuffWeaken:     Icons.remove_circle,
    AbilityEffect.debuffVulnerable: Icons.broken_image,
  };

  static String _buildAbilityTooltip(GameState game, HeroAbility a, int cd, int totalCd) {
    final sv = game.scaledAbilityValue(a);
    final dmgType = game.abilityEffectiveDamageType(a);
    final rank = game.abilityRank(a.id);
    final abilityDmgPct = game.passiveTree.totalOf(PassiveEffect.abilityDamage);
    final penPct = game.passiveTree.totalOf(PassiveEffect.allPenetration)
        + game.inventory.totalOf(ItemStat.elemPenetration);

    final lines = <String>[];

    switch (a.effect) {
      case AbilityEffect.bonusDamage:
        lines.add('${dmgType.emoji} Deals ~$sv ${dmgType.label} damage');
      case AbilityEffect.heal:
        final hp = (game.hero.maxHealth * sv / 100 * 0.5).round();
        lines.add('Restores ~$hp HP (${sv}% of max)');
      case AbilityEffect.attackBonus:
        lines.add('+$sv critical damage for ${a.duration} rounds');
      case AbilityEffect.acBonus:
        lines.add('+$sv Armor for ${a.duration} rounds');
      case AbilityEffect.stun:
        lines.add('Stuns enemy for ${a.duration} rounds');
      case AbilityEffect.dot:
        lines.add('${dmgType.emoji} ~$sv ${dmgType.label} dmg/round for ${a.duration} rounds');
      case AbilityEffect.dodge:
        lines.add('Dodges the next enemy attack completely');
      case AbilityEffect.aura:
        lines.add('Regenerate $sv HP/round for ${a.duration} rounds');
      case AbilityEffect.debuffWeaken:
        lines.add('Reduces enemy ATK by $sv% for ${a.duration} rounds');
      case AbilityEffect.debuffVulnerable:
        lines.add('Enemy takes $sv% more damage for ${a.duration} rounds');
    }

    if (rank > 0) lines.add('Rank $rank');
    if (abilityDmgPct > 0 && (a.effect == AbilityEffect.bonusDamage || a.effect == AbilityEffect.dot)) {
      lines.add('+$abilityDmgPct% ability damage bonus');
    }
    if (penPct > 0 && (a.effect == AbilityEffect.bonusDamage || a.effect == AbilityEffect.dot)) {
      lines.add('$penPct% resistance penetration');
    }
    lines.add('Cooldown: $totalCd rounds'
        '${cd > 0 ? "  •  Ready in $cd" : "  •  READY"}');

    return lines.join('\n');
  }

  static void showAbilityInfo(BuildContext context, GameState game,
      HeroAbility a, int cd, int totalCd, Color color, IconData icon) {
    _showInfoSheet(context,
      title: a.name,
      body: _buildAbilityTooltip(game, a, cd, totalCd),
      color: color,
      icon: icon,
    );
  }

  static void _showInfoSheet(BuildContext context, {
    required String title,
    required String body,
    required Color color,
    required IconData icon,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1a1a2e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: TextStyle(
                    color: color, fontSize: 16,
                    fontWeight: FontWeight.bold, letterSpacing: 1,
                  )),
                ),
              ]),
              const SizedBox(height: 10),
              Container(height: 1, color: color.withValues(alpha: 0.3)),
              const SizedBox(height: 10),
              Text(body, style: const TextStyle(
                color: Colors.white70, fontSize: 14, height: 1.5,
              )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final abilities = game.unlockedAbilities;

    // ── Status rows ──────────────────────────────────────────────────────────
    final statusRows = <Widget>[];

    void addStatus(IconData icon, Color color, String label, int rounds, String description) {
      statusRows.add(GestureDetector(
        onTap: () => _showInfoSheet(context,
            title: label, body: description, color: color, icon: icon),
        child: Container(
          margin: const EdgeInsets.only(bottom: 3),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            border: Border(left: BorderSide(color: color, width: 2)),
          ),
          child: Row(children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 5),
            Expanded(child: Text(label,
                style: TextStyle(color: color, fontSize: 11,
                    fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis)),
            Text('${rounds}r',
                style: TextStyle(color: color.withValues(alpha: 0.8),
                    fontSize: 10, fontWeight: FontWeight.bold)),
          ]),
        ),
      ));
    }

    // Hero buffs
    if (game.buffAttackBonus > 0) {
      addStatus(Icons.add_circle, const Color(0xFFffcc00),
          '+${game.buffAttackBonus} ATK', game.buffAttackRounds,
          '+${game.buffAttackBonus} bonus critical damage.\nExpires in ${game.buffAttackRounds} round${game.buffAttackRounds != 1 ? "s" : ""}.');
    }
    if (game.buffAcBonus > 0) {
      addStatus(Icons.shield, const Color(0xFF66aaff),
          '+${game.buffAcBonus} AC', game.buffAcRounds,
          '+${game.buffAcBonus} bonus Armor.\nExpires in ${game.buffAcRounds} round${game.buffAcRounds != 1 ? "s" : ""}.');
    }
    if (game.dodgeNextHit) {
      addStatus(Icons.directions_run, const Color(0xFF44ddcc), 'DODGE', 1,
          'Your next incoming attack will be completely dodged — you take zero damage.');
    }
    if (game.auraRoundsLeft > 0) {
      addStatus(Icons.healing, const Color(0xFF55ee88),
          '+${game.auraHealPerRound} HP/r', game.auraRoundsLeft,
          'Sacred Aura: regenerating +${game.auraHealPerRound} HP at the end of each round.\n${game.auraRoundsLeft} round${game.auraRoundsLeft != 1 ? "s" : ""} remaining.');
    }
    // Hero-afflicted debuffs (from boss abilities)
    if (game.heroStunRounds > 0) {
      addStatus(Icons.flash_off, const Color(0xFFff8833),
          'STUNNED', game.heroStunRounds,
          'You are stunned and cannot act!\n${game.heroStunRounds} round${game.heroStunRounds != 1 ? "s" : ""} remaining.');
    }
    if (game.heroDotRoundsLeft > 0) {
      addStatus(Icons.whatshot, game.heroDotType.color,
          '${game.heroDotDmgPerRound}/rnd', game.heroDotRoundsLeft,
          'Ongoing damage from boss ability: taking ${game.heroDotDmgPerRound} ${game.heroDotType.label} damage per round.\n${game.heroDotRoundsLeft} round${game.heroDotRoundsLeft != 1 ? "s" : ""} remaining.');
    }
    // Enemy debuffs
    if (game.dotRoundsLeft > 0) {
      addStatus(Icons.bug_report, const Color(0xFF88dd00),
          '${game.dotDmg}/rnd', game.dotRoundsLeft,
          'Damage-over-time: enemy takes ${game.dotDmg} damage at the start of each round.\n${game.dotRoundsLeft} round${game.dotRoundsLeft != 1 ? "s" : ""} remaining.');
    }
    if (game.enemyStunRounds > 0) {
      addStatus(Icons.flash_on, const Color(0xFFcc44ff),
          'STUN', game.enemyStunRounds,
          'Enemy is stunned and cannot attack.\n${game.enemyStunRounds} turn${game.enemyStunRounds != 1 ? "s" : ""} remaining.');
    }
    if (game.enemyWeakenRounds > 0) {
      addStatus(Icons.remove_circle, const Color(0xFFff4488),
          '-${game.enemyWeakenPct}%ATK', game.enemyWeakenRounds,
          'Weakened: enemy\'s attack power is reduced by ${game.enemyWeakenPct}%.\n${game.enemyWeakenRounds} round${game.enemyWeakenRounds != 1 ? "s" : ""} remaining.');
    }
    if (game.enemyVulnerableRounds > 0) {
      addStatus(Icons.broken_image, const Color(0xFFff8800),
          '+${game.enemyVulnerablePct}%DMG', game.enemyVulnerableRounds,
          'Vulnerable: enemy takes ${game.enemyVulnerablePct}% more damage from all sources.\n${game.enemyVulnerableRounds} round${game.enemyVulnerableRounds != 1 ? "s" : ""} remaining.');
    }

    final allies = game.campaignStageIndex >= 15
        ? game.unlockedAllies.where((a) => a.activeAbility != null).toList()
        : <dynamic>[];
    if (abilities.isEmpty && statusRows.isEmpty && allies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: const Color(0xFF0a0e1f),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── LEFT: hero abilities + ally abilities ─────────────────────
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (abilities.isNotEmpty) ...[
                    const Text('ABILITIES',
                        style: TextStyle(color: Color(0xFF7799cc), fontSize: 11,
                            fontWeight: FontWeight.bold, letterSpacing: 2)),
                    const SizedBox(height: 4),
                    ...abilities.map((a) {
                      final cd    = localCooldownResolver != null
                          ? localCooldownResolver!(a.id)
                          : game.cooldownRemaining(a.id);
                      final total = game.scaledAbilityCooldown(a);
                      final ready = cd == 0;
                      final Color color;
                      if (a.effect == AbilityEffect.bonusDamage ||
                          a.effect == AbilityEffect.dot) {
                        color = game.abilityEffectiveDamageType(a).color;
                      } else {
                        color = _effectColors[a.effect] ?? Colors.grey;
                      }
                      final icon     = _effectIcons[a.effect] ?? Icons.star;
                      final progress = ready
                          ? 1.0
                          : ((total - cd) / total.clamp(1, 9999)).clamp(0.0, 1.0);
                      return GestureDetector(
                        onTap: () => _showInfoSheet(
                          context,
                          title: a.name,
                          body: _buildAbilityTooltip(game, a, cd, total),
                          color: color,
                          icon: icon,
                        ),
                        child: TweenAnimationBuilder<double>(
                          key: ValueKey('${a.id}_$ready'),
                          tween: Tween(begin: ready ? 1.0 : 0.0, end: 0.0),
                          duration: const Duration(milliseconds: 700),
                          builder: (_, glow, child) => Container(
                            margin: const EdgeInsets.only(bottom: 3),
                            decoration: ready && glow > 0
                                ? BoxDecoration(boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: glow * 0.6),
                                      blurRadius: glow * 10,
                                      spreadRadius: glow * 1,
                                    ),
                                  ])
                                : null,
                            child: child,
                          ),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: ready ? 0.12 : 0.05),
                              border: Border(
                                left: BorderSide(
                                    color: color.withValues(alpha: ready ? 1.0 : 0.4),
                                    width: 2),
                              ),
                            ),
                            child: Row(children: [
                              Icon(icon, color: color, size: 12),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Expanded(
                                        child: Text(a.name,
                                            style: const TextStyle(
                                                color: Colors.white, fontSize: 11,
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      Text(ready ? 'RDY' : '${cd}r',
                                          style: TextStyle(
                                              color: color, fontSize: 11,
                                              fontWeight: FontWeight.bold)),
                                    ]),
                                    const SizedBox(height: 2),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(1),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 2,
                                        backgroundColor:
                                            Colors.white.withValues(alpha: 0.1),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            color.withValues(alpha: 0.8)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                        ),
                      );
                    }),
                  ],
                  if (allies.isNotEmpty) ...[
                    if (abilities.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      const Divider(color: Color(0xFF2a2a3a), height: 1),
                      const SizedBox(height: 5),
                    ],
                    const Text('MERCS',
                        style: TextStyle(color: Color(0xFF44cc88), fontSize: 11,
                            fontWeight: FontWeight.bold, letterSpacing: 2)),
                    const SizedBox(height: 4),
                    ...allies.map((ally) => GestureDetector(
                      onTap: () => _showInfoSheet(
                        context,
                        title: '${ally.name}: ${ally.activeAbility!.name}',
                        body: ally.activeAbility!.description,
                        color: const Color(0xFF44cc88),
                        icon: Icons.people,
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 3),
                        padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF44cc88).withValues(alpha: 0.07),
                          border: const Border(
                            left: BorderSide(color: Color(0xFF44cc88), width: 2),
                          ),
                        ),
                        child: Row(children: [
                          Text(ally.icon, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              '${ally.name}: ${ally.activeAbility!.name}',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Text('✓',
                              style: TextStyle(
                                  color: Color(0xFF44cc88), fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    )),
                  ],
                ],
              ),
            ),
            // ── Divider ──────────────────────────────────────────────────
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: const Color(0xFF2a2a3a),
            ),
            // ── RIGHT: buffs / debuffs ────────────────────────────────────
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('STATUS',
                      style: TextStyle(color: Color(0xFF7799cc), fontSize: 11,
                          fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  if (statusRows.isEmpty)
                    const Text('—',
                        style: TextStyle(color: Color(0xFF555577), fontSize: 12))
                  else
                    ...statusRows,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BattleIconBar — compact icon-only ability + status bar for battle screens.
//
// Abilities show as icons with a cooldown fill-from-bottom animation.
// Status effects show as small icon badges. Tap either for tooltip details.
// ─────────────────────────────────────────────────────────────────────────────

class BattleIconBar extends StatelessWidget {
  const BattleIconBar({super.key, this.localCooldownResolver});
  final int Function(String abilityId)? localCooldownResolver;

  static const _effectColors = <AbilityEffect, Color>{
    AbilityEffect.bonusDamage:      Color(0xFFff6633),
    AbilityEffect.heal:             Color(0xFF44cc66),
    AbilityEffect.attackBonus:      Color(0xFFffcc00),
    AbilityEffect.acBonus:          Color(0xFF66aaff),
    AbilityEffect.stun:             Color(0xFFcc44ff),
    AbilityEffect.dot:              Color(0xFF88dd00),
    AbilityEffect.dodge:            Color(0xFF44ddcc),
    AbilityEffect.aura:             Color(0xFF55ee88),
    AbilityEffect.debuffWeaken:     Color(0xFFff4488),
    AbilityEffect.debuffVulnerable: Color(0xFFff8800),
  };

  static const _effectIcons = <AbilityEffect, IconData>{
    AbilityEffect.bonusDamage:      Icons.local_fire_department,
    AbilityEffect.heal:             Icons.favorite,
    AbilityEffect.attackBonus:      Icons.add_circle,
    AbilityEffect.acBonus:          Icons.shield,
    AbilityEffect.stun:             Icons.flash_on,
    AbilityEffect.dot:              Icons.bug_report,
    AbilityEffect.dodge:            Icons.directions_run,
    AbilityEffect.aura:             Icons.healing,
    AbilityEffect.debuffWeaken:     Icons.remove_circle,
    AbilityEffect.debuffVulnerable: Icons.broken_image,
  };

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final abilities = game.unlockedAbilities;
    if (abilities.isEmpty) return const SizedBox.shrink();

    // Status effects
    final statuses = <({IconData icon, Color color, String label, int rounds})>[];
    if (game.buffAttackBonus > 0)
      statuses.add((icon: Icons.add_circle, color: const Color(0xFFffcc00),
          label: '+${game.buffAttackBonus} ATK', rounds: game.buffAttackRounds));
    if (game.buffAcBonus > 0)
      statuses.add((icon: Icons.shield, color: const Color(0xFF66aaff),
          label: '+${game.buffAcBonus} Armor', rounds: game.buffAcRounds));
    if (game.dodgeNextHit)
      statuses.add((icon: Icons.directions_run, color: const Color(0xFF44ddcc),
          label: 'DODGE', rounds: 1));
    if (game.auraRoundsLeft > 0)
      statuses.add((icon: Icons.healing, color: const Color(0xFF55ee88),
          label: '+${game.auraHealPerRound} HP/r', rounds: game.auraRoundsLeft));
    if (game.dotRoundsLeft > 0)
      statuses.add((icon: Icons.bug_report, color: const Color(0xFF88dd00),
          label: '${game.dotDmg}/rnd DoT', rounds: game.dotRoundsLeft));
    if (game.enemyStunRounds > 0)
      statuses.add((icon: Icons.flash_on, color: const Color(0xFFcc44ff),
          label: 'Enemy STUN', rounds: game.enemyStunRounds));
    if (game.enemyWeakenRounds > 0)
      statuses.add((icon: Icons.remove_circle, color: const Color(0xFFff4488),
          label: '-${game.enemyWeakenPct}% ATK', rounds: game.enemyWeakenRounds));
    if (game.enemyVulnerableRounds > 0)
      statuses.add((icon: Icons.broken_image, color: const Color(0xFFff8800),
          label: '+${game.enemyVulnerablePct}% DMG', rounds: game.enemyVulnerableRounds));

    return Container(
      color: const Color(0xFF0a0e1f),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
        children: [
          // Abilities
          ...abilities.map((a) {
            final cd = localCooldownResolver != null
                ? localCooldownResolver!(a.id)
                : game.cooldownRemaining(a.id);
            final total = game.scaledAbilityCooldown(a);
            final ready = cd == 0;
            final fill = ready ? 1.0 : ((total - cd) / total.clamp(1, 9999)).clamp(0.0, 1.0);
            final color = _effectColors[a.effect] ?? Colors.grey;
            final icon  = _effectIcons[a.effect] ?? Icons.star;

            if (a.effect == AbilityEffect.bonusDamage || a.effect == AbilityEffect.dot) {
              // Use damage type color
              final dtColor = game.abilityEffectiveDamageType(a).color;
              return _AbilityIcon(
                icon: icon, color: dtColor, fill: fill, ready: ready,
                name: a.name, cd: cd,
                onTap: () => BattleSplitPanel.showAbilityInfo(context, game, a, cd, total, dtColor, icon),
              );
            }
            return _AbilityIcon(
              icon: icon, color: color, fill: fill, ready: ready,
              name: a.name, cd: cd,
              onTap: () => BattleSplitPanel.showAbilityInfo(context, game, a, cd, total, color, icon),
            );
          }),

          // Merc icons
          if (game.unlockedAllies.isNotEmpty) ...[
            Container(width: 1, height: 28, margin: const EdgeInsets.symmetric(horizontal: 4),
                color: const Color(0xFF2a3a2a)),
            ...game.unlockedAllies.where((a) => a.activeAbility != null).map((ally) =>
              Tooltip(
                message: '${ally.name}: ${ally.activeAbility!.name}\n${ally.activeAbility!.description}',
                child: Container(
                  width: 28, height: 28,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF44cc88).withValues(alpha: 0.15),
                    border: Border.all(color: const Color(0xFF44cc88).withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(child: Text(ally.icon, style: const TextStyle(fontSize: 14))),
                ),
              ),
            ),
          ],

          if (statuses.isNotEmpty) ...[
            Container(width: 1, height: 28, margin: const EdgeInsets.symmetric(horizontal: 6),
                color: const Color(0xFF2a2a3a)),
            // Status effects
            ...statuses.map((s) => _StatusIcon(
              icon: s.icon, color: s.color, label: s.label, rounds: s.rounds)),
          ],
        ],
      )),
    );
  }
}

class _AbilityIcon extends StatelessWidget {
  const _AbilityIcon({
    required this.icon, required this.color, required this.fill,
    required this.ready, required this.name, required this.cd,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final double fill;
  final bool ready;
  final String name;
  final int cd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0d1020),
          border: Border.all(
            color: ready ? color : color.withValues(alpha: 0.3),
            width: ready ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: ready ? [
            BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 6),
          ] : null,
        ),
        child: Stack(
          children: [
            // Cooldown fill from bottom
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 32 * fill,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: ready ? 0.25 : 0.12),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            // Icon
            Center(
              child: Icon(icon, size: 16,
                  color: ready ? color : color.withValues(alpha: 0.4)),
            ),
            // Cooldown number
            if (!ready)
              Positioned(
                right: 2, bottom: 1,
                child: Text('$cd', style: TextStyle(
                    fontSize: 8, color: color.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({
    required this.icon, required this.color,
    required this.label, required this.rounds,
  });
  final IconData icon;
  final Color color;
  final String label;
  final int rounds;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$label  (${rounds}r)',
      child: Container(
        width: 26,
        height: 26,
        margin: const EdgeInsets.only(right: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Stack(
          children: [
            Center(child: Icon(icon, size: 13, color: color)),
            Positioned(
              right: 1, bottom: 0,
              child: Text('$rounds', style: TextStyle(
                  fontSize: 7, color: color, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

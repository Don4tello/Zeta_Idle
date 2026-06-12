import 'package:flutter/material.dart';
import '../models/hero_ability.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AbilityBar — row of ability chips with cooldown progress bars.
//
// Each chip shows:
//   • ability icon + name
//   • a fill bar that grows left→right as the cooldown ticks down
//   • rounds remaining (or "READY!" when fired)
// ─────────────────────────────────────────────────────────────────────────────

class AbilityBar extends StatelessWidget {
  const AbilityBar({super.key});

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
    final game      = GameStateProvider.of(context);
    final abilities = game.unlockedAbilities;
    if (abilities.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: const Color(0xFF0a0e1f),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text(
              'ABILITIES',
              style: TextStyle(
                color: AppTheme.accentGold,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          // Split into 2 rows of 3 for up to 6 abilities
          ...(() {
            final rows = <Widget>[];
            for (var i = 0; i < abilities.length; i += 3) {
              final slice = abilities.sublist(i, (i + 3).clamp(0, abilities.length));
              rows.add(
                Row(
                  children: slice.map((a) {
                    final cd    = game.cooldownRemaining(a.id);
                    final total = game.scaledAbilityCooldown(a);
                    final ready = cd == 0;
                    final color = _effectColors[a.effect] ?? Colors.grey;
                    final icon  = _effectIcons[a.effect] ?? Icons.star;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _AbilityChip(
                          ability: a,
                          cooldown: cd,
                          totalCooldown: total,
                          ready: ready,
                          color: color,
                          icon: icon,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
              if (i + 3 < abilities.length) rows.add(const SizedBox(height: 6));
            }
            return rows;
          })(),
        ],
      ),
    );
  }
}

class _AbilityChip extends StatefulWidget {
  const _AbilityChip({
    required this.ability,
    required this.cooldown,
    required this.totalCooldown,
    required this.ready,
    required this.color,
    required this.icon,
  });

  final HeroAbility ability;
  final int         cooldown;
  final int         totalCooldown;
  final bool        ready;
  final Color       color;
  final IconData    icon;

  @override
  State<_AbilityChip> createState() => _AbilityChipState();
}

class _AbilityChipState extends State<_AbilityChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  late final Animation<double> _pulse =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

  @override
  void initState() {
    super.initState();
    if (widget.ready) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_AbilityChip old) {
    super.didUpdateWidget(old);
    if (widget.ready && !old.ready) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.ready && old.ready) {
      _ctrl.stop();
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // progress: 0.0 = just fired (empty bar), 1.0 = ready (full bar)
    final total    = widget.totalCooldown.clamp(1, 9999);
    final progress = widget.ready
        ? 1.0
        : ((total - widget.cooldown) / total).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        final t = _pulse.value; // 0→1 pulsing when ready

        final borderColor = widget.ready
            ? widget.color.withValues(alpha: 0.55 + 0.45 * t)
            : widget.color.withValues(alpha: 0.55);
        final bgColor = widget.ready
            ? Color.lerp(const Color(0xFF1B1814),
                widget.color.withValues(alpha: 0.18), t)!
            : widget.color.withValues(alpha: 0.08);
        final borderWidth = widget.ready ? 1.5 + 0.5 * t : 1.0;

        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: widget.ready
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.2 + 0.35 * t),
                      blurRadius: 4 + 8 * t,
                      spreadRadius: 0.5 + 1.5 * t,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Content row — icon + name + status
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 9, 8, 5),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      size: 17,
                      color: widget.ready
                          ? Color.lerp(widget.color, Colors.white, t * 0.4)
                          : widget.color.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.ability.name,
                        style: TextStyle(
                          color: widget.ready
                              ? Color.lerp(Colors.white, Colors.white, t * 0.4)
                              : Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Cooldown number or READY badge
                    if (widget.ready)
                      Text(
                        'READY',
                        style: TextStyle(
                          color: Color.lerp(
                              widget.color, Colors.white, t * 0.4),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      )
                    else
                      Text(
                        '${widget.cooldown}r',
                        style: TextStyle(
                          color: widget.color,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              // Cooldown progress bar
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 7),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(1),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.ready
                          ? Color.lerp(widget.color,
                              Colors.white, t * 0.25)!
                          : widget.color.withValues(alpha: 0.80),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

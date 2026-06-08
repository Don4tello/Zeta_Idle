import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/battle_sprites.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DashboardHeader
//
// Zone 1 of the character-sheet dashboard.  Reads live data from
// GameStateProvider and drives two animations:
//   • TweenAnimationBuilder — smooth HP/XP bar fill transitions
//   • _dangerPulse AnimationController — red border flash when HP < 20 %
// ─────────────────────────────────────────────────────────────────────────────

class DashboardHeader extends StatefulWidget {
  const DashboardHeader({super.key});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dangerPulse;

  @override
  void initState() {
    super.initState();
    _dangerPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _dangerPulse.dispose();
    super.dispose();
  }

  // Triggered from build() via postFrameCallback to avoid modifying animation
  // state mid-layout.
  void _syncDangerPulse(bool inDanger) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (inDanger && !_dangerPulse.isAnimating) {
        _dangerPulse.repeat(reverse: true);
      } else if (!inDanger && _dangerPulse.isAnimating) {
        _dangerPulse.stop();
        _dangerPulse.animateTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final hero = game.hero;

    final hpFrac =
        hero.maxHealth > 0 ? (hero.currentHealth / hero.maxHealth).clamp(0.0, 1.0) : 0.0;
    final xpFrac = hero.experienceToNextLevel > 0
        ? (hero.experience / hero.experienceToNextLevel).clamp(0.0, 1.0)
        : 0.0;
    final inDanger = hpFrac < 0.2;

    _syncDangerPulse(inDanger);

    return AnimatedBuilder(
      animation: _dangerPulse,
      builder: (context, child) {
        final borderColor = inDanger
            ? Color.lerp(AppTheme.cardBorder, const Color(0xFFee2222), _dangerPulse.value)!
            : AppTheme.cardBorder;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            border: Border.all(color: borderColor, width: inDanger ? 2 : 1),
          ),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sprite / name / bars row ─────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero sprite preview
              Container(
                width: 72,
                height: 96,
                decoration: BoxDecoration(
                  color: AppTheme.darkBg,
                  border:
                      Border.all(color: AppTheme.accentGold.withValues(alpha: 0.35)),
                ),
                child: Center(child: BattleSprite(spriteId: hero.spriteId)),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + level badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hero.name.toUpperCase(),
                            style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 1.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _LevelBadge(level: hero.level),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Class
                    Text(
                      hero.heroClass.displayName.toUpperCase(),
                      style: AppTheme.pixelHeading(
                        fontSize: 9,
                        color: AppTheme.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // HP bar
                    _BarLabel(
                      label: 'HP',
                      current: hero.currentHealth,
                      max: hero.maxHealth,
                      color: inDanger ? const Color(0xFFee3030) : const Color(0xFF66cc44),
                    ),
                    const SizedBox(height: 3),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: hpFrac),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                      builder: (_, v, __) => _SegmentedBar(
                        value: v,
                        color: inDanger
                            ? const Color(0xFFee3030)
                            : const Color(0xFF66cc44),
                        segments: 20,
                        height: 9,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // XP bar
                    _BarLabel(
                      label: 'XP',
                      current: hero.experience,
                      max: hero.experienceToNextLevel,
                      color: AppTheme.accentGold,
                    ),
                    const SizedBox(height: 3),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: xpFrac),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      builder: (_, v, __) => _SegmentedBar(
                        value: v,
                        color: AppTheme.accentGold,
                        segments: 20,
                        height: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Container(height: 1, color: AppTheme.cardBorder),
          const SizedBox(height: 10),

          // ── Resource chips ────────────────────────────────────────────────
          Row(
            children: [
              _ResourceChip(
                icon: Icons.monetization_on_outlined,
                label: 'GOLD',
                value: '${game.gold}',
              ),
              const SizedBox(width: 6),
              _ResourceChip(
                icon: Icons.diamond_outlined,
                label: 'SHARDS',
                value: _fmtShards(game.shards),
              ),
              const SizedBox(width: 6),
              _ResourceChip(
                icon: Icons.shield_outlined,
                label: 'AC',
                value: '${hero.armorClass}',
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ── Idle income row ───────────────────────────────────────────────
          _IdleIncomeBar(
            fillRatio:     game.idleFillRatio,
            pendingGold:   game.pendingIdleGold,
            goldPerMinute: game.idleGoldPerMinute,
          ),
        ],
      ),
    );
  }

  static String _fmtShards(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.accentGold),
        color: AppTheme.darkBg,
      ),
      child: Text('LV.$level', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 1)),
    );
  }
}

class _BarLabel extends StatelessWidget {
  const _BarLabel({
    required this.label,
    required this.current,
    required this.max,
    required this.color,
  });
  final String label;
  final int current;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTheme.pixelHeading(fontSize: 9, letterSpacing: 1, color: color)),
        Text(
          '$current / $max',
          style: GoogleFonts.pixelifySans(
              fontSize: 9, color: color.withValues(alpha: 0.75)),
        ),
      ],
    );
  }
}

/// A row of uniform rectangular segments that fill left-to-right.
class _SegmentedBar extends StatelessWidget {
  const _SegmentedBar({
    required this.value,
    required this.color,
    required this.segments,
    required this.height,
  });
  final double value;
  final Color color;
  final int segments;
  final double height;

  @override
  Widget build(BuildContext context) {
    final filled = (value * segments).round().clamp(0, segments);
    return Row(
      children: List.generate(segments, (i) {
        final active = i < filled;
        return Expanded(
          child: Container(
            height: height,
            margin: EdgeInsets.only(right: i < segments - 1 ? 1.5 : 0),
            color: active ? color : color.withValues(alpha: 0.12),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _IdleIncomeBar
//
// Shows the 60-second idle-income collection cycle as a segmented progress bar.
// 12 segments = 12 × 5 s ticks.  Each segment lights up as a tick fires so the
// player can see the cycle advancing in real time.
// ─────────────────────────────────────────────────────────────────────────────

class _IdleIncomeBar extends StatelessWidget {
  const _IdleIncomeBar({
    required this.fillRatio,
    required this.pendingGold,
    required this.goldPerMinute,
  });

  final double fillRatio;
  final int    pendingGold;
  final int    goldPerMinute;

  static const _barColor    = Color(0xFF88cc44);
  static const _idleSegments = 12;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.darkBg,
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          // Icon
          const Icon(Icons.bolt, size: 12, color: _barColor),
          const SizedBox(width: 6),
          // Label
          Text(
            'IDLE',
            style: AppTheme.pixelHeading(
                fontSize: 8, letterSpacing: 1, color: AppTheme.textMuted),
          ),
          const SizedBox(width: 10),
          // Segmented fill bar
          Expanded(
            child: _SegmentedBar(
              value: fillRatio,
              color: _barColor,
              segments: _idleSegments,
              height: 7,
            ),
          ),
          const SizedBox(width: 10),
          // Pending gold (fills up, resets on collect)
          Text(
            pendingGold > 0 ? '+${pendingGold}g' : '${goldPerMinute}g/min',
            style: AppTheme.pixelHeading(
              fontSize: 9,
              letterSpacing: 0.5,
              color: pendingGold > 0 ? _barColor : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceChip extends StatelessWidget {
  const _ResourceChip({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.darkBg,
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppTheme.accentGold.withValues(alpha: 0.7)),
            const SizedBox(height: 2),
            Text(label,
                style: AppTheme.pixelHeading(
                    fontSize: 7, letterSpacing: 0.5, color: AppTheme.textMuted)),
            const SizedBox(height: 1),
            Text(
              value,
              style: GoogleFonts.pixelifySans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textLight),
            ),
          ],
        ),
      ),
    );
  }
}

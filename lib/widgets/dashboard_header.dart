import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/passive_tree.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../models/hero_race.dart';
import '../models/hero_trait.dart';
import '../models/shop_catalog.dart';
import '../widgets/battle_sprites.dart';
import '../widgets/progress_ring.dart';

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

  void _showRacePopup(BuildContext ctx, HeroRace race) {
    final info  = race.info;
    final trait = HeroTrait.forRace(race).firstOrNull;
    showDialog<void>(
      context: ctx,
      builder: (_) => Dialog(
        backgroundColor: AppTheme.panelBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: info.color.withValues(alpha: 0.6)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(info.icon, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text(
                info.displayName.toUpperCase(),
                style: AppTheme.pixelHeading(fontSize: 16, color: info.color, letterSpacing: 2),
              ),
              const SizedBox(height: 4),
              Text(
                info.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
              ),
              if (trait != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: info.color.withValues(alpha: 0.07),
                    border: Border.all(color: info.color.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(trait.icon, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          trait.name.toUpperCase(),
                          style: AppTheme.pixelHeading(fontSize: 11, color: info.color, letterSpacing: 1),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      ...trait.bonusChips.map((chip) => Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Row(children: [
                          Container(width: 3, height: 3,
                              decoration: BoxDecoration(color: info.color.withValues(alpha: 0.6), shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(chip, style: TextStyle(fontSize: 13, color: info.color, fontWeight: FontWeight.bold)),
                        ]),
                      )),
                      const SizedBox(height: 6),
                      Text(
                        trait.description,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(foregroundColor: info.color),
                  child: const Text('CLOSE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    final isPhone = MediaQuery.of(context).size.width < 600;

    final hpFrac =
        hero.maxHealth > 0 ? (hero.currentHealth / hero.maxHealth).clamp(0.0, 1.0) : 0.0;
    final xpFrac = hero.experienceToNextLevel > 0
        ? (hero.experience / hero.experienceToNextLevel).clamp(0.0, 1.0)
        : 0.0;
    final inDanger  = hpFrac < 0.2;
    final raceColor = game.heroRace?.info.color;

    _syncDangerPulse(inDanger);

    return AnimatedBuilder(
      animation: _dangerPulse,
      builder: (context, child) {
        final dangerColor = Color.lerp(
            AppTheme.cardBorder, const Color(0xFFee2222), _dangerPulse.value)!;

        // Effect 1 — subtle background tint (suppressed in danger state)
        final bgColor = (!inDanger && raceColor != null)
            ? Color.lerp(AppTheme.cardBg, raceColor, 0.06)!
            : AppTheme.cardBg;

        // Effect 2 — thick colored left border; all borders go red in danger
        final border = inDanger
            ? Border.all(color: dangerColor, width: 2)
            : Border(
                left:   BorderSide(color: raceColor ?? AppTheme.cardBorder, width: 3),
                top:    const BorderSide(color: AppTheme.cardBorder),
                right:  const BorderSide(color: AppTheme.cardBorder),
                bottom: const BorderSide(color: AppTheme.cardBorder),
              );

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: bgColor, border: border),
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
              Builder(builder: (_) {
                final frameColor = CosmeticItem.frameColorFor(game.activeFrame);
                final sprite = SizedBox(
                  width: 80,
                  height: 120,
                  child: BattleSprite(
                    spriteId: game.heroBattleSpriteId,
                    gender: hero.gender,
                    race: game.heroRace,
                    colorFilter: game.heroSpriteFilter,
                    auraColor: game.heroAuraColor,
                    auraIntensity: game.heroAuraIntensity,
                  ),
                );
                if (frameColor == null) return sprite;
                // Equipped portrait frame — coloured border + glow around the hero.
                return Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    border: Border.all(color: frameColor, width: 2),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [BoxShadow(color: frameColor.withValues(alpha: 0.5), blurRadius: 8)],
                  ),
                  child: sprite,
                );
              }),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Equipped cosmetic title
                    if (game.activeTitle != null && game.activeTitle!.isNotEmpty)
                      Text(
                        game.activeTitle!.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.pixelHeading(
                          fontSize: 9,
                          letterSpacing: 1.2,
                          color: CosmeticItem.titleColorForName(game.activeTitle),
                        ),
                      ),
                    // Name + gender icon + level badge
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  hero.name.toUpperCase(),
                                  style: AppTheme.pixelHeading(
                                    fontSize: isPhone ? 12 : 15,
                                    letterSpacing: 1.5,
                                    color: CosmeticItem.nameColorFor(game.activeNameColor)
                                        ?? AppTheme.accentGold,
                                  ).copyWith(
                                    shadows: CosmeticItem.hasGlow(game.activeNameColor)
                                        ? [Shadow(
                                            color: CosmeticItem.nameColorFor(game.activeNameColor)!,
                                            blurRadius: 10)]
                                        : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                hero.gender.icon,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: (raceColor ?? AppTheme.accentGold).withValues(alpha: 0.7),
                                ),
                              ),
                              if (game.heroRace != null) ...[
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => _showRacePopup(context, game.heroRace!),
                                  child: Text(
                                    game.heroRace!.info.icon,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        _LevelBadge(level: hero.level),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Class + prestige badge
                    Row(
                      children: [
                        Text(
                          '${hero.heroClass.displayName.toUpperCase()}'
                          '${game.heroRace != null ? "  (${game.heroRace!.info.displayName})" : ""}',
                          style: AppTheme.pixelHeading(
                            fontSize: 10,
                            color: AppTheme.textMuted,
                            letterSpacing: 2,
                          ),
                        ),
                        if (game.prestigeLevel > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFcc8844).withValues(alpha: 0.15),
                              border: Border.all(
                                  color: const Color(0xFFcc8844).withValues(alpha: 0.7)),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              '✦ REBIRTH LV.${game.prestigeLevel}',
                              style: AppTheme.pixelHeading(
                                fontSize: 9,
                                color: const Color(0xFFcc8844),
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    // Subclass specialization (level 50+)
                    if (game.activeSubclass != null) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: game.activeSubclass!.spriteSwatch,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                    color: game.activeSubclass!.spriteSwatch
                                        .withValues(alpha: 0.6),
                                    blurRadius: 4),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Text(
                              game.activeSubclass!.name.toUpperCase(),
                              style: AppTheme.pixelHeading(
                                fontSize: 9,
                                color: game.activeSubclass!.spriteSwatch,
                                letterSpacing: 1.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Medieval Power
                    const SizedBox(height: 3),
                    Tooltip(
                      message: 'Medieval Power — combined score of all your upgrades,\ngear, passives, prestige, artifacts, and allies.',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: game.medievalPowerColor.withValues(alpha: 0.10),
                          border: Border.all(color: game.medievalPowerColor.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('⚜', style: TextStyle(fontSize: 10, color: game.medievalPowerColor)),
                            const SizedBox(width: 4),
                            Text('${game.medievalPower}',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: game.medievalPowerColor)),
                            const SizedBox(width: 4),
                            Text(game.medievalPowerLabel,
                                style: TextStyle(fontSize: 9, color: game.medievalPowerColor.withValues(alpha: 0.7))),
                          ],
                        ),
                      ),
                    ),
                    // (Damage type is set by class/abilities, no manual chips)

                    // Prestige milestone title
                    if (game.prestigeTitle != null) ...[
                      const SizedBox(height: 3),
                      Row(children: [
                        Text(
                          '${game.prestigeTitle!.$2} ${game.prestigeTitle!.$1}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFddaa55),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ]),
                    ],
                    const SizedBox(height: 10),

                    // HP bar
                    Tooltip(
                      message: 'Health Points — reach 0 and you lose the battle.\nRegen: ${game.hero.constitution * 3 + game.passiveTree.totalOf(PassiveEffect.regenFlat)} HP/round',
                      child: _BarLabel(
                        label: 'HP',
                        current: hero.currentHealth,
                        max: hero.maxHealth,
                        color: inDanger ? const Color(0xFFee3030) : const Color(0xFF66cc44),
                      ),
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
                    Tooltip(
                      message: 'Experience — reach ${hero.experienceToNextLevel} to level up.\nLevel ${hero.level} → ${hero.level + 1}',
                      child: _BarLabel(
                        label: 'XP',
                        current: hero.experience,
                        max: hero.experienceToNextLevel,
                        color: AppTheme.accentGold,
                      ),
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

          const SizedBox(height: 8),
          // ── Idle progress panel ───────────────────────────────────────────
          _IdleProgressPanel(game: game),
          // Next-action guidance is shown once, by _SmartNextActionPanel on the
          // dashboard body (see dashboard_screen.dart).
        ],
      ),
    );
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
    final game = GameStateProvider.of(context);
    final xpFrac = game.hero.experienceToNextLevel > 0
        ? (game.hero.experience / game.hero.experienceToNextLevel).clamp(0.0, 1.0)
        : 0.0;
    return ProgressRing(
      progress: xpFrac,
      label: '$level',
      sublabel: 'LV',
      size: 42,
      strokeWidth: 3,
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
            style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 1, color: color)),
        Text(
          '$current / $max',
          style: GoogleFonts.rajdhani(
              fontSize: 10, color: color.withValues(alpha: 0.75)),
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
// _IdleProgressPanel
//
// Shows idle progress as a mini combat scene:
//   • hero sprite (left) vs last defeated campaign enemy (right)
//   • progress segments, resource rewards per cycle
// ─────────────────────────────────────────────────────────────────────────────

class _IdleProgressPanel extends StatefulWidget {
  const _IdleProgressPanel({required this.game});
  final GameState game;

  @override
  State<_IdleProgressPanel> createState() => _IdleProgressPanelState();
}

class _IdleProgressPanelState extends State<_IdleProgressPanel>
    with TickerProviderStateMixin {
  static const _barColor     = Color(0xFF88cc44);
  static const _idleSegments = 12;

  final _heroKey  = GlobalKey<BattleSpriteState>();
  final _enemyKey = GlobalKey<BattleSpriteState>();

  late final AnimationController _clashCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  Timer? _clashTimer;

  @override
  void initState() {
    super.initState();
    // Fire first clash after 15 s, then repeat every 15 s.
    _clashTimer = Timer.periodic(const Duration(seconds: 15), (_) => _playClash());
  }

  @override
  void dispose() {
    _clashTimer?.cancel();
    _clashCtrl.dispose();
    super.dispose();
  }

  Future<void> _playClash() async {
    if (!mounted) return;
    _heroKey.currentState?.playAttack();
    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    _clashCtrl.forward(from: 0);
    _enemyKey.currentState?.playHit();
    await Future.delayed(const Duration(milliseconds: 380));
    if (!mounted) return;
    _enemyKey.currentState?.playAttack();
    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    _heroKey.currentState?.playHit();
  }

  @override
  Widget build(BuildContext context) {
    final game      = widget.game;
    final fill      = game.idleFillRatio;
    final goldMin   = game.idleGoldPerMinute;
    final essMin    = game.idleEssencePerCycle;
    final xpMin     = game.idleXpPerCycle;
    final enemyName = game.campaignStageIndex > 0 ? game.idleEnemyName : '—';

    final canCollect = fill > 0;

    void collect() {
      if (!canCollect) return;
      game.collectIdleRewards();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFdaa520), width: 1.5),
          ),
          title: Text('⚡ IDLE REWARDS',
              textAlign: TextAlign.center,
              style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2, color: const Color(0xFFdaa520))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IdleRewardRow('💰 Gold', '+${AppTheme.fmtNumber(game.lastIdleGold)}', const Color(0xFFdaa520)),
              if (game.lastIdleEssence > 0)
                _IdleRewardRow('◆ Shards', '+${game.lastIdleEssence}', const Color(0xFF6699ff)),
              _IdleRewardRow('⚡ XP', '+${AppTheme.fmtNumber(game.lastIdleXp)}', const Color(0xFFffcc44)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('NICE', style: AppTheme.pixelHeading(fontSize: 11, color: const Color(0xFFdaa520))),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: canCollect ? collect : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkBg,
          border: Border.all(
            color: canCollect
                ? const Color(0xFFdaa520).withValues(alpha: 0.7)
                : AppTheme.cardBorder,
            width: canCollect ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            // ── IDLE label + collect hint ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '⚡ IDLE',
                    style: AppTheme.pixelHeading(
                        fontSize: 8, letterSpacing: 1,
                        color: AppTheme.textMuted),
                  ),
                  if (canCollect) ...[
                    const SizedBox(width: 6),
                    Text(
                      '• TAP TO COLLECT',
                      style: AppTheme.pixelHeading(
                          fontSize: 7, letterSpacing: 1,
                          color: const Color(0xFFdaa520)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 1),

            // ── Enemy name ─────────────────────────────────────────────────
            Text(
              enemyName.toUpperCase(),
              style: AppTheme.pixelHeading(
                  fontSize: 8, letterSpacing: 1, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 2),

            // ── Progress bar with sprites flanking ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Hero sprite — left (FittedBox keeps it in bounds)
                  SizedBox(
                    width: 24,
                    height: 36,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: BattleSprite(
                        key: _heroKey,
                        spriteId: game.heroBattleSpriteId,
                        gender: game.hero.gender,
                        colorFilter: game.heroSpriteFilter,
                        auraColor: game.heroAuraColor,
                        auraIntensity: game.heroAuraIntensity,
                      ),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(begin: 0, end: -1, duration: 900.ms, curve: Curves.easeInOut),

                  const SizedBox(width: 4),

                  // Progress bar + clash icon in center
                  Expanded(
                    child: SizedBox(
                      height: 14,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _SegmentedBar(
                              value: fill,
                              color: _barColor,
                              segments: _idleSegments,
                              height: 4),
                          AnimatedBuilder(
                            animation: _clashCtrl,
                            builder: (_, child) {
                              final t     = _clashCtrl.value;
                              final flash = t < 0.4 ? t / 0.4 : (1 - t) / 0.6;
                              final scale = 1.0 + flash * 0.6;
                              return Transform.scale(
                                scale: scale,
                                child: Opacity(
                                  opacity: (0.6 + flash * 0.4).clamp(0.0, 1.0),
                                  child: child,
                                ),
                              );
                            },
                            child: const Text('⚔', style: TextStyle(fontSize: 10))
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .scale(
                                    begin: const Offset(0.85, 0.85),
                                    end: const Offset(1.1, 1.1),
                                    duration: 700.ms,
                                    curve: Curves.easeInOut),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Enemy sprite — right (FittedBox keeps it in bounds)
                  SizedBox(
                    width: 24,
                    height: 36,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: BattleSprite(
                        key: _enemyKey,
                        spriteId: game.idleEnemySpriteId,
                        facingLeft: true,
                      ),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(begin: 0, end: -1, duration: 1100.ms, curve: Curves.easeInOut),
                ],
              ),
            ),
            const SizedBox(height: 3),

            // ── Rewards row ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RewardChip('💰', '${AppTheme.fmtNumber(goldMin)}g', AppTheme.accentGold),
                  if (essMin > 0) ...[
                    const SizedBox(width: 8),
                    _RewardChip('✦', '+$essMin', const Color(0xFF44dd88)),
                  ],
                  const SizedBox(width: 8),
                  _RewardChip('✨', '+$xpMin XP', const Color(0xFF88aaff)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip(this.icon, this.value, this.color);
  final String icon;
  final String value;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(icon, style: TextStyle(fontSize: 10, color: color)),
      const SizedBox(width: 3),
      Text(value,
          style: GoogleFonts.rajdhani(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color)),
    ]);
  }
}


Widget _IdleRewardRow(String label, String value, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: color)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    ),
  );
}


import 'dart:math';
import 'package:flutter/material.dart';
import '../models/damage_type.dart';
import 'game_icons.dart';
import '../models/hero_ability.dart' show AbilityEffect;
import '../services/game_state.dart';
import '../models/dnd_class.dart';
import '../models/hero_model.dart' show HeroGender;
import '../models/hero_race.dart';
import '../theme/app_theme.dart';
import '../utils/format_number.dart';
import 'ability_icon.dart';
import 'battle_backgrounds.dart';
import 'battle_sprites.dart';
import 'pixel_health_bar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BattleArena — reusable visual arena widget used by BattleScreen, Gauntlet,
// BossRush, and any other mode that wants the full sprite/animation treatment.
//
// Callers drive combat by calling BattleArenaState methods via GlobalKey:
//   playHeroAttack(damage, {isCrit, heroClass})
//   playEnemyAttack(damage)
//   playEnemyDeath()
//
// HP values and enemy data are props — parent calls setState to update them.
// ─────────────────────────────────────────────────────────────────────────────

class BattleArena extends StatefulWidget {
  const BattleArena({
    super.key,
    // Hero
    required this.heroName,
    required this.heroLevel,
    required this.heroCurrentHp,
    required this.heroMaxHp,
    required this.heroAttack,
    required this.heroSpriteId,
    this.heroGender,
    this.heroRace,
    this.heroAuraColor,
    this.heroAuraIntensity = 1.0,
    this.heroColorFilter,
    this.heroPet,
    // Enemy
    required this.enemyName,
    required this.enemyLevel,
    required this.enemyCurrentHp,
    required this.enemyMaxHp,
    required this.enemyAttack,
    required this.enemyId,
    this.enemyColorFilter,
    this.stageIndex = 0,
    // Context
    this.headerLabel,
    this.isBoss = false,
    this.isBossEnraged = false,
    this.affixWidget,
    this.enemyAuraColor,
    this.heroDamageType = DamageType.physical,
    this.enemyAttackType = DamageType.physical,
    this.enemyResistances = const {},
    this.heroBuffGlows = const [],
    this.enemyDebuffGlows = const [],
    this.heroCritPct,
    this.heroArmor,
  });


  final String heroName, heroSpriteId;
  final HeroGender? heroGender;
  final HeroRace?   heroRace;
  final int    heroLevel, heroCurrentHp, heroMaxHp, heroAttack;
  final Color?       heroAuraColor;
  final double       heroAuraIntensity;
  final ColorFilter? heroColorFilter;
  final Widget?      heroPet;

  final String enemyName, enemyId;
  final ColorFilter? enemyColorFilter;
  final int    enemyLevel, enemyCurrentHp, enemyMaxHp, enemyAttack;
  final int    stageIndex;

  final String? headerLabel;
  final bool    isBoss, isBossEnraged;
  final Widget? affixWidget;
  final Color?  enemyAuraColor;
  final DamageType heroDamageType;
  final DamageType enemyAttackType;
  final Map<DamageType, int> enemyResistances;
  final List<Color> heroBuffGlows;
  final List<Color> enemyDebuffGlows;
  final int? heroCritPct;
  final int? heroArmor;

  @override
  State<BattleArena> createState() => BattleArenaState();
}

class BattleArenaState extends State<BattleArena> with TickerProviderStateMixin {
  final _heroKey   = GlobalKey<BattleSpriteState>();
  final _enemyKey  = GlobalKey<BattleSpriteState>();

  late final AnimationController _shakeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 280));
  late final AnimationController _burstCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420));

  // Step 3 — low-HP danger vignette (repeats while HP is low)
  late final AnimationController _dangerCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));

  // Step 4 — VS text bounce on new enemy
  late final AnimationController _vsCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 650), value: 1.0);

  // Step 5 — boss intro flash
  late final AnimationController _bossFlashCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));

  // Enemy fade between battles
  late final AnimationController _enemyFadeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 220), value: 1.0);

  // Ability banner + edge flash
  late final AnimationController _bannerCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));

  // Elemental hit tint — brief edge vignette in the damage type's colour
  late final AnimationController _elemFlashCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 320));
  Color _elemFlashColor = Colors.white;
  String _bannerText  = '';
  String _bannerId    = '';
  Color  _bannerColor = Colors.white;

  static Color _effectColor(AbilityEffect e) => switch (e) {
    AbilityEffect.bonusDamage      => const Color(0xFFff6633),
    AbilityEffect.heal             => const Color(0xFF44cc66),
    AbilityEffect.attackBonus      => const Color(0xFFffcc00),
    AbilityEffect.acBonus          => const Color(0xFF66aaff),
    AbilityEffect.stun             => const Color(0xFFcc44ff),
    AbilityEffect.dot              => const Color(0xFF88dd00),
    AbilityEffect.dodge            => const Color(0xFF44ddcc),
    AbilityEffect.aura             => const Color(0xFF55eebb),
    AbilityEffect.debuffWeaken     => const Color(0xFFff8844),
    AbilityEffect.debuffVulnerable => const Color(0xFFdd44aa),
    AbilityEffect.silence          => const Color(0xFFffdd00),
    AbilityEffect.absorbShield     => const Color(0xFF66bbff),
    AbilityEffect.missChance       => const Color(0xFFaaaaff),
  };

  Future<void> fadeEnemyOut() async {
    await _enemyFadeCtrl.animateTo(0.0, curve: Curves.easeIn);
  }

  final List<_FloatEntry> _floaters = [];
  final _rng = Random();
  Size _arenaSize = Size.zero;

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _burstCtrl.dispose();
    _dangerCtrl.dispose();
    _vsCtrl.dispose();
    _bossFlashCtrl.dispose();
    _enemyFadeCtrl.dispose();
    _bannerCtrl.dispose();
    _elemFlashCtrl.dispose();
    for (final f in _floaters) f.ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BattleArena oldWidget) {
    super.didUpdateWidget(oldWidget);

    // VS bounce + boss flash + enemy fade-in on new enemy
    if (widget.enemyId != oldWidget.enemyId) {
      _vsCtrl.forward(from: 0.0);
      if (widget.isBoss) _bossFlashCtrl.forward(from: 0.0);
      _enemyFadeCtrl.animateTo(1.0, curve: Curves.easeOut);
    }

    // Danger vignette: start/stop based on HP ratio
    final hpRatio = widget.heroMaxHp > 0
        ? widget.heroCurrentHp / widget.heroMaxHp
        : 1.0;
    if (hpRatio < 0.25 && !_dangerCtrl.isAnimating) {
      _dangerCtrl.repeat(reverse: true);
    } else if (hpRatio >= 0.25 && _dangerCtrl.isAnimating) {
      _dangerCtrl.stop();
      _dangerCtrl.value = 0.0;
    }
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  Future<void> playHeroAttack(int damage,
      {bool isCrit = false, DndClass? heroClass,
       DamageType damageType = DamageType.physical}) async {
    _heroKey.currentState?.playAttack();
    final isWeak = (widget.enemyResistances[damageType] ?? 0) < 0;
    _spawnFloat(damage, isCrit: isCrit, onEnemy: true, damageType: damageType, isWeak: isWeak);
    // Elemental screen tint on non-physical hits
    if (damageType != DamageType.physical) {
      _elemFlashColor = damageType.color;
      _elemFlashCtrl.forward(from: 0);
    }
    // Screen shake scaled by impact: crits shake hard, big hits shake a little
    final bigHit = widget.enemyMaxHp > 0 && damage >= widget.enemyMaxHp * 0.12;
    if (isCrit) {
      _shakeCtrl.forward(from: 0.35);
    } else if (bigHit) {
      _shakeCtrl.forward(from: 0.65);
    }
    // Sync the impact with the lunge's strike frame (~55% of 460ms)
    await Future.delayed(const Duration(milliseconds: 250));
    if (mounted) {
      _enemyKey.currentState?.playHit(heavy: isCrit || bigHit);
    }
  }

  void addExtraFloat(int value,
      {bool isHeal = false, DamageType type = DamageType.physical}) {
    if (isHeal) {
      final ctrl = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 900));
      final entry = _FloatEntry(
          ctrl: ctrl,
          text: '+${fmtNum(value)}',
          color: const Color(0xFF44ee88),
          isCrit: false,
          onEnemy: false);
      setState(() => _floaters.add(entry));
      ctrl.forward().then((_) {
        if (mounted) {
          setState(() { _floaters.remove(entry); entry.ctrl.dispose(); });
        }
      });
    } else {
      _spawnFloat(value, isCrit: false, onEnemy: true, damageType: type);
    }
  }

  Future<void> playEnemyAttack(int damage,
      {DamageType damageType = DamageType.physical}) async {
    _enemyKey.currentState?.playAttack();
    // Wait through the windup so the hit lands on the strike frame
    await Future.delayed(const Duration(milliseconds: 250));
    if (mounted) {
      final bigHit = widget.heroMaxHp > 0 && damage >= widget.heroMaxHp * 0.15;
      _heroKey.currentState?.playHit(heavy: bigHit);
      if (bigHit) _shakeCtrl.forward(from: 0.55);
      _spawnFloat(damage, isCrit: false, onEnemy: false, damageType: damageType);
    }
  }

  void playEnemyDeath() {
    _shakeCtrl.forward(from: 0);
    _enemyKey.currentState?.playDeath();
    Future.delayed(const Duration(milliseconds: 280), () {
      if (mounted) _burstCtrl.forward(from: 0);
    });
  }

  Future<void> playHeroDeath() async {
    await _heroKey.currentState?.playDeath();
  }

  void playAbilityBanner(String name, AbilityEffect effect, {String id = ''}) {
    _bannerText  = name.toUpperCase();
    _bannerId    = id;
    _bannerColor = _effectColor(effect);
    _bannerCtrl.forward(from: 0);
  }

  // ── Internal ─────────────────────────────────────────────────────────────────

  void _spawnFloat(int damage,
      {required bool isCrit, required bool onEnemy,
       DamageType damageType = DamageType.physical,
       bool isWeak = false}) {
    if (damage <= 0) return;
    if (!GameStateProvider.of(context).showDamageNumbers) return;
    final Color baseColor;
    if (isCrit) {
      // Crits: bright gold with slight type tint
      baseColor = damageType != DamageType.physical
          ? Color.lerp(const Color(0xFFffdd00), damageType.color, 0.3)!
          : const Color(0xFFffdd00);
    } else if (isWeak) {
      baseColor = Color.lerp(damageType.color, Colors.white, 0.35)!;
    } else if (damageType != DamageType.physical) {
      baseColor = damageType.color;
    } else {
      baseColor = onEnemy ? const Color(0xFFff6644) : const Color(0xFF88ccff);
    }
    final ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    final weakTag = isWeak && !isCrit ? ' WEAK!' : '';
    final label = isCrit ? '${fmtNum(damage)}!' : '${fmtNum(damage)}$weakTag';
    // Crits arc outward; normal hits drift gently
    final driftX = isCrit
        ? (28.0 + _rng.nextDouble() * 24.0) * (onEnemy ? 1 : -1)
        : (_rng.nextDouble() - 0.5) * 52.0;
    // Bigger hits get bigger numbers (relative to the target's max HP)
    final targetMax = onEnemy ? widget.enemyMaxHp : widget.heroMaxHp;
    final frac = targetMax > 0 ? damage / targetMax : 0.0;
    final sizeScale = (1.0 + frac * 2.5).clamp(1.0, 1.6);
    final entry = _FloatEntry(
        ctrl: ctrl,
        text: label,
        color: baseColor,
        isCrit: isCrit,
        onEnemy: onEnemy,
        driftX: driftX,
        sizeScale: sizeScale);
    setState(() => _floaters.add(entry));
    ctrl.forward().then((_) {
      if (mounted) {
        setState(() {
          _floaters.remove(entry);
          entry.ctrl.dispose();
        });
      }
    });
  }

  Offset _shakeOffset() {
    if (!_shakeCtrl.isAnimating && _shakeCtrl.value == 0) return Offset.zero;
    final v = _shakeCtrl.value;
    final intensity = (1 - v) * 7.0;
    return Offset(sin(v * pi * 7) * intensity,
        sin(v * pi * 5 + 1.2) * intensity * 0.6);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shakeCtrl, _burstCtrl]),
      builder: (_, child) =>
          Transform.translate(offset: _shakeOffset(), child: child),
      child: LayoutBuilder(
        builder: (_, constraints) {
          _arenaSize = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            children: [
              // Background
              Positioned.fill(
                  child:
                      CustomPaint(painter: battleBackgroundFor(widget.stageIndex))),
              // Vignette + border
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.45)
                      ],
                    ),
                    border: const Border(
                        bottom: BorderSide(
                            color: AppTheme.pixelBorderBright, width: 2)),
                  ),
                ),
              ),
              // Step 3 — low-HP danger vignette
              if (widget.heroMaxHp > 0 &&
                  widget.heroCurrentHp / widget.heroMaxHp < 0.25)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _dangerCtrl,
                      builder: (_, __) => CustomPaint(
                        painter: _DangerVignettePainter(_dangerCtrl.value),
                      ),
                    ),
                  ),
                ),
              // Arena content
              Column(
                children: [
                  if (widget.headerLabel != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF241910),
                        border: Border.fromBorderSide(
                            BorderSide(color: AppTheme.accentGold, width: 1)),
                      ),
                      child: Text(widget.headerLabel!,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.accentGold,
                              letterSpacing: 2)),
                    ),
                  ],
                  if (widget.isBoss) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      color: widget.isBossEnraged
                          ? const Color(0xFF5a0000)
                          : const Color(0xFF2a0040),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.dangerous_outlined, size: 13,
                              color: widget.isBossEnraged ? const Color(0xFFff4444) : const Color(0xFFcc44ff)),
                          const SizedBox(width: 8),
                          Text(
                            widget.isBossEnraged
                                ? 'BOSS ENRAGED!'
                                : 'BOSS BATTLE',
                            style: TextStyle(
                              color: widget.isBossEnraged
                                  ? const Color(0xFFff4444)
                                  : const Color(0xFFcc44ff),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.dangerous_outlined, size: 13,
                              color: widget.isBossEnraged ? const Color(0xFFff4444) : const Color(0xFFcc44ff)),
                        ],
                      ),
                    ),
                  ],
                  if (widget.affixWidget != null) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: widget.affixWidget!,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _CombatantPanel(
                          name: widget.heroName,
                          level: widget.heroLevel,
                          currentHp: widget.heroCurrentHp,
                          maxHp: widget.heroMaxHp,
                          attack: widget.heroAttack,
                          sprite: BattleSprite(
                            key: _heroKey,
                            spriteId: widget.heroSpriteId,
                            facingLeft: false,
                            gender: widget.heroGender,
                            race: widget.heroRace,
                            auraColor: widget.heroAuraColor,
                            auraIntensity: widget.heroAuraIntensity,
                            colorFilter: widget.heroColorFilter,
                            buffGlows: widget.heroBuffGlows,
                          ),
                          petWidget: widget.heroPet,
                          nameColor: const Color(0xFF4ad46a),
                          alignRight: false,
                          critPct: widget.heroCritPct,
                          armor: widget.heroArmor,
                        ),
                        // Step 4 — VS bounce on new enemy
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: AnimatedBuilder(
                            animation: _vsCtrl,
                            builder: (_, child) {
                              final scale = _vsCtrl.value < 1.0
                                  ? Curves.elasticOut
                                      .transform(_vsCtrl.value)
                                      .clamp(0.0, 1.6)
                                  : 1.0;
                              return Transform.scale(scale: scale, child: child);
                            },
                            child: const Text('VS',
                                style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.accentGold,
                                    letterSpacing: 2)),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _enemyFadeCtrl,
                          builder: (_, child) => Opacity(
                            opacity: _enemyFadeCtrl.value,
                            child: child,
                          ),
                          child: _CombatantPanel(
                            name: widget.enemyName,
                            level: widget.enemyLevel,
                            currentHp: widget.enemyCurrentHp,
                            maxHp: widget.enemyMaxHp,
                            attack: widget.enemyAttack,
                            sprite: BattleSprite(
                              key: _enemyKey,
                              spriteId: widget.enemyId,
                              facingLeft: true,
                              auraColor: widget.enemyAuraColor,
                              buffGlows: widget.enemyDebuffGlows,
                              colorFilter: widget.enemyColorFilter,
                            ),
                            nameColor: const Color(0xFFee4040),
                            alignRight: true,
                            damageType: widget.enemyAttackType,
                            resistances: widget.enemyResistances,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: AppTheme.pixelBorderBright,
                  ),
                  const SizedBox(height: 4),
                ],
              ),
              // Step 5 — boss intro flash (purple-white slam)
              AnimatedBuilder(
                animation: _bossFlashCtrl,
                builder: (_, __) {
                  final t = _bossFlashCtrl.value;
                  if (t <= 0 || t >= 1) return const SizedBox.shrink();
                  return Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _BossFlashPainter(t),
                      ),
                    ),
                  );
                },
              ),
              // Ability name banner
              AnimatedBuilder(
                animation: _bannerCtrl,
                builder: (_, __) {
                  final t = _bannerCtrl.value;
                  if (t <= 0 || !_bannerCtrl.isAnimating && t >= 1) {
                    return const SizedBox.shrink();
                  }
                  // Phase 0–0.25: scale in (elastic), 0.25–0.65: hold, 0.65–1.0: rise + fade
                  final scaleT = (t / 0.25).clamp(0.0, 1.0);
                  final scale  = Curves.elasticOut.transform(scaleT).clamp(0.0, 1.5);
                  final fadeT  = ((t - 0.65) / 0.35).clamp(0.0, 1.0);
                  final opacity = (1.0 - fadeT).clamp(0.0, 1.0);
                  final riseY  = fadeT * 28.0;
                  return Positioned(
                    left: 0, right: 0,
                    top: _arenaSize.height * 0.42 - riseY,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: scale,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_bannerId.isNotEmpty) ...[
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _bannerColor.withValues(alpha: 0.6),
                                        blurRadius: 14,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: AbilityIcon(abilityId: _bannerId, size: 52),
                                ),
                                const SizedBox(height: 6),
                              ],
                              // Glow halo behind text
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _bannerColor.withValues(alpha: 0.12),
                                  border: Border.symmetric(
                                    horizontal: BorderSide(
                                        color: _bannerColor.withValues(alpha: 0.55),
                                        width: 1),
                                  ),
                                ),
                                child: Text(
                                  _bannerText,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: _bannerColor,
                                    letterSpacing: 2.5,
                                    shadows: [
                                      Shadow(
                                          color: _bannerColor.withValues(alpha: 0.9),
                                          blurRadius: 12),
                                      const Shadow(
                                          color: Colors.black,
                                          blurRadius: 4,
                                          offset: Offset(1, 1)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Edge flash matching ability color
              AnimatedBuilder(
                animation: _bannerCtrl,
                builder: (_, __) {
                  final t = _bannerCtrl.value;
                  if (t <= 0 || t >= 0.45) return const SizedBox.shrink();
                  final alpha = t < 0.15
                      ? (t / 0.15) * 0.22
                      : ((0.45 - t) / 0.30) * 0.22;
                  return Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _AbilityEdgeFlashPainter(
                            _bannerColor, alpha.clamp(0.0, 0.22)),
                      ),
                    ),
                  );
                },
              ),
              // Elemental hit tint — quick edge vignette in the damage colour
              AnimatedBuilder(
                animation: _elemFlashCtrl,
                builder: (_, __) {
                  final t = _elemFlashCtrl.value;
                  if (t <= 0 || t >= 1) return const SizedBox.shrink();
                  final alpha = sin(t * pi) * 0.16;
                  return Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _AbilityEdgeFlashPainter(
                            _elemFlashColor, alpha.clamp(0.0, 0.16)),
                      ),
                    ),
                  );
                },
              ),
              // Death burst overlay
              if (_burstCtrl.isAnimating || _burstCtrl.value > 0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _DeathBurstPainter(
                        _burstCtrl.value,
                        _arenaSize.width * 0.72,
                        _arenaSize.height * 0.60,
                      ),
                    ),
                  ),
                ),
              // Floating damage numbers
              ..._floaters.map(_buildFloat),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFloat(_FloatEntry f) {
    return AnimatedBuilder(
      animation: f.ctrl,
      builder: (_, __) {
        final t = f.ctrl.value;

        // Fade out in last 30%
        final alpha = t < 0.7 ? 1.0 : (1 - (t - 0.7) / 0.3);

        // Crits fly a gravity arc (up fast, then fall); normal hits rise
        final rise  = f.isCrit ? 130.0 * t - 95.0 * t * t : t * 80.0;
        final drift = f.driftX * t;

        // Scale: elastic pop in first 45%, then hold at 1.0
        final scaleFrac = (t / 0.45).clamp(0.0, 1.0);
        final scale = f.isCrit
            ? Curves.elasticOut.transform(scaleFrac)
            : Curves.easeOutBack.transform(scaleFrac);

        // Crits: brief rotation wobble that damps out quickly
        final rotation = f.isCrit
            ? sin(t * pi * 5) * (1 - min(1.0, t * 3.5)) * 0.18
            : 0.0;

        // Derive sprite centers from actual panel layout:
        // Row(spaceEvenly) with hero(140dp) + VS(~32dp) + enemy(140dp)
        const panelW = 140.0;
        const vsW    = 32.0;
        final gap   = (_arenaSize.width - 2 * panelW - vsW) / 4;
        final heroX  = gap + panelW / 2;
        final enemyX = _arenaSize.width - gap - panelW / 2;
        final cx = f.onEnemy ? enemyX : heroX;
        final cy = _arenaSize.height * 0.62 - rise;

        return Positioned(
          left: cx + drift - (f.isCrit ? 40 : 26),
          top:  cy - 16,
          child: IgnorePointer(
            child: Opacity(
              opacity: alpha.clamp(0.0, 1.0),
              child: Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scale: scale.clamp(0.0, 2.0),
                  child: Text(
                    f.text,
                    style: TextStyle(
                      fontSize: (f.isCrit ? 28 : 18) * f.sizeScale,
                      fontWeight: FontWeight.bold,
                      color: f.color,
                      shadows: [
                        const Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
                        const Shadow(color: Colors.black, blurRadius: 4, offset: Offset(-1, -1)),
                        if (f.isCrit)
                          Shadow(color: f.color.withValues(alpha: 0.7), blurRadius: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BattleLogBox — reusable battle log used by BattleScreen, Gauntlet, BossRush
// ─────────────────────────────────────────────────────────────────────────────

class BattleLogBox extends StatelessWidget {
  const BattleLogBox({super.key, required this.log, this.height = 130});
  final List<String> log;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFF17150E),
        border:
            Border(top: BorderSide(color: AppTheme.pixelBorder, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            color: const Color(0xFF211E1A),
            child: const Text('BATTLE LOG',
                style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.accentGold,
                    letterSpacing: 2)),
          ),
          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              reverse: true,
              children:
                  log.reversed.take(8).map((e) => _LogLine(text: e)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helpers
// ─────────────────────────────────────────────────────────────────────────────

class _FloatEntry {
  _FloatEntry({
    required this.ctrl,
    required this.text,
    required this.color,
    required this.isCrit,
    required this.onEnemy,
    this.driftX = 0.0,
    this.sizeScale = 1.0,
  });
  final AnimationController ctrl;
  final String text;
  final Color  color;
  final bool   isCrit, onEnemy;
  final double driftX;    // horizontal drift in pixels over the full animation
  final double sizeScale; // font scale from damage magnitude (1.0–1.6)
}

class _DeathBurstPainter extends CustomPainter {
  const _DeathBurstPainter(this.t, this.cx, this.cy);
  final double t, cx, cy;

  @override
  void paint(Canvas canvas, Size size) {
    final rng   = Random(1337);
    const count = 26;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final angle  = rng.nextDouble() * pi * 2;
      final speed  = 60 + rng.nextDouble() * 110;
      final startR = 8 + rng.nextDouble() * 12;
      final dist   = startR + t * speed;
      // Gravity: particles arc downward as they fly out
      final px     = cx + cos(angle) * dist;
      final py     = cy + sin(angle) * dist + 70.0 * t * t;
      final sz     = (1 - t) * (3 + rng.nextDouble() * 7);
      final alpha  = (1 - t * t).clamp(0.0, 1.0);
      const colors = [
        0xFFffcc44, 0xFFff8820, 0xFFee3030, 0xFFffffff, 0xFFdd60ff
      ];
      paint.color =
          Color(colors[i % colors.length]).withValues(alpha: alpha);
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset(px, py), width: sz, height: sz),
          paint);
    }
    final ringAlpha = (1 - t * 1.5).clamp(0.0, 1.0);
    if (ringAlpha > 0) {
      paint
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 3 * (1 - t)
        ..color       = const Color(0xFFffdd88).withValues(alpha: ringAlpha);
      canvas.drawCircle(Offset(cx, cy), 12 + t * 50, paint);
    }
  }

  @override
  bool shouldRepaint(_DeathBurstPainter old) => old.t != t;
}

GameIconType _dmgIcon(DamageType t) => switch (t) {
  DamageType.physical  => GameIconType.fist,
  DamageType.fire      => GameIconType.flame,
  DamageType.cold      => GameIconType.snowflake,
  DamageType.lightning => GameIconType.bolt,
  DamageType.poison    => GameIconType.flask,
  DamageType.void_     => GameIconType.moon,
};

class _CombatantPanel extends StatelessWidget {
  const _CombatantPanel({
    required this.name,
    required this.level,
    required this.currentHp,
    required this.maxHp,
    required this.attack,
    required this.sprite,
    required this.nameColor,
    required this.alignRight,
    this.petWidget,
    this.damageType,
    this.resistances,
    this.critPct,
    this.armor,
  });

  final String  name;
  final int     level, currentHp, maxHp, attack;
  final Widget  sprite;
  final Color   nameColor;
  final bool    alignRight;
  final Widget? petWidget;
  final DamageType?           damageType;
  final Map<DamageType, int>? resistances;
  final int?    critPct;   // shown on hero panel
  final int?    armor;     // shown on hero panel

  @override
  Widget build(BuildContext context) {
    final Widget spriteRow;
    if (petWidget != null) {
      // Pet renders in front of the hero (higher z-order — last in Stack).
      // Clip.none lets the pet overflow left without affecting layout sizing.
      spriteRow = Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          sprite,
          Positioned(bottom: 0, right: 42, child: petWidget!),
        ],
      );
    } else {
      spriteRow = sprite;
    }

    // Resistance badges (only non-zero entries, sorted strongest first)
    final resList = (resistances?.entries.toList() ?? [])
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));
    final resBadges = resList.map((e) {
      final isVuln = e.value < 0;
      final color  = isVuln ? const Color(0xFFFF5555) : const Color(0xFF88AACC);
      final sign   = isVuln ? '' : '+';
      return Container(
        margin: const EdgeInsets.only(right: 3),
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          '${e.key.emoji}$sign${e.value}%',
          style: TextStyle(fontSize: 8, color: color, height: 1.1),
        ),
      );
    }).toList();

    return SizedBox(
      width: 140,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            name.toUpperCase(),
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: nameColor,
                letterSpacing: 1),
            maxLines: 2,
            overflow: TextOverflow.visible,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('LV.$level  HIT:${fmtNum(attack)}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
              if (damageType != null) ...[
                const SizedBox(width: 5),
                GameIcon(_dmgIcon(damageType!), size: 13, color: damageType!.color),
              ],
            ],
          ),
          // Hero-side stat chips: crit chance and armor
          if (critPct != null || armor != null) ...[
            const SizedBox(height: 3),
            Row(mainAxisSize: MainAxisSize.min, children: [
              if (critPct != null)
                _StatChip('CRIT $critPct%', const Color(0xFFffcc44)),
              if (critPct != null && armor != null)
                const SizedBox(width: 4),
              if (armor != null && armor! > 0)
                _StatChip('ARM $armor', const Color(0xFF88aacc)),
            ]),
          ],
          // Resistance/vulnerability row (shown for enemy panel)
          if (resBadges.isNotEmpty) ...[
            const SizedBox(height: 2),
            Wrap(spacing: 2, runSpacing: 2, children: resBadges),
          ],
          const SizedBox(height: 2),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 100),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomCenter,
                child: spriteRow,
              ),
            ),
          ),
          const SizedBox(height: 4),
          PixelHealthBar(current: currentHp, max: maxHp, height: 10),
          const SizedBox(height: 2),
          Text('${fmtNum(currentHp)} / ${fmtNum(maxHp)}',
              style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
          if (damageType != null && !alignRight) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: damageType!.color.withValues(alpha: 0.15),
                border: Border.all(color: damageType!.color.withValues(alpha: 0.55), width: 1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                damageType!.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  color: damageType!.color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LogLine extends StatelessWidget {
  const _LogLine({required this.text});
  final String text;

  static Color _colorFor(String t) {
    if (t.contains('CRITICAL HIT'))             return const Color(0xFFFFE14D);
    if (t.contains('LEGENDARY DROP'))           return const Color(0xFFdd66ff);
    if (t.contains('SET ITEM DROP'))            return const Color(0xFF44ccaa);
    if (t.contains('Item dropped'))             return const Color(0xFF80d0ff);
    if (t.contains('ENRAGES'))                  return const Color(0xFFee4444);
    if (t.contains('REBIRTH') || t.contains('ASCENSION')) return AppTheme.accentGold;
    if (t.contains('FIRE') || t.contains(' Fire '))      return const Color(0xFFFF6B35);
    if (t.contains('COLD') || t.contains(' Cold '))      return const Color(0xFF6CB4E4);
    if (t.contains('LTNG') || t.contains(' Lightning ')) return const Color(0xFFFFE14D);
    if (t.contains('POIS') || t.contains(' Poison '))    return const Color(0xFF7DCF6A);
    if (t.contains('VOID') || t.contains(' Void '))      return const Color(0xFF9966FF);
    if (t.contains('stunned'))                  return const Color(0xFFcc44ff);
    if (t.contains('weakened') || t.contains('ATK reduced')) return const Color(0xFFff4488);
    if (t.contains('vulnerable'))               return const Color(0xFFff8800);
    if (t.contains(' heals') || t.contains('regenerates') || t.contains('HP/round')) {
      return const Color(0xFF44cc66);
    }
    // Hero takes damage → red
    if ((t.contains('hits!') && t.contains(' dmg')) || t.contains('bleeds')) {
      return const Color(0xFFee4444);
    }
    // Kill reward / milestone → gold
    if (t.contains('was defeated!') || t.contains('BOSS DEFEATED') || t.contains('★ MILESTONE')) {
      return AppTheme.accentGold;
    }
    // Miss / dodge / block → muted
    if (t.contains('Miss!') || t.contains('dodges') || t.contains('evades') ||
        t.contains('sidesteps') || t.contains('fully absorbed') || t.contains('deflected') ||
        t.contains('phased through') || t.contains('reads the strike')) {
      return AppTheme.textMuted;
    }
    return AppTheme.textLight;
  }

  static bool _isBold(String t) =>
      t.contains('CRITICAL HIT') || t.contains('LEGENDARY') ||
      t.contains('SET ITEM') || t.contains('ENRAGES') ||
      t.contains('REBIRTH') || t.contains('ASCENSION') ||
      t.contains('BOSS DEFEATED') || t.contains('★ MILESTONE');

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(text);
    final bold  = _isBold(text);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('▸ ',
              style: TextStyle(
                  color: bold ? color : AppTheme.accentGold, fontSize: 11)),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }
}

// ── Step 3: Danger vignette painter ──────────────────────────────────────────

class _DangerVignettePainter extends CustomPainter {
  const _DangerVignettePainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final alpha = 0.12 + t * 0.28;
    final rect  = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.85,
          colors: [
            Colors.transparent,
            const Color(0xFFcc0000).withValues(alpha: alpha),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_DangerVignettePainter old) => old.t != t;
}

// ── Ability edge flash painter ────────────────────────────────────────────────

class _AbilityEdgeFlashPainter extends CustomPainter {
  const _AbilityEdgeFlashPainter(this.color, this.alpha);
  final Color  color;
  final double alpha;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [
            Colors.transparent,
            color.withValues(alpha: alpha),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_AbilityEdgeFlashPainter old) =>
      old.alpha != alpha || old.color != color;
}

// ── Step 5: Boss intro flash painter ─────────────────────────────────────────

class _BossFlashPainter extends CustomPainter {
  const _BossFlashPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // White slam that fades out fast (first 40%)
    if (t < 0.4) {
      final whiteAlpha = t < 0.12
          ? t / 0.12          // ramp up
          : (0.4 - t) / 0.28; // fade out
      canvas.drawRect(
        rect,
        Paint()..color = Colors.white.withValues(alpha: whiteAlpha * 0.85),
      );
    }

    // Purple tint lingers a bit longer (0.1 → 0.8)
    if (t > 0.1 && t < 0.8) {
      final purpleAlpha = t < 0.25
          ? (t - 0.1) / 0.15 * 0.35
          : (0.8 - t) / 0.55 * 0.35;
      canvas.drawRect(
        rect,
        Paint()..color = const Color(0xFF440088).withValues(alpha: purpleAlpha),
      );
    }

    // Expanding ring burst from center
    if (t > 0.05 && t < 0.7) {
      final ringT   = (t - 0.05) / 0.65;
      final ringR   = ringT * size.width * 0.65;
      final ringA   = (1 - ringT) * 0.7;
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        ringR,
        Paint()
          ..style       = PaintingStyle.stroke
          ..strokeWidth = 4 * (1 - ringT)
          ..color       = const Color(0xFFcc88ff).withValues(alpha: ringA),
      );
    }
  }

  @override
  bool shouldRepaint(_BossFlashPainter old) => old.t != t;
}

// ── Small stat chip used in the hero combatant panel ─────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip(this.label, this.color);
  final String label;
  final Color  color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Text(label,
        style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.bold)),
  );
}

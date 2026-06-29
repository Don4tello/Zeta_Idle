import 'dart:math';
import 'package:flutter/material.dart';
import '../models/hero_model.dart' show HeroGender;
import '../models/zone_affix.dart';

// ─────────────────────────────────────────────────────────────
// BattleSprite widget — call playAttack() / playHit() on state
// ─────────────────────────────────────────────────────────────

class BattleSprite extends StatefulWidget {
  const BattleSprite({
    super.key,
    required this.spriteId,
    this.facingLeft = false,
    this.gender,
    this.auraColor,
    this.auraIntensity = 1.0,
    this.colorFilter,
    this.buffGlows = const [],
  });

  final String spriteId;
  final bool facingLeft;
  final HeroGender? gender;
  final Color? auraColor;
  final double auraIntensity;
  final ColorFilter? colorFilter;
  final List<Color> buffGlows;

  /// Returns the aura color for the first matching affix element, or null.
  static Color? auraColorFor(List<ZoneAffix> affixes) {
    for (final a in affixes) {
      switch (a) {
        case ZoneAffix.volatileDeath:
          return const Color(0xFFff5500);
        case ZoneAffix.ironSkin:
        case ZoneAffix.diamondHide:
          return const Color(0xFF66ccff);
        case ZoneAffix.timeFracture:
          return const Color(0xFFffff33);
        case ZoneAffix.cursedGround:
        case ZoneAffix.deathSpiral:
          return const Color(0xFF44dd00);
        case ZoneAffix.shadowCloak:
        case ZoneAffix.voidCurse:
        case ZoneAffix.abyssalRoar:
          return const Color(0xFF9933ff);
        case ZoneAffix.soulSiphon:
        case ZoneAffix.lifeleechAura:
          return const Color(0xFFcc1133);
      }
    }
    return null;
  }

  @override
  BattleSpriteState createState() => BattleSpriteState();
}

class BattleSpriteState extends State<BattleSprite>
    with TickerProviderStateMixin {
  late final AnimationController _idle;
  late final AnimationController _attack;
  late final AnimationController _hit;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _attack = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _hit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _idle.dispose();
    _attack.dispose();
    _hit.dispose();
    super.dispose();
  }

  Future<void> playAttack() async {
    await _attack.forward();
    _attack.reset();
  }

  Future<void> playHit() async {
    await _hit.forward();
    _hit.reset();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_idle, _attack, _hit]),
      builder: (context, _) {
        final idleY = sin(_idle.value * pi) * 3.0;
        final atkX =
            sin(_attack.value * pi) * (widget.facingLeft ? 14.0 : -14.0);
        final size = _sizeFor(widget.spriteId);
        Widget sprite = CustomPaint(
          size: size,
          painter: _painterFor(widget.spriteId, widget.facingLeft, _attack.value, widget.gender),
        );


        // Palette skin — applied to pixels only, before the aura glow
        if (widget.colorFilter != null) {
          sprite = ColorFiltered(
            colorFilter: widget.colorFilter!,
            child: sprite,
          );
        }

        if (widget.auraColor != null || widget.buffGlows.isNotEmpty) {
          final pulse = 0.5 + 0.5 * sin(_idle.value * pi);
          final shadows = <BoxShadow>[];

          // Cosmetic / zone-affix aura
          if (widget.auraColor != null) {
            final intensity = widget.auraIntensity;
            shadows.add(BoxShadow(
              color: widget.auraColor!.withValues(
                  alpha: (0.35 + pulse * 0.4) * intensity.clamp(0.3, 1.5)),
              blurRadius: (8 + pulse * 10) * intensity,
              spreadRadius: (1 + pulse * 3) * intensity,
            ));
          }

          // Active buff / debuff glows — tighter inner ring per effect
          for (int i = 0; i < widget.buffGlows.length; i++) {
            final phase = pulse + i * 0.3;
            shadows.add(BoxShadow(
              color: widget.buffGlows[i].withValues(
                  alpha: (0.45 + (phase % 1.0) * 0.45).clamp(0.0, 1.0)),
              blurRadius: 5 + (phase % 1.0) * 7,
              spreadRadius: 1.0 + (phase % 1.0) * 2.0,
            ));
          }

          sprite = Container(
            decoration: BoxDecoration(boxShadow: shadows),
            child: sprite,
          );
        }

        return Transform.translate(
          offset: Offset(atkX, idleY),
          child: sprite,
        );
      },
    );
  }

  static Size _sizeFor(String id) {
    switch (id) {
      // ── Legacy IDs (kept for backward-compatibility) ────────────────────
      case 'abyssal_beast':
      case 'frost_drake':
      case 'dragon_whelp':
        return const Size(100, 80);
      case 'spider_queen':
        return const Size(120, 80);
      case 'stone_golem':
      case 'blood_ogre':
        return const Size(100, 100);
      case 'dark_lord':
        return const Size(80, 130);
      case 'ancient_lich':
        return const Size(80, 140);

      // ── Wide / low creatures ────────────────────────────────────────────
      case 'chimera':
      case 'hydra':
      case 'basilisk':
        return const Size(120, 80);
      case 'golem':
      case 'minotaur':
        return const Size(100, 100);

      // ── Tall / imposing creatures ────────────────────────────────────────
      case 'lich':
      case 'mind_flayer':
        return const Size(80, 140);
      case 'phoenix':
      case 'wyvern':
        return const Size(110, 90);

      // ── Floating / small creatures ───────────────────────────────────────
      case 'pixie':
      case 'imp':
      case 'eyeball_watcher':
        return const Size(60, 70);

      // ── Everything else: standard upright silhouette ─────────────────────
      default:
        return const Size(80, 120);
    }
  }

  static CustomPainter _painterFor(String id, bool facingLeft, double t, HeroGender? gender) {
    final g = gender ?? HeroGender.male;
    switch (id) {
      case 'hero':
        return _HeroPainter(facingLeft);
      case 'hero_barbarian':
        return _BarbarianHeroPainter(facingLeft, 0.0, g);
      case 'hero_bard':
        return _BardHeroPainter(facingLeft, 0.0, g);
      case 'hero_cleric':
        return _ClericHeroPainter(facingLeft, 0.0, g);
      case 'hero_druid':
        return _DruidHeroPainter(facingLeft, 0.0, g);
      case 'hero_fighter':
        return _FighterHeroPainter(facingLeft, 0.0, g);
      case 'hero_monk':
        return _MonkHeroPainter(facingLeft, 0.0, g);
      case 'hero_ranger':
        return _RangerHeroPainter(facingLeft, 0.0, g);
      case 'hero_rogue':
        return _RogueHeroPainter(facingLeft, 0.0, g);
      case 'hero_sorcerer':
        return _SorcererHeroPainter(facingLeft, 0.0, g);
      case 'hero_warlock':
        return _WarlockHeroPainter(facingLeft, 0.0, g);
      case 'hero_wizard':
        return _WizardHeroPainter(facingLeft, 0.0, g);
      case 'crypt_skeleton':
        return _SkeletonPainter(facingLeft);
      case 'shade_warrior':
        return _ShadeWarriorPainter(facingLeft);
      case 'abyssal_beast':
        return _BeastPainter(facingLeft);
      case 'dark_lord':
        return _DarkLordPainter(facingLeft);
      case 'stone_golem':
        return _StoneGolemPainter(facingLeft);
      case 'forest_wraith':
        return _ForestWraithPainter(facingLeft);
      case 'frost_drake':
        return _FrostDrakePainter(facingLeft);
      case 'blood_ogre':
        return _BloodOgrePainter(facingLeft);
      case 'lich_apprentice':
        return _LichApprentPainter(facingLeft);
      case 'spider_queen':
        return _SpiderQueenPainter(facingLeft);
      case 'infernal_knight':
        return _InfernalKnightPainter(facingLeft);
      case 'dragon_whelp':
        return _DragonWhelpPainter(facingLeft);
      // ── Undead ────────────────────────────────────────────────────────────
      case 'skeleton':        return _SkeletonPainter(facingLeft, t);
      case 'ghoul':           return _GhoulPainter(facingLeft, t);
      case 'banshee':         return _BansheePainter(facingLeft, t);
      case 'mummy':           return _MummyPainter(facingLeft, t);
      case 'lich':            return _LichEnemyPainter(facingLeft, t);
      // ── Gremlins & Humanoids ──────────────────────────────────────────────
      case 'goblin':          return _GoblinPainter(facingLeft, t);
      case 'kobold':          return _KoboldPainter(facingLeft, t);
      case 'gnoll':           return _GnollPainter(facingLeft, t);
      case 'hobgoblin':       return _HobgoblinPainter(facingLeft, t);
      case 'orc':             return _OrcPainter(facingLeft, t);
      case 'imp':             return _ImpPainter(facingLeft, t);
      // ── Beasts & Constructs ───────────────────────────────────────────────
      case 'harpy':           return _HarpyPainter(facingLeft, t);
      case 'gargoyle':        return _GargoylePainter(facingLeft, t);
      case 'basilisk':        return _BasiliskPainter(facingLeft, t);
      case 'golem':           return _GolemPainter(facingLeft, t);
      case 'chimera':         return _ChimeraPainter(facingLeft, t);
      // ── Demonic & Mythical ────────────────────────────────────────────────
      case 'cultist':         return _CultistPainter(facingLeft, t);
      case 'succubus':        return _SuccubusPainter(facingLeft, t);
      case 'eyeball_watcher': return _EyeballWatcherPainter(facingLeft, t);
      case 'mind_flayer':     return _MindFlayerPainter(facingLeft, t);
      case 'pixie':           return _PixiePainter(facingLeft, t);
      case 'wyvern':          return _WyvernPainter(facingLeft, t);
      case 'minotaur':        return _MinotaurPainter(facingLeft, t);
      case 'hydra':           return _HydraPainter(facingLeft, t);
      case 'phoenix':         return _PhoenixPainter(facingLeft, t);

      // ── BOSSES (every 5th stage) ──────────────────────────────────────────
      case 'goblin_warchief':  return _OrcPainter(facingLeft, t);
      case 'necromancer_vael': return _LichEnemyPainter(facingLeft, t);
      case 'pharaoh_kethran':  return _MummyPainter(facingLeft, t);
      case 'the_tyrant_eye':   return _EyeballWatcherPainter(facingLeft, t);
      case 'lich_emperor':     return _LichEnemyPainter(facingLeft, t);
      case 'prism_lord':       return _GargoylePainter(facingLeft, t);
      case 'shadow_king':      return _MindFlayerPainter(facingLeft, t);
      case 'glacier_wyrm':     return _WyvernPainter(facingLeft, t);
      case 'king_of_storms':   return _PhoenixPainter(facingLeft, t);
      case 'leviathan':        return _HydraPainter(facingLeft, t);
      case 'the_dreaming_god': return _MindFlayerPainter(facingLeft, t);
      case 'prime_emperor':    return _GolemPainter(facingLeft, t);
      case 'god_of_rot':       return _ChimeraPainter(facingLeft, t);
      case 'the_void_god':     return _MindFlayerPainter(facingLeft, t);
      case 'null_sovereign':   return _LichEnemyPainter(facingLeft, t);
      case 'the_first_prisoner': return _MinotaurPainter(facingLeft, t);
      case 'gate_titan':       return _GolemPainter(facingLeft, t);
      case 'god_eater':        return _HydraPainter(facingLeft, t);
      case 'world_ender':      return _PhoenixPainter(facingLeft, t);
      case 'omega_absolute':   return _ChimeraPainter(facingLeft, t);

      // ── Crystal Sanctum (25-29) ───────────────────────────────────────────
      case 'crystal_shard':    return _PixiePainter(facingLeft, t);
      case 'prism_wraith':     return _BansheePainter(facingLeft, t);
      case 'gem_serpent':      return _BasiliskPainter(facingLeft, t);
      case 'crystal_guardian': return _GolemPainter(facingLeft, t);
      case 'arcane_colossus':  return _MinotaurPainter(facingLeft, t);

      // ── Shadow Realm (30-34) ──────────────────────────────────────────────
      case 'shadow_stalker':   return _CultistPainter(facingLeft, t);
      case 'shade_assassin':   return _GoblinPainter(facingLeft, t);
      case 'umbral_knight':    return _OrcPainter(facingLeft, t);
      case 'dark_phantom':     return _GhoulPainter(facingLeft, t);
      case 'shade_sovereign':  return _LichEnemyPainter(facingLeft, t);

      // ── Frozen Wastes (35-39) ─────────────────────────────────────────────
      case 'frost_sprite':     return _PixiePainter(facingLeft, t);
      case 'ice_wraith':       return _BansheePainter(facingLeft, t);
      case 'glacial_troll':    return _OrcPainter(facingLeft, t);
      case 'winter_wolf':      return _BasiliskPainter(facingLeft, t);
      case 'frost_dragon':     return _WyvernPainter(facingLeft, t);

      // ── Storm Heights (40-44) ─────────────────────────────────────────────
      case 'storm_hawk':         return _HarpyPainter(facingLeft, t);
      case 'thunder_elemental':  return _EyeballWatcherPainter(facingLeft, t);
      case 'lightning_drake':    return _WyvernPainter(facingLeft, t);
      case 'storm_giant':        return _MinotaurPainter(facingLeft, t);
      case 'storm_titan':        return _GolemPainter(facingLeft, t);

      // ── Abyssal Ocean (45-49) ─────────────────────────────────────────────
      case 'deep_lurker':    return _GhoulPainter(facingLeft, t);
      case 'tide_wraith':    return _BansheePainter(facingLeft, t);
      case 'abyssal_shark':  return _BasiliskPainter(facingLeft, t);
      case 'sea_colossus':   return _HydraPainter(facingLeft, t);
      case 'krakentide':     return _ChimeraPainter(facingLeft, t);

      // ── Twilight Labyrinth (50-54) ────────────────────────────────────────
      case 'mirror_shade':      return _CultistPainter(facingLeft, t);
      case 'echo_phantom':      return _BansheePainter(facingLeft, t);
      case 'dream_stalker':     return _MindFlayerPainter(facingLeft, t);
      case 'nightmare_weaver':  return _SuccubusPainter(facingLeft, t);
      case 'labyrinth_warden':  return _GargoylePainter(facingLeft, t);

      // ── Forgotten Empire (55-59) ──────────────────────────────────────────
      case 'archive_scribe':     return _CultistPainter(facingLeft, t);
      case 'assembly_drone':     return _GolemPainter(facingLeft, t);
      case 'vault_guardian':     return _GargoylePainter(facingLeft, t);
      case 'protocol_enforcer':  return _HobgoblinPainter(facingLeft, t);
      case 'eternal_sentinel':   return _LichEnemyPainter(facingLeft, t);

      // ── Plaguelands (60-64) ───────────────────────────────────────────────
      case 'plague_rat':          return _GoblinPainter(facingLeft, t);
      case 'infected_soldier':    return _HobgoblinPainter(facingLeft, t);
      case 'rot_priest':          return _CultistPainter(facingLeft, t);
      case 'corruption_beast':    return _BasiliskPainter(facingLeft, t);
      case 'plague_mother':       return _ChimeraPainter(facingLeft, t);

      // ── Celestial Ruins (65-69) ───────────────────────────────────────────
      case 'broken_seraph':    return _HarpyPainter(facingLeft, t);
      case 'divine_wraith':    return _BansheePainter(facingLeft, t);
      case 'fallen_cherub':    return _PixiePainter(facingLeft, t);
      case 'halo_specter':     return _EyeballWatcherPainter(facingLeft, t);
      case 'fallen_archangel': return _PhoenixPainter(facingLeft, t);

      // ── Dark Matter (70-74) ───────────────────────────────────────────────
      case 'null_sprite':           return _ImpPainter(facingLeft, t);
      case 'void_crawler':          return _GhoulPainter(facingLeft, t);
      case 'antimatter_construct':  return _GolemPainter(facingLeft, t);
      case 'entropy_fiend':         return _MindFlayerPainter(facingLeft, t);
      case 'null_emperor':          return _LichEnemyPainter(facingLeft, t);

      // ── Eternal Prison (75-79) ────────────────────────────────────────────
      case 'shackle_beast':     return _BasiliskPainter(facingLeft, t);
      case 'omega_warden':      return _OrcPainter(facingLeft, t);
      case 'containment_golem': return _GolemPainter(facingLeft, t);
      case 'cell_breaker':      return _MinotaurPainter(facingLeft, t);
      case 'the_unbound':       return _ChimeraPainter(facingLeft, t);

      // ── Abyss Gate (80-84) ────────────────────────────────────────────────
      case 'gate_crawler':       return _GhoulPainter(facingLeft, t);
      case 'sentinel_wraith':    return _BansheePainter(facingLeft, t);
      case 'watcher_construct':  return _EyeballWatcherPainter(facingLeft, t);
      case 'siege_engine':       return _GolemPainter(facingLeft, t);
      case 'gate_colossus':      return _MinotaurPainter(facingLeft, t);

      // ── Shattered Realm (85-89) ───────────────────────────────────────────
      case 'carrion_crawler':         return _GhoulPainter(facingLeft, t);
      case 'god_shard_elemental':     return _PhoenixPainter(facingLeft, t);
      case 'necrotic_abomination':    return _ChimeraPainter(facingLeft, t);
      case 'scar_feeder':             return _HydraPainter(facingLeft, t);
      case 'the_devourer':            return _MindFlayerPainter(facingLeft, t);

      // ── Final Frontier (90-94) ────────────────────────────────────────────
      case 'boundary_wraith':    return _BansheePainter(facingLeft, t);
      case 'no_return_specter':  return _GhoulPainter(facingLeft, t);
      case 'void_membrane':      return _EyeballWatcherPainter(facingLeft, t);
      case 'last_light_seraph':  return _HarpyPainter(facingLeft, t);
      case 'frontier_guardian':  return _LichEnemyPainter(facingLeft, t);

      // ── Omega Throne (95-99) ──────────────────────────────────────────────
      case 'omega_herald':    return _CultistPainter(facingLeft, t);
      case 'memory_shade':    return _BansheePainter(facingLeft, t);
      case 'dark_hour_titan': return _MinotaurPainter(facingLeft, t);
      case 'throne_sentinel': return _GargoylePainter(facingLeft, t);
      case 'the_omega':       return _AncientLichPainter(facingLeft);

      default:
        return _AncientLichPainter(facingLeft);
    }
  }
}

// ─────────────────────────────────────────────────────────────
// StaticEnemySprite — zero-animation snapshot for map nodes.
// Scales the sprite to fill a square of [size] px using BoxFit.contain.
// ─────────────────────────────────────────────────────────────

class StaticEnemySprite extends StatelessWidget {
  const StaticEnemySprite({super.key, required this.spriteId, required this.size});
  final String spriteId;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(size, size),
        painter: _StaticEnemyPainter(spriteId),
        isComplex: true,
        willChange: false,
      );
}

class _StaticEnemyPainter extends CustomPainter {
  const _StaticEnemyPainter(this.spriteId);
  final String spriteId;

  @override
  void paint(Canvas canvas, Size size) {
    final native = BattleSpriteState._sizeFor(spriteId);
    final scale  = min(size.width / native.width, size.height / native.height);
    final dx     = (size.width  - native.width  * scale) / 2;
    final dy     = (size.height - native.height * scale) / 2;
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);
    BattleSpriteState._painterFor(spriteId, false, 0.0, null).paint(canvas, native);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StaticEnemyPainter old) =>
      old.spriteId != spriteId;
}

// ─────────────────────────────────────────────────────────────
// Base painter — handles horizontal flip for enemies
// ─────────────────────────────────────────────────────────────

abstract class _Painter extends CustomPainter {
  const _Painter(this.facingLeft, [this.t = 0.0, this.gender = HeroGender.male]);
  final bool facingLeft;
  final double t; // attack progress 0.0 → 1.0
  final HeroGender gender;

  bool get isFemale    => gender == HeroGender.female;
  bool get isNonBinary => gender == HeroGender.nonBinary;

  static const double s = 5.0; // grid px size

  void draw(Canvas c, Size sz);

  @override
  void paint(Canvas c, Size sz) {
    c.save();
    if (facingLeft) {
      c.translate(sz.width, 0);
      c.scale(-1, 1);
    }
    draw(c, sz);
    c.restore();
  }

  @override
  bool shouldRepaint(_Painter old) => old.t != t;

  void b(Canvas c, double x, double y, double w, double h, int rgba) {
    c.drawRect(
      Rect.fromLTWH(x * s, y * s, w * s, h * s),
      Paint()..color = Color(rgba),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HERO — The Warden  (16 × 24 grid → 80 × 120 canvas)
// ─────────────────────────────────────────────────────────────

class _HeroPainter extends _Painter {
  const _HeroPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    // palette
    const S = 0xFFb4bcc8; // silver
    const SL = 0xFFd4dce8; // silver light
    const SD = 0xFF6e7890; // silver dark
    const G = 0xFFd4af37; // gold
    const GD = 0xFF9a7c1c; // gold dark
    const K = 0xFF181820; // outline
    const CP = 0xFF3c1c70; // cape purple
    const CD = 0xFF1e0e3c; // cape dark
    const BR = 0xFF3a2010; // brown boot
    const BL = 0xFF5a3818; // boot light

    // ── CAPE (behind everything) ──────────────────────────
    b(c, 0, 6, 2, 17, CD);
    b(c, 2, 6, 1, 17, CP);
    b(c, 13, 6, 1, 17, CP);
    b(c, 14, 6, 2, 17, CD);

    // ── HELMET ────────────────────────────────────────────
    b(c, 5, 0, 6, 1, G); // plume
    b(c, 6, 0, 4, 1, GD); // plume tips
    b(c, 4, 1, 8, 5, S); // helmet body
    b(c, 4, 1, 8, 1, SL); // top highlight
    b(c, 3, 2, 1, 4, SD); // left edge
    b(c, 12, 2, 1, 4, SD); // right edge
    b(c, 4, 3, 8, 2, K); // visor dark zone
    b(c, 5, 3, 6, 1, G); // visor gold band
    b(c, 5, 4, 6, 1, K); // visor slit
    b(c, 4, 5, 8, 1, SD); // chin guard

    // ── SHOULDERS ─────────────────────────────────────────
    b(c, 1, 6, 4, 3, S);
    b(c, 11, 6, 4, 3, S);
    b(c, 1, 6, 4, 1, SL);
    b(c, 11, 6, 4, 1, SL);
    b(c, 1, 8, 4, 1, SD);
    b(c, 11, 8, 4, 1, SD);

    // ── CHEST PLATE ───────────────────────────────────────
    b(c, 4, 6, 8, 8, SD); // chest dark base
    b(c, 5, 7, 6, 6, S); // chest plate
    b(c, 5, 7, 6, 1, SL); // top highlight
    b(c, 6, 8, 4, 5, G); // gold chest piece
    b(c, 7, 9, 2, 3, GD); // gold detail
    b(c, 6, 12, 4, 1, GD); // bottom trim

    // ── BELT ──────────────────────────────────────────────
    b(c, 4, 13, 8, 2, K);
    b(c, 6, 13, 4, 2, G);
    b(c, 7, 13, 2, 1, GD);

    // ── SWORD (right side) ────────────────────────────────
    b(c, 15, 3, 1, 1, G); // pommel
    b(c, 15, 4, 1, 2, BL); // grip
    b(c, 14, 6, 3, 1, SD); // crossguard
    b(c, 15, 7, 1, 7, SL); // blade

    // ── THIGHS ────────────────────────────────────────────
    b(c, 4, 15, 3, 5, S);
    b(c, 9, 15, 3, 5, S);
    b(c, 4, 15, 3, 1, SL);
    b(c, 9, 15, 3, 1, SL);
    b(c, 7, 15, 2, 5, CD); // gap

    // ── KNEE GUARDS ───────────────────────────────────────
    b(c, 4, 19, 3, 2, G);
    b(c, 9, 19, 3, 2, G);

    // ── GREAVES ───────────────────────────────────────────
    b(c, 4, 21, 3, 2, S);
    b(c, 9, 21, 3, 2, S);

    // ── BOOTS ─────────────────────────────────────────────
    b(c, 3, 22, 4, 2, BR);
    b(c, 9, 22, 4, 2, BR);
    b(c, 3, 23, 5, 1, K);
    b(c, 9, 23, 5, 1, K);
  }
}

// ─────────────────────────────────────────────────────────────
// CRYPT SKELETON  (16 × 24 grid → 80 × 120 canvas)
// ─────────────────────────────────────────────────────────────

class _SkeletonPainter extends _Painter {
  const _SkeletonPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const BO = 0xFFd8cebc; // bone
    const BD = 0xFF9c8878; // bone dark
    const K = 0xFF181820; // outline
    const EY = 0xFFee2020; // red eye glow
    const RU = 0xFF8b3218; // rust

    // ── SKULL ─────────────────────────────────────────────
    b(c, 4, 0, 8, 4, BO);
    b(c, 4, 0, 8, 1, 0xFFe8e0d0); // skull top light
    b(c, 4, 1, 3, 2, K); // left eye socket
    b(c, 9, 1, 3, 2, K); // right eye socket
    b(c, 4, 1, 3, 1, EY); // left eye glow
    b(c, 9, 1, 3, 1, EY); // right eye glow
    b(c, 5, 3, 6, 1, BD); // nose area
    b(c, 4, 3, 8, 2, BO); // jaw
    b(c, 5, 4, 2, 1, K); // jaw gap L
    b(c, 9, 4, 2, 1, K); // jaw gap R
    b(c, 5, 4, 1, 2, 0xFFf0e8d0); // tooth L
    b(c, 7, 4, 1, 2, 0xFFf0e8d0); // tooth M
    b(c, 9, 4, 1, 2, 0xFFf0e8d0); // tooth R

    // ── NECK + COLLAR BONES ───────────────────────────────
    b(c, 7, 5, 2, 1, BD);
    b(c, 2, 5, 3, 2, BO); // L collar
    b(c, 11, 5, 3, 2, BO); // R collar

    // ── RIBCAGE ───────────────────────────────────────────
    b(c, 7, 6, 2, 5, BD); // spine
    b(c, 4, 6, 3, 1, BO); b(c, 4, 7, 3, 1, BD);
    b(c, 4, 8, 3, 1, BO); b(c, 4, 9, 3, 1, BD);
    b(c, 9, 6, 3, 1, BO); b(c, 9, 7, 3, 1, BD);
    b(c, 9, 8, 3, 1, BO); b(c, 9, 9, 3, 1, BD);
    b(c, 5, 10, 6, 1, BO); // bottom rib

    // ── ARM BONES ─────────────────────────────────────────
    b(c, 2, 7, 2, 6, BO); // L upper arm
    b(c, 2, 13, 2, 5, BO); // L forearm
    b(c, 12, 7, 2, 6, BO); // R upper arm
    b(c, 12, 13, 2, 5, BO); // R forearm

    // ── PELVIS ────────────────────────────────────────────
    b(c, 5, 11, 6, 2, BO);

    // ── LEG BONES ─────────────────────────────────────────
    b(c, 5, 13, 2, 6, BO);
    b(c, 9, 13, 2, 6, BO);
    b(c, 5, 19, 2, 3, BO);
    b(c, 9, 19, 2, 3, BO);

    // ── FEET ──────────────────────────────────────────────
    b(c, 4, 22, 3, 1, BO);
    b(c, 9, 22, 3, 1, BO);

    // ── RUSTY SWORD (right hand) ──────────────────────────
    b(c, 14, 10, 1, 1, RU); // pommel
    b(c, 14, 11, 1, 2, BD); // grip
    b(c, 13, 13, 3, 1, RU); // guard
    b(c, 14, 14, 1, 8, RU); // blade
    b(c, 14, 21, 1, 1, BO); // blade tip

    // ── Attack: sword swings overhead ────────────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.05) {
        final off = sw * 10;
        b(c, 14, max(0.0, 10 - off), 1, 1, 0xFFffcc88);
        b(c, 14, max(0.0, 11 - off), 1, 2, 0xFFcccccc);
        b(c, 13, max(0.0, 13 - off), 3, 1, 0xFFffcc88);
        b(c, 14, max(0.0, 14 - off), 1, 8, 0xFFffcc88);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// SHADE WARRIOR  (16 × 24 grid → 80 × 120 canvas)
// ─────────────────────────────────────────────────────────────

class _ShadeWarriorPainter extends _Painter {
  const _ShadeWarriorPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const DK = 0xFF1c2060; // dark blue-shadow
    const MD = 0xFF3a3888; // mid shadow
    const LT = 0xFF6858a8; // light shadow
    const EY = 0xFFffd040; // yellow glow eyes
    const SW = 0xFF5040a0; // shadow sword
    const SWL = 0xFF9080d0; // sword glow
    const K = 0xFF181820;

    // ── SHADOW WISPS (sides, drawn behind) ────────────────
    b(c, 0, 7, 1, 14, DK);
    b(c, 1, 6, 1, 16, MD);
    b(c, 14, 6, 1, 16, MD);
    b(c, 15, 7, 1, 14, DK);

    // ── HELMET ────────────────────────────────────────────
    b(c, 3, 0, 10, 6, DK);
    b(c, 4, 0, 8, 1, MD); // top highlight
    b(c, 4, 1, 8, 1, LT); // bright top
    b(c, 3, 3, 10, 1, EY); // eye glow line
    b(c, 4, 3, 2, 2, EY); // left eye
    b(c, 10, 3, 2, 2, EY); // right eye
    b(c, 3, 5, 10, 1, DK); // chin

    // ── SHOULDERS ─────────────────────────────────────────
    b(c, 1, 5, 4, 3, MD);
    b(c, 11, 5, 4, 3, MD);
    b(c, 1, 5, 4, 1, LT);
    b(c, 11, 5, 4, 1, LT);

    // ── CHEST ─────────────────────────────────────────────
    b(c, 3, 5, 10, 10, DK);
    b(c, 4, 6, 8, 1, MD); // chest highlight
    b(c, 5, 7, 6, 5, MD); // chest inner
    b(c, 6, 8, 4, 3, LT); // chest center bright
    b(c, 7, 9, 2, 1, EY); // chest sigil glow

    // ── BELT ──────────────────────────────────────────────
    b(c, 3, 14, 10, 2, K);
    b(c, 6, 14, 4, 2, MD);
    b(c, 7, 14, 2, 1, EY); // buckle glow

    // ── WISPY LEGS ────────────────────────────────────────
    b(c, 3, 16, 4, 6, DK);
    b(c, 9, 16, 4, 6, DK);
    b(c, 4, 18, 2, 5, MD);
    b(c, 10, 18, 2, 5, MD);
    b(c, 5, 21, 1, 2, LT);
    b(c, 10, 21, 1, 2, LT);
    b(c, 5, 23, 1, 1, MD); // fade
    b(c, 10, 23, 1, 1, MD);

    // ── GLOWING SWORD (right side) ────────────────────────
    b(c, 15, 3, 1, 1, EY); // pommel glow
    b(c, 15, 4, 1, 2, SW); // grip
    b(c, 14, 6, 3, 1, SWL); // guard glow
    b(c, 15, 7, 1, 10, SW); // blade
    b(c, 15, 7, 1, 10, SWL); // blade glow (drawn over = bright edge)
  }
}

// ─────────────────────────────────────────────────────────────
// ABYSSAL BEAST  (20 × 16 grid → 100 × 80 canvas)
// ─────────────────────────────────────────────────────────────

class _BeastPainter extends _Painter {
  const _BeastPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const GR = 0xFF4a6828; // beast green
    const GD = 0xFF2a3c18; // green dark
    const TN = 0xFF8a6a38; // tan/belly
    const EY = 0xFFff4010; // red-orange eye
    const FG = 0xFFf0e8d0; // fang ivory
    const K = 0xFF181820;

    // ── MAIN BODY ─────────────────────────────────────────
    b(c, 4, 4, 14, 7, GR);
    b(c, 5, 3, 12, 2, GR); // upper hump
    b(c, 6, 2, 10, 2, TN); // hump highlight
    b(c, 5, 9, 12, 2, GD); // belly shadow
    b(c, 7, 5, 8, 4, TN); // belly stripe

    // ── HEAD (left side) ──────────────────────────────────
    b(c, 0, 2, 6, 7, GR);
    b(c, 0, 2, 6, 1, TN); // top highlight
    b(c, 0, 3, 2, 2, K); // eye socket
    b(c, 0, 3, 2, 1, EY); // eye glow
    b(c, 0, 5, 6, 1, GD); // snout crease
    b(c, 0, 5, 6, 3, GR); // snout lower
    b(c, 0, 8, 6, 1, K); // mouth
    b(c, 1, 7, 1, 2, FG); // fang 1
    b(c, 3, 7, 1, 2, FG); // fang 2
    b(c, 5, 7, 1, 2, FG); // fang 3

    // ── FRONT CLAWS (left) ────────────────────────────────
    b(c, 0, 8, 3, 4, GD);
    b(c, 0, 11, 1, 3, TN); // claw 1
    b(c, 1, 11, 1, 3, TN); // claw 2
    b(c, 2, 11, 1, 3, TN); // claw 3

    // ── BACK CLAWS (right) ────────────────────────────────
    b(c, 16, 7, 4, 4, GD);
    b(c, 17, 10, 1, 3, TN);
    b(c, 18, 10, 1, 3, TN);
    b(c, 19, 10, 1, 3, TN);

    // ── LEGS ──────────────────────────────────────────────
    b(c, 3, 10, 4, 5, GD); // front left leg
    b(c, 13, 10, 4, 5, GD); // front right leg
    b(c, 3, 14, 5, 1, TN); // left foot
    b(c, 13, 14, 5, 1, TN); // right foot

    // ── SCALE DETAILS ─────────────────────────────────────
    b(c, 7, 4, 2, 1, GD);
    b(c, 11, 4, 2, 1, GD);
    b(c, 9, 6, 2, 1, GD);
    b(c, 6, 7, 2, 1, TN);
    b(c, 12, 7, 2, 1, TN);

    // ── TAIL ──────────────────────────────────────────────
    b(c, 17, 4, 3, 3, GR);
    b(c, 19, 5, 1, 4, GD);
  }
}

// ─────────────────────────────────────────────────────────────
// DARK LORD  (16 × 26 grid → 80 × 130 canvas)
// ─────────────────────────────────────────────────────────────

class _DarkLordPainter extends _Painter {
  const _DarkLordPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const BK = 0xFF181018; // lord black
    const DK = 0xFF2a1030; // lord dark
    const PU = 0xFF4a1860; // lord purple
    const RE = 0xFF8b0000; // deep red
    const EY = 0xFFff1010; // glowing red eye
    const MG = 0xFFaa20e8; // magic purple
    const GD = 0xFFd4af37; // gold accent

    // ── CROWN SPIKES ──────────────────────────────────────
    b(c, 3, 0, 1, 3, PU);
    b(c, 5, 0, 1, 2, PU);
    b(c, 7, 0, 2, 4, RE); // center spike (blood red)
    b(c, 10, 0, 1, 2, PU);
    b(c, 12, 0, 1, 3, PU);
    b(c, 3, 2, 10, 2, DK); // crown base

    // ── HELMET ────────────────────────────────────────────
    b(c, 3, 3, 10, 6, BK);
    b(c, 3, 3, 10, 1, DK); // top highlight
    b(c, 4, 5, 8, 1, RE); // eye glow band
    b(c, 4, 5, 3, 2, EY); // left eye
    b(c, 9, 5, 3, 2, EY); // right eye
    b(c, 5, 6, 1, 1, 0xFFff6040); // left eye bright
    b(c, 10, 6, 1, 1, 0xFFff6040); // right eye bright
    b(c, 3, 8, 10, 1, BK); // chin

    // ── CAPE (behind body) ────────────────────────────────
    b(c, 0, 8, 3, 17, PU);
    b(c, 13, 8, 3, 17, PU);
    b(c, 0, 8, 3, 1, DK);
    b(c, 13, 8, 3, 1, DK);

    // ── CHEST ARMOR ───────────────────────────────────────
    b(c, 3, 8, 10, 10, BK);
    b(c, 3, 8, 10, 1, DK); // chest top
    b(c, 5, 9, 6, 7, RE); // red chest sigil
    b(c, 6, 10, 4, 5, EY); // sigil inner
    b(c, 7, 11, 2, 3, MG); // magic orb on chest
    b(c, 7, 11, 2, 1, 0xFFdd60ff); // orb highlight

    // ── BELT ──────────────────────────────────────────────
    b(c, 3, 17, 10, 2, DK);
    b(c, 6, 17, 4, 2, PU);
    b(c, 7, 17, 2, 1, GD); // gold buckle

    // ── LOWER ROBE ────────────────────────────────────────
    b(c, 3, 19, 10, 5, BK);
    b(c, 0, 19, 3, 5, PU);
    b(c, 13, 19, 3, 5, PU);

    // ── FLOATING WISP BOTTOM ──────────────────────────────
    b(c, 4, 23, 8, 1, PU);
    b(c, 5, 24, 6, 1, DK);
    b(c, 6, 25, 4, 1, DK);

    // ── MAGIC STAFF (right side) ──────────────────────────
    b(c, 15, 0, 1, 1, 0xFFdd60ff); // orb top glow
    b(c, 15, 1, 1, 2, MG); // orb
    b(c, 15, 3, 1, 1, EY); // orb glow
    b(c, 15, 4, 1, 14, BK); // staff body
    b(c, 15, 7, 1, 1, PU); // staff accent
    b(c, 15, 12, 1, 1, PU); // staff accent
    b(c, 15, 17, 1, 1, MG); // staff bottom glow
  }
}

// ─────────────────────────────────────────────────────────────
// STONE GOLEM  (20 × 20 grid → 100 × 100 canvas)
// ─────────────────────────────────────────────────────────────

class _StoneGolemPainter extends _Painter {
  const _StoneGolemPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const GY = 0xFF788090; // stone grey
    const GD = 0xFF4a5060; // stone dark
    const GL = 0xFFa0aab8; // stone light
    const EY = 0xFFff8020; // orange eye glow
    const K  = 0xFF181820;
    const MS = 0xFF306028; // moss

    // ── HEAD (fused with shoulders) ───────────────────────
    b(c, 4, 0, 12, 7, GY);
    b(c, 4, 0, 12, 1, GL);
    b(c, 3, 1,  1, 6, GD);
    b(c, 16, 1, 1, 6, GD);
    b(c, 5, 1,  3, 2, K);
    b(c, 12, 1, 3, 2, K);
    b(c, 6, 1,  2, 1, EY);
    b(c, 13, 1, 2, 1, EY);
    b(c, 6, 1,  1, 1, 0xFFffb040);
    b(c, 13, 1, 1, 1, 0xFFffb040);
    b(c, 7, 5,  6, 1, K);
    b(c, 8, 4,  1, 2, GD);
    b(c, 11, 4, 1, 2, GD);
    b(c, 5, 0,  2, 1, GD);
    b(c, 13, 0, 2, 1, GD);

    // ── BODY ──────────────────────────────────────────────
    b(c, 2, 6, 16, 10, GY);
    b(c, 2, 6, 16,  1, GL);
    b(c, 2, 14, 16, 2, GD);
    b(c, 6, 8,  8, 5, GL);
    b(c, 7, 9,  6, 3, GY);
    b(c, 3, 7,  3, 2, MS);
    b(c, 14, 8, 3, 2, MS);
    b(c, 8, 13, 5, 1, MS);
    b(c, 9, 8,  1, 4, GD);
    b(c, 5, 11, 2, 1, GD);
    b(c, 13, 10,2, 1, GD);

    // ── SHOULDERS / ARMS ──────────────────────────────────
    b(c, 0, 4,  3, 8, GY);
    b(c, 0, 4,  3, 2, GL);
    b(c, 17, 4, 3, 8, GY);
    b(c, 17, 4, 3, 2, GL);
    b(c, 0, 11, 3, 5, GD);
    b(c, 17, 11,3, 5, GD);
    b(c, 0, 15, 3, 3, GY);
    b(c, 0, 15, 3, 1, GL);
    b(c, 17, 15,3, 3, GY);
    b(c, 17, 15,3, 1, GL);
    b(c, 0, 17, 3, 1, K);
    b(c, 17, 17,3, 1, K);

    // ── LEGS / FEET ───────────────────────────────────────
    b(c, 4, 16, 5, 4, GD);
    b(c, 11, 16,5, 4, GD);
    b(c, 4, 16, 5, 1, GY);
    b(c, 11, 16,5, 1, GY);
    b(c, 3, 19, 6, 1, K);
    b(c, 11, 19,6, 1, K);
  }
}

// ─────────────────────────────────────────────────────────────
// FOREST WRAITH  (16 × 24 grid → 80 × 120 canvas)
// ─────────────────────────────────────────────────────────────

class _ForestWraithPainter extends _Painter {
  const _ForestWraithPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const CL = 0xFF0e1808; // dark cloak
    const GN = 0xFF1e4c10; // forest green
    const GL = 0xFF3a8030; // green light
    const GW = 0xFF70c050; // green glow
    const EY = 0xFF50ff30; // eye glow
    const K  = 0xFF181820;

    // ── WISPY BASE ────────────────────────────────────────
    b(c, 3, 19, 10, 2, GN);
    b(c, 4, 20,  8, 1, GL);
    b(c, 5, 21,  6, 1, GW);
    b(c, 2, 20,  2, 3, GN);
    b(c, 12, 20, 2, 3, GN);
    b(c, 6, 22,  4, 1, GN);

    // ── CLOAK BODY ────────────────────────────────────────
    b(c, 2, 6, 12, 14, CL);
    b(c, 2, 6, 12,  1, GN);
    b(c, 0, 8,  2, 13, GN);
    b(c, 14, 8, 2, 13, GN);
    b(c, 1, 10, 1, 10, GL);
    b(c, 14, 10,1, 10, GL);
    b(c, 3, 7,  1, 12, GL);
    b(c, 12, 7, 1, 12, GL);
    b(c, 5, 10, 6,  6, GN);

    // ── HOOD ──────────────────────────────────────────────
    b(c, 3, 0, 10, 7, CL);
    b(c, 3, 0, 10,  1, GN);
    b(c, 2, 2,  1,  5, GN);
    b(c, 13, 2, 1,  5, GN);
    b(c, 4, 1,  8,  1, GL);
    b(c, 5, 2,  6,  3, GN);

    // Eyes
    b(c, 5, 3, 2, 2, K);
    b(c, 9, 3, 2, 2, K);
    b(c, 5, 3, 2, 1, EY);
    b(c, 9, 3, 2, 1, EY);
    b(c, 6, 3, 1, 1, 0xFFb0ffb0);
    b(c, 10, 3,1, 1, 0xFFb0ffb0);

    // ── CLAWS ─────────────────────────────────────────────
    b(c, 1, 12, 2, 5, GN);
    b(c, 13, 12,2, 5, GN);
    b(c, 0, 16, 1, 3, GW);
    b(c, 2, 17, 1, 3, GW);
    b(c, 1, 16, 1, 2, GW);
    b(c, 13, 16,1, 3, GW);
    b(c, 15, 17,1, 3, GW);
    b(c, 14, 16,1, 2, GW);
  }
}

// ─────────────────────────────────────────────────────────────
// FROST DRAKE  (20 × 16 grid → 100 × 80 canvas)
// ─────────────────────────────────────────────────────────────

class _FrostDrakePainter extends _Painter {
  const _FrostDrakePainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const IC = 0xFF8ab8d8; // ice blue
    const ID = 0xFF4878a0; // ice dark
    const IL = 0xFFc8e8f8; // ice light
    const BL = 0xFF182840; // belly dark
    const EY = 0xFF40e8ff; // cyan eye
    const FG = 0xFFe8f8ff; // frost fang
    const K  = 0xFF181820;
    const WN = 0xFF6090b0; // wing membrane

    // ── BODY ──────────────────────────────────────────────
    b(c, 4, 4, 12, 7, IC);
    b(c, 5, 3, 10, 2, IC);
    b(c, 6, 2,  8, 2, IL);
    b(c, 5, 9, 12, 2, ID);
    b(c, 7, 5,  8, 4, BL);

    // Scale details
    b(c, 7, 4, 2, 1, ID);
    b(c, 11, 4,2, 1, ID);
    b(c, 9, 6, 2, 1, ID);
    b(c, 6, 7, 2, 1, IL);
    b(c, 12, 7,2, 1, IL);

    // ── HEAD ──────────────────────────────────────────────
    b(c, 0, 1, 6, 7, IC);
    b(c, 0, 1, 6, 1, IL);
    b(c, 0, 2, 2, 2, K);
    b(c, 0, 2, 2, 1, EY);
    b(c, 0, 4, 6, 1, ID);
    b(c, 0, 4, 6, 4, IC);
    b(c, 0, 8, 6, 1, K);
    // Frost breath / teeth
    b(c, 1, 6, 1, 3, FG);
    b(c, 3, 7, 1, 2, FG);
    b(c, 5, 6, 1, 3, FG);
    // Horns
    b(c, 2, 0, 1, 2, ID);
    b(c, 4, 0, 1, 2, ID);

    // ── WINGS (upper) ─────────────────────────────────────
    b(c, 7, 0, 3, 4, WN);
    b(c, 10, 0,4, 3, WN);
    b(c, 14, 0,5, 4, WN);
    b(c, 7, 0, 3, 1, IL);
    b(c, 13, 1,1, 3, ID);

    // ── FRONT CLAWS ───────────────────────────────────────
    b(c, 0, 8,  3, 4, ID);
    b(c, 0, 11, 1, 3, IL);
    b(c, 1, 11, 1, 3, IL);
    b(c, 2, 11, 1, 3, IL);

    // ── BACK CLAWS ────────────────────────────────────────
    b(c, 15, 7, 4, 4, ID);
    b(c, 16, 10,1, 3, IL);
    b(c, 17, 10,1, 3, IL);
    b(c, 18, 10,1, 3, IL);

    // ── LEGS ──────────────────────────────────────────────
    b(c, 3, 10, 4, 5, ID);
    b(c, 13, 10,4, 5, ID);
    b(c, 3, 14, 5, 1, IL);
    b(c, 13, 14,5, 1, IL);

    // ── TAIL ──────────────────────────────────────────────
    b(c, 17, 4, 3, 3, IC);
    b(c, 19, 5, 1, 5, ID);
  }
}

// ─────────────────────────────────────────────────────────────
// BLOOD OGRE  (20 × 20 grid → 100 × 100 canvas)
// ─────────────────────────────────────────────────────────────

class _BloodOgrePainter extends _Painter {
  const _BloodOgrePainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const RD = 0xFF7a1810; // blood red skin
    const RL = 0xFF9e2e20; // red light
    const RK = 0xFF4a0c08; // red dark
    const TN = 0xFFb87850; // tusk/tooth ivory
    const K  = 0xFF181820;
    const BR = 0xFF3a2010; // loin cloth brown
    const BL = 0xFFcc2010; // blood splatter

    // ── HEAD ──────────────────────────────────────────────
    b(c, 4, 0, 12, 7, RD);
    b(c, 4, 0, 12, 1, RL);
    b(c, 3, 1,  1, 6, RK);
    b(c, 16, 1, 1, 6, RK);
    b(c, 5, 2,  3, 2, K);
    b(c, 12, 2, 3, 2, K);
    b(c, 5, 2,  3, 1, 0xFFff2010);
    b(c, 12, 2, 3, 1, 0xFFff2010);
    // Tusks
    b(c, 6, 6, 2, 3, TN);
    b(c, 12, 6,2, 3, TN);
    // Brow ridge
    b(c, 4, 1, 4, 1, RK);
    b(c, 12, 1,4, 1, RK);
    // Nose
    b(c, 8, 4, 4, 2, RK);
    b(c, 9, 4, 2, 1, RL);
    // Mouth
    b(c, 6, 6, 8, 1, K);

    // ── BODY (hunched) ────────────────────────────────────
    b(c, 2, 6, 16, 12, RD);
    b(c, 2, 6, 16,  1, RL);
    b(c, 2, 16, 16, 2, RK);
    b(c, 6, 8,  8,  8, RL);
    b(c, 7, 9,  6,  6, RD);
    // Loin cloth
    b(c, 7, 16, 6, 4, BR);
    b(c, 8, 16, 4, 1, 0xFF5a3018);
    // Blood splatter on chest
    b(c, 8, 8,  2, 2, BL);
    b(c, 12, 10,2, 1, BL);
    b(c, 6, 11, 1, 2, BL);

    // ── SHOULDERS / ARMS ──────────────────────────────────
    b(c, 0, 4,  3, 9, RD);
    b(c, 0, 4,  3, 2, RL);
    b(c, 17, 4, 3, 9, RD);
    b(c, 17, 4, 3, 2, RL);
    b(c, 0, 12, 3, 6, RK);
    b(c, 17, 12,3, 6, RK);
    // Fists
    b(c, 0, 17, 3, 3, RD);
    b(c, 0, 17, 3, 1, RL);
    b(c, 17, 17,3, 3, RD);
    b(c, 17, 17,3, 1, RL);
    b(c, 0, 19, 3, 1, K);
    b(c, 17, 19,3, 1, K);

    // ── LEGS ──────────────────────────────────────────────
    b(c, 4, 18, 5, 2, RK);
    b(c, 11, 18,5, 2, RK);
    b(c, 3, 19, 6, 1, K);
    b(c, 11, 19,6, 1, K);
  }
}

// ─────────────────────────────────────────────────────────────
// LICH APPRENTICE  (16 × 24 grid → 80 × 120 canvas)
// ─────────────────────────────────────────────────────────────

class _LichApprentPainter extends _Painter {
  const _LichApprentPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const BO = 0xFFccc0a8; // bone
    const BD = 0xFF988870; // bone dark
    const PU = 0xFF3c1068; // robe purple
    const PL = 0xFF6030a0; // robe light
    const EY = 0xFF40c8ff; // blue glow eye
    const OR = 0xFF50e850; // orb green
    const K  = 0xFF181820;

    // ── SKULL ─────────────────────────────────────────────
    b(c, 4, 0, 8, 5, BO);
    b(c, 4, 0, 8, 1, 0xFFe8e0d0);
    b(c, 4, 1, 3, 2, K);
    b(c, 9, 1, 3, 2, K);
    b(c, 4, 1, 3, 1, EY);
    b(c, 9, 1, 3, 1, EY);
    b(c, 5, 3, 6, 1, BD);
    b(c, 4, 3, 8, 2, BO);
    b(c, 5, 4, 2, 1, K);
    b(c, 9, 4, 2, 1, K);
    b(c, 5, 4, 1, 2, 0xFFf0e8d0);
    b(c, 7, 4, 1, 2, 0xFFf0e8d0);
    b(c, 9, 4, 1, 2, 0xFFf0e8d0);
    b(c, 7, 5, 2, 1, BD); // neck

    // ── ROBE BODY ─────────────────────────────────────────
    b(c, 0, 5,  16, 18, PU);
    b(c, 0, 5,  16,  1, PL);
    b(c, 2, 6,  12, 14, PU);
    b(c, 4, 7,   8, 10, PL);
    b(c, 5, 8,   6,  8, PU);
    b(c, 6, 9,   4,  4, PL);
    b(c, 7, 10,  2,  2, 0xFF8040c0); // sigil glow
    // Robe hem
    b(c, 1, 20,  14, 3, PU);
    b(c, 2, 22,  12, 1, PL);
    b(c, 3, 23,  10, 1, BD);

    // ── BONE HANDS / ARMS ─────────────────────────────────
    b(c, 0, 8,  2, 8, PU);
    b(c, 14, 8, 2, 8, PU);
    b(c, 0, 14, 2, 4, BO); // L hand
    b(c, 14, 14,2, 4, BO); // R hand (holding staff)
    b(c, 0, 17, 1, 2, BD);
    b(c, 1, 18, 1, 2, BD);
    b(c, 14, 17,1, 2, BD);
    b(c, 15, 18,1, 2, BD);

    // ── STAFF (right side) ────────────────────────────────
    b(c, 15, 0, 1, 1, 0xFFa0ffb0); // orb glow top
    b(c, 15, 1, 1, 2, OR);          // orb
    b(c, 15, 3, 1, 1, EY);          // orb shimmer
    b(c, 15, 4, 1, 16, BD);         // staff shaft
    b(c, 15, 8, 1,  1, PL);
    b(c, 15, 14,1,  1, PL);
    b(c, 15, 19,1,  1, OR);
  }
}

// ─────────────────────────────────────────────────────────────
// SPIDER QUEEN  (24 × 16 grid → 120 × 80 canvas)
// ─────────────────────────────────────────────────────────────

class _SpiderQueenPainter extends _Painter {
  const _SpiderQueenPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const BK = 0xFF18101c; // black body
    const PU = 0xFF4a1070; // purple
    const PL = 0xFF7830a8; // purple light
    const EY = 0xFF40ff80; // green eyes
    const LG = 0xFF303040; // leg dark
    const LL = 0xFF5050a0; // leg light
    const K  = 0xFF181820;

    // ── ABDOMEN (right, large oval) ───────────────────────
    b(c, 13, 2, 9, 10, PU);
    b(c, 13, 2, 9,  2, PL);
    b(c, 13, 10,9,  2, BK);
    b(c, 14, 3, 7,  8, PU);
    b(c, 15, 4, 5,  6, PL);
    b(c, 16, 5, 3,  4, 0xFF9840d0);
    // Abdomen pattern
    b(c, 16, 6, 3, 1, BK);
    b(c, 17, 4, 1, 1, PL);

    // ── CEPHALOTHORAX (left, smaller) ────────────────────
    b(c, 4, 4, 10, 8, BK);
    b(c, 4, 4, 10, 1, PU);
    b(c, 5, 5,  8, 6, BK);
    b(c, 6, 5,  6, 5, PU);
    b(c, 7, 6,  4, 3, PL);

    // ── EYES (cluster) ────────────────────────────────────
    b(c, 4, 5, 2, 1, EY);
    b(c, 7, 4, 2, 1, EY);
    b(c, 10,5, 2, 1, EY);
    b(c, 5, 6, 1, 1, 0xFFb0ffb0);
    b(c, 9, 5, 1, 1, 0xFFb0ffb0);

    // ── LEGS (6 visible, 3 per side) ─────────────────────
    // Left legs
    b(c, 0, 3,  5, 1, LG);  // upper L1
    b(c, 0, 3,  5, 1, LL);
    b(c, 0, 4,  4, 1, LG);  // mid L1
    b(c, 0, 5,  3, 1, LL);  // lower L1

    b(c, 0, 6,  5, 1, LG);  // L2
    b(c, 0, 7,  4, 1, LG);
    b(c, 0, 8,  3, 1, LL);

    b(c, 0, 9,  5, 1, LG);  // L3
    b(c, 0, 10, 4, 1, LG);
    b(c, 0, 11, 3, 1, LL);

    // Right legs (past abdomen)
    b(c, 19, 3, 5, 1, LG);
    b(c, 20, 4, 4, 1, LG);
    b(c, 21, 5, 3, 1, LL);

    b(c, 19, 6, 5, 1, LG);
    b(c, 20, 7, 4, 1, LG);
    b(c, 21, 8, 3, 1, LL);

    b(c, 19, 9,  5, 1, LG);
    b(c, 20, 10, 4, 1, LG);
    b(c, 21, 11, 3, 1, LL);

    // Leg tips (claws)
    b(c, 0, 5,  1, 1, LL);
    b(c, 0, 8,  1, 1, LL);
    b(c, 0, 11, 1, 1, LL);
    b(c, 23, 5, 1, 1, LL);
    b(c, 23, 8, 1, 1, LL);
    b(c, 23, 11,1, 1, LL);

    // ── FANGS ─────────────────────────────────────────────
    b(c, 5, 9,  2, 4, K);
    b(c, 8, 9,  2, 4, K);
    b(c, 6, 9,  1, 5, 0xFFd8f8e0);
    b(c, 9, 9,  1, 5, 0xFFd8f8e0);
    b(c, 6, 13, 1, 1, EY); // venom drop
    b(c, 9, 13, 1, 1, EY);
  }
}

// ─────────────────────────────────────────────────────────────
// INFERNAL KNIGHT  (16 × 24 grid → 80 × 120 canvas)
// ─────────────────────────────────────────────────────────────

class _InfernalKnightPainter extends _Painter {
  const _InfernalKnightPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const BK = 0xFF1a0808; // black armour
    const DK = 0xFF3a1010; // dark red
    const RE = 0xFF8b1500; // deep red
    const EY = 0xFFff4010; // fire eye
    const FR = 0xFFff8020; // flame orange
    const FL = 0xFFffcc40; // flame yellow
    const K  = 0xFF181820;

    // ── FLAME WISPS (shoulders, drawn behind) ────────────
    b(c, 0, 5,  2, 5, RE);
    b(c, 1, 4,  1, 3, FR);
    b(c, 14, 5, 2, 5, RE);
    b(c, 14, 4, 1, 3, FR);
    b(c, 0, 3,  1, 2, FL);
    b(c, 14, 3, 1, 2, FL);

    // ── HELMET ────────────────────────────────────────────
    b(c, 3, 0, 10, 6, BK);
    b(c, 3, 0, 10, 1, DK);
    b(c, 4, 2,  8, 1, RE);
    b(c, 4, 2,  3, 2, EY);
    b(c, 9, 2,  3, 2, EY);
    b(c, 5, 2,  1, 1, FR);
    b(c, 10, 2, 1, 1, FR);
    b(c, 3, 5, 10, 1, BK);
    // Horns on helmet
    b(c, 4, 0, 1, 3, RE);
    b(c, 11, 0,1, 3, RE);
    b(c, 4, 0, 1, 1, FR);
    b(c, 11, 0,1, 1, FR);

    // ── SHOULDERS ─────────────────────────────────────────
    b(c, 1, 5, 4, 3, DK);
    b(c, 11, 5,4, 3, DK);
    b(c, 1, 5, 4, 1, RE);
    b(c, 11, 5,4, 1, RE);

    // ── CHEST ─────────────────────────────────────────────
    b(c, 3, 5, 10, 10, BK);
    b(c, 3, 5, 10,  1, DK);
    b(c, 5, 6,  6,  7, RE);
    b(c, 6, 7,  4,  5, EY);
    b(c, 7, 8,  2,  3, FR);
    b(c, 7, 8,  2,  1, FL);

    // ── BELT ──────────────────────────────────────────────
    b(c, 3, 14, 10, 2, K);
    b(c, 6, 14,  4, 2, DK);
    b(c, 7, 14,  2, 1, RE);

    // ── LEGS ──────────────────────────────────────────────
    b(c, 3, 16,  4, 6, DK);
    b(c, 9, 16,  4, 6, DK);
    b(c, 4, 18,  2, 5, RE);
    b(c, 10, 18, 2, 5, RE);
    b(c, 5, 22,  1, 1, FR); // ankle flame L
    b(c, 10, 22, 1, 1, FR); // ankle flame R
    b(c, 5, 23,  1, 1, FR);
    b(c, 10, 23, 1, 1, FR);

    // ── FLAMING SWORD (right side) ────────────────────────
    b(c, 15, 2, 1, 1, FL); // pommel glow
    b(c, 15, 3, 1, 2, RE); // grip
    b(c, 14, 5, 3, 1, DK); // guard
    b(c, 15, 6, 1, 10,BK); // blade
    b(c, 15, 6, 1, 10,RE); // blade fire
    b(c, 15, 7, 1,  1, FR);
    b(c, 15, 10,1,  1, FR);
    b(c, 15, 13,1,  1, FL);
  }
}

// ─────────────────────────────────────────────────────────────
// DRAGON WHELP  (20 × 16 grid → 100 × 80 canvas)
// ─────────────────────────────────────────────────────────────

class _DragonWhelpPainter extends _Painter {
  const _DragonWhelpPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const GR = 0xFF2e6e18; // dragon green
    const GD = 0xFF1a4010; // green dark
    const GL = 0xFF50a030; // green light
    const GY = 0xFFb8883a; // golden belly
    const EY = 0xFFff6020; // red-orange eye
    const FG = 0xFFf0e0c0; // fang
    const K  = 0xFF181820;
    const WN = 0xFF3a8028; // wing membrane

    // ── BODY ──────────────────────────────────────────────
    b(c, 4, 3, 12, 8, GR);
    b(c, 5, 2, 10, 2, GR);
    b(c, 6, 1,  8, 2, GL);
    b(c, 5, 9, 12, 2, GD);
    b(c, 7, 4,  8, 5, GY);

    // Scale details
    b(c, 7, 3, 2, 1, GD);
    b(c, 11, 3,2, 1, GD);
    b(c, 9, 5, 2, 1, GD);
    b(c, 6, 6, 2, 1, GL);
    b(c, 12, 6,2, 1, GL);

    // ── HEAD ──────────────────────────────────────────────
    b(c, 0, 1, 6, 6, GR);
    b(c, 0, 1, 6, 1, GL);
    b(c, 0, 2, 2, 2, K);
    b(c, 0, 2, 2, 1, EY);
    b(c, 0, 5, 6, 1, GD);
    b(c, 0, 5, 6, 3, GR);
    b(c, 0, 8, 6, 1, K);
    b(c, 1, 6, 1, 2, FG);
    b(c, 3, 7, 1, 2, FG);
    b(c, 5, 6, 1, 2, FG);
    // Horns
    b(c, 2, 0, 1, 2, GD);
    b(c, 4, 0, 1, 2, GD);

    // ── WINGS (folded back) ───────────────────────────────
    b(c, 7, 0, 4, 3, WN);
    b(c, 11, 0,5, 2, WN);
    b(c, 7, 0, 4, 1, GL);
    b(c, 15, 1,3, 3, WN);

    // ── LEGS / CLAWS ──────────────────────────────────────
    b(c, 3, 9,  3, 5, GD);
    b(c, 13, 9, 3, 5, GD);
    b(c, 3, 13, 5, 1, GY);
    b(c, 13, 13,5, 1, GY);
    b(c, 2, 13, 1, 2, GL);  // claw L
    b(c, 3, 14, 1, 2, GL);
    b(c, 4, 13, 1, 2, GL);
    b(c, 15, 13,1, 2, GL);  // claw R
    b(c, 16, 14,1, 2, GL);
    b(c, 17, 13,1, 2, GL);

    // ── TAIL ──────────────────────────────────────────────
    b(c, 17, 4, 3, 3, GR);
    b(c, 19, 5, 1, 4, GD);
    b(c, 19, 8, 1, 2, GL); // tail tip
  }
}

// ─────────────────────────────────────────────────────────────
// ANCIENT LICH  (16 × 28 grid → 80 × 140 canvas)
// ─────────────────────────────────────────────────────────────

class _AncientLichPainter extends _Painter {
  const _AncientLichPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const BO = 0xFFd0c4a8; // ancient bone
    const BD = 0xFF907860; // bone dark
    const PU = 0xFF1a0840; // deep robe purple
    const PL = 0xFF3a1870; // robe lighter
    const EY = 0xFF60d0ff; // icy blue glow
    const CR = 0xFFd4af37; // crown gold
    const MG = 0xFF20a0e8; // ice magic
    const K  = 0xFF181820;

    // ── CROWN ─────────────────────────────────────────────
    b(c, 3, 0, 10, 3, CR);
    b(c, 3, 0, 10, 1, 0xFFf0d060); // crown top
    b(c, 4, 0, 1, 4, CR); // spike L outer
    b(c, 7, 0, 2, 5, CR); // spike center (tallest)
    b(c, 11, 0,1, 4, CR); // spike R outer
    b(c, 5, 0, 1, 3, 0xFFf0d060); // spike highlights
    b(c, 10, 0,1, 3, 0xFFf0d060);
    b(c, 7, 0, 2, 1, 0xFFf8e870); // center spike tip
    // Crown jewel
    b(c, 7, 2, 2, 2, MG);
    b(c, 7, 2, 2, 1, 0xFFa0f0ff);

    // ── SKULL ─────────────────────────────────────────────
    b(c, 3, 3, 10, 6, BO);
    b(c, 3, 3, 10, 1, 0xFFe8ddc8);
    b(c, 2, 4,  1, 5, BD);
    b(c, 13, 4, 1, 5, BD);
    b(c, 3, 4,  3, 2, K);
    b(c, 10, 4, 3, 2, K);
    b(c, 3, 4,  3, 1, EY);
    b(c, 10, 4, 3, 1, EY);
    b(c, 4, 4,  1, 1, 0xFFc0f0ff);
    b(c, 11, 4, 1, 1, 0xFFc0f0ff);
    b(c, 5, 7,  6, 1, BD);
    b(c, 4, 7,  8, 2, BO);
    b(c, 5, 8,  2, 1, K);
    b(c, 9, 8,  2, 1, K);
    b(c, 5, 8,  1, 2, 0xFFf0e8d0);
    b(c, 7, 8,  1, 2, 0xFFf0e8d0);
    b(c, 9, 8,  1, 2, 0xFFf0e8d0);
    b(c, 7, 8,  2, 1, BD); // neck

    // ── CAPE / ROBE ───────────────────────────────────────
    b(c, 0, 9,   3, 19, PL); // L cape
    b(c, 13, 9,  3, 19, PL); // R cape
    b(c, 0, 9,   3,  1, PU);
    b(c, 13, 9,  3,  1, PU);

    b(c, 2, 9,  12, 18, PU); // robe body
    b(c, 2, 9,  12,  1, PL); // robe top
    b(c, 4, 10,  8, 14, PL); // robe lighter inner
    b(c, 5, 11,  6, 10, PU); // robe core shadow
    b(c, 6, 12,  4,  6, 0xFF2a1050); // deep centre

    // ── BONE HANDS ────────────────────────────────────────
    b(c, 0, 14, 2, 8, PU);
    b(c, 14, 14,2, 8, PU);
    b(c, 0, 18, 2, 5, BO); // L hand
    b(c, 14, 18,2, 5, BO); // R hand
    b(c, 0, 22, 1, 2, BD);
    b(c, 1, 23, 1, 2, BD);
    b(c, 14, 22,1, 2, BD);
    b(c, 15, 23,1, 2, BD);

    // ── ROBE BOTTOM ───────────────────────────────────────
    b(c, 2, 24,  12, 3, PU);
    b(c, 3, 26,  10, 1, PL);
    b(c, 5, 27,   6, 1, BD);

    // ── ICE STAFF (right side) ────────────────────────────
    b(c, 15, 0, 1, 2, 0xFFe0f8ff); // ice crystal top
    b(c, 15, 2, 1, 2, MG);          // orb
    b(c, 15, 4, 1, 1, EY);          // orb glow
    b(c, 15, 5, 1, 20, BD);         // staff shaft
    b(c, 15, 8, 1,  1, MG);
    b(c, 15, 14,1,  1, MG);
    b(c, 15, 20,1,  1, EY);
    b(c, 15, 24,1,  1, MG);
    b(c, 14, 0, 1, 2, 0xFFc0e8ff); // crystal side shard
  }
}

// ─────────────────────────────────────────────────────────────
// GHOUL  (16 × 24 grid → 80 × 120 canvas)
// Feral rotting undead — hunched, long clawed arms, no weapon
// ─────────────────────────────────────────────────────────────

class _GhoulPainter extends _Painter {
  const _GhoulPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const GS = 0xFF3a4028; // ghoul grey-green skin
    const GL = 0xFF526038; // skin light
    const GD = 0xFF1a2010; // skin dark
    const EY = 0xFFc0c000; // sickly yellow eye glow
    const BO = 0xFFc8b890; // exposed bone
    const RG = 0xFF2c1c08; // tattered rags dark
    const RL = 0xFF4c3018; // rags light
    const K  = 0xFF181820;

    // ── SKULL ─────────────────────────────────────────────
    b(c, 4, 0, 8, 5, GS);
    b(c, 4, 0, 8, 1, GL);
    b(c, 3, 1, 1, 4, GD);
    b(c, 12, 1, 1, 4, GD);
    b(c, 4, 1, 3, 2, K);      // left eye socket
    b(c, 9, 1, 3, 2, K);      // right eye socket
    b(c, 4, 1, 2, 1, EY);     // left eye glow
    b(c, 9, 1, 2, 1, EY);     // right eye glow
    b(c, 7, 3, 2, 1, GD);     // nose cavity
    b(c, 4, 3, 8, 2, GS);     // jaw
    b(c, 5, 4, 1, 2, BO);     // tooth 1
    b(c, 7, 4, 1, 2, BO);     // tooth 2
    b(c, 9, 4, 1, 2, BO);     // tooth 3
    b(c, 6, 4, 1, 1, K);
    b(c, 8, 4, 1, 1, K);
    b(c, 10, 4, 1, 1, K);

    // ── NECK ──────────────────────────────────────────────
    b(c, 7, 5, 2, 2, GD);

    // ── HUNCHED TORSO ─────────────────────────────────────
    b(c, 3, 6, 10, 8, GS);
    b(c, 3, 6, 10, 1, GL);
    b(c, 3, 12, 10, 2, GD);
    b(c, 7, 7, 2, 5, GD);     // spine crease
    // Exposed ribs on sides
    b(c, 3, 7, 1, 1, BO);
    b(c, 3, 9, 1, 1, BO);
    b(c, 3, 11, 1, 1, BO);
    b(c, 12, 7, 1, 1, BO);
    b(c, 12, 9, 1, 1, BO);
    b(c, 12, 11, 1, 1, BO);

    // ── TATTERED RAGS (waist) ─────────────────────────────
    b(c, 4, 13, 8, 2, RG);
    b(c, 5, 13, 6, 1, RL);

    // ── LONG DANGLING ARMS ────────────────────────────────
    b(c, 1, 7, 3, 8, GS);     // left upper arm
    b(c, 1, 7, 3, 1, GL);
    b(c, 0, 14, 3, 5, GD);    // left forearm
    b(c, 0, 18, 1, 3, BO);    // left claws
    b(c, 1, 19, 1, 3, BO);
    b(c, 2, 18, 1, 3, BO);

    b(c, 12, 7, 3, 8, GS);    // right upper arm
    b(c, 12, 7, 3, 1, GL);
    b(c, 13, 14, 3, 5, GD);   // right forearm
    b(c, 13, 18, 1, 3, BO);   // right claws
    b(c, 14, 19, 1, 3, BO);
    b(c, 15, 18, 1, 3, BO);

    // ── CROUCHING LEGS ────────────────────────────────────
    b(c, 4, 15, 3, 5, GS);
    b(c, 9, 15, 3, 5, GS);
    b(c, 7, 15, 2, 5, GD);    // leg gap
    b(c, 3, 19, 4, 2, GD);    // left foot
    b(c, 9, 19, 4, 2, GD);    // right foot
    b(c, 3, 20, 1, 2, BO);    // toe claws
    b(c, 5, 21, 1, 2, BO);
    b(c, 9, 20, 1, 2, BO);
    b(c, 11, 21, 1, 2, BO);

    // ── Attack: right claws lunge raised ─────────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.1) {
        final off = sw * 7;
        b(c, 12, max(0.0, 13 - off), 3, 6, 0xFF1a2010);
        b(c, 13, max(0.0, 18 - off), 1, 3, 0xFFc8b890);
        b(c, 14, max(0.0, 19 - off), 1, 3, 0xFFc8b890);
        b(c, 15, max(0.0, 18 - off), 1, 3, 0xFFc8b890);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// BANSHEE  (16 × 24 grid → 80 × 120 canvas)
// Screaming spectral spirit — no solid lower body, wispy form
// ─────────────────────────────────────────────────────────────

class _BansheePainter extends _Painter {
  const _BansheePainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const WH = 0xFFe8f0ff; // ghostly white
    const WL = 0xFFb8c8e8; // ghost mid
    const WD = 0xFF7890b8; // ghost dark
    const EY = 0xFF40e8ff; // teal eye glow
    const WS = 0xFF9ab8d8; // wisp blue
    const HT = 0xFFd0d8f8; // hair tendrils
    const K  = 0xFF181820;

    // ── STREAMING HAIR TENDRILS (behind head) ─────────────
    b(c, 0, 0, 2, 9, WD);
    b(c, 14, 0, 2, 9, WD);
    b(c, 2, 0, 2, 6, HT);
    b(c, 12, 0, 2, 6, HT);
    b(c, 1, 1, 1, 5, WS);
    b(c, 14, 1, 1, 5, WS);

    // ── HEAD ──────────────────────────────────────────────
    b(c, 4, 1, 8, 6, WH);
    b(c, 4, 1, 8, 1, 0xFFffffff);
    b(c, 3, 2, 1, 5, WL);
    b(c, 12, 2, 1, 5, WL);
    // Sunken eye sockets
    b(c, 4, 2, 3, 2, WD);
    b(c, 9, 2, 3, 2, WD);
    b(c, 4, 2, 3, 1, EY);
    b(c, 9, 2, 3, 1, EY);
    b(c, 5, 2, 1, 1, 0xFFa0f8ff);
    b(c, 10, 2, 1, 1, 0xFFa0f8ff);
    // Screaming mouth (wide open)
    b(c, 4, 5, 8, 3, K);
    b(c, 5, 5, 6, 2, 0xFF101828);
    b(c, 5, 5, 1, 1, WH);     // upper teeth
    b(c, 7, 5, 2, 1, WH);
    b(c, 10, 5, 1, 1, WH);
    b(c, 5, 7, 1, 1, WH);     // lower teeth
    b(c, 8, 7, 1, 1, WH);
    b(c, 10, 7, 1, 1, WH);

    // ── NECK / UPPER BODY ─────────────────────────────────
    b(c, 6, 7, 4, 1, WL);
    b(c, 4, 8, 8, 4, WH);
    b(c, 4, 8, 8, 1, 0xFFffffff);
    b(c, 5, 9, 6, 2, WL);
    b(c, 6, 10, 4, 1, WD);

    // ── REACHING SPECTRAL ARMS ────────────────────────────
    b(c, 1, 8, 4, 4, WD);
    b(c, 1, 8, 4, 1, WL);
    b(c, 11, 8, 4, 4, WD);
    b(c, 11, 8, 4, 1, WL);
    // Finger wisps (left)
    b(c, 0, 11, 1, 4, WL);
    b(c, 1, 12, 1, 4, WH);
    b(c, 2, 11, 1, 4, WL);
    b(c, 3, 13, 1, 3, WS);
    // Finger wisps (right)
    b(c, 12, 11, 1, 4, WL);
    b(c, 13, 12, 1, 4, WH);
    b(c, 14, 11, 1, 4, WL);
    b(c, 15, 13, 1, 3, WS);

    // ── ETHEREAL LOWER BODY (wisps fading) ────────────────
    b(c, 4, 12, 8, 4, WH);
    b(c, 5, 13, 6, 3, WL);
    b(c, 6, 15, 4, 2, WD);
    b(c, 5, 17, 6, 2, WS);
    b(c, 6, 18, 4, 2, WD);
    b(c, 5, 20, 2, 2, WS);
    b(c, 9, 20, 2, 2, WS);
    b(c, 6, 21, 2, 2, WD);
    b(c, 8, 21, 2, 2, WD);
    b(c, 7, 22, 2, 1, WS);
    b(c, 6, 23, 1, 1, WD);
    b(c, 9, 23, 1, 1, WD);

    // ── Attack: scream waves radiate outward ──────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.15) {
        final w = sw * 7;
        b(c, max(0.0, 8 - w), 2, min(w, 8.0), 1, 0xFF44ddff);
        b(c, 8, 2, min(w, 8.0), 1, 0xFF44ddff);
        b(c, max(0.0, 7 - w), 4, min(w, 7.0), 1, 0xFF88eeff);
        b(c, 9, 4, min(w, 7.0), 1, 0xFF88eeff);
        b(c, max(0.0, 6 - w), 6, min(w, 6.0), 1, 0xFF44ddff);
        b(c, 10, 6, min(w, 6.0), 1, 0xFF44ddff);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// MUMMY  (16 × 24 grid → 80 × 120 canvas)
// Ancient cursed pharaoh wrapped in yellowed bandages
// ─────────────────────────────────────────────────────────────

class _MummyPainter extends _Painter {
  const _MummyPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const BW = 0xFFe0d090; // yellowed bandage
    const BD = 0xFF9a8840; // bandage dark
    const BL = 0xFFf0e8b0; // bandage light
    const SK = 0xFF2a1808; // dark exposed skin
    const EY = 0xFFff8800; // amber eyes
    const AM = 0xFFd4af37; // amulet gold
    const AK = 0xFF9a7c1c; // amulet dark
    const K  = 0xFF181820;

    // ── HEAD (wrapped) ────────────────────────────────────
    b(c, 4, 0, 8, 6, BW);
    b(c, 4, 0, 8, 1, BL);
    b(c, 3, 1, 1, 5, BD);
    b(c, 12, 1, 1, 5, BD);
    b(c, 4, 1, 8, 1, BD);     // horizontal wrap strip
    b(c, 4, 3, 8, 1, BD);     // horizontal wrap strip
    // Eyes glowing through wrappings
    b(c, 4, 2, 3, 1, K);
    b(c, 9, 2, 3, 1, K);
    b(c, 5, 2, 2, 1, EY);
    b(c, 9, 2, 2, 1, EY);
    b(c, 5, 2, 1, 1, 0xFFffcc40);
    b(c, 10, 2, 1, 1, 0xFFffcc40);
    b(c, 5, 4, 6, 2, BW);
    b(c, 4, 5, 8, 1, BD);
    b(c, 12, 4, 2, 8, BD);    // trailing strip from head

    // ── NECK ──────────────────────────────────────────────
    b(c, 6, 6, 4, 2, BW);
    b(c, 6, 7, 4, 1, BD);

    // ── SHOULDERS ─────────────────────────────────────────
    b(c, 1, 6, 4, 4, BW);
    b(c, 11, 6, 4, 4, BW);
    b(c, 1, 6, 4, 1, BL);
    b(c, 11, 6, 4, 1, BL);

    // ── CHEST (broad wraps + scarab amulet) ───────────────
    b(c, 3, 8, 10, 8, BW);
    b(c, 3, 8, 10, 1, BL);
    b(c, 3, 10, 10, 1, BD);   // wrap strip
    b(c, 3, 12, 10, 1, BD);   // wrap strip
    b(c, 6, 9, 4, 4, AM);     // amulet (drawn after strips — appears on top)
    b(c, 7, 10, 2, 2, AK);    // amulet dark center
    b(c, 7, 9, 2, 1, 0xFFf0d060); // amulet top glow

    // ── BELT ──────────────────────────────────────────────
    b(c, 3, 15, 10, 2, BD);
    b(c, 4, 15, 8, 1, BW);

    // ── ARMS (heavily wrapped) ────────────────────────────
    b(c, 1, 9, 3, 12, BW);
    b(c, 12, 9, 3, 12, BW);
    b(c, 1, 10, 3, 1, BD);    // arm wrap strip
    b(c, 1, 13, 3, 1, BD);
    b(c, 1, 16, 3, 1, BD);
    b(c, 12, 10, 3, 1, BD);
    b(c, 12, 13, 3, 1, BD);
    b(c, 12, 16, 3, 1, BD);
    b(c, 1, 20, 3, 1, SK);    // exposed dark hands
    b(c, 12, 20, 3, 1, SK);

    // ── LEGS (thick wrapped) ──────────────────────────────
    b(c, 4, 17, 3, 6, BW);
    b(c, 9, 17, 3, 6, BW);
    b(c, 7, 17, 2, 6, K);     // leg gap
    b(c, 4, 18, 3, 1, BD);    // knee wrap
    b(c, 9, 18, 3, 1, BD);
    b(c, 4, 21, 3, 1, BD);
    b(c, 9, 21, 3, 1, BD);

    // ── FEET ──────────────────────────────────────────────
    b(c, 3, 22, 4, 1, BW);
    b(c, 9, 22, 4, 1, BW);
    b(c, 3, 23, 5, 1, BD);
    b(c, 8, 23, 5, 1, BD);

    // ── DANGLING BANDAGE STRIPS ───────────────────────────
    b(c, 0, 14, 1, 7, BD);
    b(c, 15, 16, 1, 5, BD);

    // ── Attack: fists raise + amulet blazes ──────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.1) {
        final off = sw * 8;
        b(c, 1, max(0.0, 9 - off), 3, 4, 0xFFe0d090);
        b(c, 1, max(0.0, 9 - off), 3, 1, 0xFFf0e8b0);
        b(c, 12, max(0.0, 9 - off), 3, 4, 0xFFe0d090);
        b(c, 12, max(0.0, 9 - off), 3, 1, 0xFFf0e8b0);
        b(c, 6, 9, 4, 4, 0xFFffd060);
        b(c, 7, 10, 2, 2, 0xFFffff88);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// LICH (enemy)  (16 × 28 grid → 80 × 140 canvas)
// Necrotic sorcerer-king — iron crown, death-green magic
// Distinct from ANCIENT LICH (gold crown, ice magic)
// ─────────────────────────────────────────────────────────────

class _LichEnemyPainter extends _Painter {
  const _LichEnemyPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const BK = 0xFF080810; // void black
    const DK = 0xFF160824; // robe dark
    const PL = 0xFF3a1860; // robe purple-light
    const BO = 0xFFc0b090; // aged bone
    const BD = 0xFF807060; // bone dark
    const EY = 0xFF50ff30; // necrotic green eye
    const CR = 0xFF404040; // iron crown
    const CL = 0xFF686868; // crown light
    const MG = 0xFF18d010; // death magic green
    const K  = 0xFF181820;

    // ── IRON CROWN (jagged, dark) ──────────────────────────
    b(c, 3, 0, 10, 3, CR);
    b(c, 4, 0, 8, 1, CL);
    b(c, 3, 0, 2, 4, CR);     // spike L
    b(c, 7, 0, 2, 5, CL);     // center spike (tallest)
    b(c, 11, 0, 2, 4, CR);    // spike R
    b(c, 5, 0, 2, 2, CR);     // minor spike L
    b(c, 9, 0, 2, 2, CR);     // minor spike R
    // Death jewel
    b(c, 7, 2, 2, 2, EY);
    b(c, 7, 2, 2, 1, 0xFFc0ffc0);

    // ── SKULL ─────────────────────────────────────────────
    b(c, 3, 3, 10, 6, BO);
    b(c, 3, 3, 10, 1, 0xFFd8cbb0);
    b(c, 2, 4, 1, 5, BD);
    b(c, 13, 4, 1, 5, BD);
    b(c, 3, 4, 3, 2, K);
    b(c, 10, 4, 3, 2, K);
    b(c, 3, 4, 3, 1, EY);     // death-green eyes
    b(c, 10, 4, 3, 1, EY);
    b(c, 4, 4, 1, 1, 0xFFb0ffb0);
    b(c, 11, 4, 1, 1, 0xFFb0ffb0);
    b(c, 5, 7, 6, 1, BD);
    b(c, 4, 7, 8, 2, BO);
    b(c, 5, 8, 2, 1, K);
    b(c, 9, 8, 2, 1, K);
    b(c, 5, 8, 1, 2, 0xFFe8e0c0);
    b(c, 7, 8, 1, 2, 0xFFe8e0c0);
    b(c, 9, 8, 1, 2, 0xFFe8e0c0);
    b(c, 7, 9, 2, 1, BD);

    // ── CAPE / ROBE ───────────────────────────────────────
    b(c, 0, 9, 3, 19, PL);    // L cape
    b(c, 13, 9, 3, 19, PL);   // R cape
    b(c, 0, 9, 3, 1, DK);
    b(c, 13, 9, 3, 1, DK);
    b(c, 2, 9, 12, 18, BK);   // robe body
    b(c, 2, 9, 12, 1, DK);
    b(c, 4, 10, 8, 14, DK);
    b(c, 5, 11, 6, 10, BK);
    b(c, 6, 12, 4, 6, 0xFF040408); // void core

    // ── NECROTIC SIGIL on chest ────────────────────────────
    b(c, 6, 13, 4, 1, EY);    // horizontal bar
    b(c, 7, 11, 2, 5, EY);    // vertical bar
    b(c, 7, 13, 2, 1, 0xFFc0ffc0); // bright center

    // ── BONE HANDS ────────────────────────────────────────
    b(c, 0, 14, 2, 8, DK);
    b(c, 14, 14, 2, 8, DK);
    b(c, 0, 18, 2, 5, BO);
    b(c, 14, 18, 2, 5, BO);
    b(c, 0, 22, 1, 2, BD);
    b(c, 1, 23, 1, 2, BD);
    b(c, 14, 22, 1, 2, BD);
    b(c, 15, 23, 1, 2, BD);

    // ── ROBE BOTTOM ───────────────────────────────────────
    b(c, 2, 24, 12, 3, BK);
    b(c, 3, 26, 10, 1, PL);
    b(c, 5, 27, 6, 1, BD);

    // ── DEATH STAFF (right side) ──────────────────────────
    b(c, 15, 0, 1, 2, 0xFFc0ffc0); // orb glow top
    b(c, 15, 2, 1, 2, MG);
    b(c, 15, 4, 1, 1, EY);
    b(c, 15, 5, 1, 20, BD);   // staff shaft
    b(c, 15, 8, 1, 1, MG);
    b(c, 15, 14, 1, 1, MG);
    b(c, 15, 20, 1, 1, EY);
    b(c, 15, 24, 1, 1, MG);
    b(c, 14, 0, 1, 2, 0xFF80e080); // shard crystal

    // ── Attack: death orb fires from staff ───────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.15) {
        final orbX = max(0.0, 14.0 - sw * 14.0);
        b(c, orbX, 2, 2, 2, 0xFF50ff30);
        b(c, orbX, 2, 2, 1, 0xFFc0ffc0);
        if (orbX + 2 < 14) {
          b(c, orbX + 2, 3, 14 - orbX - 2, 1, 0xFF18d010);
        }
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// GOBLIN  (16 × 24 grid → 80 × 120 canvas)
// Scrappy green gremlin — huge ears, toothy grin, belt dagger
// ─────────────────────────────────────────────────────────────

class _GoblinPainter extends _Painter {
  const _GoblinPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const GN = 0xFF3a6018; // goblin green skin
    const GL = 0xFF5a8830; // skin light
    const GD = 0xFF1e3808; // skin dark
    const EY = 0xFFd8b000; // yellow eye glow
    const RG = 0xFF2c1808; // tattered rags dark
    const RL = 0xFF503020; // rags light
    const BO = 0xFFc8a040; // tooth/bone ivory
    const MT = 0xFF707880; // crude metal
    const K  = 0xFF181820;

    // ── BIG POINTED EARS ──────────────────────────────────
    b(c, 1, 1, 3, 4, GN);
    b(c, 12, 1, 3, 4, GN);
    b(c, 1, 1, 3, 1, GL);
    b(c, 12, 1, 3, 1, GL);
    b(c, 2, 2, 1, 2, GD);   // ear hollow L
    b(c, 13, 2, 1, 2, GD);  // ear hollow R

    // ── SKULL (big, wide) ─────────────────────────────────
    b(c, 3, 0, 10, 6, GN);
    b(c, 3, 0, 10, 1, GL);
    b(c, 3, 1, 1, 5, GD);
    b(c, 12, 1, 1, 5, GD);
    b(c, 5, 1, 2, 2, K);    // left eye socket
    b(c, 9, 1, 2, 2, K);    // right eye socket
    b(c, 5, 1, 2, 1, EY);
    b(c, 9, 1, 2, 1, EY);
    b(c, 6, 3, 4, 1, GD);   // flat nose
    b(c, 7, 3, 2, 1, K);    // nostrils
    // Toothy grin
    b(c, 4, 4, 8, 2, K);
    b(c, 5, 4, 6, 1, 0xFF102808);
    b(c, 5, 4, 1, 2, BO);
    b(c, 7, 4, 2, 1, BO);
    b(c, 10, 4, 1, 2, BO);  // longer tusk R

    // ── NECK ──────────────────────────────────────────────
    b(c, 7, 6, 2, 1, GD);

    // ── HUNCHED BODY ──────────────────────────────────────
    b(c, 4, 6, 8, 7, RG);
    b(c, 4, 6, 8, 1, RL);
    b(c, 5, 7, 6, 4, GN);
    b(c, 6, 8, 4, 3, GL);
    b(c, 4, 12, 8, 1, GD);

    // ── BELT ──────────────────────────────────────────────
    b(c, 4, 13, 8, 2, RG);
    b(c, 7, 13, 2, 1, BO);  // crude buckle

    // ── ARMS ──────────────────────────────────────────────
    b(c, 2, 7, 3, 8, GN);
    b(c, 2, 7, 3, 1, GL);
    b(c, 2, 14, 3, 2, GD);  // left fist
    b(c, 11, 7, 3, 8, GN);
    b(c, 11, 7, 3, 1, GL);
    // Dagger (right hand)
    b(c, 14, 5, 1, 1, BO);  // pommel
    b(c, 14, 6, 1, 2, RG);  // grip
    b(c, 13, 8, 3, 1, MT);  // guard
    b(c, 14, 9, 1, 6, MT);  // blade
    b(c, 14, 14, 1, 1, GL); // blade tip

    // ── LEGS ──────────────────────────────────────────────
    b(c, 5, 15, 3, 6, RG);
    b(c, 8, 15, 3, 6, RG);
    b(c, 5, 15, 3, 1, RL);
    b(c, 8, 15, 3, 1, RL);
    b(c, 4, 20, 4, 2, RG);
    b(c, 8, 20, 4, 2, RG);
    b(c, 4, 21, 5, 1, K);
    b(c, 8, 21, 5, 1, K);

    // ── Attack: dagger thrusts overhead ──────────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.05) {
        final off = sw * 6;
        b(c, 14, max(0.0, 5 - off), 1, 1, 0xFFc8a040);
        b(c, 14, max(0.0, 6 - off), 1, 2, 0xFF2c1808);
        b(c, 13, max(0.0, 8 - off), 3, 1, 0xFF707880);
        b(c, 14, max(0.0, 9 - off), 1, 6, 0xFFaaa8b0);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// IMP  (12 × 14 grid → 60 × 70 canvas)
// Tiny fiend — horns, bat wings, claws, barbed tail
// ─────────────────────────────────────────────────────────────

class _ImpPainter extends _Painter {
  const _ImpPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const RD = 0xFF8b1020; // imp red skin
    const RL = 0xFFb83040; // skin light
    const RK = 0xFF4a0810; // skin dark
    const EY = 0xFFff8000; // orange eye glow
    const HN = 0xFF1a0c08; // horn dark
    const WN = 0xFF6a1828; // wing membrane
    const TL = 0xFF280808; // tail
    const K  = 0xFF181820;

    // ── HORNS ─────────────────────────────────────────────
    b(c, 3, 0, 1, 2, HN);
    b(c, 8, 0, 1, 2, HN);

    // ── HEAD ──────────────────────────────────────────────
    b(c, 3, 1, 6, 5, RD);
    b(c, 3, 1, 6, 1, RL);
    b(c, 2, 2, 1, 4, RK);
    b(c, 9, 2, 1, 4, RK);
    b(c, 3, 2, 2, 1, K);    // left eye
    b(c, 7, 2, 2, 1, K);    // right eye
    b(c, 3, 2, 1, 1, EY);
    b(c, 8, 2, 1, 1, EY);
    b(c, 5, 4, 2, 1, RK);   // snout
    b(c, 4, 5, 4, 1, K);    // mouth
    b(c, 5, 5, 1, 1, 0xFFe0d0b0); // fang L
    b(c, 7, 5, 1, 1, 0xFFe0d0b0); // fang R

    // ── WINGS (behind body) ───────────────────────────────
    b(c, 0, 4, 3, 6, WN);
    b(c, 0, 4, 3, 1, 0xFF9a2838);
    b(c, 9, 4, 3, 6, WN);
    b(c, 9, 4, 3, 1, 0xFF9a2838);
    b(c, 0, 9, 2, 3, RK);
    b(c, 10, 9, 2, 3, RK);

    // ── BODY ──────────────────────────────────────────────
    b(c, 4, 6, 4, 5, RD);
    b(c, 4, 6, 4, 1, RL);
    b(c, 5, 7, 2, 3, RL);

    // ── ARMS + CLAWS ──────────────────────────────────────
    b(c, 2, 7, 2, 4, RD);
    b(c, 1, 10, 1, 2, RK);
    b(c, 2, 11, 1, 2, RK);
    b(c, 8, 7, 2, 4, RD);
    b(c, 9, 10, 1, 2, RK);
    b(c, 10, 11, 1, 2, RK);

    // ── LEGS ──────────────────────────────────────────────
    b(c, 4, 11, 2, 3, RD);
    b(c, 6, 11, 2, 3, RD);
    b(c, 3, 13, 3, 1, RK);
    b(c, 6, 13, 3, 1, RK);

    // ── BARBED TAIL ───────────────────────────────────────
    b(c, 9, 8, 1, 3, TL);
    b(c, 10, 10, 1, 2, TL);
    b(c, 11, 12, 1, 2, TL); // tail tip

    // ── Attack: claw slash marks fire forward ────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.2) {
        final len = min(sw * 5, 4.0);
        b(c, 0, 7, len, 1, 0xFFb83040);
        b(c, 0, 9, len, 1, 0xFFb83040);
        b(c, 0, 8, min(sw * 4, 3.0), 1, 0xFFff8000);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// KOBOLD  (16 × 24 grid → 80 × 120 canvas)
// Reptilian tunnel-warrior — scales, snout, crude spear
// ─────────────────────────────────────────────────────────────

class _KoboldPainter extends _Painter {
  const _KoboldPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const SC = 0xFF7a5828; // brown scales
    const SL = 0xFF9a7840; // scale light
    const SD = 0xFF4a3010; // scale dark
    const EY = 0xFF60c860; // slit green eye
    const RG = 0xFF2c1808; // crude rags
    const RL = 0xFF4a2e18; // rags light
    const MT = 0xFF888090; // crude metal
    const ML = 0xFFaaa8b0; // metal light
    const K  = 0xFF181820;

    // ── HEAD (reptilian, elongated snout) ─────────────────
    b(c, 4, 0, 8, 5, SC);
    b(c, 4, 0, 8, 1, SL);
    b(c, 3, 1, 1, 4, SD);
    b(c, 12, 1, 1, 4, SD);
    b(c, 4, 1, 3, 1, K);    // left slit eye
    b(c, 9, 1, 3, 1, K);    // right slit eye
    b(c, 5, 1, 2, 1, EY);
    b(c, 9, 1, 2, 1, EY);
    // Snout (forward-pointing)
    b(c, 3, 2, 10, 4, SC);
    b(c, 3, 2, 10, 1, SL);
    b(c, 4, 3, 8, 1, SD);
    b(c, 6, 3, 1, 1, K);    // nostril L
    b(c, 9, 3, 1, 1, K);    // nostril R
    b(c, 4, 5, 8, 1, K);    // mouth line
    b(c, 5, 4, 1, 2, 0xFFd0c090); // fang L
    b(c, 10, 4, 1, 2, 0xFFd0c090); // fang R

    // ── NECK ──────────────────────────────────────────────
    b(c, 7, 6, 2, 1, SD);

    // ── WIRY BODY ─────────────────────────────────────────
    b(c, 4, 6, 8, 8, SC);
    b(c, 4, 6, 8, 1, SL);
    b(c, 4, 12, 8, 2, SD);
    b(c, 5, 7, 6, 6, RG);
    b(c, 6, 8, 4, 4, RL);
    b(c, 4, 8, 1, 1, SL); b(c, 4, 10, 1, 1, SL); b(c, 4, 12, 1, 1, SL);
    b(c, 11, 8, 1, 1, SL); b(c, 11, 10, 1, 1, SL); b(c, 11, 12, 1, 1, SL);

    // ── BELT ──────────────────────────────────────────────
    b(c, 4, 14, 8, 2, RG);
    b(c, 5, 14, 6, 1, RL);

    // ── ARMS ──────────────────────────────────────────────
    b(c, 2, 7, 3, 9, SC);
    b(c, 2, 7, 3, 1, SL);
    b(c, 11, 7, 3, 9, SC);
    b(c, 11, 7, 3, 1, SL);
    b(c, 2, 15, 3, 2, SD);
    b(c, 11, 15, 3, 2, SD);

    // ── CRUDE SPEAR (right side) ──────────────────────────
    b(c, 15, 0, 1, 3, ML);  // spearhead
    b(c, 15, 2, 1, 1, 0xFFd0d0c0);
    b(c, 15, 3, 1, 18, SD); // shaft dark
    b(c, 15, 4, 1, 16, RL); // shaft light

    // ── LEGS (digitigrade) ────────────────────────────────
    b(c, 5, 16, 3, 5, SC);
    b(c, 8, 16, 3, 5, SC);
    b(c, 5, 16, 3, 1, SL);
    b(c, 8, 16, 3, 1, SL);
    b(c, 7, 16, 1, 5, K);
    b(c, 4, 20, 4, 2, SD);
    b(c, 8, 20, 4, 2, SD);
    b(c, 3, 21, 2, 1, SC); b(c, 6, 21, 2, 1, SC);
    b(c, 8, 21, 2, 1, SC); b(c, 11, 21, 2, 1, SC);

    // ── Attack: spear tip lunges forward ─────────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.15) {
        final tipX = max(0.0, 14.0 - sw * 12.0);
        b(c, tipX, 0, 2, 3, 0xFFaaa8b0);
        b(c, tipX, 0, 2, 1, 0xFFd0d0c0);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// GNOLL  (16 × 24 grid → 80 × 120 canvas)
// Hyena-headed warrior — spotted fur, fanged muzzle, axe
// ─────────────────────────────────────────────────────────────

class _GnollPainter extends _Painter {
  const _GnollPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const FN = 0xFF9a8448; // fur tan
    const FL = 0xFFb8a060; // fur light
    const FD = 0xFF5a4820; // fur dark
    const SP = 0xFF1a1810; // spots
    const EY = 0xFF406820; // green eye
    const MZ = 0xFF6a5430; // muzzle dark
    const AR = 0xFF7a7878; // crude armor
    const AX = 0xFF909098; // axe metal
    const K  = 0xFF181820;

    // ── POINTED EARS ──────────────────────────────────────
    b(c, 3, 0, 2, 3, FN);
    b(c, 11, 0, 2, 3, FN);
    b(c, 3, 0, 1, 2, FD);
    b(c, 12, 0, 1, 2, FD);

    // ── SKULL ─────────────────────────────────────────────
    b(c, 3, 2, 10, 4, FN);
    b(c, 3, 2, 10, 1, FL);
    b(c, 3, 3, 1, 3, FD);
    b(c, 12, 3, 1, 3, FD);
    b(c, 3, 1, 4, 1, FD);   // brow ridge L
    b(c, 9, 1, 4, 1, FD);   // brow ridge R
    b(c, 4, 3, 2, 1, K);
    b(c, 10, 3, 2, 1, K);
    b(c, 4, 3, 2, 1, EY);
    b(c, 10, 3, 2, 1, EY);
    b(c, 7, 2, 1, 1, SP); b(c, 9, 3, 1, 1, SP); b(c, 5, 4, 1, 1, SP);

    // ── HYENA MUZZLE ──────────────────────────────────────
    b(c, 4, 5, 8, 4, MZ);
    b(c, 4, 5, 8, 1, FN);
    b(c, 5, 6, 6, 1, FD);
    b(c, 4, 8, 8, 1, K);    // mouth line
    b(c, 5, 7, 1, 2, 0xFFe0c890); // fang L
    b(c, 10, 7, 1, 2, 0xFFe0c890); // fang R

    // ── NECK ──────────────────────────────────────────────
    b(c, 6, 9, 4, 2, FN);
    b(c, 6, 10, 4, 1, FD);

    // ── BODY ──────────────────────────────────────────────
    b(c, 3, 10, 10, 8, FN);
    b(c, 3, 10, 10, 1, FL);
    b(c, 3, 16, 10, 2, FD);
    b(c, 5, 11, 6, 5, AR);  // crude armor vest
    b(c, 5, 11, 6, 1, 0xFF9a9898);
    b(c, 3, 11, 1, 1, SP); b(c, 3, 13, 1, 1, SP); b(c, 3, 15, 1, 1, SP);
    b(c, 12, 11, 1, 1, SP); b(c, 12, 14, 1, 1, SP);

    // ── BELT ──────────────────────────────────────────────
    b(c, 4, 17, 8, 2, FD);
    b(c, 5, 17, 6, 1, MZ);

    // ── ARMS ──────────────────────────────────────────────
    b(c, 1, 10, 3, 9, FN);
    b(c, 1, 10, 3, 1, FL);
    b(c, 12, 10, 3, 9, FN);
    b(c, 12, 10, 3, 1, FL);
    b(c, 1, 18, 3, 2, FD);
    // Axe (right hand)
    b(c, 14, 7, 1, 14, MZ); // handle
    b(c, 13, 7, 3, 1, AX);  // axe head top
    b(c, 13, 8, 3, 4, AX);  // axe blade
    b(c, 12, 9, 2, 2, 0xFFb0b0b8); // blade bright edge
    b(c, 13, 12, 3, 1, AX); // blade bottom

    // ── LEGS ──────────────────────────────────────────────
    b(c, 4, 19, 3, 4, FD);
    b(c, 9, 19, 3, 4, FD);
    b(c, 7, 19, 2, 4, K);
    b(c, 4, 20, 1, 1, SP); b(c, 9, 21, 1, 1, SP);
    b(c, 3, 22, 4, 2, FD);
    b(c, 9, 22, 4, 2, FD);
    b(c, 3, 23, 5, 1, K);
    b(c, 8, 23, 5, 1, K);

    // ── Attack: axe raised overhead ───────────────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.05) {
        final off = sw * 7;
        b(c, 14, max(0.0, 6 - off), 1, 7, 0xFF1a1810);
        b(c, 12, max(0.0, 7 - off), 2, 1, 0xFFb0b0b8);
        b(c, 13, max(0.0, 7 - off), 3, 5, 0xFF909098);
        b(c, 13, max(0.0, 12 - off), 3, 1, 0xFF909098);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// HOBGOBLIN  (16 × 24 grid → 80 × 120 canvas)
// Disciplined iron-armored soldier — helm, surcoat, sword
// ─────────────────────────────────────────────────────────────

class _HobgoblinPainter extends _Painter {
  const _HobgoblinPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const HG = 0xFF507838; // hobgoblin green skin
    const HL = 0xFF6a9850; // skin light
    const HD = 0xFF304820; // skin dark
    const EY = 0xFFd0a000; // amber eye
    const IR = 0xFF686870; // iron
    const IL = 0xFF909098; // iron light
    const ID = 0xFF404048; // iron dark
    const BL = 0xFF2838a0; // surcoat blue
    const GD = 0xFFb09030; // gold trim
    const K  = 0xFF181820;

    // ── IRON HELM ─────────────────────────────────────────
    b(c, 4, 0, 8, 5, IR);
    b(c, 4, 0, 8, 1, IL);
    b(c, 3, 1, 1, 4, ID);
    b(c, 12, 1, 1, 4, ID);
    b(c, 4, 3, 8, 1, ID);   // visor band
    b(c, 5, 3, 6, 1, 0xFF101018); // visor slit
    b(c, 4, 4, 8, 1, GD);   // chin guard gold trim

    // ── FACE (below helm, green skin) ─────────────────────
    b(c, 4, 5, 8, 3, HG);
    b(c, 5, 5, 6, 1, HL);
    b(c, 5, 5, 2, 1, K);
    b(c, 9, 5, 2, 1, K);
    b(c, 5, 5, 2, 1, EY);
    b(c, 9, 5, 2, 1, EY);
    b(c, 6, 7, 1, 2, 0xFFd0c890); // tusk L
    b(c, 9, 7, 1, 2, 0xFFd0c890); // tusk R

    // ── NECK ──────────────────────────────────────────────
    b(c, 7, 8, 2, 1, HD);

    // ── PAULDRONS ─────────────────────────────────────────
    b(c, 1, 8, 4, 3, IR);
    b(c, 11, 8, 4, 3, IR);
    b(c, 1, 8, 4, 1, IL);
    b(c, 11, 8, 4, 1, IL);
    b(c, 1, 10, 4, 1, ID);
    b(c, 11, 10, 4, 1, ID);

    // ── CHEST PLATE ───────────────────────────────────────
    b(c, 4, 8, 8, 8, ID);
    b(c, 5, 9, 6, 6, IR);
    b(c, 5, 9, 6, 1, IL);
    b(c, 6, 10, 4, 5, BL);  // surcoat
    b(c, 6, 10, 4, 1, 0xFF3848c0);
    b(c, 7, 12, 2, 1, GD);  // rank insignia

    // ── BELT ──────────────────────────────────────────────
    b(c, 4, 15, 8, 2, ID);
    b(c, 6, 15, 4, 2, BL);
    b(c, 7, 15, 2, 1, GD);

    // ── ARMS (plate) ──────────────────────────────────────
    b(c, 1, 11, 3, 8, IR);
    b(c, 1, 11, 3, 1, IL);
    b(c, 12, 11, 3, 8, IR);
    b(c, 12, 11, 3, 1, IL);
    b(c, 1, 18, 3, 2, ID);  // gauntlet L
    b(c, 12, 18, 3, 2, ID); // gauntlet R

    // ── SWORD (right side) ────────────────────────────────
    b(c, 15, 3, 1, 1, GD);  // pommel
    b(c, 15, 4, 1, 2, ID);  // grip
    b(c, 14, 6, 3, 1, IR);  // crossguard
    b(c, 15, 7, 1, 10, IL); // blade
    b(c, 15, 7, 1, 10, 0xFFd0d8e0); // bright edge

    // ── LEGS (plate) ──────────────────────────────────────
    b(c, 4, 17, 3, 6, IR);
    b(c, 9, 17, 3, 6, IR);
    b(c, 4, 17, 3, 1, IL);
    b(c, 9, 17, 3, 1, IL);
    b(c, 7, 17, 2, 6, BL);  // surcoat between legs
    b(c, 3, 22, 5, 2, ID);  // sabatons
    b(c, 8, 22, 5, 2, ID);
    b(c, 3, 22, 5, 1, IR);
    b(c, 8, 22, 5, 1, IR);

    // ── Attack: sword slashes overhead ───────────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.05) {
        final off = sw * 8;
        b(c, 15, max(0.0, 3 - off), 1, 1, 0xFFb09030);
        b(c, 15, max(0.0, 4 - off), 1, 2, 0xFF404048);
        b(c, 14, max(0.0, 6 - off), 2, 1, 0xFF909098);
        b(c, 15, max(0.0, 7 - off), 1, 10, 0xFFd0d8e0);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// ORC  (16 × 24 grid → 80 × 120 canvas)
// Muscular green brute — wide jaw, upward tusks, spiked club
// ─────────────────────────────────────────────────────────────

class _OrcPainter extends _Painter {
  const _OrcPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const OR = 0xFF4a6828; // orc green skin
    const OL = 0xFF6a8840; // skin light
    const OD = 0xFF283810; // skin dark
    const EY = 0xFFe07810; // amber-orange eye
    const TK = 0xFFd8c080; // tusk ivory
    const LR = 0xFF3a1808; // leather dark
    const LL = 0xFF5a3018; // leather light
    const MX = 0xFF808880; // crude metal
    const K  = 0xFF181820;

    // ── HEAD (wide, brutish jaw) ───────────────────────────
    b(c, 3, 0, 10, 6, OR);
    b(c, 3, 0, 10, 1, OL);
    b(c, 2, 1, 1, 5, OD);
    b(c, 13, 1, 1, 5, OD);
    b(c, 3, 1, 4, 1, OD);   // brow ridge L
    b(c, 9, 1, 4, 1, OD);   // brow ridge R
    b(c, 4, 2, 3, 2, K);
    b(c, 9, 2, 3, 2, K);
    b(c, 4, 2, 3, 1, EY);
    b(c, 9, 2, 3, 1, EY);
    b(c, 6, 3, 4, 1, OD);   // flat nose
    b(c, 7, 3, 2, 1, K);    // nostrils
    b(c, 3, 4, 10, 3, OR);  // wide jaw
    b(c, 3, 6, 10, 1, OD);
    b(c, 5, 5, 1, 3, TK);   // upward tusk L
    b(c, 10, 5, 1, 3, TK);  // upward tusk R
    b(c, 4, 4, 1, 2, TK);
    b(c, 11, 4, 1, 2, TK);
    b(c, 7, 5, 2, 1, K);    // mouth gap

    // ── NECK ──────────────────────────────────────────────
    b(c, 6, 7, 4, 2, OR);
    b(c, 6, 8, 4, 1, OD);

    // ── WIDE BODY ─────────────────────────────────────────
    b(c, 2, 8, 12, 9, OR);
    b(c, 2, 8, 12, 1, OL);
    b(c, 2, 15, 12, 2, OD);
    b(c, 4, 9, 8, 6, LR);   // leather armor vest
    b(c, 5, 9, 6, 5, LL);
    b(c, 6, 10, 4, 4, LR);

    // ── BELT ──────────────────────────────────────────────
    b(c, 3, 16, 10, 2, LR);
    b(c, 4, 16, 8, 1, LL);
    b(c, 7, 16, 2, 1, MX);

    // ── ARMS (muscular) ───────────────────────────────────
    b(c, 0, 8, 3, 10, OR);
    b(c, 0, 8, 3, 1, OL);
    b(c, 13, 8, 3, 10, OR);
    b(c, 13, 8, 3, 1, OL);
    b(c, 0, 17, 3, 2, OD);
    b(c, 13, 17, 3, 2, OD);

    // ── SPIKED CLUB (right side) ──────────────────────────
    b(c, 15, 2, 1, 18, LR); // shaft
    b(c, 14, 2, 3, 4, MX);  // club head
    b(c, 13, 1, 1, 3, MX);  // spike L
    b(c, 15, 0, 1, 3, MX);  // spike top
    b(c, 13, 1, 1, 1, 0xFFc0c0c8);
    b(c, 15, 0, 1, 1, 0xFFc0c0c8);

    // ── LEGS ──────────────────────────────────────────────
    b(c, 4, 18, 3, 5, OR);
    b(c, 9, 18, 3, 5, OR);
    b(c, 4, 18, 3, 1, OL);
    b(c, 9, 18, 3, 1, OL);
    b(c, 7, 18, 2, 5, OD);
    b(c, 3, 22, 5, 2, LR);  // crude boots
    b(c, 8, 22, 5, 2, LR);
    b(c, 3, 23, 6, 1, K);
    b(c, 8, 23, 5, 1, K);

    // ── Attack: club swings overhead ─────────────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.05) {
        final off = sw * 8;
        b(c, 14, max(0.0, 2 - off), 2, 4, 0xFF808880);
        b(c, 13, max(0.0, 1 - off), 1, 3, 0xFF808880);
        b(c, 14, max(0.0, 0 - off), 1, 3, 0xFF808880);
        b(c, 13, max(0.0, 1 - off), 1, 1, 0xFFc0c0c8);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// HARPY  (16 × 24 grid → 80 × 120 canvas)
// Winged predator — spread feathered wings, taloned legs
// ─────────────────────────────────────────────────────────────

class _HarpyPainter extends _Painter {
  const _HarpyPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const FT = 0xFF8a6030; // feather tawny
    const FL = 0xFFb08040; // feather light
    const FD = 0xFF4a3010; // feather dark
    const SK = 0xFFe0b880; // skin
    const SL = 0xFFf0d0a0; // skin light
    const EY = 0xFFd04020; // fierce red eye
    const TL = 0xFF3a2008; // talon
    const HR = 0xFF1a1008; // dark hair
    const K  = 0xFF181820;

    // ── WILD HAIR (behind head) ───────────────────────────
    b(c, 2, 0, 3, 5, HR);
    b(c, 11, 0, 3, 5, HR);
    b(c, 3, 0, 2, 3, FD);

    // ── HEAD ──────────────────────────────────────────────
    b(c, 4, 0, 8, 6, SK);
    b(c, 4, 0, 8, 1, SL);
    b(c, 3, 1, 1, 5, SK);
    b(c, 12, 1, 1, 5, SK);
    b(c, 5, 1, 2, 2, K);
    b(c, 9, 1, 2, 2, K);
    b(c, 5, 1, 1, 1, EY);
    b(c, 10, 1, 1, 1, EY);
    b(c, 7, 3, 2, 1, SK);   // nose bridge
    b(c, 5, 4, 6, 2, K);    // beak/mouth
    b(c, 6, 4, 4, 1, 0xFFd09000); // beak gold
    b(c, 5, 5, 6, 1, SK);

    // ── NECK ──────────────────────────────────────────────
    b(c, 7, 6, 2, 2, SK);

    // ── WINGS SPREAD BEHIND BODY ──────────────────────────
    // Left wing
    b(c, 0, 4, 4, 14, FT);
    b(c, 0, 4, 4, 1, FL);
    b(c, 0, 5, 1, 12, FD);  // leading edge
    b(c, 1, 6, 2, 10, FL);
    b(c, 0, 16, 4, 3, FD);  // lower feather tips
    b(c, 0, 17, 1, 3, FT);
    b(c, 1, 18, 1, 3, FT);
    b(c, 2, 17, 1, 2, FD);
    b(c, 3, 16, 1, 2, FD);
    // Right wing
    b(c, 12, 4, 4, 14, FT);
    b(c, 12, 4, 4, 1, FL);
    b(c, 15, 5, 1, 12, FD);
    b(c, 13, 6, 2, 10, FL);
    b(c, 12, 16, 4, 3, FD);
    b(c, 15, 17, 1, 3, FT);
    b(c, 14, 18, 1, 3, FT);
    b(c, 13, 17, 1, 2, FD);
    b(c, 12, 16, 1, 2, FD);

    // ── BODY (lithe) ──────────────────────────────────────
    b(c, 4, 7, 8, 8, SK);
    b(c, 4, 7, 8, 1, SL);
    b(c, 4, 13, 8, 2, 0xFFb08060);
    // Feathered arm-wings
    b(c, 4, 8, 2, 6, FT);
    b(c, 10, 8, 2, 6, FT);
    b(c, 4, 10, 2, 3, FL);
    b(c, 10, 10, 2, 3, FL);

    // ── LOIN WRAP (feathers) ──────────────────────────────
    b(c, 5, 14, 6, 3, FD);
    b(c, 6, 14, 4, 2, FT);

    // ── TALONED LEGS ──────────────────────────────────────
    b(c, 5, 17, 3, 3, SK);
    b(c, 8, 17, 3, 3, SK);
    b(c, 5, 19, 3, 1, TL);
    b(c, 8, 19, 3, 1, TL);
    // Forward-facing talons
    b(c, 4, 20, 1, 3, TL);
    b(c, 5, 21, 1, 3, TL);
    b(c, 6, 20, 1, 3, TL);
    b(c, 8, 20, 1, 3, TL);
    b(c, 9, 21, 1, 3, TL);
    b(c, 10, 20, 1, 3, TL);

    // ── Attack: talons strike forward ────────────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.1) {
        final ext = sw * 3;
        b(c, max(0.0, 4 - ext), 20, 1, 3, 0xFF3a2008);
        b(c, max(0.0, 5 - ext), 21, 1, 3, 0xFF3a2008);
        b(c, max(0.0, 6 - ext), 20, 1, 3, 0xFF3a2008);
        b(c, max(0.0, 8 - ext), 20, 1, 3, 0xFF3a2008);
        b(c, max(0.0, 9 - ext), 21, 1, 3, 0xFF3a2008);
        b(c, max(0.0, 10 - ext), 20, 1, 3, 0xFF3a2008);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// GARGOYLE  (16 × 24 grid → 80 × 120 canvas)
// Stone sentinel — wings furled, fanged jaw, orange eye-glow
// ─────────────────────────────────────────────────────────────

class _GargoylePainter extends _Painter {
  const _GargoylePainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const GY = 0xFF787888; // stone grey
    const GL = 0xFF989ab0; // stone light
    const GD = 0xFF505060; // stone dark
    const CR = 0xFF404050; // stone crack
    const EY = 0xFFff6020; // eye glow
    const HN = 0xFF383848; // horn
    const K  = 0xFF181820;

    // ── HORNS ─────────────────────────────────────────────
    b(c, 4, 0, 1, 3, HN);
    b(c, 5, 0, 1, 2, GD);
    b(c, 10, 0, 1, 3, HN);
    b(c, 11, 0, 1, 2, GD);

    // ── HEAD (brutish, fanged) ─────────────────────────────
    b(c, 3, 2, 10, 5, GY);
    b(c, 3, 2, 10, 1, GL);
    b(c, 2, 3, 1, 4, GD);
    b(c, 13, 3, 1, 4, GD);
    b(c, 3, 3, 3, 2, K);
    b(c, 10, 3, 3, 2, K);
    b(c, 3, 3, 3, 1, EY);
    b(c, 10, 3, 3, 1, EY);
    b(c, 4, 3, 1, 1, 0xFFff9040);
    b(c, 11, 3, 1, 1, 0xFFff9040);
    b(c, 5, 5, 6, 1, GD);   // brow crease
    b(c, 7, 3, 1, 2, CR);   // face crack
    // Wide jaw + stone fangs
    b(c, 3, 6, 10, 2, GY);
    b(c, 4, 6, 1, 3, GL);   // fang L
    b(c, 6, 6, 1, 3, GL);   // fang M
    b(c, 10, 6, 1, 3, GL);  // fang R
    b(c, 12, 6, 1, 3, GL);  // fang far R
    b(c, 5, 6, 1, 1, K); b(c, 7, 6, 3, 1, K); b(c, 11, 6, 1, 1, K);

    // ── NECK ──────────────────────────────────────────────
    b(c, 7, 8, 2, 1, GD);

    // ── WINGS FURLED AROUND BODY ──────────────────────────
    b(c, 0, 6, 4, 15, GD);  // left wing outer
    b(c, 1, 7, 3, 13, GY);  // left wing surface
    b(c, 12, 6, 4, 15, GD); // right wing outer
    b(c, 12, 7, 3, 13, GY); // right wing surface
    b(c, 0, 9, 1, 3, CR); b(c, 0, 14, 1, 3, CR);   // membrane cracks L
    b(c, 15, 9, 1, 3, CR); b(c, 15, 14, 1, 3, CR); // membrane cracks R

    // ── BODY (hunched stone) ──────────────────────────────
    b(c, 3, 8, 10, 9, GY);
    b(c, 3, 8, 10, 1, GL);
    b(c, 3, 15, 10, 2, GD);
    b(c, 4, 9, 8, 7, GD);
    b(c, 5, 10, 6, 5, GY);
    b(c, 6, 11, 4, 3, GL);
    b(c, 6, 10, 1, 3, CR);  // body crack L
    b(c, 9, 11, 1, 4, CR);  // body crack R

    // ── CLAWED LEGS ───────────────────────────────────────
    b(c, 4, 16, 3, 5, GD);
    b(c, 9, 16, 3, 5, GD);
    b(c, 4, 16, 3, 1, GY);
    b(c, 9, 16, 3, 1, GY);
    b(c, 7, 16, 2, 5, K);
    b(c, 3, 20, 2, 3, GD);  // claws L
    b(c, 5, 21, 2, 3, GD);
    b(c, 9, 20, 2, 3, GD);  // claws R
    b(c, 11, 21, 2, 3, GD);

    // ── Attack: stone fist punch ─────────────────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.1) {
        final ext = sw * 4;
        b(c, max(0.0, 12 - ext), 12, min(ext + 2, 6.0), 3, 0xFF787888);
        b(c, max(0.0, 12 - ext), 12, min(ext + 2, 6.0), 1, 0xFF989ab0);
        b(c, max(0.0, 12 - ext), 14, min(ext + 2, 6.0), 1, 0xFF505060);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// BASILISK  (24 × 16 grid → 120 × 80 canvas)
// Low wide lizard — six eyes, spine ridge, powerful jaw
// ─────────────────────────────────────────────────────────────

class _BasiliskPainter extends _Painter {
  const _BasiliskPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const SC = 0xFF3a5020; // dark green scales
    const SL = 0xFF5a7030; // scale light
    const SD = 0xFF202c10; // scale dark
    const EY = 0xFFff4010; // petrifying eye
    const FG = 0xFFe0d080; // fang ivory
    const BL = 0xFF788050; // belly lighter
    const K  = 0xFF181820;

    // ── MAIN BODY ─────────────────────────────────────────
    b(c, 4, 3, 16, 8, SC);
    b(c, 5, 2, 14, 2, SC);
    b(c, 6, 1, 12, 2, SL);  // spine highlight
    b(c, 5, 9, 16, 2, SD);  // belly shadow
    b(c, 7, 5, 10, 4, BL);  // belly stripe

    // ── HEAD (large, wide) ────────────────────────────────
    b(c, 0, 2, 6, 8, SC);
    b(c, 0, 2, 6, 1, SL);
    b(c, 0, 9, 6, 1, SD);
    // Head eyes
    b(c, 0, 2, 2, 2, K);
    b(c, 0, 2, 2, 1, EY);
    b(c, 0, 2, 1, 1, 0xFFff8040);
    b(c, 2, 3, 2, 2, K);
    b(c, 2, 3, 2, 1, EY);
    b(c, 0, 5, 2, 2, K);
    b(c, 0, 5, 2, 1, EY);
    // Snout and mouth
    b(c, 0, 7, 6, 3, SC);
    b(c, 0, 9, 6, 1, K);
    b(c, 1, 8, 1, 2, FG);
    b(c, 3, 7, 1, 2, FG);
    b(c, 5, 8, 1, 2, FG);

    // ── SPINE EYES (along back) ────────────────────────────
    b(c, 8, 2, 2, 1, K);  b(c, 8, 2, 2, 1, EY);
    b(c, 12, 1, 2, 1, K); b(c, 12, 1, 2, 1, EY);
    b(c, 16, 2, 2, 1, K); b(c, 16, 2, 2, 1, EY);
    // Spinal ridge bumps
    b(c, 7, 1, 1, 2, SD);
    b(c, 10, 0, 1, 2, SD);
    b(c, 13, 0, 1, 2, SD);
    b(c, 17, 1, 1, 2, SD);
    b(c, 20, 1, 1, 2, SD);

    // ── FRONT LEGS ────────────────────────────────────────
    b(c, 3, 10, 4, 4, SD);
    b(c, 3, 10, 4, 1, SC);
    b(c, 2, 13, 1, 3, SL);
    b(c, 3, 13, 1, 3, SL);
    b(c, 4, 13, 1, 3, SL);
    b(c, 5, 14, 1, 2, SL);

    // ── BACK LEGS ─────────────────────────────────────────
    b(c, 15, 10, 4, 4, SD);
    b(c, 15, 10, 4, 1, SC);
    b(c, 14, 13, 1, 3, SL);
    b(c, 15, 13, 1, 3, SL);
    b(c, 16, 13, 1, 3, SL);
    b(c, 17, 14, 1, 2, SL);

    // ── SCALE DETAIL ──────────────────────────────────────
    b(c, 7, 4, 2, 1, SD); b(c, 11, 4, 2, 1, SD); b(c, 14, 5, 2, 1, SD);
    b(c, 9, 6, 2, 1, SL); b(c, 13, 7, 2, 1, SL);

    // ── TAPERING TAIL ─────────────────────────────────────
    b(c, 19, 4, 5, 4, SC);
    b(c, 20, 3, 4, 2, SL);
    b(c, 21, 6, 3, 3, SD);
    b(c, 22, 7, 2, 3, SC);
    b(c, 23, 8, 1, 3, SD);

    // ── Attack: all eyes blaze + petrification beam ──────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.15) {
        b(c, 0, 2, 2, 2, 0xFFffa060);
        b(c, 2, 3, 2, 2, 0xFFffa060);
        b(c, 0, 5, 2, 2, 0xFFffa060);
        b(c, 8, 2, 2, 1, 0xFFffa060);
        b(c, 12, 1, 2, 1, 0xFFffa060);
        b(c, 16, 2, 2, 1, 0xFFffa060);
        if (sw > 0.3) {
          final beamLen = min(sw * 10, 8.0);
          b(c, 0, 3, beamLen, 2, 0xFFff6030);
          b(c, 0, 4, beamLen, 1, 0xFFffffff);
        }
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// CHIMERA  (24 × 16 grid → 120 × 80 canvas)
// Three-headed nightmare — lion body, goat spine, serpent tail
// ─────────────────────────────────────────────────────────────

class _ChimeraPainter extends _Painter {
  const _ChimeraPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const LN = 0xFFc89040; // lion tawny
    const LL = 0xFFe0b060; // lion light
    const LD = 0xFF806020; // lion dark
    const MN = 0xFF5a3010; // mane dark
    const ML = 0xFF8a5820; // mane light
    const GT = 0xFF9a9070; // goat grey-tan
    const GH = 0xFFc0b090; // goat light
    const SN = 0xFF4a6818; // serpent green
    const SL = 0xFF6a8828; // serpent light
    const EY = 0xFFff4820; // lion/serpent eye
    const GE = 0xFF40a030; // goat eye
    const FG = 0xFFe0d080; // fang
    const K  = 0xFF181820;

    // ── MAIN LION BODY ────────────────────────────────────
    b(c, 4, 4, 15, 7, LN);
    b(c, 5, 3, 13, 2, LN);
    b(c, 6, 2, 11, 2, LL);  // back highlight
    b(c, 5, 9, 14, 2, LD);  // belly shadow
    b(c, 7, 5, 8, 4, LL);   // belly stripe

    // ── LION HEAD (left) ──────────────────────────────────
    b(c, 0, 2, 5, 9, MN);   // mane behind
    b(c, 1, 3, 4, 7, ML);
    b(c, 2, 3, 6, 6, LN);   // head
    b(c, 2, 3, 6, 1, LL);
    b(c, 1, 4, 1, 5, LD);
    b(c, 2, 4, 2, 2, K);    // eye
    b(c, 2, 4, 2, 1, EY);
    b(c, 2, 4, 1, 1, 0xFFff8040);
    b(c, 0, 6, 8, 4, LN);   // snout
    b(c, 0, 9, 8, 1, K);    // mouth line
    b(c, 1, 7, 2, 1, LD);   // nose
    b(c, 1, 8, 1, 2, FG);
    b(c, 4, 8, 1, 2, FG);
    b(c, 6, 7, 1, 2, FG);

    // ── GOAT HEAD (rising from back, center) ──────────────
    b(c, 9, 0, 1, 3, GT);   // horn L
    b(c, 8, 0, 1, 2, GT);
    b(c, 13, 0, 1, 3, GT);  // horn R
    b(c, 14, 0, 1, 2, GT);
    b(c, 9, 1, 5, 5, GT);   // head
    b(c, 9, 1, 5, 1, GH);
    b(c, 8, 2, 1, 4, GT);
    b(c, 14, 2, 1, 4, GT);
    b(c, 10, 2, 2, 1, K);   // eye
    b(c, 10, 2, 2, 1, GE);
    b(c, 10, 4, 3, 2, GT);  // snout
    b(c, 10, 5, 3, 1, K);

    // ── SERPENT TAIL / HEAD (right) ───────────────────────
    b(c, 19, 3, 5, 5, SN);  // neck
    b(c, 19, 3, 5, 1, SL);
    b(c, 18, 3, 6, 4, SN);  // head
    b(c, 18, 3, 6, 1, SL);
    b(c, 22, 4, 2, 2, K);   // eye
    b(c, 22, 4, 2, 1, EY);
    b(c, 18, 6, 6, 1, K);   // mouth
    b(c, 19, 5, 1, 2, FG);
    b(c, 22, 5, 1, 2, FG);
    b(c, 21, 8, 3, 3, SN);  // tail tip
    b(c, 22, 10, 2, 3, 0xFF2a4010);

    // ── FRONT LEGS ────────────────────────────────────────
    b(c, 3, 10, 4, 4, LD);
    b(c, 3, 10, 4, 1, LN);
    b(c, 2, 13, 1, 3, LL);
    b(c, 3, 13, 1, 3, LL);
    b(c, 4, 13, 1, 3, LL);
    b(c, 5, 14, 1, 2, LL);

    // ── BACK LEGS ─────────────────────────────────────────
    b(c, 14, 10, 4, 4, LD);
    b(c, 14, 10, 4, 1, LN);
    b(c, 13, 13, 1, 3, LL);
    b(c, 14, 13, 1, 3, LL);
    b(c, 15, 13, 1, 3, LL);
    b(c, 16, 14, 1, 2, LL);

    // ── FUR / SCALE DETAIL ────────────────────────────────
    b(c, 8, 5, 1, 1, LD); b(c, 11, 6, 1, 1, LD); b(c, 15, 4, 1, 1, LD);
    b(c, 9, 7, 2, 1, LL); b(c, 13, 8, 2, 1, LL);

    // ── Attack: lion head snaps open ─────────────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.1) {
        b(c, 0, 8, 8, 3, 0xFFc89040);
        b(c, 0, 9, 8, 1, 0xFF181820);
        b(c, 1, 8, 2, 2, 0xFFe0d080);
        b(c, 4, 8, 1, 2, 0xFFe0d080);
        b(c, 6, 8, 1, 2, 0xFFe0d080);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// GOLEM (enemy)  (20 × 20 grid → 100 × 100 canvas)
// Enchanted stone colossus — rune veins, arcane eyes, blue-grey
// Distinct from STONE GOLEM (mossy, orange-eyed)
// ─────────────────────────────────────────────────────────────

class _GolemPainter extends _Painter {
  const _GolemPainter(super.facingLeft, [super.t = 0.0]);

  @override
  void draw(Canvas c, Size sz) {
    const DG = 0xFF3a3a48; // dark granite
    const MG = 0xFF585868; // mid granite
    const LG = 0xFF7878a0; // light granite (bluish)
    const RN = 0xFF4080ff; // rune glow blue
    const RL = 0xFF80b0ff; // rune light
    const CR = 0xFF282828; // stone crack
    const EY = 0xFF60a8ff; // arcane eye
    const K  = 0xFF181820;

    // ── HEAD (flat, block-like) ────────────────────────────
    b(c, 4, 0, 12, 6, MG);
    b(c, 4, 0, 12, 1, LG);
    b(c, 3, 1, 1, 5, DG);
    b(c, 16, 1, 1, 5, DG);
    // Arcane glowing eye slits
    b(c, 5, 1, 4, 2, K);
    b(c, 11, 1, 4, 2, K);
    b(c, 5, 1, 4, 1, EY);
    b(c, 11, 1, 4, 1, EY);
    b(c, 6, 1, 2, 1, RL);
    b(c, 12, 1, 2, 1, RL);
    // Forehead rune
    b(c, 9, 0, 2, 3, RN);
    b(c, 8, 1, 4, 1, RN);
    b(c, 9, 0, 2, 1, RL);
    // Face cracks
    b(c, 7, 3, 1, 2, CR);
    b(c, 12, 2, 1, 2, CR);
    // Stone mouth (grinding)
    b(c, 6, 4, 8, 2, DG);
    b(c, 7, 4, 6, 1, CR);

    // ── BODY (massive slab) ───────────────────────────────
    b(c, 2, 5, 16, 10, MG);
    b(c, 2, 5, 16, 1, LG);
    b(c, 2, 13, 16, 2, DG);
    b(c, 4, 6, 12, 8, DG);
    b(c, 5, 7, 10, 6, MG);
    b(c, 6, 8, 8, 4, LG);

    // ── ARCANE RUNE VEINS ─────────────────────────────────
    b(c, 9, 5, 2, 10, RN);  // vertical vein
    b(c, 4, 9, 12, 2, RN);  // horizontal vein
    b(c, 5, 7, 2, 4, RN);   // branch L
    b(c, 13, 7, 2, 4, RN);  // branch R
    b(c, 9, 5, 2, 1, RL);   // bright node top
    b(c, 9, 9, 2, 1, RL);   // bright node cross
    b(c, 9, 13, 2, 1, RL);  // bright node bottom

    // ── SHOULDERS / ARMS ──────────────────────────────────
    b(c, 0, 4, 3, 8, MG);
    b(c, 0, 4, 3, 2, LG);
    b(c, 17, 4, 3, 8, MG);
    b(c, 17, 4, 3, 2, LG);
    b(c, 0, 11, 3, 5, DG);
    b(c, 17, 11, 3, 5, DG);
    // Fists
    b(c, 0, 15, 3, 3, MG);
    b(c, 0, 15, 3, 1, LG);
    b(c, 17, 15, 3, 3, MG);
    b(c, 17, 15, 3, 1, LG);
    b(c, 0, 17, 3, 1, K);
    b(c, 17, 17, 3, 1, K);
    b(c, 1, 15, 1, 2, RN);  // fist rune L
    b(c, 18, 15, 1, 2, RN); // fist rune R

    // ── LEGS (squat, powerful) ────────────────────────────
    b(c, 5, 15, 4, 4, DG);
    b(c, 11, 15, 4, 4, DG);
    b(c, 5, 15, 4, 1, MG);
    b(c, 11, 15, 4, 1, MG);
    b(c, 4, 18, 6, 2, K);
    b(c, 10, 18, 6, 2, K);
    b(c, 4, 18, 6, 1, DG);
    b(c, 10, 18, 6, 1, DG);

    // ── Attack: rune fist rises + rune veins blaze ───────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.1) {
        final off = sw * 8;
        b(c, 17, max(0.0, 4 - off), 3, 3, 0xFF585868);
        b(c, 17, max(0.0, 4 - off), 3, 1, 0xFF7878a0);
        b(c, 17, max(0.0, 7 - off), 3, 3, 0xFF585868);
        b(c, 17, max(0.0, 7 - off), 3, 1, 0xFF7878a0);
        b(c, 18, max(0.0, 8 - off), 1, 2, 0xFF80b0ff);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// CULTIST  (16 × 24 grid → 80 × 120 canvas)
// ─────────────────────────────────────────────────────────────
class _CultistPainter extends _Painter {
  const _CultistPainter(super.facingLeft, [super.t = 0.0]);
  @override
  void draw(Canvas c, Size sz) {
    const CR = 0xFF8B1A1A; // crimson robe
    const CL = 0xFF6B0F0F; // crimson shadow
    const SK = 0xFFd4b090; // pale skin
    const BK = 0xFF111111; // near black
    const GO = 0xFFe8c030; // gold sigil
    const SV = 0xFFcccccc; // silver dagger
    const EY = 0xFFff4422; // red glow eyes

    // Hood
    b(c, 5, 0, 6, 1, CL);
    b(c, 3, 1, 10, 3, CR);
    b(c, 5, 2, 6, 2, BK);
    b(c, 6, 3, 2, 1, EY);
    b(c, 8, 3, 2, 1, EY);

    // Shoulders
    b(c, 1, 4, 14, 2, CR);

    // Arms
    b(c, 1, 6, 2, 9, CR);
    b(c, 13, 6, 2, 9, CR);
    b(c, 0, 14, 2, 1, SK);
    b(c, 14, 14, 1, 1, SK);

    // Robe body
    b(c, 3, 6, 10, 14, CR);
    b(c, 4, 7, 8, 12, CL);

    // Ritual sigil (on top of robe)
    b(c, 7, 9, 2, 1, GO);
    b(c, 6, 10, 4, 1, GO);
    b(c, 7, 10, 2, 3, GO);
    b(c, 6, 12, 4, 1, GO);
    b(c, 7, 11, 2, 1, 0xFFffd060);

    // Dagger (right hand)
    b(c, 15, 10, 1, 5, SV);
    b(c, 14, 14, 2, 1, GO);

    // Hem / feet
    b(c, 3, 20, 4, 3, CL);
    b(c, 9, 20, 4, 3, CL);
    b(c, 5, 21, 2, 2, BK);
    b(c, 9, 21, 2, 2, BK);

    // ── Attack: sigil blazes + dagger thrusts ────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.1) {
        final off = sw * 6;
        b(c, 6, 9, 4, 4, 0xFFffd060);
        b(c, 7, 9, 2, 4, 0xFFffff88);
        b(c, 6, 11, 4, 1, 0xFFffff88);
        b(c, 15, max(0.0, 10 - off), 1, 5, 0xFFdddddd);
        b(c, 14, max(0.0, 14 - off), 2, 1, 0xFFffd060);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// SUCCUBUS  (16 × 24 grid → 80 × 120 canvas)
// ─────────────────────────────────────────────────────────────
class _SuccubusPainter extends _Painter {
  const _SuccubusPainter(super.facingLeft, [super.t = 0.0]);
  @override
  void draw(Canvas c, Size sz) {
    const SK = 0xFFe8b0a0; // pale pink skin
    const PT = 0xFF5a1a7a; // purple top
    const PD = 0xFF3d0f5a; // purple dark
    const WF = 0xFF1a0a2a; // wing frame/membrane
    const HN = 0xFFcc1133; // horn red
    const EY = 0xFFee1188; // eye magenta
    const GL = 0xFF9933ff; // hand glow violet
    const HR = 0xFFcc2255; // hair dark rose

    // Wings (behind body, drawn first)
    b(c, 0, 3, 4, 10, WF);
    b(c, 12, 3, 4, 10, WF);
    b(c, 0, 12, 4, 3, WF);
    b(c, 12, 12, 4, 3, WF);

    // Head
    b(c, 4, 2, 8, 5, SK);
    b(c, 5, 1, 6, 2, HR);
    b(c, 6, 3, 1, 1, EY);
    b(c, 9, 3, 1, 1, EY);
    b(c, 6, 0, 1, 2, HN);
    b(c, 9, 0, 1, 2, HN);

    // Torso
    b(c, 5, 6, 6, 7, PT);
    b(c, 5, 7, 6, 5, PD);
    b(c, 6, 8, 4, 3, SK);
    b(c, 5, 8, 1, 3, PT);
    b(c, 10, 8, 1, 3, PT);

    // Waist / hips
    b(c, 5, 13, 6, 4, PD);
    b(c, 4, 13, 1, 4, WF);
    b(c, 11, 13, 1, 4, WF);

    // Arms
    b(c, 3, 6, 2, 8, SK);
    b(c, 11, 6, 2, 8, SK);

    // Glowing hands
    b(c, 2, 13, 2, 2, GL);
    b(c, 12, 13, 2, 2, GL);

    // Legs
    b(c, 5, 17, 3, 5, SK);
    b(c, 8, 17, 3, 5, SK);
    b(c, 5, 21, 3, 2, PD);
    b(c, 8, 21, 3, 2, PD);

    // ── Attack: life-drain tendrils shoot out ────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.1) {
        final ext = sw * 4;
        final rightX = min(12.0 + ext, 14.0);
        b(c, max(0.0, 2 - ext), 13, min(ext + 2, 6.0), 2, 0xFF9933ff);
        b(c, rightX, 13, min(ext + 2, 16.0 - rightX), 2, 0xFF9933ff);
        b(c, 2, 13, 2, 2, 0xFFffaaff);
        b(c, 12, 13, 2, 2, 0xFFffaaff);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// EYEBALL WATCHER  (12 × 14 grid → 60 × 70 canvas)
// ─────────────────────────────────────────────────────────────
class _EyeballWatcherPainter extends _Painter {
  const _EyeballWatcherPainter(super.facingLeft, [super.t = 0.0]);
  @override
  void draw(Canvas c, Size sz) {
    const BD = 0xFF2a1a0a; // dark brown body
    const BL = 0xFF3d2810; // brown lighter
    const EW = 0xFFeeeecc; // eye white
    const EP = 0xFFcc2200; // pupil dark red
    const IR = 0xFF883300; // iris orange
    const TN = 0xFF1a1505; // tentacle near-black
    const BM = 0xFFffee00; // beam yellow
    const VN = 0xFF5500aa; // vein purple

    // Main body
    b(c, 2, 1, 8, 10, BD);
    b(c, 1, 3, 10, 8, BD);
    b(c, 3, 0, 6, 12, BL);
    b(c, 2, 1, 8, 1, BL);

    // Central large eye
    b(c, 3, 4, 6, 5, EW);
    b(c, 4, 5, 4, 3, IR);
    b(c, 5, 5, 2, 3, EP);
    b(c, 5, 6, 2, 1, BM);
    b(c, 4, 10, 4, 1, BM);

    // Peripheral eyes
    b(c, 1, 2, 2, 1, EW); b(c, 1, 3, 1, 1, EP);
    b(c, 9, 2, 2, 1, EW); b(c, 10, 3, 1, 1, EP);
    b(c, 0, 5, 2, 1, EW); b(c, 0, 5, 1, 1, EP);
    b(c, 10, 5, 2, 1, EW); b(c, 11, 5, 1, 1, EP);
    b(c, 1, 8, 2, 1, EW); b(c, 2, 8, 1, 1, EP);
    b(c, 9, 8, 2, 1, EW); b(c, 9, 8, 1, 1, EP);
    b(c, 4, 0, 2, 1, EW); b(c, 4, 0, 1, 1, EP);
    b(c, 7, 0, 2, 1, EW); b(c, 7, 0, 1, 1, EP);

    // Vein detail
    b(c, 6, 1, 1, 3, VN);
    b(c, 4, 2, 1, 2, VN);

    // Tentacle roots
    b(c, 3, 11, 1, 3, TN);
    b(c, 5, 12, 1, 2, TN);
    b(c, 7, 12, 1, 2, TN);
    b(c, 9, 11, 1, 3, TN);

    // ── Attack: eldritch beam fires ──────────────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.15) {
        final beamW = min(sw * 10, 8.0);
        b(c, 12.0 - beamW, 6, beamW, 1, 0xFFffee00);
        b(c, 12.0 - beamW, 6, min(beamW, 4.0), 1, 0xFFffffff);
        b(c, 5, 5, 2, 3, 0xFFffaa00);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// MIND-FLAYER  (16 × 28 grid → 80 × 140 canvas)
// ─────────────────────────────────────────────────────────────
class _MindFlayerPainter extends _Painter {
  const _MindFlayerPainter(super.facingLeft, [super.t = 0.0]);
  @override
  void draw(Canvas c, Size sz) {
    const PU = 0xFF4a2060; // purple skin dome
    const PL = 0xFF341545; // dome shadow
    const RB = 0xFF1a0a2a; // robe dark indigo
    const RL = 0xFF2d1545; // robe highlight
    const TN = 0xFF5a2880; // tentacle purple
    const TL = 0xFF7840a0; // tentacle light
    const PS = 0xFF9933ff; // psionic glow
    const EY = 0xFFaaffee; // teal eye glow
    const GD = 0xFF665500; // gold trim

    // Robe (drawn first; tentacles will overwrite)
    b(c, 3, 4, 10, 22, RB);
    b(c, 4, 5, 8, 20, RL);
    b(c, 2, 6, 2, 14, RB);
    b(c, 12, 6, 2, 14, RB);
    b(c, 1, 8, 2, 2, RB);
    b(c, 13, 8, 2, 2, RB);
    b(c, 0, 9, 1, 2, PS);
    b(c, 15, 9, 1, 2, PS);
    b(c, 3, 24, 2, 3, RB);
    b(c, 11, 24, 2, 3, RB);
    b(c, 5, 25, 6, 2, RL);

    // Gold collar
    b(c, 4, 4, 8, 1, GD);

    // Dome head
    b(c, 4, 0, 8, 6, PU);
    b(c, 5, 0, 6, 7, PU);
    b(c, 4, 0, 8, 1, PL);
    b(c, 5, 1, 6, 1, 0xFF6a3080);

    // Eyes
    b(c, 6, 4, 2, 1, EY);
    b(c, 8, 4, 2, 1, EY);

    // Psionic aura beside head
    b(c, 3, 0, 1, 6, PS);
    b(c, 12, 0, 1, 6, PS);

    // Tentacles drawn OVER robe
    b(c, 5, 6, 1, 10, TN);
    b(c, 5, 8, 1, 8, TL);
    b(c, 6, 7, 1, 11, TN);
    b(c, 6, 9, 1, 9, TL);
    b(c, 9, 7, 1, 11, TN);
    b(c, 9, 9, 1, 9, TL);
    b(c, 10, 6, 1, 10, TN);
    b(c, 10, 8, 1, 8, TL);
    b(c, 4, 15, 1, 2, TN);
    b(c, 7, 17, 1, 2, TN);
    b(c, 8, 17, 1, 2, TN);
    b(c, 11, 15, 1, 2, TN);

    // ── Attack: psionic tentacles shoot outward ───────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.1) {
        final ext = sw * 4;
        b(c, max(0.0, 5 - ext), 10, 2, 8, 0xFF5a2880);
        b(c, max(0.0, 6 - ext), 12, 2, 8, 0xFF5a2880);
        b(c, min(9.0 + ext, 14.0), 10, 2, 8, 0xFF5a2880);
        b(c, min(8.0 + ext, 13.0), 12, 2, 8, 0xFF5a2880);
        b(c, max(0.0, 5 - ext), 17, 2, 1, 0xFF9933ff);
        b(c, min(9.0 + ext, 14.0), 17, 2, 1, 0xFF9933ff);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// PIXIE  (12 × 14 grid → 60 × 70 canvas)
// ─────────────────────────────────────────────────────────────
class _PixiePainter extends _Painter {
  const _PixiePainter(super.facingLeft, [super.t = 0.0]);
  @override
  void draw(Canvas c, Size sz) {
    const WA = 0xFF80ffcc; // wing teal-aqua
    const WB = 0xFFccffee; // wing highlight
    const WP = 0xFFff88ff; // wing pink lower
    const LF = 0xFF228833; // leaf green
    const LL = 0xFF44bb44; // leaf lighter
    const SK = 0xFFf5e0c8; // fair skin
    const HR = 0xFF997722; // golden hair
    const MA = 0xFFffeeaa; // magic glow
    const EY = 0xFF661100; // dark eye

    // Upper butterfly wings (drawn first)
    b(c, 0, 2, 4, 5, WA);
    b(c, 0, 2, 3, 4, WB);
    b(c, 8, 2, 4, 5, WA);
    b(c, 9, 2, 3, 4, WB);

    // Lower wings
    b(c, 1, 7, 3, 4, WP);
    b(c, 1, 7, 2, 3, WA);
    b(c, 8, 7, 3, 4, WP);
    b(c, 9, 7, 2, 3, WA);

    // Head
    b(c, 4, 3, 4, 2, HR);
    b(c, 4, 5, 4, 3, SK);
    b(c, 5, 6, 1, 1, EY);
    b(c, 6, 6, 1, 1, EY);

    // Leaf garment
    b(c, 4, 8, 4, 3, LF);
    b(c, 4, 8, 4, 1, LL);
    b(c, 3, 9, 1, 2, LF);
    b(c, 8, 9, 1, 2, LF);

    // Legs
    b(c, 5, 11, 1, 3, SK);
    b(c, 6, 11, 1, 3, SK);

    // Magic sparkle hands
    b(c, 3, 8, 1, 1, MA);
    b(c, 8, 8, 1, 1, MA);
    b(c, 2, 7, 1, 1, MA);
    b(c, 9, 7, 1, 1, MA);

    // ── Attack: magic bolt fires from hands ──────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.15) {
        final ext = sw * 4;
        b(c, min(8.0 + ext, 10.0), 7, 2, 2, 0xFF80ffcc);
        b(c, min(8.0 + ext, 10.0), 7, 2, 1, 0xFFffffff);
        b(c, 5, max(0.0, 6 - sw * 2), 2, 1, 0xFF80ffcc);
        b(c, max(0.0, 1 - sw), 7, 2, 1, 0xFFffeeaa);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// WYVERN  (22 × 18 grid → 110 × 90 canvas)
// ─────────────────────────────────────────────────────────────
class _WyvernPainter extends _Painter {
  const _WyvernPainter(super.facingLeft, [super.t = 0.0]);
  @override
  void draw(Canvas c, Size sz) {
    const SC = 0xFF2a6e30; // scale green
    const SD = 0xFF1a4820; // scale shadow
    const SL = 0xFF3d9045; // scale light
    const WG = 0xFF1a3a1f; // wing dark
    const WL = 0xFF265e2a; // wing lighter
    const VN = 0xFFaaff44; // venom bright green
    const EY = 0xFFff8800; // orange eye
    const WH = 0xFFddddcc; // white fang/claw
    const BK = 0xFF111108; // near black

    // Tail (barbed, rightmost)
    b(c, 16, 8, 6, 3, SC);
    b(c, 18, 9, 4, 2, SD);
    b(c, 20, 8, 2, 2, SL);
    b(c, 21, 7, 1, 1, VN);
    b(c, 19, 10, 1, 1, VN);
    b(c, 20, 11, 1, 1, VN);

    // Wings (above body)
    b(c, 7, 0, 9, 6, WG);
    b(c, 8, 0, 7, 5, WL);
    b(c, 6, 0, 2, 7, SC);
    b(c, 14, 0, 2, 8, SC);

    // Body
    b(c, 5, 6, 14, 6, SC);
    b(c, 6, 7, 12, 4, SL);
    b(c, 5, 7, 14, 2, SD);
    b(c, 7, 10, 8, 2, SD);
    b(c, 6, 5, 3, 2, SC);

    // Head (leftmost)
    b(c, 0, 5, 7, 5, SC);
    b(c, 0, 6, 8, 3, SL);
    b(c, 0, 7, 3, 2, SD);
    b(c, 1, 6, 2, 1, WH);
    b(c, 5, 5, 2, 1, EY);
    b(c, 4, 4, 1, 1, EY);

    // Neck spine ridges
    b(c, 5, 3, 2, 3, SL);
    b(c, 7, 2, 2, 4, SL);
    b(c, 9, 1, 2, 5, SC);

    // Two strong legs
    b(c, 8, 12, 3, 4, SD);
    b(c, 8, 15, 4, 2, BK);
    b(c, 9, 16, 1, 1, WH);
    b(c, 13, 12, 3, 4, SD);
    b(c, 12, 15, 4, 2, BK);
    b(c, 12, 16, 1, 1, WH);

    // ── Attack: tail whips upward ────────────────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.1) {
        final off = sw * 4;
        b(c, 16, max(0.0, 8 - off), 6, 3, 0xFF2a6e30);
        b(c, 18, max(0.0, 9 - off), 4, 2, 0xFF1a4820);
        b(c, 20, max(0.0, 8 - off), 2, 2, 0xFF3d9045);
        b(c, 21, max(0.0, 7 - off), 1, 1, 0xFFaaff44);
        b(c, 19, max(0.0, 10 - off), 1, 1, 0xFFaaff44);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// MINOTAUR  (20 × 20 grid → 100 × 100 canvas)
// ─────────────────────────────────────────────────────────────
class _MinotaurPainter extends _Painter {
  const _MinotaurPainter(super.facingLeft, [super.t = 0.0]);
  @override
  void draw(Canvas c, Size sz) {
    const BF = 0xFF4a3020; // brown fur
    const BL = 0xFF352010; // brown dark
    const LT = 0xFF6a4830; // brown lighter
    const AR = 0xFF556644; // armor plate
    const AL = 0xFF778866; // armor lighter
    const HR = 0xFF1a1a0a; // horn dark
    const HN = 0xFF2a2515; // horn mid
    const NR = 0xFFccaa55; // nose ring gold
    const EY = 0xFFdd3300; // red-orange eye
    const AX = 0xFFaaaaaa; // axe silver
    const AH = 0xFF888888; // axe handle
    const BK = 0xFF0a0a0a; // near black

    // Massive curved horns
    b(c, 2, 0, 5, 3, HN);
    b(c, 0, 0, 3, 2, HR);
    b(c, 1, 2, 2, 1, HR);
    b(c, 13, 0, 5, 3, HN);
    b(c, 17, 0, 3, 2, HR);
    b(c, 17, 2, 2, 1, HR);

    // Head (large bovine)
    b(c, 5, 0, 10, 8, BF);
    b(c, 6, 1, 8, 6, LT);
    b(c, 7, 5, 6, 3, BL);
    b(c, 8, 6, 4, 2, LT);
    b(c, 7, 2, 2, 2, EY);
    b(c, 11, 2, 2, 2, EY);
    b(c, 8, 1, 1, 1, BK);
    b(c, 11, 1, 1, 1, BK);
    b(c, 9, 7, 2, 1, BK);
    b(c, 9, 6, 2, 1, NR);

    // Neck + shoulder armor
    b(c, 4, 7, 12, 4, BF);
    b(c, 2, 9, 16, 3, AR);
    b(c, 3, 9, 14, 2, AL);

    // Torso
    b(c, 4, 11, 12, 6, BF);
    b(c, 5, 12, 10, 4, LT);

    // Left arm + fist
    b(c, 1, 10, 3, 7, BF);
    b(c, 0, 16, 3, 2, BK);

    // Right arm + battle axe
    b(c, 16, 10, 3, 7, BF);
    b(c, 19, 7, 1, 6, AH);
    b(c, 18, 6, 2, 2, AX);
    b(c, 18, 12, 2, 2, AX);

    // Legs / hooves
    b(c, 5, 17, 4, 3, BL);
    b(c, 11, 17, 4, 3, BL);
    b(c, 4, 19, 5, 1, BK);
    b(c, 11, 19, 5, 1, BK);

    // ── Attack: axe swings overhead ──────────────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.05) {
        final off = sw * 7;
        b(c, 19, max(0.0, 7 - off), 1, 6, 0xFF888888);
        b(c, 18, max(0.0, 6 - off), 2, 2, 0xFFaaaaaa);
        b(c, 18, max(0.0, 12 - off), 2, 2, 0xFFaaaaaa);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// HYDRA  (24 × 16 grid → 120 × 80 canvas)
// ─────────────────────────────────────────────────────────────
class _HydraPainter extends _Painter {
  const _HydraPainter(super.facingLeft, [super.t = 0.0]);
  @override
  void draw(Canvas c, Size sz) {
    const SG = 0xFF1a5e28; // scale green dark
    const SL = 0xFF2e9040; // scale lighter
    const SM = 0xFF3db858; // scale mid-bright
    const YA = 0xFF88ff44; // acid yellow-green
    const EY = 0xFFff4400; // orange-red eye
    const WH = 0xFFeeeecc; // tooth/fang white
    const BL = 0xFF0d3315; // very dark green

    // Wide body
    b(c, 3, 8, 18, 6, SG);
    b(c, 4, 9, 16, 4, SL);
    b(c, 5, 10, 14, 2, SM);
    b(c, 0, 10, 4, 4, SG);
    b(c, 20, 10, 4, 4, SG);
    b(c, 5, 14, 4, 2, BL);
    b(c, 15, 14, 4, 2, BL);

    // Left neck + head
    b(c, 2, 3, 3, 8, SG);
    b(c, 2, 3, 3, 6, SL);
    b(c, 0, 0, 6, 5, SG);
    b(c, 1, 1, 4, 3, SL);
    b(c, 0, 2, 3, 2, SG);
    b(c, 0, 3, 2, 1, WH);
    b(c, 3, 1, 2, 1, EY);
    b(c, 1, 4, 3, 1, YA);
    b(c, 2, 5, 2, 1, YA);

    // Center neck + head
    b(c, 10, 2, 3, 9, SG);
    b(c, 10, 2, 3, 7, SL);
    b(c, 8, 0, 7, 4, SG);
    b(c, 9, 0, 5, 3, SL);
    b(c, 8, 2, 3, 2, SG);
    b(c, 8, 3, 2, 1, WH);
    b(c, 11, 0, 2, 1, EY);
    b(c, 10, 4, 3, 1, YA);

    // Right neck + head
    b(c, 18, 3, 3, 8, SG);
    b(c, 18, 3, 3, 6, SL);
    b(c, 18, 0, 6, 5, SG);
    b(c, 19, 1, 4, 3, SL);
    b(c, 21, 2, 3, 2, SG);
    b(c, 22, 3, 2, 1, WH);
    b(c, 19, 1, 2, 1, EY);
    b(c, 19, 5, 3, 1, YA);

    // ── Attack: all 3 heads snap + acid erupts ────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.15) {
        final acid = sw * 4;
        b(c, 1, min(15.0, 5 + acid), 2, min(acid, 3.0), 0xFF88ff44);
        b(c, 10, min(15.0, 4 + acid), 2, min(acid, 3.0), 0xFF88ff44);
        b(c, 19, min(15.0, 5 + acid), 2, min(acid, 3.0), 0xFF88ff44);
        b(c, 3, 1, 2, 1, 0xFFffa060);
        b(c, 11, 0, 2, 1, 0xFFffa060);
        b(c, 19, 1, 2, 1, 0xFFffa060);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// PHOENIX  (22 × 18 grid → 110 × 90 canvas)
// ─────────────────────────────────────────────────────────────
class _PhoenixPainter extends _Painter {
  const _PhoenixPainter(super.facingLeft, [super.t = 0.0]);
  @override
  void draw(Canvas c, Size sz) {
    const FC = 0xFFff6600; // fire orange core
    const FF = 0xFFff9900; // fire gold-orange
    const FD = 0xFFcc3300; // fire dark red
    const FY = 0xFFffee00; // fire yellow tip
    const WH = 0xFFffffff; // white fire peak
    const GD = 0xFFffdd44; // gold plumage
    const RD = 0xFFcc2200; // deep red plumage
    const EY = 0xFFffff88; // bright eye
    const BK = 0xFF1a0800; // near-black shadow

    // Left wing fire
    b(c, 0, 2, 8, 12, FD);
    b(c, 0, 3, 7, 10, FC);
    b(c, 1, 4, 5, 8, FF);
    b(c, 2, 5, 3, 6, FY);
    b(c, 0, 1, 3, 1, FY);
    b(c, 0, 0, 2, 1, WH);

    // Right wing fire
    b(c, 14, 2, 8, 12, FD);
    b(c, 15, 3, 7, 10, FC);
    b(c, 16, 4, 5, 8, FF);
    b(c, 17, 5, 3, 6, FY);
    b(c, 19, 1, 3, 1, FY);
    b(c, 20, 0, 2, 1, WH);

    // Body
    b(c, 8, 5, 6, 8, GD);
    b(c, 9, 6, 4, 6, FC);
    b(c, 9, 5, 4, 1, FY);

    // Head
    b(c, 9, 2, 4, 5, GD);
    b(c, 9, 1, 4, 2, RD);
    b(c, 10, 2, 2, 1, EY);

    // Flame crest
    b(c, 9, 0, 1, 2, FY);
    b(c, 10, 0, 1, 1, FF);
    b(c, 11, 0, 1, 2, FY);
    b(c, 12, 0, 1, 1, FF);

    // Legs / talons
    b(c, 9, 13, 2, 3, RD);
    b(c, 11, 13, 2, 3, RD);
    b(c, 8, 15, 2, 1, BK);
    b(c, 12, 15, 2, 1, BK);

    // Tail fire
    b(c, 7, 14, 8, 3, FD);
    b(c, 8, 15, 6, 2, FC);
    b(c, 9, 16, 4, 1, FF);
    b(c, 7, 16, 2, 1, FY);
    b(c, 13, 16, 2, 1, FY);
    b(c, 8, 17, 2, 1, FY);
    b(c, 12, 17, 2, 1, FY);

    // ── Attack: fire bursts from wings ───────────────────────
    if (t > 0) {
      final sw = sin(t * pi);
      if (sw > 0.15) {
        b(c, 0, min(17.0, 1 + sw * 6), 3, 2, 0xFFffee00);
        b(c, 19, min(17.0, 1 + sw * 6), 3, 2, 0xFFffee00);
        b(c, 2, min(17.0, 3 + sw * 5), 4, 2, 0xFFff9900);
        b(c, 16, min(17.0, 3 + sw * 5), 4, 2, 0xFFff9900);
        b(c, 9, 5, 4, 8, 0xFFffcc00);
        b(c, 10, 5, 2, 8, 0xFFffffff);
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// BARBARIAN HERO  (16 × 24 grid → 80 × 120 canvas)
// ─────────────────────────────────────────────────────────────
class _BarbarianHeroPainter extends _Painter {
  const _BarbarianHeroPainter(super.facingLeft, [super.t = 0.0, super.gender = HeroGender.male]);
  @override
  void draw(Canvas c, Size sz) {
    const SK = 0xFFc8784c; // skin
    const SL = 0xFFe09060; // skin light
    const LE = 0xFF7b4a1f; // leather dark
    const LL = 0xFF9b6a3f; // leather light
    const HN = 0xFFddd0a0; // bone horn
    const HD = 0xFF9a9060; // horn dark
    const FU = 0xFF1a100a; // dark fur
    const GR = 0xFF9a2020; // red war paint
    const K  = 0xFF100808; // outline

    // Horns
    b(c, 3, 0, 1, 4, HN); b(c, 12, 0, 1, 4, HN);
    b(c, 2, 1, 1, 3, HN); b(c, 13, 1, 1, 3, HN);
    b(c, 3, 0, 1, 1, HD); b(c, 12, 0, 1, 1, HD);
    // Skull cap (leather)
    b(c, 3, 1, 10, 3, LE); b(c, 3, 1, 10, 1, LL);
    b(c, 4, 4, 8, 1, LE);
    // Face
    b(c, 4, 4, 8, 5, SK); b(c, 5, 4, 6, 1, SL);
    b(c, 5, 5, 1, 1, K); b(c, 10, 5, 1, 1, K);
    if (isFemale) {
      b(c, 3, 4, 1, 5, 0xFF8a3010); // long braid left
      b(c, 12, 4, 1, 5, 0xFF8a3010); // long braid right
      b(c, 5, 5, 1, 1, GR); // war paint
    } else if (isNonBinary) {
      b(c, 3, 3, 1, 4, 0xFF8a3010); // side shave + tuft
      b(c, 5, 5, 1, 1, GR);
    } else {
      b(c, 5, 5, 1, 1, GR); // war paint
      b(c, 5, 8, 6, 1, FU); // jaw stubble
    }
    // Neck
    b(c, 6, 9, 4, 1, SK);
    // Wide bare shoulders
    b(c, 0, 9, 5, 4, SK); b(c, 11, 9, 5, 4, SK);
    b(c, 0, 9, 5, 1, SL); b(c, 11, 9, 5, 1, SL);
    // Chest (leather wrap in centre)
    b(c, 3, 10, 10, 5, SK);
    b(c, 5, 10, 6, 5, LE); b(c, 6, 10, 4, 1, LL);
    // Fur loincloth
    b(c, 4, 15, 8, 3, FU); b(c, 5, 15, 6, 1, LE);
    // Arms (large, bare)
    b(c, 1, 13, 3, 7, SK); b(c, 12, 13, 3, 7, SK);
    b(c, 1, 14, 3, 2, LE); b(c, 12, 14, 3, 2, LE); // bracers
    // Fists
    b(c, 0, 20, 4, 2, SK); b(c, 12, 20, 4, 2, SK);
    // Legs
    b(c, 4, 18, 3, 5, LE); b(c, 9, 18, 3, 5, LE);
    // Boots
    b(c, 3, 21, 5, 3, FU); b(c, 8, 21, 5, 3, FU);
    b(c, 3, 22, 6, 1, LL); b(c, 8, 22, 5, 1, LL);
  }
}

// ─────────────────────────────────────────────────────────────
// BARD HERO  (16 × 24)
// ─────────────────────────────────────────────────────────────
class _BardHeroPainter extends _Painter {
  const _BardHeroPainter(super.facingLeft, [super.t = 0.0, super.gender = HeroGender.male]);
  @override
  void draw(Canvas c, Size sz) {
    const HT = 0xFF3c1870; // hat dark
    const HL = 0xFF6c38b0; // hat light
    const FT = 0xFFe8c030; // feather gold
    const SK = 0xFFe0c090; // skin
    const TN = 0xFF1c3e90; // tunic blue
    const TL = 0xFF2c56b8; // tunic light
    const TR = 0xFF9030a0; // trim purple
    const BR = 0xFF5c3810; // hair brown
    const BT = 0xFF3c2010; // boot dark
    const BL = 0xFF5a3820; // boot light

    // Tall hat body
    b(c, 4, 0, 8, 5, HT); b(c, 5, 0, 6, 1, HL);
    // Hat brim
    b(c, 2, 5, 12, 1, HL); b(c, 2, 5, 12, 1, HT);
    b(c, 1, 5, 14, 1, HL);
    // Feather (right side)
    b(c, 10, 0, 2, 6, FT); b(c, 11, 0, 1, 4, 0xFFf0e050);
    // Hair + face
    if (isFemale) {
      b(c, 3, 6, 2, 7, BR); b(c, 11, 6, 2, 7, BR); // longer flowing hair
      b(c, 5, 6, 6, 4, SK);
      b(c, 6, 7, 1, 1, 0xFF301818); b(c, 9, 7, 1, 1, 0xFF301818);
      b(c, 7, 9, 2, 1, 0xFFc05050);
      b(c, 10, 7, 1, 1, 0xFFd4af37); // earring
    } else if (isNonBinary) {
      b(c, 3, 6, 2, 5, BR); b(c, 11, 6, 1, 5, BR); // asymmetric
      b(c, 5, 6, 6, 4, SK);
      b(c, 6, 7, 1, 1, 0xFF301818); b(c, 9, 7, 1, 1, 0xFF301818);
      b(c, 7, 9, 2, 1, 0xFFc05050);
    } else {
      b(c, 3, 6, 2, 5, BR); b(c, 11, 6, 2, 5, BR);
      b(c, 5, 6, 6, 4, SK);
      b(c, 6, 7, 1, 1, 0xFF301818); b(c, 9, 7, 1, 1, 0xFF301818);
      b(c, 7, 9, 2, 1, 0xFFc05050);
    }
    // Neck
    b(c, 7, 10, 2, 1, SK);
    // Shoulders (slim)
    b(c, 3, 10, 3, 2, TN); b(c, 10, 10, 3, 2, TN);
    b(c, 3, 10, 3, 1, TL); b(c, 10, 10, 3, 1, TL);
    // Tunic body
    b(c, 4, 10, 8, 8, TN); b(c, 5, 11, 6, 6, TL);
    b(c, 4, 10, 8, 1, TL);
    // Collar / trim
    b(c, 4, 17, 8, 1, TR);
    // Arms
    b(c, 2, 12, 2, 8, TN); b(c, 12, 12, 2, 8, TN);
    b(c, 2, 12, 2, 5, TL); b(c, 12, 12, 2, 5, TL);
    // Hands
    b(c, 2, 19, 2, 2, SK); b(c, 12, 19, 2, 2, SK);
    // Legs
    b(c, 5, 18, 3, 5, TN); b(c, 8, 18, 3, 5, TN);
    b(c, 5, 18, 2, 4, TL); b(c, 9, 18, 2, 4, TL);
    // Boots
    b(c, 4, 21, 4, 3, BT); b(c, 8, 21, 4, 3, BT);
    b(c, 4, 21, 4, 1, BL); b(c, 8, 21, 4, 1, BL);
  }
}

// ─────────────────────────────────────────────────────────────
// CLERIC HERO  (16 × 24)
// ─────────────────────────────────────────────────────────────
class _ClericHeroPainter extends _Painter {
  const _ClericHeroPainter(super.facingLeft, [super.t = 0.0, super.gender = HeroGender.male]);
  @override
  void draw(Canvas c, Size sz) {
    const WH = 0xFFd4d4c4; // robe off-white
    const WL = 0xFFf0f0e4; // robe highlight
    const WD = 0xFF9898880; // robe shadow (unused — use below)
    const GD = 0xFFd4af37; // gold holy symbol
    const BL = 0xFF1c3480; // blue trim
    const SK = 0xFFe0c890; // skin
    const HM = 0xFFb0b8c0; // helm silver
    const HL = 0xFFd0d8e0; // helm light
    const K  = 0xFF181818; // outline
    const BT = 0xFF4a3020; // boots

    // Bowl helm
    b(c, 5, 0, 6, 5, HM); b(c, 5, 0, 6, 1, HL);
    b(c, 4, 1, 1, 4, 0xFF808898); b(c, 11, 1, 1, 4, 0xFF808898);
    b(c, 4, 4, 8, 1, 0xFF808898);
    // Face
    b(c, 5, 2, 6, 3, SK);
    b(c, 6, 3, 1, 1, K); b(c, 9, 3, 1, 1, K);
    if (isFemale) {
      b(c, 4, 4, 1, 4, 0xFFb89060); b(c, 11, 4, 1, 4, 0xFFb89060); // hair under helm
    } else if (isNonBinary) {
      b(c, 4, 4, 1, 3, 0xFFb89060); // hair peeking one side
    }
    // Neck
    b(c, 7, 5, 2, 1, SK);
    // Pauldrons
    b(c, 2, 5, 4, 3, HM); b(c, 10, 5, 4, 3, HM);
    b(c, 2, 5, 4, 1, HL); b(c, 10, 5, 4, 1, HL);
    // Robe body
    b(c, 4, 5, 8, 11, WH); b(c, 5, 6, 6, 9, WL);
    b(c, 4, 5, 8, 1, BL); // collar
    // Gold cross / holy symbol on chest
    b(c, 7, 7, 2, 6, GD);   // vertical bar
    b(c, 5, 10, 6, 2, GD);  // horizontal bar
    b(c, 7, 7, 2, 1, 0xFFfff0a0); // top glow
    // Blue hem trim
    b(c, 4, 15, 8, 1, BL);
    // Arms (robed)
    b(c, 2, 8, 2, 7, WH); b(c, 12, 8, 2, 7, WH);
    b(c, 2, 8, 2, 4, WL); b(c, 12, 8, 2, 4, WL);
    // Hands
    b(c, 2, 15, 2, 2, SK); b(c, 12, 15, 2, 2, SK);
    // Robe skirt (wide)
    b(c, 3, 16, 10, 7, WH); b(c, 4, 17, 8, 5, WL);
    b(c, 3, 22, 10, 1, BL);
    // Boots under robe
    b(c, 5, 21, 2, 3, BT); b(c, 9, 21, 2, 3, BT);
  }
}

// ─────────────────────────────────────────────────────────────
// DRUID HERO  (16 × 24)
// ─────────────────────────────────────────────────────────────
class _DruidHeroPainter extends _Painter {
  const _DruidHeroPainter(super.facingLeft, [super.t = 0.0, super.gender = HeroGender.male]);
  @override
  void draw(Canvas c, Size sz) {
    const GR = 0xFF284a20; // dark green robe
    const GL = 0xFF3a6830; // green light
    const GG = 0xFF4a8840; // bright green
    const BR = 0xFF5c3810; // bark/wood brown
    const BL = 0xFF7a5020; // brown light
    const SK = 0xFFc8a060; // skin (tanned)
    const AT = 0xFF6a4010; // antler dark
    const AL = 0xFF8a5818; // antler light
    const LF = 0xFF2c6020; // leaf green
    const WH = 0xFFb0a890; // grey-white hair

    // Antlers
    b(c, 3, 0, 2, 5, AT); b(c, 11, 0, 2, 5, AT);
    b(c, 2, 1, 1, 3, AT); b(c, 13, 1, 1, 3, AT);
    b(c, 4, 0, 1, 2, AT); b(c, 11, 0, 1, 2, AT);
    b(c, 3, 0, 1, 1, AL); b(c, 12, 0, 1, 1, AL);
    // Leaf wreath / crown
    b(c, 4, 2, 8, 2, LF); b(c, 5, 2, 6, 1, GG);
    // Hair + face
    if (isFemale) {
      b(c, 4, 4, 2, 7, WH); b(c, 10, 4, 2, 7, WH); // long flowing hair
      b(c, 3, 5, 2, 6, WH); b(c, 11, 5, 2, 6, WH);
      b(c, 5, 4, 6, 5, SK);
      b(c, 6, 5, 1, 1, 0xFF2a1808); b(c, 9, 5, 1, 1, 0xFF2a1808);
      b(c, 5, 8, 6, 1, LF); // vine circlet on chin
      b(c, 7, 9, 2, 1, SK);
    } else if (isNonBinary) {
      b(c, 4, 4, 2, 5, WH); b(c, 10, 4, 2, 5, WH);
      b(c, 3, 5, 2, 4, WH); b(c, 11, 5, 2, 4, WH);
      b(c, 5, 4, 6, 5, SK);
      b(c, 6, 5, 1, 1, 0xFF2a1808); b(c, 9, 5, 1, 1, 0xFF2a1808);
      b(c, 6, 8, 4, 1, 0xFFb08050); // short beard
      b(c, 7, 9, 2, 1, SK);
    } else {
      b(c, 4, 4, 2, 5, WH); b(c, 10, 4, 2, 5, WH);
      b(c, 3, 5, 2, 4, WH); b(c, 11, 5, 2, 4, WH);
      b(c, 5, 4, 6, 5, SK);
      b(c, 6, 5, 1, 1, 0xFF2a1808); b(c, 9, 5, 1, 1, 0xFF2a1808);
      b(c, 6, 8, 4, 1, 0xFFb08050);
      b(c, 5, 9, 6, 4, WH); b(c, 6, 10, 4, 3, 0xFFe0d8c0); // long beard
      b(c, 7, 9, 2, 1, SK);
    }
    // Shoulders (robed)
    b(c, 3, 9, 3, 3, GL); b(c, 10, 9, 3, 3, GL);
    b(c, 3, 9, 3, 1, GG); b(c, 10, 9, 3, 1, GG);
    // Robe body
    b(c, 4, 9, 8, 9, GR); b(c, 5, 10, 6, 7, GL);
    b(c, 6, 11, 4, 3, GG); // front highlight
    // Brown belt
    b(c, 4, 17, 8, 1, BR); b(c, 5, 17, 6, 1, BL);
    // Robe lower
    b(c, 3, 18, 10, 5, GR); b(c, 4, 18, 8, 4, GL);
    // Arms
    b(c, 2, 11, 2, 8, GR); b(c, 12, 11, 2, 8, GR);
    b(c, 2, 11, 2, 5, GL); b(c, 12, 11, 2, 5, GL);
    // Staff (right side)
    b(c, 14, 6, 1, 17, BR); b(c, 15, 6, 1, 17, BL);
    b(c, 13, 5, 3, 2, GG); // staff tip (leaf/glow)
    b(c, 14, 4, 1, 2, 0xFF80e040);
    // Boots
    b(c, 5, 21, 2, 3, BR); b(c, 9, 21, 2, 3, BR);
  }
}

// ─────────────────────────────────────────────────────────────
// FIGHTER HERO  (16 × 24)
// ─────────────────────────────────────────────────────────────
class _FighterHeroPainter extends _Painter {
  const _FighterHeroPainter(super.facingLeft, [super.t = 0.0, super.gender = HeroGender.male]);
  @override
  void draw(Canvas c, Size sz) {
    const IR = 0xFF686870; // iron grey
    const IL = 0xFF909098; // iron light
    const ID = 0xFF3a3a40; // iron dark
    const BU = 0xFF283060; // blue surcoat
    const BL = 0xFF3840a0; // blue light
    const GD = 0xFFb89030; // gold trim
    const SW = 0xFFc0c8d0; // sword silver

    // Great helm (full face cover)
    b(c, 4, 0, 8, 6, IR); b(c, 4, 0, 8, 1, IL);
    b(c, 3, 1, 1, 5, ID); b(c, 12, 1, 1, 5, ID);
    b(c, 4, 2, 8, 2, ID);
    b(c, 5, 2, 6, 1, 0xFF101020);
    b(c, 4, 4, 8, 1, ID); b(c, 4, 5, 8, 1, GD);
    if (isFemale) {
      b(c, 7, 0, 2, 1, 0xFFcc3030); // red plume crest
      b(c, 3, 5, 1, 3, 0xFFb89060); // hair peeking from sides
      b(c, 12, 5, 1, 3, 0xFFb89060);
    } else if (isNonBinary) {
      b(c, 7, 0, 2, 1, 0xFF4080cc); // blue plume crest
    }
    // Wide pauldrons
    b(c, 0, 5, 5, 4, IR); b(c, 11, 5, 5, 4, IR);
    b(c, 0, 5, 5, 1, IL); b(c, 11, 5, 5, 1, IL);
    b(c, 0, 8, 5, 1, ID); b(c, 11, 8, 5, 1, ID);
    // Chest plate
    b(c, 4, 5, 8, 9, ID); b(c, 5, 6, 6, 7, IR); b(c, 5, 6, 6, 1, IL);
    b(c, 6, 9, 4, 1, GD); // chest stripe
    // Blue surcoat below chest
    b(c, 4, 14, 8, 4, BU); b(c, 5, 14, 6, 4, BL);
    b(c, 4, 17, 8, 1, GD);
    // Arms in plate
    b(c, 1, 9, 3, 9, IR); b(c, 12, 9, 3, 9, IR);
    b(c, 1, 9, 3, 1, IL); b(c, 12, 9, 3, 1, IL);
    // Gauntlets
    b(c, 1, 17, 3, 3, ID); b(c, 12, 17, 3, 3, ID);
    b(c, 1, 17, 3, 1, IR); b(c, 12, 17, 3, 1, IR);
    // Legs in plate
    b(c, 4, 18, 3, 5, IR); b(c, 9, 18, 3, 5, IR);
    b(c, 4, 18, 3, 1, IL); b(c, 9, 18, 3, 1, IL);
    // Greaves / sabatons
    b(c, 3, 22, 5, 2, ID); b(c, 8, 22, 5, 2, ID);
    b(c, 3, 23, 6, 1, ID); b(c, 8, 23, 5, 1, ID);
    // Great sword (right side)
    b(c, 13, 2, 2, 21, SW); b(c, 14, 2, 1, 21, 0xFFe0e8f0);
    b(c, 11, 2, 3, 1, GD); // crossguard top
    b(c, 11, 3, 3, 1, GD); // crossguard bottom
  }
}

// ─────────────────────────────────────────────────────────────
// MONK HERO  (16 × 24)
// ─────────────────────────────────────────────────────────────
class _MonkHeroPainter extends _Painter {
  const _MonkHeroPainter(super.facingLeft, [super.t = 0.0, super.gender = HeroGender.male]);
  @override
  void draw(Canvas c, Size sz) {
    const SA = 0xFFc89030; // saffron/orange
    const SL = 0xFFe8b040; // saffron light
    const SD = 0xFF8a6010; // saffron dark
    const SK = 0xFFc8785c; // skin
    const SS = 0xFFe09060; // skin light
    const WR = 0xFFe8dcc8; // bandage wrap
    const WT = 0xFFf8f0e0; // wrap highlight
    const K  = 0xFF181010; // outline

    // Head + face
    if (isFemale) {
      b(c, 5, 0, 6, 3, SK); b(c, 5, 0, 6, 1, SS);
      b(c, 4, 1, 8, 4, SK);
      b(c, 4, 0, 2, 3, 0xFF201008); b(c, 10, 0, 2, 3, 0xFF201008); // short hair sides
      b(c, 5, 0, 6, 1, 0xFF201008); // top hair
      b(c, 5, 4, 6, 4, SK); b(c, 5, 4, 6, 1, SS);
      b(c, 6, 5, 1, 1, K); b(c, 9, 5, 1, 1, K);
      b(c, 7, 7, 2, 1, 0xFF804030);
    } else if (isNonBinary) {
      b(c, 5, 0, 6, 3, SK); b(c, 5, 0, 6, 1, SS);
      b(c, 4, 1, 8, 4, SK);
      b(c, 4, 0, 8, 1, SA); // saffron headband
      b(c, 5, 4, 6, 4, SK); b(c, 5, 4, 6, 1, SS);
      b(c, 6, 5, 1, 1, K); b(c, 9, 5, 1, 1, K);
      b(c, 7, 7, 2, 1, 0xFF804030);
    } else {
      b(c, 5, 0, 6, 3, SK); b(c, 5, 0, 6, 1, SS);
      b(c, 4, 1, 8, 4, SK);
      b(c, 5, 4, 6, 4, SK); b(c, 5, 4, 6, 1, SS);
      b(c, 6, 5, 1, 1, K); b(c, 9, 5, 1, 1, K);
      b(c, 7, 7, 2, 1, 0xFF804030);
    }
    // Gi collar wrap
    b(c, 4, 2, 2, 5, SA); b(c, 10, 2, 2, 5, SA);
    // Neck
    b(c, 7, 8, 2, 1, SK);
    // Gi collar
    b(c, 5, 8, 6, 1, WR); b(c, 5, 8, 6, 1, WT);
    // Gi body (orange, V-cross wrap)
    b(c, 4, 9, 8, 9, SA); b(c, 5, 9, 6, 8, SL);
    b(c, 6, 10, 4, 1, WT); // highlight
    b(c, 5, 9, 3, 6, SD);  // crossed gi fold
    // Belt (dark sash)
    b(c, 4, 17, 8, 2, SD); b(c, 6, 17, 4, 1, SA);
    // Wide gi pants
    b(c, 3, 19, 10, 5, SA); b(c, 4, 19, 8, 4, SL);
    // Arms (bare skin)
    b(c, 1, 9, 3, 8, SK); b(c, 12, 9, 3, 8, SK);
    b(c, 1, 9, 3, 1, SS); b(c, 12, 9, 3, 1, SS);
    // Hand wraps / bandages
    b(c, 1, 15, 3, 4, WR); b(c, 12, 15, 3, 4, WR);
    b(c, 1, 16, 3, 1, WT); b(c, 12, 16, 3, 1, WT);
    b(c, 2, 19, 2, 1, SK); b(c, 12, 19, 2, 1, SK); // knuckle skin
    // Bare feet
    b(c, 4, 22, 4, 2, SK); b(c, 8, 22, 4, 2, SK);
    b(c, 3, 23, 5, 1, SK); b(c, 8, 23, 5, 1, SK);
  }
}

// ─────────────────────────────────────────────────────────────
// RANGER HERO  (16 × 24)
// ─────────────────────────────────────────────────────────────
class _RangerHeroPainter extends _Painter {
  const _RangerHeroPainter(super.facingLeft, [super.t = 0.0, super.gender = HeroGender.male]);
  @override
  void draw(Canvas c, Size sz) {
    const HD = 0xFF1a3018; // hood dark
    const HL = 0xFF2a4828; // hood mid
    const HG = 0xFF3a6030; // hood bright
    const CL = 0xFF1c3c1a; // cloak
    const CL2 = 0xFF2c5228; // cloak light
    const LB = 0xFF5c3810; // leather
    const LL = 0xFF7a5020; // leather light
    const SK = 0xFFc8a060; // skin
    const QD = 0xFF3a2010; // quiver dark
    const AR = 0xFFb8a060; // arrow shaft

    // Hood
    b(c, 3, 0, 10, 5, HD); b(c, 4, 0, 8, 1, HL);
    b(c, 5, 1, 6, 2, 0xFF0a1808);
    // Face in shadow
    b(c, 5, 3, 6, 3, SK);
    b(c, 6, 4, 1, 1, 0xFF201008); b(c, 9, 4, 1, 1, 0xFF201008);
    b(c, 4, 2, 1, 4, HD); b(c, 11, 2, 1, 4, HD);
    if (isFemale) {
      b(c, 3, 5, 2, 5, 0xFF5a3010); b(c, 11, 5, 2, 5, 0xFF5a3010); // long hair under hood
    } else if (isNonBinary) {
      b(c, 3, 5, 1, 4, 0xFF5a3010); // hair peeking one side
    }
    // Hood over shoulders / cloak
    b(c, 2, 5, 12, 4, CL); b(c, 3, 5, 10, 3, CL2);
    b(c, 2, 5, 12, 1, HL);
    // Quiver on right shoulder/back
    b(c, 13, 3, 2, 9, QD); b(c, 14, 4, 1, 8, LL);
    b(c, 13, 2, 1, 4, AR); b(c, 14, 1, 1, 4, AR); // arrows
    b(c, 15, 2, 1, 3, AR);
    // Leather chest plate (under cloak)
    b(c, 4, 9, 8, 7, LB); b(c, 5, 9, 6, 6, LL);
    // Belt
    b(c, 4, 15, 8, 1, QD); b(c, 7, 15, 2, 1, LL); // buckle
    // Arms (cloak sleeves)
    b(c, 2, 9, 2, 9, CL); b(c, 12, 9, 2, 9, CL);
    b(c, 2, 9, 2, 5, CL2); b(c, 12, 9, 2, 5, CL2);
    // Gloved hands
    b(c, 2, 17, 2, 3, LB); b(c, 12, 17, 2, 3, LB);
    b(c, 2, 17, 2, 1, LL); b(c, 12, 17, 2, 1, LL);
    // Legs (leather)
    b(c, 4, 16, 3, 6, LB); b(c, 9, 16, 3, 6, LB);
    b(c, 5, 16, 2, 5, LL); b(c, 9, 16, 2, 5, LL);
    // Boots
    b(c, 3, 21, 5, 3, QD); b(c, 8, 21, 5, 3, QD);
    b(c, 3, 21, 5, 1, LL); b(c, 8, 21, 5, 1, LL);
  }
}

// ─────────────────────────────────────────────────────────────
// ROGUE HERO  (16 × 24)
// ─────────────────────────────────────────────────────────────
class _RogueHeroPainter extends _Painter {
  const _RogueHeroPainter(super.facingLeft, [super.t = 0.0, super.gender = HeroGender.male]);
  @override
  void draw(Canvas c, Size sz) {
    const DK = 0xFF141420; // void dark
    const DM = 0xFF2a2840; // dark mid
    const DL = 0xFF3c3858; // dark light
    const PU = 0xFF4020a0; // purple accent
    const SK = 0xFFc8a060; // skin
    const BL = 0xFF8898c8; // blade silver
    const GD = 0xFFc8a020; // gold buckle
    const EY = 0xFF40d0e0; // teal glowing eyes

    // Full cowl / hood
    b(c, 4, 0, 8, 6, DK); b(c, 5, 0, 6, 1, DM);
    b(c, 3, 1, 1, 5, DK); b(c, 12, 1, 1, 5, DK);
    b(c, 5, 2, 6, 3, 0xFF08080f);
    // Glowing eyes
    final eyeColor = isFemale ? 0xFFe040d0 : isNonBinary ? 0xFFd0e040 : EY;
    b(c, 6, 3, 1, 1, eyeColor); b(c, 9, 3, 1, 1, eyeColor);
    // Face mask
    b(c, 5, 5, 6, 2, DM);
    if (isFemale) {
      b(c, 3, 5, 1, 4, 0xFF1a1428); // hair strands under cowl
      b(c, 12, 5, 1, 4, 0xFF1a1428);
    }
    // Neck
    b(c, 7, 7, 2, 1, SK);
    // Shoulders (sleek)
    b(c, 3, 6, 3, 3, DK); b(c, 10, 6, 3, 3, DK);
    b(c, 3, 6, 3, 1, DM); b(c, 10, 6, 3, 1, DM);
    // Body (slim, dark)
    b(c, 4, 7, 8, 10, DK); b(c, 5, 8, 6, 8, DM);
    b(c, 6, 9, 4, 3, DL); // centre highlight
    // Bandolier / belt
    b(c, 4, 12, 8, 1, GD);
    // Left dagger (hip)
    b(c, 3, 13, 2, 4, DM); b(c, 4, 11, 1, 4, BL);
    b(c, 3, 13, 2, 1, GD);
    // Right dagger (hip)
    b(c, 11, 13, 2, 4, DM); b(c, 11, 11, 1, 4, BL);
    b(c, 11, 13, 2, 1, GD);
    // Arms (slim dark sleeves)
    b(c, 2, 8, 2, 10, DK); b(c, 12, 8, 2, 10, DK);
    b(c, 2, 8, 2, 7, DM); b(c, 12, 8, 2, 7, DM);
    // Gloved hands
    b(c, 2, 17, 2, 2, DK); b(c, 12, 17, 2, 2, DK);
    // Legs (slim, dark)
    b(c, 5, 17, 3, 6, DM); b(c, 8, 17, 3, 6, DM);
    b(c, 5, 17, 2, 5, DL); b(c, 9, 17, 2, 5, DL);
    // Dark boots
    b(c, 4, 21, 4, 3, DK); b(c, 8, 21, 4, 3, DK);
    b(c, 4, 21, 4, 1, DM); b(c, 8, 21, 4, 1, DM);
    // Purple hem accent
    b(c, 4, 16, 8, 1, PU);
  }
}

// ─────────────────────────────────────────────────────────────
// SORCERER HERO  (16 × 24)
// ─────────────────────────────────────────────────────────────
class _SorcererHeroPainter extends _Painter {
  const _SorcererHeroPainter(super.facingLeft, [super.t = 0.0, super.gender = HeroGender.male]);
  @override
  void draw(Canvas c, Size sz) {
    const RB = 0xFF1c1880; // robe dark blue
    const RL = 0xFF2c2ab0; // robe light
    const GW = 0xFF80c0ff; // magical glow cyan
    const GD = 0xFFd4af37; // gold circlet
    const SK = 0xFFe8c890; // pale skin
    const HR = 0xFFd0c0b0; // silver-white hair
    const EY = 0xFF40a0ff; // glowing eyes blue
    const OM = 0xFFa060ff; // orb purple

    // Hair + face
    if (isFemale) {
      // Long flowing hair past shoulders
      b(c, 3, 0, 2, 9, HR); b(c, 11, 0, 2, 9, HR);
      b(c, 4, 0, 8, 2, HR); b(c, 5, 0, 6, 1, 0xFFf0e0d0);
      b(c, 2, 3, 2, 6, HR); b(c, 12, 3, 2, 6, HR); // extra flowing sides
      b(c, 4, 3, 8, 1, GD); // circlet
      b(c, 5, 3, 6, 5, SK); b(c, 5, 3, 6, 1, 0xFFf8e8c0);
      b(c, 6, 4, 1, 1, EY); b(c, 9, 4, 1, 1, EY);
      b(c, 7, 6, 2, 1, 0xFFc08080); // lips
    } else if (isNonBinary) {
      // Asymmetric: short one side, swept the other
      b(c, 3, 0, 2, 4, HR); b(c, 11, 0, 2, 7, HR);
      b(c, 4, 0, 8, 2, HR); b(c, 5, 0, 6, 1, 0xFFf0e0d0);
      b(c, 12, 3, 1, 4, HR); // long sweep right
      b(c, 4, 3, 8, 1, GD);
      b(c, 5, 3, 6, 5, SK); b(c, 5, 3, 6, 1, 0xFFf8e8c0);
      b(c, 6, 4, 1, 1, EY); b(c, 9, 4, 1, 1, EY);
      b(c, 7, 7, 2, 1, SK);
    } else {
      // Wild hair (default male)
      b(c, 3, 0, 2, 6, HR); b(c, 11, 0, 2, 6, HR);
      b(c, 4, 0, 8, 2, HR); b(c, 5, 0, 6, 1, 0xFFf0e0d0);
      b(c, 4, 1, 2, 3, HR); b(c, 10, 1, 2, 3, HR);
      b(c, 4, 3, 8, 1, GD);
      b(c, 5, 3, 6, 5, SK); b(c, 5, 3, 6, 1, 0xFFf8e8c0);
      b(c, 6, 4, 1, 1, EY); b(c, 9, 4, 1, 1, EY);
      b(c, 7, 7, 2, 1, SK);
    }
    // Neck + collar
    b(c, 7, 8, 2, 1, SK);
    b(c, 5, 8, 6, 1, GD);
    // Robe body
    b(c, 3, 9, 10, 10, RB); b(c, 4, 9, 8, 9, RL);
    b(c, 4, 9, 8, 1, GD); // top trim
    // Arcane runes on chest (glowing lines)
    b(c, 6, 11, 4, 1, GW); b(c, 6, 13, 4, 1, GW);
    b(c, 7, 12, 2, 2, OM); // chest orb
    b(c, 7, 11, 2, 1, 0xFFd0e8ff); // orb glow top
    // Arms in flowing robes
    b(c, 1, 10, 3, 9, RB); b(c, 12, 10, 3, 9, RB);
    b(c, 2, 10, 2, 7, RL); b(c, 12, 10, 2, 7, RL);
    // Left hand (open)
    b(c, 1, 18, 3, 3, SK);
    // Right hand casting orb
    b(c, 12, 18, 3, 3, SK);
    b(c, 12, 17, 3, 2, GW); // glow
    b(c, 13, 16, 2, 3, OM); // orb floating
    b(c, 13, 15, 2, 1, 0xFFe0d0ff); // orb highlight
    // Robe lower (flows wide)
    b(c, 2, 19, 12, 5, RB); b(c, 3, 19, 10, 4, RL);
    b(c, 4, 20, 8, 3, RL);
    b(c, 3, 23, 10, 1, GW); // hem glow
  }
}

// ─────────────────────────────────────────────────────────────
// WARLOCK HERO  (16 × 24)
// ─────────────────────────────────────────────────────────────
class _WarlockHeroPainter extends _Painter {
  const _WarlockHeroPainter(super.facingLeft, [super.t = 0.0, super.gender = HeroGender.male]);
  @override
  void draw(Canvas c, Size sz) {
    const VD = 0xFF0c0c18; // void black
    const DM = 0xFF1a1828; // dark robe
    const DL = 0xFF2a2840; // robe light
    const EL = 0xFF20e040; // eldritch green bright
    const EG = 0xFF10a028; // eldritch green dark
    const PU = 0xFF5818b0; // purple horn/helm
    const PL = 0xFF7828e0; // purple light
    const SK = 0xFFc0b090; // pallid skin

    // Demonic helmet with curved horns
    b(c, 5, 0, 6, 5, PU); b(c, 5, 0, 6, 1, PL);
    b(c, 2, 0, 3, 6, PU); b(c, 11, 0, 3, 6, PU); // outer horns
    b(c, 2, 0, 2, 4, DM); b(c, 12, 0, 2, 4, DM); // inner horn shadow
    b(c, 3, 0, 1, 2, EG); b(c, 12, 0, 1, 2, EG); // horn tip glow
    // Visor zone
    b(c, 4, 2, 8, 3, VD);
    final eyeGlow = isFemale ? 0xFFe020e0 : isNonBinary ? 0xFF20e0e0 : EL;
    final eyeDark = isFemale ? 0xFF8010a0 : isNonBinary ? 0xFF10a0a0 : EG;
    b(c, 5, 3, 2, 1, eyeGlow); b(c, 9, 3, 2, 1, eyeGlow);
    b(c, 6, 3, 1, 1, eyeDark); b(c, 9, 3, 1, 1, eyeDark);
    if (isFemale) {
      b(c, 3, 5, 1, 4, 0xFF2a1020); b(c, 12, 5, 1, 4, 0xFF2a1020); // hair under helm
    }
    // Neck guard
    b(c, 6, 5, 4, 2, DM);
    // Tattered robe body
    b(c, 3, 7, 10, 11, DM); b(c, 4, 7, 8, 10, DL);
    // Eldritch rune marks
    b(c, 6, 8, 4, 1, EG); b(c, 5, 11, 2, 1, EG); b(c, 9, 11, 2, 1, EG);
    b(c, 6, 14, 4, 1, EG);
    // Arms (tattered dark sleeves)
    b(c, 1, 8, 3, 10, DM); b(c, 12, 8, 3, 10, DM);
    b(c, 1, 9, 2, 6, DL); b(c, 13, 9, 2, 6, DL);
    // Left hand — eldritch casting glow
    b(c, 1, 18, 3, 2, SK);
    b(c, 0, 17, 4, 3, EG); b(c, 1, 17, 2, 2, EL);
    // Right hand
    b(c, 12, 18, 3, 2, SK);
    // Tattered hem (jagged lower robe)
    b(c, 3, 18, 10, 4, DM); b(c, 4, 18, 8, 3, DL);
    b(c, 3, 21, 2, 3, VD); b(c, 6, 21, 2, 3, VD);
    b(c, 9, 21, 2, 3, VD); b(c, 12, 21, 2, 3, VD);
    // Eldritch ground glow
    b(c, 4, 23, 8, 1, EG); b(c, 6, 23, 4, 1, EL);
  }
}

// ─────────────────────────────────────────────────────────────
// WIZARD HERO  (16 × 24)
// ─────────────────────────────────────────────────────────────
class _WizardHeroPainter extends _Painter {
  const _WizardHeroPainter(super.facingLeft, [super.t = 0.0, super.gender = HeroGender.male]);
  @override
  void draw(Canvas c, Size sz) {
    const HD = 0xFF1c2060; // hat dark blue
    const HL = 0xFF2c30a0; // hat light
    const HB = 0xFF141840; // hat brim
    const RB = 0xFF1c2478; // robe dark
    const RL = 0xFF2c34a8; // robe light
    const ST = 0xFFd4af37; // gold star / trim
    const SK = 0xFFe8c890; // skin
    const WB = 0xFFe8e0d0; // white beard
    const BR = 0xFF6a4810; // staff wood
    const BL = 0xFF8a6020; // staff light
    const GW = 0xFFa0c8ff; // gem blue glow

    // Tall pointed hat
    b(c, 6, 0, 4, 5, HD); b(c, 6, 0, 4, 1, HL); // peak
    b(c, 5, 3, 6, 3, HD); b(c, 5, 3, 6, 1, HL);
    b(c, 4, 5, 8, 1, HD);
    b(c, 1, 6, 14, 1, HB); b(c, 2, 6, 12, 1, HL); // brim
    // Stars on hat
    b(c, 6, 1, 1, 1, ST); b(c, 8, 3, 1, 1, ST); b(c, 5, 4, 1, 1, ST);
    // Hair + face
    if (isFemale) {
      // Long flowing white hair, no beard
      b(c, 4, 7, 2, 9, WB); b(c, 10, 7, 2, 9, WB);
      b(c, 3, 8, 2, 7, WB); b(c, 11, 8, 2, 7, WB);
      b(c, 5, 7, 6, 5, SK); b(c, 5, 7, 6, 1, 0xFFF8E8C0);
      b(c, 6, 8, 1, 1, 0xFF201810); b(c, 9, 8, 1, 1, 0xFF201810);
      b(c, 7, 10, 2, 1, 0xFFc08080); // lips
    } else if (isNonBinary) {
      // Medium hair, short beard
      b(c, 4, 7, 2, 6, WB); b(c, 10, 7, 2, 6, WB);
      b(c, 3, 8, 2, 4, WB); b(c, 11, 8, 2, 4, WB);
      b(c, 5, 7, 6, 5, SK); b(c, 5, 7, 6, 1, 0xFFF8E8C0);
      b(c, 6, 8, 1, 1, 0xFF201810); b(c, 9, 8, 1, 1, 0xFF201810);
      b(c, 5, 11, 6, 2, WB); b(c, 6, 12, 4, 1, 0xFFf0e8d8); // short beard
    } else {
      // Classic long-bearded wizard
      b(c, 4, 7, 2, 7, WB); b(c, 10, 7, 2, 7, WB);
      b(c, 3, 8, 2, 5, WB); b(c, 11, 8, 2, 5, WB);
      b(c, 5, 7, 6, 5, SK); b(c, 5, 7, 6, 1, 0xFFF8E8C0);
      b(c, 6, 8, 1, 1, 0xFF201810); b(c, 9, 8, 1, 1, 0xFF201810);
      b(c, 5, 11, 6, 5, WB); b(c, 6, 12, 4, 4, 0xFFf0e8d8);
      b(c, 7, 15, 2, 2, WB);
    }
    // Robe body
    b(c, 4, 12, 8, 11, RB); b(c, 5, 13, 6, 9, RL);
    b(c, 4, 12, 8, 1, ST); // collar gold trim
    // Star motifs on robe
    b(c, 6, 15, 1, 1, ST); b(c, 9, 17, 1, 1, ST); b(c, 6, 20, 1, 1, ST);
    // Arms in wide robes
    b(c, 2, 12, 2, 9, RB); b(c, 12, 12, 2, 9, RB);
    b(c, 2, 13, 2, 6, RL); b(c, 12, 13, 2, 6, RL);
    // Hands
    b(c, 2, 20, 2, 2, SK); b(c, 12, 20, 2, 2, SK);
    // Staff (left side, tall)
    b(c, 0, 8, 1, 16, BR); b(c, 1, 8, 1, 15, BL);
    // Staff gem top
    b(c, 0, 5, 3, 4, RB); b(c, 0, 6, 3, 1, GW);
    b(c, 1, 5, 1, 2, 0xFFd0e8ff); // gem highlight
    b(c, 0, 5, 2, 1, ST); // gold setting
    // Robe hem
    b(c, 3, 22, 10, 1, RB); b(c, 4, 22, 8, 1, RL);
    b(c, 5, 21, 6, 2, RL);
  }
}

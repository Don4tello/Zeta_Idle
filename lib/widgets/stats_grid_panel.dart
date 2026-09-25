import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/damage_type.dart';
import '../models/endless_upgrades.dart';
import '../models/equipment.dart';
import '../models/hero_model.dart';
import '../models/passive_tree.dart';
import '../models/upgrade.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StatsGridPanel
// ─────────────────────────────────────────────────────────────────────────────

class StatsGridPanel extends StatelessWidget {
  const StatsGridPanel({super.key, this.readOnly = false});

  /// When true, cards show the stat + tap-for-info only (no gold-upgrade button)
  /// — used on the Hero sheet and Bonuses sheet where it's a reference display.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final hero = game.hero;

    // Effective attribute = base + equipped-gear bonus. Combat already scales
    // damage/resist/dodge/DoT/HoT/CD-skip off this total (an item's +STR fully
    // raises the stat), so the sheet now shows the same effective number and
    // effects instead of the bare base value.
    int eff(int base, ItemStat s) => game.effectiveAttr(base, s);
    final data = <({
      String abbr,
      IconData icon,
      Color color,
      String? upgradeId,
      int score,
      int dmgPct,
    })>[
      (abbr: 'STR', icon: Icons.fitness_center,   color: EndlessNode.str.color,          upgradeId: 'str_1', score: eff(hero.strength,     ItemStat.strength),     dmgPct: game.attrDamagePctFor(DamageType.physical)),
      (abbr: 'DEX', icon: Icons.directions_run,   color: EndlessNode.dex.color,          upgradeId: 'dex_1', score: eff(hero.dexterity,    ItemStat.dexterity),    dmgPct: game.attrDamagePctFor(DamageType.lightning)),
      (abbr: 'CON', icon: Icons.favorite,         color: EndlessNode.con.color,          upgradeId: 'con_1', score: eff(hero.constitution, ItemStat.constitution), dmgPct: game.attrDamagePctFor(DamageType.poison)),
      (abbr: 'INT', icon: Icons.psychology,       color: EndlessNode.intelligence.color, upgradeId: 'int_1', score: eff(hero.intelligence, ItemStat.intelligence), dmgPct: game.attrDamagePctFor(DamageType.void_)),
      (abbr: 'WIS', icon: Icons.visibility,       color: EndlessNode.wis.color,          upgradeId: 'wis_1', score: eff(hero.wisdom,       ItemStat.wisdom),       dmgPct: game.attrDamagePctFor(DamageType.cold)),
      (abbr: 'CHA', icon: Icons.theater_comedy,   color: EndlessNode.cha.color,          upgradeId: 'cha_1', score: eff(hero.charisma,     ItemStat.charisma),     dmgPct: game.attrDamagePctFor(DamageType.fire)),
    ];

    final keyStats = hero.heroClass.info.keyStats;

    Widget row(int from) => Row(
      children: List.generate(3, (i) {
        final d = data[from + i];
        final upgrade   = _findUpgrade(game.upgrades, d.upgradeId);
        final canAfford = upgrade != null && !upgrade.isMaxed && game.gold >= upgrade.cost;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
            child: _StatCard(
              abbr:        d.abbr,
              score:       d.score,
              dmgPct:      d.dmgPct,
              icon:        d.icon,
              color:       d.color,
              upgrade:     upgrade,
              canAfford:   canAfford,
              isKeyAbility: keyStats.contains(d.abbr),
              hero:        hero,
              readOnly:    readOnly,
              onUpgrade:   canAfford ? () { game.purchaseUpgrade(upgrade!); game.audioService.playClaim(); } : null,
            ),
          ),
        );
      }),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'ABILITY SCORES',
            style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2, color: AppTheme.textMuted),
          ),
        ),
        row(0),
        const SizedBox(height: 6),
        row(3),
      ],
    );
  }

  static Upgrade? _findUpgrade(List<Upgrade> list, String? id) {
    if (id == null) return null;
    for (final u in list) {
      if (u.id == id) return u;
    }
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatCard
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatefulWidget {
  const _StatCard({
    required this.abbr,
    required this.score,
    required this.dmgPct,
    required this.icon,
    required this.color,
    required this.upgrade,
    required this.canAfford,
    required this.isKeyAbility,
    required this.hero,
    required this.onUpgrade,
    this.readOnly = false,
  });

  final String     abbr;
  final int        score;   // effective attribute (base + equipped gear)
  final int        dmgPct;  // effective damage % this attribute grants

  final IconData   icon;
  final Color      color;
  final Upgrade?   upgrade;
  final bool       canAfford;
  final bool       isKeyAbility;
  final HeroModel  hero;
  final VoidCallback? onUpgrade;
  final bool       readOnly;

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce;
  late final Animation<double>   _scale;

  // ── Stat metadata ──────────────────────────────────────────────────────────

  String get _fullName {
    const names = {
      'STR': 'Strength',     'DEX': 'Dexterity',
      'CON': 'Constitution', 'INT': 'Intelligence',
      'WIS': 'Wisdom',       'CHA': 'Charisma',
    };
    return names[widget.abbr] ?? widget.abbr;
  }

  String get _description {
    switch (widget.abbr) {
      case 'STR': return 'Raw Power — the universal weapon stat: +1 flat damage to EVERY '
          'hit (any element) and +1 armor per point.';
      case 'DEX': return 'Boosts Lightning damage (up to +25%) and Lightning resistance.\n'
          'Also grants Dodge chance: +0.5% per point above 10 (max 30%).';
      case 'CON': return 'Boosts Poison damage (up to +25%) and Poison resistance.\n'
          'Also adds +1% Max HP per point and boosts your HP regen.';
      case 'INT': return 'Boosts Void damage (up to +25%) and Void resistance.\n'
          'Also amplifies damage-over-time: +1% per point above 10.';
      case 'WIS': return 'Boosts Cold damage (up to +25%) and Cold resistance.\n'
          'Also amplifies heal-over-time (auras): +1% per point above 10.';
      case 'CHA': return 'Boosts Fire damage (up to +25%) and Fire resistance.\n'
          'Also gives a chance to skip an ability cooldown: charisma÷5% (max 20%).';
      default:    return '';
    }
  }

  // Live value box — the damage-type % PLUS this stat's signature secondary
  // effect. Uses the EFFECTIVE attribute (base + gear) and effective damage %,
  // so it matches what combat actually grants (see attrDamagePctFor).
  String get _currentEffect {
    final s = widget.score;      // effective attribute total
    final dmg = widget.dmgPct;   // effective damage % for this stat's type
    int abv10(int x) => x > 10 ? x - 10 : 0;
    switch (widget.abbr) {
      case 'STR': return '+$s hit dmg   •   +$s armor';
      case 'DEX': return 'Lightning Dmg +$dmg%'
          '   •   Dodge +${(abv10(s) * 0.5).clamp(0, 30).round()}%';
      case 'CON': return 'Poison Dmg +$dmg%'
          '   •   +$s% Max HP';
      case 'INT': return 'Void Dmg +$dmg%'
          '   •   DoT +${abv10(s)}%';
      case 'WIS': return 'Cold Dmg +$dmg%'
          '   •   Heal-o-t +${abv10(s)}%';
      case 'CHA': return 'Fire Dmg +$dmg%'
          '   •   CD skip ${(s / 5).clamp(0, 20).round()}%';
      default:    return '';
    }
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.00, end: 1.12), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 0.94), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.00), weight: 30),
    ]).animate(CurvedAnimation(parent: _bounce, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  // ── Info dialog ────────────────────────────────────────────────────────────

  void _showInfoDialog(BuildContext context) {
    final isMaxed = widget.upgrade?.isMaxed ?? true;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              border: Border.all(color: widget.color, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon + name
                Icon(widget.icon, size: 30, color: widget.color),
                const SizedBox(height: 6),
                Text(
                  widget.abbr,
                  style: AppTheme.pixelHeading(fontSize: 21, color: widget.color, letterSpacing: 3),
                ),
                Text(
                  _fullName.toUpperCase(),
                  style: AppTheme.pixelHeading(fontSize: 10, color: AppTheme.textMuted, letterSpacing: 2),
                ),
                const SizedBox(height: 14),
                Container(height: 1, color: widget.color.withValues(alpha: 0.3)),
                const SizedBox(height: 12),

                // Description
                Text(
                  _description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sourceCodePro(
                    fontSize: 14,
                    color: AppTheme.textLight,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),

                // Current effect box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.darkBg,
                    border: Border.all(color: widget.color.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    _currentEffect,
                    textAlign: TextAlign.center,
                    style: AppTheme.pixelHeading(
                      fontSize: 11,
                      color: widget.color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Upgrade call-to-action — interactive view only. These attributes
                // aren't directly buyable; they come from items, subclass, traits, etc.
                if (!widget.readOnly) ...[
                  if (!isMaxed) ...[
                    if (widget.canAfford)
                      GestureDetector(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _bounce.forward(from: 0);
                          widget.onUpgrade?.call();
                        },
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 48),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.18),
                            border: Border.all(color: widget.color),
                          ),
                          child: Text(
                            '+ UPGRADE  ·  ${widget.upgrade!.cost} GOLD',
                            textAlign: TextAlign.center,
                            style: AppTheme.pixelHeading(
                              fontSize: 14,
                              color: widget.color,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      )
                    else
                      Text(
                        'Need ${widget.upgrade?.cost} gold to upgrade',
                        style: AppTheme.pixelHeading(
                            fontSize: 13, color: AppTheme.textMuted, letterSpacing: 0.5),
                      ),
                    const SizedBox(height: 10),
                  ] else ...[
                    Text('FULLY UPGRADED',
                        style: AppTheme.pixelHeading(fontSize: 13, color: AppTheme.textMuted)),
                    const SizedBox(height: 10),
                  ],
                ],

                // Close
                GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48, minWidth: 120),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Text(
                      'CLOSE',
                      style: AppTheme.pixelHeading(
                          fontSize: 14, color: AppTheme.textMuted, letterSpacing: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isMaxed  = widget.upgrade?.isMaxed ?? true;

    final isKey = widget.isKeyAbility;

    final dmgType = switch (widget.abbr) {
      'STR' => DamageType.physical,
      'DEX' => DamageType.lightning,
      'CON' => DamageType.poison,
      'INT' => DamageType.void_,
      'WIS' => DamageType.cold,
      'CHA' => DamageType.fire,
      _     => DamageType.physical,
    };

    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: widget.canAfford
              ? Color.lerp(AppTheme.cardBg, widget.color, 0.07)!
              : isKey
                  ? Color.lerp(AppTheme.cardBg, widget.color, 0.05)!
                  : AppTheme.cardBg,
          border: Border(
            left:   BorderSide(color: widget.color, width: widget.canAfford ? 4 : isKey ? 4 : 3),
            top:    BorderSide(color: isKey ? widget.color.withValues(alpha: 0.35) : AppTheme.cardBorder),
            right:  BorderSide(color: isKey ? widget.color.withValues(alpha: 0.35) : AppTheme.cardBorder),
            bottom: BorderSide(color: isKey ? widget.color.withValues(alpha: 0.35) : AppTheme.cardBorder),
          ),
          boxShadow: widget.canAfford
              ? [BoxShadow(color: widget.color.withValues(alpha: 0.18), blurRadius: 8, spreadRadius: 0)]
              : isKey
                  ? [BoxShadow(color: widget.color.withValues(alpha: 0.10), blurRadius: 6, spreadRadius: 0)]
                  : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Main info area — tap to open dialog ────────────────────────
            GestureDetector(
              onTap: () => _showInfoDialog(context),
              child: Tooltip(
                message: _description.replaceAll('\n', ' '),
                preferBelow: false,
                waitDuration: const Duration(milliseconds: 600),
                textStyle: GoogleFonts.sourceCodePro(fontSize: 11, color: AppTheme.textLight),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  border: Border.all(color: widget.color.withValues(alpha: 0.6)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(widget.icon, size: 14, color: widget.color),
                          const SizedBox(height: 3),
                          Text(
                            widget.abbr,
                            style: AppTheme.pixelHeading(
                                fontSize: 10, letterSpacing: 0.5, color: widget.color),
                          ),
                          Text(
                            '${widget.score}',
                            style: GoogleFonts.rajdhani(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textLight,
                            ),
                          ),
                          Text(
                            widget.abbr == 'STR'
                                ? '⚔ Power'
                                : '${dmgType.emoji} ${dmgType.label}',
                            style: AppTheme.pixelHeading(
                                fontSize: 10, letterSpacing: 0, color: dmgType.color),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'tap for info',
                            style: AppTheme.pixelHeading(
                              fontSize: 7,
                              letterSpacing: 0.3,
                              color: AppTheme.textMuted.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      // ★ badge for key ability scores
                      if (isKey)
                        Positioned(
                          top: -2,
                          right: 0,
                          child: Text(
                            '★',
                            style: TextStyle(
                              fontSize: 9,
                              color: widget.color.withValues(alpha: 0.85),
                              height: 1,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Divider + upgrade (hidden in read-only reference mode) ─────
            if (!widget.readOnly) ...[
              Container(height: 1, color: AppTheme.cardBorder),
              if (isMaxed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    'MAX',
                    style: AppTheme.pixelHeading(fontSize: 8, letterSpacing: 1, color: AppTheme.textMuted),
                  ),
                )
              else
                _PlusButton(
                  color:     widget.color,
                  canAfford: widget.canAfford,
                  cost:      widget.upgrade!.cost,
                  onTap: () {
                    _bounce.forward(from: 0);
                    widget.onUpgrade?.call();
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PlusButton
// Separate tap target so the "purchase" action is clearly distinct from the
// "get info" action on the main card body.
// ─────────────────────────────────────────────────────────────────────────────

class _PlusButton extends StatelessWidget {
  const _PlusButton({
    required this.color,
    required this.canAfford,
    required this.cost,
    required this.onTap,
  });

  final Color    color;
  final bool     canAfford;
  final int      cost;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canAfford ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width:   double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: canAfford ? color.withValues(alpha: 0.18) : Colors.transparent,
        ),
        child: canAfford
            ? Text(
                '+',
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              )
            : Text(
                '${cost}g',
                textAlign: TextAlign.center,
                style: AppTheme.pixelHeading(
                  fontSize: 9,
                  letterSpacing: 0.5,
                  color: AppTheme.textMuted.withValues(alpha: 0.4),
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CombatStatsPanel
// Aggregate view of all combat-relevant derived stats, shown on the SHEET tab.
// ─────────────────────────────────────────────────────────────────────────────

class CombatStatsPanel extends StatelessWidget {
  const CombatStatsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final h    = game.hero;
    final pt   = game.passiveTree;
    final inv  = game.inventory;

    final atkTotal  = h.attackBonus
        + pt.totalOf(PassiveEffect.attackFlat)
        + inv.totalOf(ItemStat.attackBonus)
        + inv.totalOf(ItemStat.strength)
        + game.petAttackBonus + game.skinAttackBonus + game.auraAttackBonus
        + game.questAttackBonus + game.artifactPowerBonus
        + game.ascAtkBonus + game.runeAtkBonus;

    final dmgFlat   = h.damageMod
        + pt.totalOf(PassiveEffect.damageFlat)
        + inv.totalOf(ItemStat.damageBonus)
        + inv.totalOf(ItemStat.strength)
        + game.petDamage + game.skinDamage + game.auraDamage
        + game.questDamageBonus + game.artifactPowerBonus
        + game.ascDmgBonus + game.runeDmgBonus;

    final dmgPct    = pt.totalOf(PassiveEffect.allDamage)
        + inv.totalOf(ItemStat.damagePercent)
        + h.damagePctFor(h.activeDamageType)
        + game.allyDmgPctBonus
        + game.ascAllDamagePct.round();

    final acTotal   = h.armorClass
        + pt.totalOf(PassiveEffect.armorFlat)
        + inv.totalOf(ItemStat.armorClass)
        + inv.totalOf(ItemStat.dexterity)
        + game.petArmor + game.skinArmor;

    final critPct   = game.totalCritChancePct;
    final critOver  = game.critOverflowPct;
    final critDmg   = game.totalCritDamageMult;
    final pierce    = pt.totalOf(PassiveEffect.pierce);
    final regen     = pt.totalOf(PassiveEffect.regenFlat)
        + inv.totalOf(ItemStat.constitution) * 3
        + game.petHpRegen + game.skinHpRegen;
    final xpMult    = h.xpMultiplier;

    final power = atkTotal + dmgFlat;

    // Effective DPS estimate: (avg base dmg + power) × (1 + dmgPct/100) × crit factor
    final avgBase = 4.5 + power;
    final critFactor = 1.0 + (critPct.clamp(0, 100)) / 100.0 * 1.0;
    final dps = (avgBase * (1.0 + dmgPct / 100.0) * critFactor).round();

    final stats = [
      _CS('Est. DPS',   '$dps / hit',                      const Color(0xFFff4488)),
      _CS('Power',      '+$power',                        const Color(0xFFff6644)),
      _CS('DMG Mult',   '+$dmgPct%',                      const Color(0xFFff6633)),
      _CS('Armor',      '$acTotal (${game.armorDrPctFor(acTotal).round()}%)', const Color(0xFF66aaff)),
      _CS('Max HP',     '${h.maxHealth}',                  const Color(0xFFff6666)),
      _CS('HP Regen',   '+$regen / round',                 const Color(0xFF44cc88)),
      _CS('Crit Chance',
          critOver > 0 ? '100%  (+$critOver% overflow)'
                       : critPct > 0 ? '+$critPct%' : '5% (nat 20)',
          const Color(0xFFffee44)),
      _CS('Crit Damage',
          critOver > 0 ? '×${critDmg.toStringAsFixed(2)}  (+$critOver% from overflow)'
                       : '×${critDmg.toStringAsFixed(2)}',
          const Color(0xFFffaa22)),
      _CS('Pierce',     pierce > 0 ? '$pierce AC ignored' : '—', const Color(0xFFffaa44)),
      _CS('Dodge',      '${game.heroDodgeRating.round()} (${game.effectiveDodgePct.round()}%)', const Color(0xFF88ffcc)),
      _CS('XP Mult',    '×${xpMult.toStringAsFixed(2)}',  const Color(0xFF88ddff)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'COMBAT STATS',
            style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2, color: AppTheme.textMuted),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            border: Border.all(color: AppTheme.cardBorder),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: List.generate(stats.length, (i) {
              final s = stats[i];
              final isLast = i == stats.length - 1;
              return Container(
                decoration: BoxDecoration(
                  border: isLast ? null : const Border(
                    bottom: BorderSide(color: AppTheme.cardBorder, width: 0.5),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 14,
                      decoration: BoxDecoration(
                        color: s.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.label,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      ),
                    ),
                    Text(
                      s.value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: s.color,
                        fontFamily: GoogleFonts.sourceCodePro().fontFamily,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _CS {
  const _CS(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color  color;
}

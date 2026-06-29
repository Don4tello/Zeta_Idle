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
  const StatsGridPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final hero = game.hero;

    final data = <({
      String abbr,
      IconData icon,
      Color color,
      String? upgradeId,
      int score,
      int mod,
    })>[
      (abbr: 'STR', icon: Icons.fitness_center,   color: EndlessNode.str.color,          upgradeId: 'str_1', score: hero.strength,     mod: hero.strMod),
      (abbr: 'DEX', icon: Icons.directions_run,   color: EndlessNode.dex.color,          upgradeId: 'dex_1', score: hero.dexterity,    mod: hero.dexMod),
      (abbr: 'CON', icon: Icons.favorite,         color: EndlessNode.con.color,          upgradeId: 'con_1', score: hero.constitution, mod: hero.conMod),
      (abbr: 'INT', icon: Icons.psychology,       color: EndlessNode.intelligence.color, upgradeId: 'int_1', score: hero.intelligence, mod: hero.intMod),
      (abbr: 'WIS', icon: Icons.visibility,       color: EndlessNode.wis.color,          upgradeId: 'wis_1', score: hero.wisdom,       mod: hero.wisMod),
      (abbr: 'CHA', icon: Icons.theater_comedy,   color: EndlessNode.cha.color,          upgradeId: 'cha_1', score: hero.charisma,     mod: hero.chaMod),
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
              icon:        d.icon,
              color:       d.color,
              upgrade:     upgrade,
              canAfford:   canAfford,
              isKeyAbility: keyStats.contains(d.abbr),
              hero:        hero,
              onUpgrade:   canAfford ? () => game.purchaseUpgrade(upgrade!) : null,
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
    required this.icon,
    required this.color,
    required this.upgrade,
    required this.canAfford,
    required this.isKeyAbility,
    required this.hero,
    required this.onUpgrade,
  });

  final String     abbr;
  final int        score;

  final IconData   icon;
  final Color      color;
  final Upgrade?   upgrade;
  final bool       canAfford;
  final bool       isKeyAbility;
  final HeroModel  hero;
  final VoidCallback? onUpgrade;

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
      case 'STR': return 'Physical Damage % bonus (stat÷4, max 25%).\nScales Physical damage resistance.';
      case 'DEX': return 'Lightning Damage % bonus (stat÷4, max 25%).\nScales Lightning damage resistance.';
      case 'CON': return 'Poison Damage % bonus (stat÷4, max 25%).\nScales Poison damage resistance.';
      case 'INT': return 'Void Damage % bonus (stat÷4, max 25%).\nScales Void damage resistance.';
      case 'WIS': return 'Cold Damage % bonus (stat÷4, max 25%).\nScales Cold damage resistance.';
      case 'CHA': return 'Fire Damage % bonus (stat÷4, max 25%).\nScales Fire damage resistance.';
      default:    return '';
    }
  }

  String get _currentEffect {
    final h = widget.hero;
    switch (widget.abbr) {
      case 'STR': return 'Physical Dmg  +${h.damagePctFor(DamageType.physical)}%';
      case 'DEX': return 'Lightning Dmg  +${h.damagePctFor(DamageType.lightning)}%';
      case 'CON': return 'Poison Dmg  +${h.damagePctFor(DamageType.poison)}%';
      case 'INT': return 'Void Dmg  +${h.damagePctFor(DamageType.void_)}%';
      case 'WIS': return 'Cold Dmg  +${h.damagePctFor(DamageType.cold)}%';
      case 'CHA': return 'Fire Dmg  +${h.damagePctFor(DamageType.fire)}%';
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

                // Upgrade call-to-action (inside dialog)
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
                            style: GoogleFonts.pixelifySans(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textLight,
                            ),
                          ),
                          Text(
                            '${dmgType.emoji} ${dmgType.label}',
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

            // ── Divider ────────────────────────────────────────────────────
            Container(height: 1, color: AppTheme.cardBorder),

            // ── Plus button or MAX label ───────────────────────────────────
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
                style: GoogleFonts.pixelifySans(
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
        + game.questAttackBonus + game.artifactAttackBonus
        + game.ascAtkBonus + game.runeAtkBonus + game.allyAtkBonus;

    final dmgFlat   = h.damageMod
        + pt.totalOf(PassiveEffect.damageFlat)
        + inv.totalOf(ItemStat.damageBonus)
        + inv.totalOf(ItemStat.strength)
        + game.petDamage + game.skinDamage + game.auraDamage
        + game.questDamageBonus + game.artifactDamageBonus
        + game.ascDmgBonus + game.runeDmgBonus + game.allyDmgBonus;

    final dmgPct    = pt.totalOf(PassiveEffect.allDamage)
        + inv.totalOf(ItemStat.damagePercent)
        + h.levelBonusDamagePct
        + h.damagePctFor(h.activeDamageType);

    final acTotal   = h.armorClass
        + pt.totalOf(PassiveEffect.armorFlat)
        + inv.totalOf(ItemStat.armorClass)
        + inv.totalOf(ItemStat.dexterity)
        + game.petArmor + game.skinArmor;

    final hitPct    = inv.totalOf(ItemStat.hitChance);
    final critPct   = pt.totalOf(PassiveEffect.critChance) + game.prestigeCritBonus;
    final pierce    = pt.totalOf(PassiveEffect.pierce);
    final regen     = pt.totalOf(PassiveEffect.regenFlat)
        + inv.totalOf(ItemStat.constitution) * 3
        + game.petHpRegen + game.skinHpRegen;
    final dodge     = pt.totalOf(PassiveEffect.dodgeChance) + game.petDodgeChance;
    final xpMult    = h.xpMultiplier;

    final power = atkTotal + dmgFlat;

    // Effective DPS estimate: (avg base dmg + power) × (1 + dmgPct/100) × crit factor
    final avgBase = 4.5 + power;
    final critFactor = 1.0 + (critPct.clamp(0, 100)) / 100.0 * 1.0;
    final dps = (avgBase * (1.0 + dmgPct / 100.0) * critFactor).round();

    final stats = [
      _CS('Est. DPS',   '~$dps / hit',                     const Color(0xFFff4488)),
      _CS('Power',      '+$power',                        const Color(0xFFff6644)),
      _CS('DMG Mult',   '+$dmgPct%',                      const Color(0xFFff6633)),
      _CS('Armor',      '$acTotal',                        const Color(0xFF66aaff)),
      _CS('Max HP',     '${h.maxHealth}',                  const Color(0xFFff6666)),
      _CS('HP Regen',   '+$regen / round',                 const Color(0xFF44cc88)),
      _CS('Hit Chance', hitPct > 0 ? '+$hitPct%' : '—',  const Color(0xFFffcc44)),
      _CS('Crit Chance',critPct > 0 ? '+$critPct%' : '5% (nat 20)', const Color(0xFFffee44)),
      _CS('Pierce',     pierce > 0 ? '$pierce AC ignored' : '—', const Color(0xFFffaa44)),
      _CS('Dodge',      dodge > 0 ? '+$dodge%' : '—',     const Color(0xFF88ffcc)),
      _CS('XP Mult',    '×${xpMult.toStringAsFixed(2)}',  const Color(0xFF88ddff)),
      _CS('Lv Milestone', '+${h.levelBonusDamagePct}% DMG', const Color(0xFFaa88ff)),
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

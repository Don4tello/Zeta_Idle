import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/endless_upgrades.dart';
import '../models/hero_model.dart';
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

    Widget row(int from) => Row(
      children: List.generate(3, (i) {
        final d = data[from + i];
        final upgrade   = _findUpgrade(game.upgrades, d.upgradeId);
        final canAfford = upgrade != null && !upgrade.isMaxed && game.gold >= upgrade.cost;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
            child: _StatCard(
              abbr:      d.abbr,
              score:     d.score,
              modifier:  d.mod,
              icon:      d.icon,
              color:     d.color,
              upgrade:   upgrade,
              canAfford: canAfford,
              hero:      hero,
              onUpgrade: canAfford ? () => game.purchaseUpgrade(upgrade!) : null,
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
            style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted),
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
    required this.modifier,
    required this.icon,
    required this.color,
    required this.upgrade,
    required this.canAfford,
    required this.hero,
    required this.onUpgrade,
  });

  final String     abbr;
  final int        score;
  final int        modifier;
  final IconData   icon;
  final Color      color;
  final Upgrade?   upgrade;
  final bool       canAfford;
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
      case 'STR': return 'Improves your attack roll bonus and\nthe bonus damage on every hit.';
      case 'DEX': return 'Raises Armor Class — the higher your\nAC, the more enemy attacks miss.';
      case 'CON': return 'Increases maximum Hit Points\nand HP gained each level-up.';
      case 'INT': return 'Multiplies gold earned from every\nenemy defeated.';
      case 'WIS': return 'Boosts idle progress rate —\nhow much you earn per tap at rest.';
      case 'CHA': return 'Increases XP earned from every\nvictory, speeding up level-ups.';
      default:    return '';
    }
  }

  String get _currentEffect {
    final h = widget.hero;
    switch (widget.abbr) {
      case 'STR': return 'ATK Bonus +${h.attackBonus}   ·   Dmg Mod +${h.damageMod}';
      case 'DEX': return 'Armor Class  ${h.armorClass}';
      case 'CON': return 'Max HP  ${h.maxHealth}';
      case 'INT': return 'Gold Rate  ×${h.goldRate}';
      case 'WIS': return 'Idle Rate  ${h.idleRate} / tap';
      case 'CHA': return 'XP Multiplier  ×${h.xpMultiplier.toStringAsFixed(2)}';
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
                  style: AppTheme.pixelHeading(fontSize: 20, color: widget.color, letterSpacing: 3),
                ),
                Text(
                  _fullName.toUpperCase(),
                  style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.textMuted, letterSpacing: 2),
                ),
                const SizedBox(height: 14),
                Container(height: 1, color: widget.color.withValues(alpha: 0.3)),
                const SizedBox(height: 12),

                // Description
                Text(
                  _description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sourceCodePro(
                    fontSize: 11,
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
                      fontSize: 10,
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
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: widget.color.withValues(alpha: 0.18),
                          border: Border.all(color: widget.color),
                        ),
                        child: Text(
                          '+ UPGRADE  ·  ${widget.upgrade!.cost} GOLD',
                          textAlign: TextAlign.center,
                          style: AppTheme.pixelHeading(
                            fontSize: 10,
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
                          fontSize: 9, color: AppTheme.textMuted, letterSpacing: 0.5),
                    ),
                  const SizedBox(height: 10),
                ] else ...[
                  Text('FULLY UPGRADED',
                      style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.textMuted)),
                  const SizedBox(height: 10),
                ],

                // Close
                GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 7),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Text(
                      'CLOSE',
                      style: AppTheme.pixelHeading(
                          fontSize: 9, color: AppTheme.textMuted, letterSpacing: 2),
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
    final modSign  = widget.modifier >= 0 ? '+' : '';
    final modColor = widget.modifier > 0
        ? widget.color
        : widget.modifier < 0
            ? const Color(0xFFcc4444)
            : AppTheme.textMuted;

    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          // Subtle colour tint when the player can afford the upgrade
          color: widget.canAfford
              ? Color.lerp(AppTheme.cardBg, widget.color, 0.07)!
              : AppTheme.cardBg,
          border: Border(
            left:   BorderSide(color: widget.color, width: widget.canAfford ? 4 : 3),
            top:    const BorderSide(color: AppTheme.cardBorder),
            right:  const BorderSide(color: AppTheme.cardBorder),
            bottom: const BorderSide(color: AppTheme.cardBorder),
          ),
          // Glow when affordable
          boxShadow: widget.canAfford
              ? [BoxShadow(color: widget.color.withValues(alpha: 0.18), blurRadius: 8, spreadRadius: 0)]
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
                textStyle: GoogleFonts.sourceCodePro(fontSize: 10, color: AppTheme.textLight),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  border: Border.all(color: widget.color.withValues(alpha: 0.6)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.icon, size: 14, color: widget.color),
                      const SizedBox(height: 3),
                      Text(
                        widget.abbr,
                        style: AppTheme.pixelHeading(
                            fontSize: 9, letterSpacing: 0.5, color: widget.color),
                      ),
                      Text(
                        '${widget.score}',
                        style: GoogleFonts.pixelifySans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textLight,
                        ),
                      ),
                      Text(
                        '$modSign${widget.modifier}',
                        style: AppTheme.pixelHeading(
                            fontSize: 9, letterSpacing: 0, color: modColor),
                      ),
                      // Small hint nudging the player to tap for info
                      const SizedBox(height: 4),
                      Text(
                        'tap for info',
                        style: AppTheme.pixelHeading(
                          fontSize: 6,
                          letterSpacing: 0.3,
                          color: AppTheme.textMuted.withValues(alpha: 0.5),
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
                  style: AppTheme.pixelHeading(fontSize: 7, letterSpacing: 1, color: AppTheme.textMuted),
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              )
            : Text(
                '${cost}g',
                textAlign: TextAlign.center,
                style: AppTheme.pixelHeading(
                  fontSize: 8,
                  letterSpacing: 0.5,
                  color: AppTheme.textMuted.withValues(alpha: 0.4),
                ),
              ),
      ),
    );
  }
}

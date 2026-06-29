import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/endless_upgrades.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class EndlessUpgradeScreen extends StatelessWidget {
  const EndlessUpgradeScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            border: Border.all(
                color: const Color(0xFFcc88ff).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  color: Color(0xFFcc88ff), size: 14),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Upgrades are permanent per character. '
                  'Bonuses apply in all game modes.',
                  style: GoogleFonts.pixelifySans(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...EndlessNode.values.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _NodeCard(node: e.value, game: game)
                .animate(delay: (e.key * 60).ms)
                .fadeIn(duration: 300.ms)
                .slideX(
                    begin: 0.06,
                    duration: 300.ms,
                    curve: Curves.easeOut),
          );
        }),
        const SizedBox(height: 8),
        _SynergyPanel(game: game),
      ],
    );

    if (embedded) return body;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('UPGRADES'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Tooltip(
              message: AppTheme.resourceTooltips['echoes']!,
              child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔊',
                    style: TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                Text(
                  AppTheme.fmtNumber(game.echoes),
                  style: GoogleFonts.pixelifySans(
                    color: const Color(0xFFcc88ff),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'ECHOES',
                  style: GoogleFonts.pixelifySans(
                    color: const Color(0xFFcc88ff).withValues(alpha: 0.6),
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          ),
        ],
      ),
      body: body,
    );
  }

}

// ─────────────────────────────────────────────────────────────
// Node Card
// ─────────────────────────────────────────────────────────────

class _NodeCard extends StatefulWidget {
  const _NodeCard({required this.node, required this.game});

  final EndlessNode node;
  final GameState   game;

  @override
  State<_NodeCard> createState() => _NodeCardState();
}

class _NodeCardState extends State<_NodeCard> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _syncPulse(bool canAfford) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (canAfford && !_pulse.isAnimating) {
        _pulse.repeat(reverse: true);
      } else if (!canAfford && _pulse.isAnimating) {
        _pulse.stop();
        _pulse.animateTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final u         = widget.game.endlessUpgrades;
    final node      = widget.node;
    final game      = widget.game;
    final level     = u.levelOf(node);
    final cost      = u.costFor(node);
    final canAfford = game.echoes >= cost;
    final col       = node.color;

    _syncPulse(canAfford);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: canAfford
            ? Color.lerp(AppTheme.cardBg, col, 0.05)!
            : AppTheme.cardBg,
        border: Border(
          left:   BorderSide(color: col, width: canAfford ? 4 : 3),
          top:    const BorderSide(color: AppTheme.cardBorder),
          right:  const BorderSide(color: AppTheme.cardBorder),
          bottom: const BorderSide(color: AppTheme.cardBorder),
        ),
        boxShadow: canAfford
            ? [BoxShadow(color: col.withValues(alpha: 0.14), blurRadius: 8)]
            : null,
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Stat chip
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: col.withValues(alpha: 0.12),
              border: Border.all(color: col.withValues(alpha: 0.7)),
            ),
            child: Center(
              child: Text(
                node.statLabel,
                style: GoogleFonts.pixelifySans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: col,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Main content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + level
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      node.displayName.toUpperCase(),
                      style: GoogleFonts.pixelifySans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textLight,
                        letterSpacing: 1,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: level > 0
                                ? col.withValues(alpha: 0.6)
                                : AppTheme.cardBorder),
                        color: level > 0
                            ? col.withValues(alpha: 0.08)
                            : Colors.transparent,
                      ),
                      child: Text(
                        'Lv $level',
                        style: GoogleFonts.pixelifySans(
                          fontSize: 11,
                          color: level > 0 ? col : AppTheme.textMuted,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                // Current bonus or base description
                Text(
                  level > 0 ? _bonusText(node, u) : node.effectLabel,
                  style: GoogleFonts.pixelifySans(
                    fontSize: 11,
                    color:
                        level > 0 ? AppTheme.accentGold : AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 10),

                // Cost row + upgrade button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Shard cost
                    Row(
                      children: [
                        Text('🔊',
                          style: TextStyle(
                            fontSize: 11,
                            color: canAfford
                                ? const Color(0xFFcc88ff)
                                : AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          AppTheme.fmtNumber(cost),
                          style: GoogleFonts.pixelifySans(
                            fontSize: 12,
                            color: canAfford
                                ? const Color(0xFFcc88ff)
                                : AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'for Lv ${level + 1}',
                          style: GoogleFonts.pixelifySans(
                            fontSize: 10,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    // Upgrade button — pulses when affordable
                    GestureDetector(
                      onTap: canAfford
                          ? () => game.purchaseEndlessUpgrade(node)
                          : null,
                      child: AnimatedBuilder(
                        animation: _pulse,
                        builder: (_, __) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: canAfford
                                ? col.withValues(alpha: 0.08 + 0.16 * _pulse.value)
                                : AppTheme.darkBg,
                            border: Border.all(
                              color: canAfford
                                  ? col.withValues(alpha: 0.5 + 0.5 * _pulse.value)
                                  : AppTheme.cardBorder,
                              width: canAfford ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (canAfford) ...[
                                Icon(Icons.upgrade, size: 12, color: col),
                                const SizedBox(width: 5),
                              ],
                              Text(
                                canAfford ? 'UPGRADE' : 'UPGRADE',
                                style: GoogleFonts.pixelifySans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: canAfford ? col : AppTheme.textMuted,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Milestones ──────────────────────────────
                const SizedBox(height: 10),
                Container(height: 1, color: AppTheme.cardBorder),
                const SizedBox(height: 8),
                ...node.milestones.asMap().entries.map((entry) {
                  final isLast = entry.key == node.milestones.length - 1;
                  final perk = entry.value;
                  final unlocked = level >= perk.levelRequired;
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Level gate badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: unlocked
                                  ? col.withValues(alpha: 0.7)
                                  : AppTheme.cardBorder,
                            ),
                            color: unlocked
                                ? col.withValues(alpha: 0.12)
                                : Colors.transparent,
                          ),
                          child: Text(
                            'Lv${perk.levelRequired}',
                            style: GoogleFonts.pixelifySans(
                              fontSize: 9,
                              color:
                                  unlocked ? col : AppTheme.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    unlocked
                                        ? Icons.check
                                        : Icons.lock_outline,
                                    size: 9,
                                    color: unlocked
                                        ? col
                                        : AppTheme.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    perk.name,
                                    style: GoogleFonts.pixelifySans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: unlocked
                                          ? col
                                          : AppTheme.textMuted,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 13),
                                child: Text(
                                  perk.description,
                                  style: GoogleFonts.pixelifySans(
                                    fontSize: 10,
                                    color: unlocked
                                        ? AppTheme.textLight
                                            .withValues(alpha: 0.65)
                                        : AppTheme.textMuted
                                            .withValues(alpha: 0.45),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _bonusText(EndlessNode node, EndlessUpgrades u) {
    switch (node) {
      case EndlessNode.str:
        final pct = ((u.damageMultiplier - 1) * 100).toStringAsFixed(1);
        return '+$pct% attack damage';
      case EndlessNode.dex:
        return '+${u.attackRollBonus} critical damage';
      case EndlessNode.con:
        return '-${u.flatDamageReduction} damage taken per hit';
      case EndlessNode.intelligence:
        final pct = ((u.goldMultiplier - 1) * 100).toStringAsFixed(1);
        return '+$pct% gold from battles';
      case EndlessNode.wis:
        final pct = ((u.shardMultiplier - 1) * 100).toStringAsFixed(1);
        return '+$pct% Echoes earned';
      case EndlessNode.cha:
        final pct = ((u.xpMultiplier - 1) * 100).toStringAsFixed(1);
        return '+$pct% XP from victories';
    }
  }

}

// ── Synergy panel ─────────────────────────────────────────────────────────────

class _SynergyPanel extends StatelessWidget {
  const _SynergyPanel({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final synergies = game.endlessUpgrades.allSynergies;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('SYNERGIES',
              style: GoogleFonts.pixelifySans(
                  fontSize: 11,
                  letterSpacing: 2,
                  color: const Color(0xFF80d0ff),
                  fontWeight: FontWeight.bold)),
        ),
        ...synergies.map((s) => _SynergyCard(status: s)),
      ],
    );
  }
}

class _SynergyCard extends StatelessWidget {
  const _SynergyCard({required this.status});
  final SynergyStatus status;

  @override
  Widget build(BuildContext context) {
    final unlocked = status.unlocked;
    final color = unlocked ? const Color(0xFF80d0ff) : const Color(0xFF445566);
    final req = 10;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: unlocked
            ? const Color(0xFF0d1f2d)
            : const Color(0xFF0d1218),
        border: Border.all(color: color.withValues(alpha: unlocked ? 0.5 : 0.2)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(unlocked ? '✦' : '○',
                style: TextStyle(color: color, fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status.name,
                    style: GoogleFonts.pixelifySans(
                        fontSize: 11,
                        color: unlocked ? const Color(0xFFddeeFF) : const Color(0xFF667788),
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(status.effectLabel,
                    style: TextStyle(
                        fontSize: 11,
                        color: unlocked ? color : const Color(0xFF445566))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(status.nodeLabel,
                  style: TextStyle(
                      fontSize: 10,
                      color: color.withValues(alpha: 0.8),
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                unlocked
                    ? 'ACTIVE'
                    : '${status.node1.statLabel} ${status.level1}/$req  •  ${status.node2.statLabel} ${status.level2}/$req',
                style: TextStyle(
                    fontSize: 9,
                    color: unlocked
                        ? const Color(0xFF44cc88)
                        : const Color(0xFF445566)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

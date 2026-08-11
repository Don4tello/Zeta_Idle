import 'package:flutter/material.dart';
import '../models/prestige_shop.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/currency_info.dart';
import 'main_shell.dart' show TutorialTip;

class PrestigeScreen extends StatelessWidget {
  const PrestigeScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!embedded)
            TutorialTip(
              tutorialKey: 'prestige',
              game: game,
              text: 'You can now Rebirth! ✦ Prestige your hero to reset progress '
                  'but earn permanent Paragon Points ✦ and multipliers that stack forever. '
                  'Each rebirth makes every future run significantly stronger.',
            ),
          _RebirthPanel(game: game),
          const SizedBox(height: 20),
          _BonusPanel(game: game),
          const SizedBox(height: 20),
          _ParagonBoard(game: game),
          const SizedBox(height: 20),
          Row(children: [
            Text('PARAGON SHOP',
                style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
            const SizedBox(width: 10),
            _SoulBadge(souls: game.prestigeSouls, large: false),
          ]),
          const SizedBox(height: 4),
          const Text(
            'Spend Paragon Points on permanent upgrades that persist across all future runs.',
            style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 14),
          // Grouped by category
          ...PrestigeCategory.values.map((cat) => _CategorySection(
                cat: cat,
                nodes: kPrestigeNodes.where((n) => n.category == cat).toList(),
                game: game,
              )),
        ],
      ),
    );

    if (embedded) return body;

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('REBIRTH', style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _SoulBadge(souls: game.prestigeSouls, large: false),
          ),
        ],
      ),
      body: body,
    );
  }
}

// ── Category section ──────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.cat,
    required this.nodes,
    required this.game,
  });
  final PrestigeCategory cat;
  final List<PrestigeNode> nodes;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('${cat.icon}  ${cat.label}',
              style: AppTheme.pixelHeading(
                  fontSize: 11, letterSpacing: 1.5, color: AppTheme.textMuted)),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: AppTheme.cardBorder, height: 1)),
        ]),
        const SizedBox(height: 8),
        ...nodes.map((node) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ShopNode(node: node, game: game),
            )),
        const SizedBox(height: 12),
      ],
    );
  }
}

// ── Rebirth panel ─────────────────────────────────────────────────────────────

class _RebirthPanel extends StatelessWidget {
  const _RebirthPanel({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final canPrestige  = game.canPrestige;
    final soulsPreview = (game.campaignStageIndex / 5).floor().clamp(1, 200)
        + game.prestigeSoulConduit;
    final stageIndex   = game.campaignStageIndex;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(
          color: canPrestige ? const Color(0xFFcc8844) : AppTheme.cardBorder,
          width: canPrestige ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('REBIRTH',
                style: AppTheme.pixelHeading(
                    fontSize: 12, letterSpacing: 2, color: const Color(0xFFcc8844))),
            const Spacer(),
            if (game.prestigeLevel > 0)
              _SoulBadge(souls: game.prestigeLevel, large: false, label: 'REBIRTH'),
          ]),
          const SizedBox(height: 8),
          const Text(
            'Complete all 100 campaign stages and defeat the Omega Absolute, then Rebirth to start over as a stronger hero. '
            'Each Rebirth makes future runs faster, more powerful, and unlocks stronger item drops.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.5),
          ),
          const SizedBox(height: 10),
          _ResetRow(label: 'Resets', items: const ['Hero level', 'Gold', 'Items', 'Subclass']),
          const SizedBox(height: 4),
          _ResetRow(
            label: 'Keeps',
            items: const ['Shards', 'Echoes', 'Abilities', 'Passive tree', 'Cosmetics'],
            keepColor: true,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1a2a1a),
              border: Border.all(color: const Color(0xFF44cc88).withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOU WILL GAIN', style: AppTheme.pixelHeading(
                    fontSize: 10, letterSpacing: 2, color: const Color(0xFF44cc88))),
                const SizedBox(height: 6),
                Text('✦ ${(game.campaignStageIndex / 5).floor().clamp(1, 200)} Paragon Points',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFcc8844), fontWeight: FontWeight.bold)),
                Text('+15% Gold  •  +10% XP  •  +10% Idle  •  +3.5% Damage (per rebirth)',
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                Text('⬡ +10 Mythril',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9966ff))),
                Text('⚔ Stronger item drops  (+10% weapon power  •  +1 stat per item)',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF88dd88))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Milestone title track
          _MilestoneTitleTrack(prestigeLevel: game.prestigeLevel),
          const SizedBox(height: 12),
          if (canPrestige) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2623),
                border: Border.all(color: const Color(0xFFaacc44)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFFaacc44), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Ready to Rebirth!  +$soulsPreview Paragon Point${soulsPreview == 1 ? '' : 's'}  •  +10 Mythril',
                      style: const TextStyle(fontSize: 13, color: Color(0xFFaacc44)),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    'After rebirth:  Gold +${((game.prestigeGoldMult * 1.10 - 1) * 100).round()}%  •  '
                    'XP +${((game.prestigeXpMult * 1.05 - 1) * 100).round()}%  •  '
                    'Idle +${((game.prestigeIdleMult * 1.05 - 1) * 100).round()}%',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF88aa55)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _confirmPrestige(context, game, soulsPreview),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2a1a0a),
                  foregroundColor: const Color(0xFFcc8844),
                  side: const BorderSide(color: Color(0xFFcc8844), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('✦  REBIRTH  ✦',
                    style: AppTheme.pixelHeading(
                        fontSize: 14, letterSpacing: 2, color: const Color(0xFFcc8844))),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF17150E),
                border: Border.all(color: AppTheme.cardBorder),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(children: [
                const Icon(Icons.lock_outline, color: AppTheme.textMuted, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Complete Stage 100 — Defeat the Omega Absolute to unlock Rebirth.  '
                    '(Stage ${stageIndex + 1} / 100)',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                ),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmPrestige(BuildContext context, GameState game, int soulsPreview) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('Confirm Rebirth?',
            style: AppTheme.pixelHeading(fontSize: 14, color: const Color(0xFFcc8844))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your hero will be reborn. Hero level, gold, items, and subclass will reset.',
              style: TextStyle(fontSize: 13, color: AppTheme.textLight),
            ),
            const SizedBox(height: 10),
            Text(
              'You will earn $soulsPreview Paragon Point${soulsPreview == 1 ? '' : 's'} to spend in the Paragon Shop.',
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFFaacc44), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Gold income, XP, and idle rate will increase permanently.',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL',
                style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              if (!game.canPrestige) return;
              Navigator.pop(context);
              await game.prestige();
            },
            child: Text('REBIRTH',
                style: AppTheme.pixelHeading(fontSize: 11, color: const Color(0xFFcc8844))),
          ),
        ],
      ),
    );
  }
}

class _ResetRow extends StatelessWidget {
  const _ResetRow({required this.label, required this.items, this.keepColor = false});
  final String label;
  final List<String> items;
  final bool keepColor;

  @override
  Widget build(BuildContext context) {
    final color = keepColor ? const Color(0xFF44cc88) : const Color(0xFFcc4444);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          child: Text(label,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: items
                .map((item) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        border: Border.all(color: color.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(item, style: TextStyle(fontSize: 11, color: color)),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ── Bonus panel ───────────────────────────────────────────────────────────────

class _BonusPanel extends StatelessWidget {
  const _BonusPanel({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    if (game.prestigeLevel == 0 && game.prestigeShop.ownedNodes.isEmpty) {
      return const SizedBox.shrink();
    }
    final chips = <String>[];
    if (game.prestigeLevel > 0) {
      chips.add('+${((game.prestigeGoldMult - 1) * 100).round()}% Gold income');
      chips.add('+${((game.prestigeXpMult - 1) * 100).round()}% XP');
      chips.add('+${((game.prestigeIdleMult - 1) * 100).round()}% Idle');
    }
    if (game.prestigeLevel > 0) {
      chips.add('+${(game.prestigeLevel * 3.5).round()}% Damage');
    }
    final s = game.prestigeShop;
    if (s.isUnlocked('iron_resolve'))        chips.add('+30% Max HP');
    if (s.isUnlocked('blood_drinker'))       chips.add('5% HP on kill');
    if (s.isUnlocked('killing_blow'))        chips.add('+8% Crit');
    if (s.isUnlocked('deaths_edge'))         chips.add('+80% Crit DMG');
    if (s.isUnlocked('destroyer'))           chips.add('+20% Damage');
    if (s.isUnlocked('start_gold'))          chips.add('+20% Gold Income');
    if (s.isUnlocked('war_spoils'))          chips.add('+35% More Gold');
    if (s.isUnlocked('carrion_picker'))      chips.add('+50% Shards');
    if (s.isUnlocked('essence_bonus'))       chips.add('+50% Shard Gain');
    if (s.isUnlocked('treasure_sense'))      chips.add('+35% Battle Gold');
    if (s.isUnlocked('swift_learner'))       chips.add('+30% XP');
    if (s.isUnlocked('head_start'))          chips.add('Start Stage 11');
    if (s.isUnlocked('head_start_2'))        chips.add('Start Stage 21');
    if (s.isUnlocked('ability_disc'))        chips.add('-35% Ability Cost');
    if (s.isUnlocked('instant_recall'))      chips.add('+1,500 Start Gold');
    if (s.isUnlocked('idle_bonus'))          chips.add('+30 Idle Rate');
    if (s.isUnlocked('forge_bonus'))         chips.add('Forge: 2 items');
    if (s.isUnlocked('soul_conduit'))        chips.add('+5 PP/Rebirth');
    if (s.isUnlocked('artifact_vault'))      chips.add('Artifacts persist');
    if (s.isUnlocked('mythril_memory'))      chips.add('Keep 50% Mythril');
    if (s.isUnlocked('soul_overdrive'))      chips.add('Start at Stage 41');
    if (s.isUnlocked('paragon_dominance'))   chips.add('+${game.prestigeLevel}% All Stats');

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ACTIVE BONUSES',
              style: AppTheme.pixelHeading(
                  fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: chips.map(_BonusChip.new).toList(),
          ),
        ],
      ),
    );
  }
}

class _BonusChip extends StatelessWidget {
  const _BonusChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1a2a1a),
        border: Border.all(color: const Color(0xFF44cc88).withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF44cc88))),
    );
  }
}

// ── Milestone title track ─────────────────────────────────────────────────────

class _MilestoneTitleTrack extends StatelessWidget {
  const _MilestoneTitleTrack({required this.prestigeLevel});
  final int prestigeLevel;

  static const _milestones = <int, (String, String)>{
    1:  ('Reborn',       '🔥'),
    2:  ('Twice-Forged', '⚒'),
    3:  ('Veteran',      '🛡'),
    5:  ('Champion',     '⚔'),
    7:  ('Warlord',      '🗡'),
    10: ('Legend',       '💀'),
    15: ('Mythic',       '✦'),
    20: ('Arcane Lord',  '🔮'),
    25: ('Eternal',      '♾'),
    50: ('Transcendent', '🌟'),
  };

  @override
  Widget build(BuildContext context) {
    // Show up to the next 4 unlocked/upcoming milestones
    final keys = _milestones.keys.toList()..sort();
    final visible = keys.where((k) => k <= prestigeLevel + 5 || prestigeLevel < 5).take(6).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1410),
        border: Border.all(color: const Color(0xFF3a2a18)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MILESTONE TITLES',
              style: AppTheme.pixelHeading(
                  fontSize: 9, letterSpacing: 2, color: const Color(0xFFcc8844))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: visible.map((k) {
              final (title, emoji) = _milestones[k]!;
              final earned = prestigeLevel >= k;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: earned
                      ? const Color(0xFFcc8844).withValues(alpha: 0.15)
                      : const Color(0xFF17130E),
                  border: Border.all(
                    color: earned
                        ? const Color(0xFFcc8844).withValues(alpha: 0.7)
                        : const Color(0xFF3a2a18),
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(emoji,
                      style: TextStyle(
                          fontSize: 13,
                          color: earned ? null : const Color(0xFF443320))),
                  const SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: earned
                                  ? const Color(0xFFddaa55)
                                  : const Color(0xFF554433))),
                      Text('LV $k',
                          style: TextStyle(
                              fontSize: 9,
                              color: earned
                                  ? const Color(0xFF997744)
                                  : const Color(0xFF3a2a18))),
                    ],
                  ),
                  if (earned) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle, size: 11, color: Color(0xFFcc8844)),
                  ],
                ]),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Soul shop node ────────────────────────────────────────────────────────────

class _ShopNode extends StatelessWidget {
  const _ShopNode({required this.node, required this.game});
  final PrestigeNode node;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final owned      = game.prestigeShop.isUnlocked(node.id);
    final prereqMet  = node.prerequisiteId == null ||
        game.prestigeShop.isUnlocked(node.prerequisiteId!);
    final canAfford  = game.prestigeSouls >= node.soulCost;
    final canBuy     = !owned && prereqMet && canAfford;
    final borderColor = owned
        ? const Color(0xFFcc8844)
        : (!prereqMet || !canAfford)
            ? AppTheme.cardBorder.withValues(alpha: 0.4)
            : AppTheme.cardBorder;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(color: borderColor, width: owned ? 1.5 : 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(node.name,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: owned ? const Color(0xFFcc8844) : AppTheme.textLight)),
                  if (owned) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFcc8844).withValues(alpha: 0.15),
                        border: Border.all(color: const Color(0xFFcc8844)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text('OWNED',
                          style: AppTheme.pixelHeading(
                              fontSize: 9, color: const Color(0xFFcc8844))),
                    ),
                  ],
                ]),
                const SizedBox(height: 3),
                Text(node.description,
                    style: TextStyle(
                        fontSize: 12,
                        color: (!prereqMet || owned)
                            ? AppTheme.textMuted
                            : AppTheme.textLight)),
                if (!prereqMet) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Requires: ${kPrestigeNodes.firstWhere((n) => n.id == node.prerequisiteId, orElse: () => node).name}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFFcc4444)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (!owned)
            Column(
              children: [
                _SoulBadge(
                    souls: node.soulCost,
                    large: false,
                    dim: !canAfford || !prereqMet),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: canBuy
                      ? () { game.purchasePrestigeNode(node.id); game.audioService.playClaim(); }
                      : null,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFcc8844),
                    disabledForegroundColor: AppTheme.cardBorder,
                    side: BorderSide(
                        color: canBuy
                            ? const Color(0xFFcc8844)
                            : AppTheme.cardBorder),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('BUY',
                      style: AppTheme.pixelHeading(
                          fontSize: 11,
                          letterSpacing: 1,
                          color: canBuy
                              ? const Color(0xFFcc8844)
                              : AppTheme.cardBorder)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Shared widget ─────────────────────────────────────────────────────────────

class _SoulBadge extends StatelessWidget {
  const _SoulBadge({
    required this.souls,
    required this.large,
    this.label = 'PP',
    this.dim = false,
  });
  final int souls;
  final bool large;
  final String label;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final color = dim ? AppTheme.textMuted : const Color(0xFFcc8844);
    return InfoTip(
      message: CurrencyInfo.paragonPoints,
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: large ? 14 : 8, vertical: large ? 8 : 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: dim ? 0.3 : 0.7)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('✦', style: TextStyle(fontSize: large ? 18 : 13, color: color)),
            const SizedBox(width: 5),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$souls',
                    style: TextStyle(
                        fontSize: large ? 16 : 12,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(label,
                    style: TextStyle(
                        fontSize: large ? 9 : 8,
                        color: color.withValues(alpha: 0.7))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Paragon board: rankable, infinitely-scaling stats ────────────────────────
class _ParagonBoard extends StatelessWidget {
  const _ParagonBoard({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13110E),
        border: Border.all(color: const Color(0xFF6a4fb0)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('✦ PARAGON BOARD',
                style: AppTheme.pixelHeading(
                    fontSize: 13, letterSpacing: 2, color: const Color(0xFFb59bff))),
            const Spacer(),
            _SoulBadge(souls: game.prestigeSouls, large: false),
          ]),
          const SizedBox(height: 2),
          const Text('Invest points into a direction — ranks scale forever.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 10),
          ...kParagonStats.map((s) => _ParagonRow(stat: s, game: game)),
        ],
      ),
    );
  }
}

class _ParagonRow extends StatelessWidget {
  const _ParagonRow({required this.stat, required this.game});
  final ParagonStat stat;
  final GameState game;

  String _effectLabel(ParagonEffect e) => switch (e) {
        ParagonEffect.damage => 'damage',
        ParagonEffect.hp => 'max HP',
        ParagonEffect.gold => 'gold',
        ParagonEffect.xp => 'XP',
        ParagonEffect.crit => 'crit chance',
        ParagonEffect.critDmg => 'crit damage',
        ParagonEffect.idle => 'idle income',
      };

  @override
  Widget build(BuildContext context) {
    final rank = game.prestigeShop.paragonRank(stat.id);
    final cost = game.prestigeShop.paragonCost(stat);
    final canAfford = game.prestigeSouls >= cost;
    final total = rank * stat.perRank;
    final totalStr = total == total.truncateToDouble()
        ? total.toStringAsFixed(0)
        : total.toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Text(stat.icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(stat.name,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(width: 6),
              Text('Rank $rank',
                  style: const TextStyle(fontSize: 11, color: Color(0xFFb59bff))),
            ]),
            Text('+$totalStr${stat.suffix} ${_effectLabel(stat.effect)}',
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ]),
        ),
        ElevatedButton(
          onPressed: canAfford ? () => game.rankUpParagon(stat.id) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2a1f45),
            foregroundColor: const Color(0xFFb59bff),
            side: BorderSide(
                color: canAfford ? const Color(0xFF6a4fb0) : AppTheme.cardBorder),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: const Size(0, 34),
            disabledForegroundColor: AppTheme.textMuted,
          ),
          child: Text('$cost ✦',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }
}

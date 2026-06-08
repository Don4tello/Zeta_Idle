import 'package:flutter/material.dart';
import '../models/prestige_shop.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class PrestigeScreen extends StatelessWidget {
  const PrestigeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1f3a),
        title: Text('PRESTIGE', style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _SoulBadge(souls: game.prestigeSouls, large: false),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RebirthPanel(game: game),
            const SizedBox(height: 20),
            _BonusPanel(game: game),
            const SizedBox(height: 20),
            Text('SOUL SHOP',
                style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2)),
            const SizedBox(height: 4),
            Text('Spend souls on permanent upgrades that persist across all future runs.',
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            const SizedBox(height: 10),
            ...kPrestigeNodes.map((node) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ShopNode(node: node, game: game),
            )),
          ],
        ),
      ),
    );
  }
}

// ── Rebirth panel ─────────────────────────────────────────────────────────────

class _RebirthPanel extends StatelessWidget {
  const _RebirthPanel({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final canPrestige = game.canPrestige;
    final soulsPreview = (game.campaignStageIndex / 5).floor().clamp(1, 50);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0e1225),
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
            Text('REBIRTH', style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2,
                color: const Color(0xFFcc8844))),
            const Spacer(),
            if (game.prestigeLevel > 0)
              _SoulBadge(souls: game.prestigeLevel, large: false, label: 'LEVEL'),
          ]),
          const SizedBox(height: 10),
          // Resets / Keeps table
          _ResetRow(label: 'Resets', items: const ['Hero level', 'Gold', 'Items', 'Subclass']),
          const SizedBox(height: 4),
          _ResetRow(label: 'Keeps', items: const ['Shards', 'Essence', 'Abilities', 'Passive tree', 'Cosmetics'],
              keepColor: true),
          const SizedBox(height: 12),
          if (canPrestige) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1f3a),
                border: Border.all(color: const Color(0xFFaacc44)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(children: [
                const Icon(Icons.auto_awesome, color: Color(0xFFaacc44), size: 16),
                const SizedBox(width: 8),
                Text('Ready to Rebirth! You will earn $soulsPreview soul${soulsPreview == 1 ? '' : 's'}.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFaacc44))),
              ]),
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
                    style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2,
                        color: const Color(0xFFcc8844))),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0a0c18),
                border: Border.all(color: AppTheme.cardBorder),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(children: [
                const Icon(Icons.lock_outline, color: AppTheme.textMuted, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Reach Campaign Stage 25 to unlock Rebirth.\n'
                  '(Stage ${game.campaignStageIndex + 1} / 25)',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
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
        backgroundColor: const Color(0xFF1a1f3a),
        title: Text('Confirm Rebirth?',
            style: AppTheme.pixelHeading(fontSize: 13, color: const Color(0xFFcc8844))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your hero will be reborn. Hero level, gold, items, and subclass will reset.',
              style: TextStyle(fontSize: 12, color: AppTheme.textLight),
            ),
            const SizedBox(height: 10),
            Text(
              'You will earn $soulsPreview soul${soulsPreview == 1 ? '' : 's'} to spend in the Soul Shop.',
              style: const TextStyle(fontSize: 13, color: Color(0xFFaacc44), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Gold income, XP, and idle rate will increase permanently.',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL',
                style: AppTheme.pixelHeading(fontSize: 10, color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              game.prestige();
              Navigator.pop(context);
            },
            child: Text('REBIRTH',
                style: AppTheme.pixelHeading(fontSize: 10, color: const Color(0xFFcc8844))),
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
              style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: items.map((item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                border: Border.all(color: color.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(item, style: TextStyle(fontSize: 10, color: color)),
            )).toList(),
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
    if (game.prestigeLevel == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0e1225),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ACTIVE BONUSES',
              style: AppTheme.pixelHeading(fontSize: 9, letterSpacing: 2, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _BonusChip('+${((game.prestigeGoldMult - 1) * 100).round()}% Gold'),
              _BonusChip('+${((game.prestigeXpMult - 1) * 100).round()}% XP'),
              _BonusChip('+${((game.prestigeIdleMult - 1) * 100).round()}% Idle'),
              if (game.prestigeShop.isUnlocked('shard_bonus'))  _BonusChip('+30% Shards'),
              if (game.prestigeShop.isUnlocked('essence_bonus')) _BonusChip('+30% Essence'),
              if (game.prestigeShop.isUnlocked('idle_bonus'))   _BonusChip('+5 Idle Rate'),
              if (game.prestigeShop.isUnlocked('ability_disc')) _BonusChip('-25% Ability Cost'),
              if (game.prestigeShop.isUnlocked('start_gold'))   _BonusChip('+500 Start Gold'),
              if (game.prestigeShop.isUnlocked('start_gold_2')) _BonusChip('+1500 Start Gold'),
              if (game.prestigeShop.isUnlocked('head_start'))   _BonusChip('Start Stage 6'),
              if (game.prestigeShop.isUnlocked('head_start_2')) _BonusChip('Start Stage 11'),
              if (game.prestigeShop.isUnlocked('forge_bonus'))  _BonusChip('Forge: 2 items'),
            ],
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
      child: Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF44cc88))),
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
    final owned   = game.prestigeShop.isUnlocked(node.id);
    final prereqMet = node.prerequisiteId == null ||
        game.prestigeShop.isUnlocked(node.prerequisiteId!);
    final canAfford = game.prestigeSouls >= node.soulCost;
    final canBuy = !owned && prereqMet && canAfford;
    final borderColor = owned
        ? const Color(0xFFcc8844)
        : (!prereqMet || !canAfford)
            ? AppTheme.cardBorder.withValues(alpha: 0.4)
            : AppTheme.cardBorder;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0e1225),
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
                          fontSize: 13,
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
                          style: AppTheme.pixelHeading(fontSize: 8, color: const Color(0xFFcc8844))),
                    ),
                  ],
                ]),
                const SizedBox(height: 3),
                Text(node.description,
                    style: TextStyle(
                        fontSize: 11,
                        color: (!prereqMet || owned) ? AppTheme.textMuted : AppTheme.textLight)),
                if (!prereqMet) ...[
                  const SizedBox(height: 4),
                  Text('Requires: ${node.prerequisiteId}',
                      style: const TextStyle(fontSize: 10, color: Color(0xFFcc4444))),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (!owned)
            Column(
              children: [
                _SoulBadge(souls: node.soulCost, large: false,
                    dim: !canAfford || !prereqMet),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: canBuy ? () => game.purchasePrestigeNode(node.id) : null,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFcc8844),
                    disabledForegroundColor: AppTheme.cardBorder,
                    side: BorderSide(
                        color: canBuy ? const Color(0xFFcc8844) : AppTheme.cardBorder),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('BUY',
                      style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 1,
                          color: canBuy ? const Color(0xFFcc8844) : AppTheme.cardBorder)),
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
  const _SoulBadge({required this.souls, required this.large, this.label = 'SOULS', this.dim = false});
  final int souls;
  final bool large;
  final String label;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final color = dim ? AppTheme.textMuted : const Color(0xFFcc8844);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 14 : 8, vertical: large ? 8 : 4),
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
                  style: TextStyle(fontSize: large ? 9 : 8, color: color.withValues(alpha: 0.7))),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/artifact.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class ArtifactScreen extends StatelessWidget {
  const ArtifactScreen({super.key});

  static const _slotColors = {
    ArtifactSlot.ring:    Color(0xFFffcc44),
    ArtifactSlot.amulet:  Color(0xFF66aaff),
    ArtifactSlot.trinket: Color(0xFF88cc44),
  };

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0a0e27),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1a1f3a),
          title: Text('ARTIFACTS',
              style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2)),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: _MythrilBadge(mythril: game.mythril),
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppTheme.accentGold,
            labelColor: AppTheme.accentGold,
            unselectedLabelColor: AppTheme.textMuted,
            tabs: ArtifactSlot.values
                .map((s) => Tab(
                    child: Text(s.label.toUpperCase(),
                        style: AppTheme.pixelHeading(
                            fontSize: 10, letterSpacing: 1))))
                .toList(),
          ),
        ),
        body: Column(
          children: [
            // Equipped summary
            _EquippedBar(game: game),
            // Slot tabs
            Expanded(
              child: TabBarView(
                children: ArtifactSlot.values
                    .map((slot) => _SlotTab(
                          game: game,
                          slot: slot,
                          color: _slotColors[slot]!,
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MythrilBadge extends StatelessWidget {
  const _MythrilBadge({required this.mythril});
  final int mythril;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF6644cc).withValues(alpha: 0.2),
        border: Border.all(color: const Color(0xFF9966ff).withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('⬡', style: TextStyle(fontSize: 10, color: Color(0xFF9966ff))),
        const SizedBox(width: 4),
        Text('$mythril',
            style: AppTheme.pixelHeading(
                fontSize: 12, color: const Color(0xFF9966ff))),
      ]),
    );
  }
}

class _EquippedBar extends StatelessWidget {
  const _EquippedBar({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0e1225),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ArtifactSlot.values.map((slot) {
          final art = game.equippedArtifact(slot);
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: art != null
                    ? const Color(0xFF1a1f3a)
                    : Colors.transparent,
                border: Border.all(
                    color: art != null
                        ? AppTheme.accentGold.withValues(alpha: 0.4)
                        : AppTheme.cardBorder.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(slot.icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(
                    art?.name ?? 'Empty',
                    style: TextStyle(
                      fontSize: 8,
                      color: art != null ? Colors.white70 : AppTheme.textMuted,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SlotTab extends StatelessWidget {
  const _SlotTab({required this.game, required this.slot, required this.color});
  final GameState game;
  final ArtifactSlot slot;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final artifacts = Artifact.all.where((a) => a.slot == slot).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            border: Border.all(color: AppTheme.cardBorder),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'Earn Mythril ⬡ by completing Dungeon runs, Boss Rush, and Prestige. '
            'Buy artifacts once, then equip or swap freely.',
            style: TextStyle(fontSize: 10, color: AppTheme.textMuted, height: 1.5),
          ),
        ),
        ...artifacts.map((art) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ArtifactCard(game: game, artifact: art, color: color),
            )),
      ],
    );
  }
}

class _ArtifactCard extends StatelessWidget {
  const _ArtifactCard({
    required this.game,
    required this.artifact,
    required this.color,
  });
  final GameState game;
  final Artifact artifact;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final owned    = game.ownedArtifacts.contains(artifact.id);
    final equipped = game.equippedArtifact(artifact.slot)?.id == artifact.id;
    final canBuy   = game.mythril >= artifact.mythrilCost;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: equipped
            ? color.withValues(alpha: 0.05)
            : const Color(0xFF0e1225),
        border: Border.all(
          color: equipped
              ? color.withValues(alpha: 0.6)
              : AppTheme.cardBorder,
          width: equipped ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(artifact.slot.icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(artifact.name,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: owned ? color : Colors.white54)),
            ),
            if (equipped)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text('ON',
                    style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.bold)),
              ),
          ]),
          const SizedBox(height: 4),
          Text(artifact.flavorText,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textMuted,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: _statChips(artifact, color),
          ),
          const SizedBox(height: 10),
          Row(children: [
            if (!owned) ...[
              _MythrilCost(cost: artifact.mythrilCost, affordable: canBuy),
              const SizedBox(width: 10),
              _ArtButton(
                label: 'FORGE',
                color: canBuy ? color : AppTheme.cardBorder,
                onTap: canBuy ? () => game.buyArtifact(artifact) : null,
              ),
            ] else ...[
              _ArtButton(
                label: equipped ? 'EQUIPPED' : 'EQUIP',
                color: equipped ? AppTheme.textMuted : color,
                onTap: equipped
                    ? null
                    : () => game.equipArtifact(artifact),
              ),
              if (equipped) ...[
                const SizedBox(width: 8),
                _ArtButton(
                  label: 'REMOVE',
                  color: Colors.white30,
                  onTap: () => game.unequipArtifact(artifact.slot),
                ),
              ],
            ],
          ]),
        ],
      ),
    );
  }

  List<Widget> _statChips(Artifact a, Color c) {
    final chips = <Widget>[];
    void add(int v, String label) {
      if (v == 0) return;
      chips.add(_StatChip(
        label: '${v > 0 ? '+' : ''}$v $label',
        color: v < 0 ? const Color(0xFFff4444) : c,
      ));
    }
    add(a.attackBonus, 'ATK');
    add(a.damageBonus, 'DMG');
    add(a.acBonus,     'AC');
    add(a.hpPct,       'HP%');
    add(a.shardPct,    '◆%');
    add(a.goldPct,     'Gold%');
    add(a.xpPct,       'XP%');
    return chips;
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 9, color: color, fontWeight: FontWeight.bold)),
    );
  }
}

class _MythrilCost extends StatelessWidget {
  const _MythrilCost({required this.cost, required this.affordable});
  final int cost;
  final bool affordable;

  @override
  Widget build(BuildContext context) {
    final c = affordable ? const Color(0xFF9966ff) : AppTheme.cardBorder;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text('⬡', style: TextStyle(fontSize: 12, color: c)),
      const SizedBox(width: 3),
      Text('$cost',
          style: TextStyle(
              fontSize: 11,
              color: c,
              fontWeight: FontWeight.bold)),
    ]);
  }
}

class _ArtButton extends StatelessWidget {
  const _ArtButton({required this.label, required this.color, this.onTap});
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        disabledForegroundColor: AppTheme.cardBorder,
        side: BorderSide(color: onTap != null ? color : AppTheme.cardBorder),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label,
          style: AppTheme.pixelHeading(
              fontSize: 10,
              letterSpacing: 1,
              color: onTap != null ? color : AppTheme.cardBorder)),
    );
  }
}

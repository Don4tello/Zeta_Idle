import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/passive_tree.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class PassiveTreeScreen extends StatelessWidget {
  const PassiveTreeScreen({super.key, this.embedded = false});

  final bool embedded;

  static const _branchColors = <PassiveBranch, Color>{
    PassiveBranch.slayer:    Color(0xFFff5533),
    PassiveBranch.guardian:  Color(0xFF4488ff),
    PassiveBranch.merchant:  Color(0xFF44cc66),
    PassiveBranch.mystic:    Color(0xFFcc44ff),
    PassiveBranch.ascendant: Color(0xFFffcc33),
  };

  static const _branchNames = <PassiveBranch, String>{
    PassiveBranch.slayer:    'SLAYER',
    PassiveBranch.guardian:  'GUARDIAN',
    PassiveBranch.merchant:  'MERCHANT',
    PassiveBranch.mystic:    'MYSTIC',
    PassiveBranch.ascendant: 'ASCENDANT',
  };

  static const _branchEmojis = <PassiveBranch, String>{
    PassiveBranch.slayer:    '⚔',
    PassiveBranch.guardian:  '🛡',
    PassiveBranch.merchant:  '💰',
    PassiveBranch.mystic:    '✨',
    PassiveBranch.ascendant: '⭐',
  };

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);

    final essenceRow = Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(children: [
        const Icon(Icons.auto_awesome, color: Color(0xFFaaff88), size: 13),
        const SizedBox(width: 5),
        Text(
          '${game.essence}',
          style: GoogleFonts.pixelifySans(
            color: const Color(0xFFaaff88),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        const Text('essence', style: TextStyle(color: Colors.white38, fontSize: 12)),
        const Spacer(),
        Text(
          '${game.passiveTree.unlockedCount} nodes unlocked',
          style: const TextStyle(color: Colors.white30, fontSize: 11),
        ),
      ]),
    );

    final treeBody = ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      children: PassiveBranch.values.map((branch) {
        final nodes = kPassiveNodes
            .where((n) => n.branch == branch)
            .toList()
          ..sort((a, b) => a.tier.compareTo(b.tier));
        final color  = _branchColors[branch]!;
        final locked = branch == PassiveBranch.ascendant &&
            !game.passiveTree.ascendantBranchAvailable;

        final otherCount = branch == PassiveBranch.ascendant
            ? kPassiveNodes
                .where((n) => n.branch != PassiveBranch.ascendant &&
                    game.passiveTree.isUnlocked(n.id))
                .length
            : 0;

        final totalRanks = nodes.fold(0, (s, n) => s + game.passiveTree.rankOf(n.id));
        final maxRanks   = nodes.fold(0, (s, n) => s + n.maxRank);

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Branch header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  border: Border(left: BorderSide(color: locked ? Colors.white24 : color, width: 3)),
                ),
                child: Row(children: [
                  Text(_branchEmojis[branch]!, style: TextStyle(
                    fontSize: 17,
                    color: locked ? Colors.white30 : Colors.white,
                  )),
                  const SizedBox(width: 8),
                  Text(
                    _branchNames[branch]!,
                    style: TextStyle(
                      color: locked ? Colors.white30 : color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  if (locked)
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.lock_outline, color: Colors.white30, size: 11),
                      const SizedBox(width: 4),
                      Text(
                        '$otherCount / 4 nodes needed',
                        style: const TextStyle(color: Colors.white30, fontSize: 10),
                      ),
                    ])
                  else ...[
                    Text(
                      '$totalRanks',
                      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '/$maxRanks',
                      style: const TextStyle(color: Colors.white30, fontSize: 11),
                    ),
                  ],
                ]),
              ),
              const SizedBox(height: 6),
              // Node row with connectors
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < nodes.length; i++) ...[
                      if (i > 0)
                        _Connector(
                          color: color,
                          active: !locked && game.passiveTree.isUnlocked(nodes[i - 1].id),
                        ),
                      Expanded(
                        child: _NodeCard(
                          node: nodes[i],
                          game: game,
                          color: color,
                          locked: locked,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );

    if (embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          essenceRow,
          Expanded(child: treeBody),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('PASSIVE TREE'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.auto_awesome, color: Color(0xFFaaff88), size: 14),
              const SizedBox(width: 5),
              Text(
                '${game.essence}',
                style: GoogleFonts.pixelifySans(
                  color: const Color(0xFFaaff88),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Text('essence', style: TextStyle(color: Colors.white38, fontSize: 12)),
            ]),
          ),
        ],
      ),
      body: treeBody,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Connector extends StatelessWidget {
  const _Connector({required this.color, required this.active});
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 8,
      child: Center(
        child: Container(height: 2, color: active ? color.withOpacity(0.5) : Colors.white12),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NodeCard extends StatelessWidget {
  const _NodeCard({
    required this.node,
    required this.game,
    required this.color,
    required this.locked,
  });

  final PassiveNode node;
  final GameState   game;
  final Color       color;
  final bool        locked;

  @override
  Widget build(BuildContext context) {
    final rank       = game.passiveTree.rankOf(node.id);
    final isMax      = game.passiveTree.isMaxRank(node.id);
    final canUpgrade = !locked && game.passiveTree.canUpgrade(node.id);
    final cost       = canUpgrade ? game.passiveTree.costForNextRank(node.id) : 0;
    final canAfford  = canUpgrade && game.essence >= cost;

    final borderColor = locked
        ? const Color(0xFF211E1A)
        : isMax
            ? color
            : canAfford
                ? color.withOpacity(0.55)
                : rank > 0
                    ? color.withOpacity(0.28)
                    : const Color(0xFF2E2A26);

    return GestureDetector(
      onTap: canAfford ? () => game.upgradePassive(node.id) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: locked
              ? const Color(0xFF090c15)
              : rank > 0
                  ? color.withOpacity(0.10)
                  : const Color(0xFF0d1020),
          border: Border.all(color: borderColor, width: isMax ? 2 : 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              node.emoji,
              style: TextStyle(
                fontSize: 19,
                color: locked ? Colors.white24 : Colors.white,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              node.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: locked
                    ? Colors.white24
                    : rank > 0
                        ? color
                        : Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              node.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: locked ? Colors.white12 : Colors.white38,
                fontSize: 8,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            // Rank dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(node.maxRank, (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Text(
                  i < rank ? '●' : '○',
                  style: TextStyle(
                    fontSize: 8,
                    color: i < rank ? color : color.withOpacity(locked ? 0.08 : 0.22),
                  ),
                ),
              )),
            ),
            const SizedBox(height: 4),
            if (isMax)
              Text(
                'MAX',
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              )
            else if (!locked)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 8,
                    color: canAfford ? const Color(0xFFaaff88) : Colors.white24,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    canUpgrade ? '$cost' : '—',
                    style: TextStyle(
                      color: canAfford ? const Color(0xFFaaff88) : Colors.white24,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

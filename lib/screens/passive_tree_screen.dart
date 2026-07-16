import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/passive_tree.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart' show TutorialTip;

class PassiveTreeScreen extends StatelessWidget {
  const PassiveTreeScreen({super.key, this.embedded = false});

  final bool embedded;

  static const _branchColors = <PassiveBranch, Color>{
    PassiveBranch.slayer:       Color(0xFFff5533),
    PassiveBranch.guardian:     Color(0xFF4488ff),
    PassiveBranch.merchant:     Color(0xFF44cc66),
    PassiveBranch.mystic:       Color(0xFFcc44ff),
    PassiveBranch.elementalist: Color(0xFFff8844),
    PassiveBranch.ascendant:    Color(0xFFffcc33),
  };

  static const _branchNames = <PassiveBranch, String>{
    PassiveBranch.slayer:       'SLAYER',
    PassiveBranch.guardian:     'GUARDIAN',
    PassiveBranch.merchant:     'MERCHANT',
    PassiveBranch.mystic:       'MYSTIC',
    PassiveBranch.elementalist: 'ELEMENTALIST',
    PassiveBranch.ascendant:    'ASCENDANT',
  };

  static const _branchEmojis = <PassiveBranch, String>{
    PassiveBranch.slayer:       '⚔',
    PassiveBranch.guardian:     '🛡',
    PassiveBranch.merchant:     '💰',
    PassiveBranch.mystic:       '✨',
    PassiveBranch.elementalist: '🜂',
    PassiveBranch.ascendant:    '⭐',
  };

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);

    final essenceRow = Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(children: [
        Tooltip(
          message: AppTheme.resourceTooltips['essence']!,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFaaff88), size: 13),
            const SizedBox(width: 5),
            Text(
              '${game.essence}',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFFaaff88),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Text('essence', style: TextStyle(color: Colors.white38, fontSize: 12)),
          ]),
        ),
        const Spacer(),
        Text(
          '${game.passiveTree.unlockedCount} nodes unlocked',
          style: const TextStyle(color: Colors.white30, fontSize: 11),
        ),
      ]),
    );

    final treeBody = ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      children: [
        if (!embedded)
          TutorialTip(
            tutorialKey: 'passives',
            game: game,
            text: 'You\'ve earned Essence ✦ — spend it here on permanent passive '
                'nodes that survive every rebirth. Your class branch is at the top. '
                'Each node ranks up to 5 for bigger bonuses.',
          ),
        ...[PassiveBranch.elementalist, ...PassiveBranch.values.where((b) => b != PassiveBranch.elementalist)].map((branch) {
        final className = game.hero.heroClass.name;
        final classInfo = game.hero.heroClass.info;
        List<PassiveNode> nodes;
        if (branch == PassiveBranch.elementalist) {
          nodes = elementalistNodesFor(classInfo.classElement, classInfo.secondaryElement);
        } else {
          nodes = kPassiveNodes
              .where((n) => n.branch == branch && !n.isConnector &&
                  (n.classOnly == null || n.classOnly == className))
              .toList();
        }
        nodes.sort((a, b) => a.tier.compareTo(b.tier));
        final color  = _branchColors[branch]!;
        final branchName = branch == PassiveBranch.elementalist
            ? 'THE ${game.hero.heroClass.displayName.toUpperCase()}'
            : _branchNames[branch]!;
        final locked = branch == PassiveBranch.ascendant &&
            !game.passiveTree.ascendantBranchAvailable;

        final otherCount = branch == PassiveBranch.ascendant
            ? game.passiveTree.ascendantUnlockPoints
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
                    branchName,
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
                        '$otherCount / 5 branches at 25',
                        style: const TextStyle(color: Colors.white30, fontSize: 10),
                      ),
                    ])
                  else ...[
                    if (totalRanks > 0)
                      GestureDetector(
                        onTap: () async {
                          final refund = game.passiveTree.respecBranchRefund(branch);
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF1a1a2e),
                              title: Text('Respec ${_branchNames[branch]}?',
                                  style: const TextStyle(color: Colors.white, fontSize: 14)),
                              content: Text('Refund $refund essence (75%)',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true),
                                    child: Text('Respec', style: TextStyle(color: color))),
                              ],
                            ),
                          );
                          if (ok == true) game.respecBranch(branch);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: color.withValues(alpha: 0.4)),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text('RESPEC', style: TextStyle(
                              fontSize: 8, color: color.withValues(alpha: 0.7), fontWeight: FontWeight.bold)),
                        ),
                      ),
                    const SizedBox(width: 8),
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
              // Node row with connectors — horizontally scrollable
              SizedBox(
                height: 155,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (int i = 0; i < nodes.length; i++) ...[
                      if (i > 0)
                        _Connector(
                          color: color,
                          active: !locked && game.passiveTree.isUnlocked(nodes[i - 1].id),
                        ),
                      SizedBox(
                        width: 100,
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
              ),
            ],
          ),
        );
      }),

        // ── Connector Nodes ──────────────────────────────────────────────
        if (PassiveTree.connectorNodes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF2a2a1a),
              border: const Border(left: BorderSide(color: Color(0xFFccaa44), width: 3)),
            ),
            child: Text('CROSS-BRANCH', style: TextStyle(
              color: const Color(0xFFccaa44), fontSize: 12,
              fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ),
          const SizedBox(height: 6),
          ...PassiveTree.connectorNodes.map((node) {
            final rank = game.passiveTree.rankOf(node.id);
            final can = game.passiveTree.canUpgrade(node.id);
            final cost = game.passiveTree.costForNextRank(node.id);
            final affordable = game.essence >= cost;
            final maxed = game.passiveTree.isMaxRank(node.id);
            return Container(
              margin: const EdgeInsets.only(bottom: 4, left: 8, right: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF231F1B),
                border: Border.all(color: can ? const Color(0xFFccaa44) : Colors.white12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(children: [
                Text(node.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(node.name, style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold,
                        color: can ? const Color(0xFFccaa44) : Colors.white38)),
                    Text('${node.description}  [$rank/${node.maxRank}]',
                        style: const TextStyle(fontSize: 9, color: Colors.white38)),
                  ],
                )),
                if (!maxed)
                  GestureDetector(
                    onTap: can && affordable ? () { game.upgradePassive(node.id); game.audioService.playUiConfirm(); } : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: can && affordable ? const Color(0xFF2a2a1a) : Colors.transparent,
                        border: Border.all(color: can && affordable ? const Color(0xFFccaa44) : Colors.white12),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text('$cost ✦', style: TextStyle(fontSize: 10,
                          color: can && affordable ? const Color(0xFFccaa44) : Colors.white24)),
                    ),
                  ),
              ]),
            );
          }),
        ],

        // ── Full Respec Button ───────────────────────────────────────────
        const SizedBox(height: 16),
        if (game.passiveTree.unlockedCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () async {
                final refund = game.passiveTree.fullRespecRefund;
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF1a1a2e),
                    title: const Text('Full Respec?', style: TextStyle(color: Colors.white, fontSize: 14)),
                    content: Text(
                      'Reset ALL passive nodes.\nRefund $refund essence (60%).\nCost: 50 zcoins.',
                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel')),
                      TextButton(
                        onPressed: game.zcoins >= 50 ? () => Navigator.pop(ctx, true) : null,
                        child: Text('Respec (50 ZC)',
                            style: TextStyle(color: game.zcoins >= 50 ? const Color(0xFFcc88ff) : Colors.white24)),
                      ),
                    ],
                  ),
                );
                if (ok == true) game.fullRespec();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFcc88ff),
                side: const BorderSide(color: Color(0xFFcc88ff)),
              ),
              child: const Text('FULL RESPEC (50 ZC)',
                  style: TextStyle(fontSize: 11, letterSpacing: 1)),
            ),
          ),
        const SizedBox(height: 24),
      ],
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
                style: GoogleFonts.rajdhani(
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

  static String _effectLabel(PassiveEffect e) => switch (e) {
    PassiveEffect.attackFlat      => 'Critical Damage',
    PassiveEffect.damageFlat      => 'Flat Damage',
    PassiveEffect.critChance      => 'Crit Chance',
    PassiveEffect.pierce          => 'Armor Pierce',
    PassiveEffect.allDamage       => 'All Damage',
    PassiveEffect.maxHp           => 'Max HP',
    PassiveEffect.regenFlat       => 'HP Regen/round',
    PassiveEffect.armorFlat       => 'Armor',
    PassiveEffect.dodgeChance     => 'Dodge Chance',
    PassiveEffect.goldFlat        => 'Gold Income',
    PassiveEffect.shardFlat       => 'Shards/kill',
    PassiveEffect.xpFlat          => 'XP Gain',
    PassiveEffect.idleFlat        => 'Idle Rate',
    PassiveEffect.cooldownReduce  => 'Cooldown Reduction',
    PassiveEffect.abilityDamage   => 'Ability Damage',
    PassiveEffect.healBoost       => 'Heal Boost',
    PassiveEffect.essenceGain     => 'Essence Gain',
    PassiveEffect.allPenetration  => 'Elemental Penetration',
    PassiveEffect.fireDamage      => 'Fire Damage',
    PassiveEffect.coldDamage      => 'Cold Damage',
    PassiveEffect.lightningDamage => 'Lightning Damage',
    PassiveEffect.poisonDamage    => 'Poison Damage',
    PassiveEffect.voidDamage      => 'Void Damage',
    PassiveEffect.fireRes         => 'Fire Resistance',
    PassiveEffect.coldRes         => 'Cold Resistance',
    PassiveEffect.lightningRes    => 'Lightning Resistance',
    PassiveEffect.poisonRes       => 'Poison Resistance',
    PassiveEffect.voidRes         => 'Void Resistance',
    PassiveEffect.allRes          => 'All Resistances',
  };

  static String _sign(PassiveEffect e) =>
      e == PassiveEffect.cooldownReduce ? '−' : '+';

  static String _suffix(PassiveEffect e) => switch (e) {
    PassiveEffect.attackFlat || PassiveEffect.damageFlat ||
    PassiveEffect.armorFlat  || PassiveEffect.shardFlat  ||
    PassiveEffect.idleFlat   || PassiveEffect.pierce     ||
    PassiveEffect.regenFlat  || PassiveEffect.cooldownReduce => '',
    _ => '%',
  };

  void _showDetail(BuildContext context) {
    final sign       = _sign(node.effect);
    final suffix     = _suffix(node.effect);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1a1a2e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
        final rank       = game.passiveTree.rankOf(node.id);
        final isMax      = game.passiveTree.isMaxRank(node.id);
        final canUpgrade = !locked && game.passiveTree.canUpgrade(node.id);
        final cost       = canUpgrade ? game.passiveTree.costForNextRank(node.id) : 0;
        final canAfford  = canUpgrade && game.essence >= cost;
        return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                Text(node.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(node.name,
                          style: TextStyle(color: color, fontSize: 16,
                              fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Text(_effectLabel(node.effect),
                          style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ),
                Text('$rank / ${node.maxRank}',
                    style: TextStyle(color: color, fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 10),
              Container(height: 1, color: color.withValues(alpha: 0.3)),
              const SizedBox(height: 10),
              // Stat per rank breakdown
              ...List.generate(node.maxRank, (i) {
                final tierRank = i + 1;
                final tierValue = node.value * tierRank;
                final isCurrent = tierRank == rank;
                final isAchieved = tierRank <= rank;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    Text(
                      isAchieved ? '●' : '○',
                      style: TextStyle(
                          color: isAchieved ? color : Colors.white24, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tier $tierRank',
                      style: TextStyle(
                          color: isCurrent ? Colors.white : Colors.white54,
                          fontSize: 12,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal),
                    ),
                    const Spacer(),
                    Text(
                      '$sign$tierValue$suffix',
                      style: TextStyle(
                          color: isAchieved ? color : Colors.white30,
                          fontSize: 13,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text('NOW',
                            style: TextStyle(color: color, fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ]),
                );
              }),
              if (!isMax && !locked) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: canAfford
                        ? () {
                            game.upgradePassive(node.id);
                            game.audioService.playUiConfirm();
                            setSheetState(() {});
                          }
                        : null,
                    icon: const Icon(Icons.auto_awesome, size: 14),
                    label: Text(
                      canUpgrade
                          ? 'UPGRADE  ($cost ✦)'
                          : node.branch == PassiveBranch.ascendant
                              ? 'LOCKED — spend 25 ranks in more branches'
                              : 'LOCKED — max all branch nodes first',
                      style: const TextStyle(fontSize: 13, letterSpacing: 0.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canAfford
                          ? color.withValues(alpha: 0.20)
                          : const Color(0xFF1a1a2e),
                      foregroundColor: canAfford ? color : Colors.white30,
                      side: BorderSide(
                          color: canAfford ? color : Colors.white12, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
              ],
              if (isMax)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text('MAX RANK — ${sign}${node.value * node.maxRank}$suffix total',
                        style: TextStyle(color: color, fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
        );
      }),
    );
  }

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

    return TweenAnimationBuilder<double>(
      key: ValueKey(rank),
      tween: Tween(begin: rank > 0 ? 1.25 : 1.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: GestureDetector(
      onTap: () => _showDetail(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: locked
              ? const Color(0xFF090c15)
              : rank > 0
                  ? color.withOpacity(0.10)
                  : const Color(0xFF0d1020),
          border: Border.all(
            color: node.isKeystone && rank > 0 ? color : borderColor,
            width: node.isKeystone ? 2.5 : isMax ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(node.isKeystone ? 8 : 6),
          boxShadow: node.isKeystone && rank > 0 ? [
            BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              node.emoji,
              style: TextStyle(
                fontSize: 16,
                color: locked ? Colors.white24 : Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              node.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: locked
                    ? Colors.white24
                    : rank > 0
                        ? color
                        : Colors.white54,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            Text(
              node.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: locked ? Colors.white12 : Colors.white38,
                fontSize: 7,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            // Rank fill bar
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                height: 4,
                width: 40,
                child: Stack(children: [
                  Container(color: locked ? Colors.white10 : color.withValues(alpha: 0.15)),
                  FractionallySizedBox(
                    widthFactor: node.maxRank > 0 ? rank / node.maxRank : 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 1),
            Text('$rank/${node.maxRank}',
                style: TextStyle(fontSize: 7, color: locked ? Colors.white12 : color.withValues(alpha: 0.6))),
            const SizedBox(height: 2),
            if (isMax)
              Text('MAX',
                style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1))
            else if (!locked)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 8,
                      color: canAfford ? const Color(0xFFaaff88) : Colors.white24),
                    const SizedBox(width: 2),
                    Text(canUpgrade ? '✦ $cost' : '—',
                      style: TextStyle(
                        color: canAfford ? const Color(0xFFaaff88) : Colors.white24,
                        fontSize: 8, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
      ),
      ),    // GestureDetector
    );      // TweenAnimationBuilder
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/routing/app_router.dart';
import '../data/enemy_data.dart';
import 'rebirth_flow_screen.dart';
import '../data/campaign_lore.dart';
import '../data/world_zone_data.dart';
import '../models/world_zone.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../screens/main_shell.dart';
import '../widgets/battle_sprites.dart';
import '../widgets/zcoin_icon.dart';

class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game     = GameStateProvider.of(context);
    final stage    = game.currentCampaignStage;
    final zone     = game.currentZone;
    final stageNum = game.campaignStageIndex + 1;

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text(
          game.campaignHardMode ? '⚡ CAMPAIGN — HARD' : 'CAMPAIGN',
          style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2,
              color: game.campaignHardMode ? const Color(0xFFff4444) : AppTheme.accentGold),
        ),
        actions: [
          if (game.effectiveUnlockStage >= 50)
            IconButton(
              icon: Icon(
                game.campaignHardMode ? Icons.whatshot : Icons.whatshot_outlined,
                color: game.campaignHardMode ? const Color(0xFFff4444) : AppTheme.textMuted,
                size: 20,
              ),
              tooltip: game.campaignHardMode ? 'Disable Hard Mode' : 'Enable Hard Mode (+50% rewards)',
              onPressed: () => game.toggleHardMode(),
            ),
          IconButton(
            icon: const Icon(Icons.leaderboard, color: AppTheme.accentGold, size: 20),
            tooltip: 'Campaign Leaderboard',
            onPressed: () => context.push(Routes.leaderboard),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TutorialTip(
            tutorialKey: 'campaign',
            game: game,
            text: 'Campaign advances stage by stage. Defeat each boss to unlock the next. '
                'Reach stage 25, 50, 75, or 100 to Rebirth and earn permanent upgrades.',
          ),

          _StarProgressRow(game: game),
          const SizedBox(height: 8),

          // Zone entry lore card �� shown once on first visit to each zone
          _ZoneIntroCard(game: game, zone: zone),

          // Current stage card
          _StageCard(
            stageNum: stageNum,
            title: stage.title,
            description: stage.description,
            difficulty: stage.difficulty,
            zone: zone,
            game: game,
          ),
          const SizedBox(height: 10),

          // Energy bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a2e),
              border: Border.all(color: const Color(0xFF44aaff).withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(children: [
              const Text('⚡', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text('${game.energy}/${GameState.maxEnergy}',
                  style: AppTheme.pixelHeading(fontSize: 12, color: const Color(0xFF44aaff))),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: game.energy / GameState.maxEnergy,
                    minHeight: 6,
                    backgroundColor: const Color(0xFF2a2a3a),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF44aaff)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (game.energy < GameState.maxEnergy) ...[
                Builder(builder: (_) {
                  final rem = game.energyRechargeRemaining;
                  return Text('${rem.inMinutes}:${(rem.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 9, color: AppTheme.textMuted));
                }),
                const SizedBox(width: 8),
              ],
              if (game.dailyEnergyRefillsUsed < GameState.maxDailyRefills)
                GestureDetector(
                  onTap: () { game.useEnergyRefill(); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF44aaff).withValues(alpha: 0.15),
                      border: Border.all(color: const Color(0xFF44aaff)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text('+${GameState.refillAmount}  (${GameState.maxDailyRefills - game.dailyEnergyRefillsUsed} left)',
                        style: const TextStyle(fontSize: 8, color: Color(0xFF44aaff), fontWeight: FontWeight.bold)),
                  ),
                ),
              if (game.energy < GameState.maxEnergy)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: GestureDetector(
                    onTap: game.zcoins >= 50 ? () { game.buyEnergy(); } : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: game.zcoins >= 50 ? const Color(0xFFcc88ff).withValues(alpha: 0.15) : Colors.transparent,
                        border: Border.all(color: game.zcoins >= 50 ? const Color(0xFFcc88ff) : AppTheme.cardBorder),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        ZCoinIcon(size: 10, animate: false),
                        const SizedBox(width: 3),
                        Text('50',
                            style: TextStyle(fontSize: 8, color: game.zcoins >= 50 ? const Color(0xFFcc88ff) : AppTheme.cardBorder, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 14),

          // Energy empty tip — shown once when player first hits 0
          if (game.energy == 0 && !game.tutorialEnergyEmptySeen)
            TutorialTip(
              tutorialKey: 'energyEmpty',
              game: game,
              text: 'Out of energy! ⚡ It refills 1 every 5 min. '
                  'Tap the +10 button above for 3 free daily refills. '
                  'Or buy +20 energy for 💎 50 ZCoins.',
            ),
          // Full campaign map
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Text('🗺', style: TextStyle(fontSize: 11)),
                const SizedBox(width: 5),
                Text('STAGE MAP  •  tap any ✓ node to replay',
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textMuted, letterSpacing: 0.5)),
              ],
            ),
          ),
          _CampaignMap(game: game),

          // Prestige section
          if (game.prestigeLevel > 0) ...[
            const SizedBox(height: 14),
            _PrestigeCard(game: game),
          ],
          if (game.canPrestige) ...[
            if (game.prestigeLevel == 0) ...[
              const SizedBox(height: 14),
              _FirstRebirthTutorial(),
            ],
            const SizedBox(height: 10),
            _PrestigeButton(game: game),
          ],

        ],
      ),
    );
  }
}

// ── Campaign map ──────────────────────────────────────────────────────────────

class _CampaignMap extends StatefulWidget {
  const _CampaignMap({required this.game});
  final GameState game;

  @override
  State<_CampaignMap> createState() => _CampaignMapState();
}

class _CampaignMapState extends State<_CampaignMap> {
  final _scroll = ScrollController();
  int? _selectedReplayStage;
  int _lastStageIndex = -1;
  Offset? _tapDownLocal;
  double _mapWidth = 0;

  // Fixed row height — used to compute initial scroll offset
  static const double _zoneHeaderH = 28.0;
  static const double _nodesH      = 80.0;
  static const double _zoneH       = _zoneHeaderH + _nodesH;

  @override
  void initState() {
    super.initState();
    _lastStageIndex = widget.game.campaignStageIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentZone());
  }

  @override
  void didUpdateWidget(covariant _CampaignMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.game.campaignStageIndex != _lastStageIndex) {
      _lastStageIndex = widget.game.campaignStageIndex;
      _selectedReplayStage = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentZone());
    }
  }

  void _scrollToCurrentZone() {
    if (!_scroll.hasClients) return;
    final zoneIdx    = widget.game.campaignStageIndex ~/ 5;
    final targetOffset = (zoneIdx * _zoneH - 32).clamp(0.0, _scroll.position.maxScrollExtent);
    _scroll.animateTo(targetOffset,
        duration: const Duration(milliseconds: 600), curve: Curves.easeOut);
  }

  void _showSimDialog(BuildContext context, int stageIdx, GameState game) {
    final maxSims = game.energy;
    if (maxSims == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No energy! Wait for it to refill.'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF442222),
      ));
      return;
    }
    final options = [1, 5, 10, 25, maxSims].where((n) => n <= maxSims).toSet().toList()..sort();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1814),
        title: Text('⚡ Simulate Stage ${stageIdx + 1}',
            style: const TextStyle(color: Color(0xFF44aaff), fontSize: 14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Energy available: $maxSims',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            const SizedBox(height: 4),
            const Text('Battles run instantly. Loot goes straight to your bag.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((n) {
                final label = n == maxSims && n > 25 ? 'ALL ($n)' : '$n×';
                return ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    final result = game.simulateCampaignBattles(stageIdx, n);
                    _showSimResult(context, result, stageIdx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF44aaff).withValues(alpha: 0.15),
                    foregroundColor: const Color(0xFF44aaff),
                    side: const BorderSide(color: Color(0xFF44aaff)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textMuted)),
          ),
        ],
      ),
    );
  }

  void _showSimResult(BuildContext context, SimBattleResult result, int stageIdx) {
    final drops = result.itemsDropped;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1814),
        title: Text('Stage ${stageIdx + 1} — ${result.count}× Simulated',
            style: const TextStyle(color: Color(0xFF44aaff), fontSize: 13)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _simRow('💰 Gold', '+${result.goldEarned}', const Color(0xFFffcc44)),
            const SizedBox(height: 4),
            _simRow('✦ XP', '+${result.xpEarned}', const Color(0xFF88cc44)),
            if (drops.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Items dropped (${drops.length}):',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              const SizedBox(height: 6),
              ...drops.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text('• ${item.name} (${item.rarityLabel})',
                    style: TextStyle(fontSize: 11, color: _rarityColor(item.rarityLabel))),
              )),
            ] else ...[
              const SizedBox(height: 8),
              const Text('No items dropped this run.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF44aaff).withValues(alpha: 0.15),
              foregroundColor: const Color(0xFF44aaff),
              side: const BorderSide(color: Color(0xFF44aaff)),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _simRow(String label, String value, Color color) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
    ],
  );

  Color _rarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'mythic':    return const Color(0xFFDD1111);
      case 'unique':    return const Color(0xFFE8A0FF);
      case 'legendary': return const Color(0xFFFFD700);
      case 'set':       return const Color(0xFF00cc88);
      case 'epic':      return const Color(0xFFcc44ff);
      case 'rare':      return const Color(0xFF6699ff);
      case 'uncommon':  return const Color(0xFF55cc55);
      default:          return AppTheme.textMuted;
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onMapTap(Offset localPos, BuildContext context) {
    final scrollOffset = _scroll.hasClients ? _scroll.offset : 0.0;
    final contentY = localPos.dy + scrollOffset;
    final zoneIdx = (contentY / _zoneH).floor();
    final withinZone = contentY % _zoneH;
    if (withinZone < _zoneHeaderH) return; // tapped zone header
    if (zoneIdx < 0 || zoneIdx >= kWorldZones.length) return;

    if (_mapWidth <= 0) return;
    final nodeWidth = ((_mapWidth - 32) / 5).clamp(48.0, 80.0);
    final connectorW = (_mapWidth - 5 * nodeWidth) / 4;
    final period = nodeWidth + connectorW;
    final nodeIdx = (localPos.dx / period).floor().clamp(0, 4);
    final localInPeriod = localPos.dx - nodeIdx * period;
    if (localInPeriod > nodeWidth) return; // tapped connector gap

    final stageIdx = zoneIdx * 5 + nodeIdx;
    final isCleared = stageIdx < widget.game.campaignStageIndex;
    final isCurrent = stageIdx == widget.game.campaignStageIndex;
    if (isCleared || isCurrent) {
      final selecting = _selectedReplayStage != stageIdx;
      setState(() {
        _selectedReplayStage = selecting ? stageIdx : null;
      });
      if (selecting) {
        // Scroll the outer page to its bottom so the overlay (at map bottom) is visible
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final outer = Scrollable.maybeOf(context);
          outer?.position.animateTo(
            outer.position.maxScrollExtent,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) => _tapDownLocal = e.localPosition,
      onPointerUp: (e) {
        final down = _tapDownLocal;
        _tapDownLocal = null;
        if (down == null) return;
        if ((e.localPosition - down).distance > 12) return;
        _onMapTap(e.localPosition, context);
      },
      child: LayoutBuilder(builder: (ctx, constraints) {
        _mapWidth = constraints.maxWidth;
        return Container(
        height: 400,
        decoration: BoxDecoration(
          color: const Color(0xFF181614),
          border: Border.all(color: AppTheme.cardBorder),
          borderRadius: BorderRadius.circular(4),
        ),
        child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            // ── Scrollable zone map ───────────────────────────────────────
            Builder(builder: (ctx) {
              final currentStage = GameStateProvider.of(ctx).campaignStageIndex;
              return ListView.builder(
                controller: _scroll,
                itemCount: kWorldZones.length,
                // Add bottom padding so the last rows aren't hidden behind overlay
                padding: _selectedReplayStage != null
                    ? const EdgeInsets.only(bottom: 86)
                    : EdgeInsets.zero,
                itemBuilder: (_, i) => _ZoneRow(
                  zone: kWorldZones[i],
                  currentStageIndex: currentStage,
                  selectedReplay: _selectedReplayStage,
                  onReplayTap: (stageIdx) => setState(() =>
                      _selectedReplayStage =
                          _selectedReplayStage == stageIdx ? null : stageIdx),
                ),
              );
            }),

            // ── Stage action overlay (pinned to bottom of map) ────────────
            if (_selectedReplayStage != null)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Builder(builder: (ctx) {
                  final stageIdx  = _selectedReplayStage!;
                  final isCurrent = stageIdx == widget.game.campaignStageIndex;
                  final enemy     = EnemyData.enemyForStage(stageIdx);
                  final color     = isCurrent ? const Color(0xFF44dd88) : AppTheme.accentGold;

                  void fight() {
                    if (isCurrent) {
                      widget.game.startBattle();
                    } else {
                      widget.game.startCampaignReplayBattle(stageIdx);
                    }
                    if (widget.game.currentEnemy == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Not enough energy!'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Color(0xFF442222),
                      ));
                      return;
                    }
                    context.push(Routes.battle);
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF12111a).withValues(alpha: 0.97),
                      border: Border(
                        top: BorderSide(color: color.withValues(alpha: 0.5), width: 1),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Enemy info + close
                        Row(children: [
                          StaticEnemySprite(
                              spriteId: EnemyData.spriteIdForStage(stageIdx), size: 30),
                          const SizedBox(width: 8),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(enemy.name,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: color),
                                  overflow: TextOverflow.ellipsis),
                              Text(
                                'Stage ${stageIdx + 1}  •  Lv${enemy.level}'
                                '  •  HP:${enemy.maxHealth}'
                                '${enemy.armorClass > 0 ? "  •  AC:${enemy.armorClass}" : ""}',
                                style: const TextStyle(
                                    fontSize: 9, color: AppTheme.textMuted),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )),
                          GestureDetector(
                            onTap: () => setState(() => _selectedReplayStage = null),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.close, size: 16, color: AppTheme.textMuted),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 7),
                        // Action buttons
                        Row(children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: fight,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color.withValues(alpha: 0.15),
                                foregroundColor: color,
                                side: BorderSide(color: color),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                minimumSize: const Size(0, 44),
                              ),
                              child: Text('⚔  FIGHT (−1 ⚡)',
                                  style: AppTheme.pixelHeading(
                                      fontSize: 10, color: color)),
                            ),
                          ),
                          if (!isCurrent) ...[
                            const SizedBox(width: 8),
                            Builder(builder: (ctx) {
                              final hasPremium = widget.game.hasPremium;
                              return Tooltip(
                                message: hasPremium ? '' : 'Requires Premium Pass subscription',
                                child: ElevatedButton(
                                  onPressed: hasPremium
                                      ? () => _showSimDialog(context, stageIdx, widget.game)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: hasPremium
                                        ? const Color(0xFF44aaff).withValues(alpha: 0.15)
                                        : AppTheme.cardBorder.withValues(alpha: 0.15),
                                    foregroundColor: hasPremium
                                        ? const Color(0xFF44aaff)
                                        : AppTheme.textMuted,
                                    disabledBackgroundColor:
                                        AppTheme.cardBorder.withValues(alpha: 0.15),
                                    disabledForegroundColor: AppTheme.textMuted,
                                    side: BorderSide(
                                        color: hasPremium
                                            ? const Color(0xFF44aaff)
                                            : AppTheme.cardBorder),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    minimumSize: const Size(0, 44),
                                  ),
                                  child: Text(hasPremium ? '⚡ SIM' : '🔒 SIM',
                                      style: AppTheme.pixelHeading(
                                          fontSize: 10,
                                          color: hasPremium
                                              ? const Color(0xFF44aaff)
                                              : AppTheme.textMuted)),
                                ),
                              );
                            }),
                          ],
                        ]),
                        // Boss lore intro — first encounter only
                        if (enemy.namedBoss && isCurrent)
                          Builder(builder: (_) {
                            final lore = bossLoreFor(enemy.id);
                            if (lore == null ||
                                widget.game.seenBossIntros.contains(enemy.id)) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1a0a0a),
                                  border: Border.all(
                                      color: const Color(0xFFcc4444)
                                          .withValues(alpha: 0.5)),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('BOSS ENCOUNTER',
                                        style: TextStyle(
                                            fontSize: 7,
                                            color: Color(0xFFcc4444),
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5)),
                                    const SizedBox(height: 4),
                                    Text(lore.intro,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: AppTheme.textLight,
                                            height: 1.4,
                                            fontStyle: FontStyle.italic)),
                                    const SizedBox(height: 5),
                                    GestureDetector(
                                      onTap: () =>
                                          widget.game.markBossIntroSeen(enemy.id),
                                      child: const Text('[ dismiss ]',
                                          style: TextStyle(
                                              fontSize: 8,
                                              color: AppTheme.textMuted)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  );
                }),
              ),
          ],
        ),
      ),
    );}), // Container + LayoutBuilder
    ); // Listener
  }
}

// ── One zone row (header + 5 stage nodes) ────────────────────────────────────

class _ZoneRow extends StatelessWidget {
  const _ZoneRow({required this.zone, required this.currentStageIndex, this.selectedReplay, this.onReplayTap});
  final WorldZone zone;
  final int currentStageIndex;
  final int? selectedReplay;
  final void Function(int)? onReplayTap;

  @override
  Widget build(BuildContext context) {
    final firstIdx  = zone.firstStage - 1; // 0-based index of zone's stage 1
    final isRebirth = zone.lastStage % 25 == 0; // gates at 25/50/75/100

    return Column(
      children: [
        // Zone header
        Container(
          height: _CampaignMapState._zoneHeaderH,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: zone.color.withValues(alpha: isRebirth ? 0.28 : 0.16),
          child: Row(
            children: [
              Text(zone.icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(zone.name.toUpperCase(),
                    style: AppTheme.pixelHeading(
                        fontSize: 9, letterSpacing: 1.5, color: zone.color),
                    overflow: TextOverflow.ellipsis),
              ),
              Text('${zone.firstStage}–${zone.lastStage}',
                  style: TextStyle(fontSize: 9, color: zone.color.withValues(alpha: 0.75))),
              if (zone.modifier != null) ...[
                const SizedBox(width: 5),
                Tooltip(
                  message: zone.modifier!.description,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: zone.color.withValues(alpha: 0.18),
                      border: Border.all(color: zone.color.withValues(alpha: 0.45)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text('${zone.modifier!.icon} ${zone.modifier!.label}',
                        style: TextStyle(fontSize: 8, color: zone.color)),
                  ),
                ),
              ],
              if (isRebirth) ...[
                const SizedBox(width: 5),
                Text('✦', style: TextStyle(fontSize: 10, color: zone.color)),
              ],
            ],
          ),
        ),
        // Stage nodes — node width scales with screen to prevent overflow
        LayoutBuilder(builder: (ctx, constraints) {
          // Reserve ~8px per connector (4 connectors); nodes share remaining width
          final nodeWidth = ((constraints.maxWidth - 32) / 5).clamp(48.0, 80.0);
          return SizedBox(
            height: _CampaignMapState._nodesH,
            child: Row(
              children: [
                for (int i = 0; i < 5; i++) ...[
                  if (i > 0) Builder(builder: (ctx2) {
                    final prevIdx = firstIdx + i - 1;
                    final prevCleared = prevIdx < currentStageIndex;
                    final prevCurrent = prevIdx == currentStageIndex;
                    final thisIdx = firstIdx + i;
                    final thisCleared = thisIdx < currentStageIndex;
                    final thisCurrent = thisIdx == currentStageIndex;
                    final lit = prevCleared || prevCurrent || thisCleared || thisCurrent;
                    return Expanded(
                      child: Container(
                        height: 2,
                        color: lit
                            ? zone.color.withValues(alpha: 0.55)
                            : zone.color.withValues(alpha: 0.12),
                      ),
                    );
                  }),
                  Builder(builder: (ctx2) {
                    final stageIdx  = firstIdx + i;
                    final isBoss    = stageIdx % 5 == 4;
                    final isCleared = stageIdx < currentStageIndex;
                    final isCurrent = stageIdx == currentStageIndex;
                    final game = GameStateProvider.of(ctx2);
                    return SizedBox(
                      width: nodeWidth,
                      height: _CampaignMapState._nodesH,
                      child: Center(child: _StageNode(
                        stageNum: stageIdx + 1,
                        spriteId: EnemyData.spriteIdForStage(stageIdx),
                        isBoss: isBoss,
                        isCleared: isCleared,
                        isCurrent: isCurrent,
                        color: zone.color,
                        stars: isCleared ? game.starsForStage(stageIdx) : 0,
                      )),
                    );
                  }),
                ],
              ],
            ),
          );
        }),
        // Divider between zones (thin gold line at rebirth gates)
        Divider(
          height: 1,
          thickness: isRebirth ? 1.5 : 0.5,
          color: isRebirth
              ? zone.color.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.04),
        ),
      ],
    );
  }
}

// ── Individual stage node ─────────────────────────────────────────────────────

class _StageNode extends StatelessWidget {
  const _StageNode({
    required this.stageNum,
    required this.spriteId,
    required this.isBoss,
    required this.isCleared,
    required this.isCurrent,
    required this.color,
    this.stars = 0,
  });

  final int stageNum;
  final String spriteId;
  final bool isBoss, isCleared, isCurrent;
  final Color color;
  final int stars;

  @override
  Widget build(BuildContext context) {
    final double size = isBoss ? 52.0 : 42.0;

    final Color border = isCleared || isCurrent
        ? color
        : color.withValues(alpha: 0.30);
    final double bw = isCurrent ? 2.5 : 1.5;

    // Sprite visibility: full for current, dimmed for cleared, very dim for locked
    final double spriteOpacity = isCurrent ? 1.0 : isCleared ? 0.55 : 0.20;

    // Background tint behind sprite
    final Color bg = isCleared
        ? color.withValues(alpha: 0.12)
        : isCurrent
            ? color.withValues(alpha: 0.08)
            : const Color(0xFF181614);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            border: Border.all(color: border, width: bw),
            boxShadow: isCurrent
                ? [BoxShadow(
                    color: color.withValues(alpha: 0.50),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Enemy sprite scaled to fill the circle
              Opacity(
                opacity: spriteOpacity,
                child: StaticEnemySprite(spriteId: spriteId, size: size),
              ),
              // Cleared overlay: faint tint + checkmark badge
              if (isCleared)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: isBoss ? 14 : 12,
                    height: isBoss ? 14 : 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.85),
                    ),
                    child: Icon(Icons.check,
                        size: isBoss ? 9 : 7, color: Colors.black87),
                  ),
                ),
              // Boss indicator: skull badge top-left
              if (isBoss && !isCleared)
                Positioned(
                  top: 1,
                  left: 2,
                  child: Text('☠',
                      style: TextStyle(
                          fontSize: 10,
                          color: isCurrent
                              ? Colors.white
                              : color.withValues(alpha: 0.7))),
                ),
              // Loot drop icons — top-right on boss nodes
              if (isBoss)
                Positioned(
                  top: 1,
                  right: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: 'Legendary item: 2% drop',
                        child: Text('✦',
                            style: TextStyle(
                              fontSize: 8,
                              color: const Color(0xFFcc8844)
                                  .withValues(alpha: isCleared || isCurrent ? 0.9 : 0.45),
                              height: 1.2,
                            )),
                      ),
                      Tooltip(
                        message: 'Set item: 0.3% drop',
                        child: Text('◈',
                            style: TextStyle(
                              fontSize: 8,
                              color: const Color(0xFF88aaff)
                                  .withValues(alpha: isCleared || isCurrent ? 0.9 : 0.45),
                              height: 1.2,
                            )),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          isCleared ? '↺' : isBoss ? 'BOSS' : '$stageNum',
          style: TextStyle(
            fontSize: isCleared ? 10 : 8,
            letterSpacing: 0.5,
            color: isCurrent
                ? Colors.white
                : isCleared
                    ? color.withValues(alpha: 0.85)
                    : color.withValues(alpha: 0.45),
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (isCleared && stars > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => Text(
              '★',
              style: TextStyle(
                fontSize: 6,
                color: i < stars ? const Color(0xFFFFD700) : const Color(0xFF444444),
              ),
            )),
          ),
      ],
    );
  }
}

// ── Stage card ────────────────────────────────────────────────────────────────

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.stageNum,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.zone,
    required this.game,
  });
  final int stageNum;
  final String title;
  final String description;
  final int difficulty;
  final WorldZone zone;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final hasEnergy = game.energy > 0;
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: zone.color.withValues(alpha: 0.12),
                  border: Border.all(color: zone.color.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(game.campaignStageLabel,
                    style: AppTheme.pixelHeading(
                        fontSize: 10, color: zone.color, letterSpacing: 1)),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  difficulty.clamp(1, 10),
                  (i) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(left: 2),
                    decoration: BoxDecoration(
                      color: _diffColor(difficulty),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
          const SizedBox(height: 6),
          Text(description,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: hasEnergy ? () {
                game.startBattle();
                if (game.currentEnemy != null) context.push(Routes.battle);
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: zone.color.withValues(alpha: 0.18),
                foregroundColor: zone.color,
                disabledBackgroundColor: AppTheme.cardBorder.withValues(alpha: 0.3),
                disabledForegroundColor: AppTheme.textMuted,
                side: BorderSide(color: hasEnergy ? zone.color : AppTheme.cardBorder),
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Text(
                hasEnergy ? '⚔  FIGHT  (−1 ⚡)' : '⚡ No energy — refills in ${game.energyRechargeRemaining.inMinutes}m',
                style: AppTheme.pixelHeading(fontSize: 11, color: hasEnergy ? zone.color : AppTheme.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _diffColor(int d) {
    if (d <= 33) return const Color(0xFF44cc66);
    if (d <= 66) return const Color(0xFFffaa33);
    return const Color(0xFFff4444);
  }
}

// ── Prestige section ──────────────────────────────────────────────────────────

class _PrestigeCard extends StatelessWidget {
  const _PrestigeCard({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a0a2a),
        border: Border.all(color: const Color(0xFFcc44ff).withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Rebirth Lv${game.prestigeLevel}  •  '
        '+${((game.prestigeGoldMult - 1) * 100).round()}% gold  •  '
        '+${((game.prestigeXpMult - 1) * 100).round()}% XP  •  '
        '+${((game.prestigeIdleMult - 1) * 100).round()}% idle',
        style: const TextStyle(
            color: Color(0xFFcc88ff), fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _FirstRebirthTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a0a2a),
        border: Border.all(color: const Color(0xFFcc44ff).withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Text('✦', style: TextStyle(fontSize: 14, color: Color(0xFFffaaff))),
            SizedBox(width: 8),
            Text('REBIRTH UNLOCKED',
                style: TextStyle(
                    color: Color(0xFFffaaff),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5)),
          ]),
          const SizedBox(height: 8),
          const Text(
            'You have reached a Rebirth Gate. Resetting your run earns permanent '
            'Rebirth Levels that boost gold, XP, and idle income for all future runs.\n\n'
            'You keep: ability upgrades, shards, and newly earned souls.\n'
            'You lose: hero level, gold, and endless perks.\n\n'
            'Tap REBIRTH below when you are ready. The REBIRTH tab in your Hero screen '
            'unlocks after your first reset for ongoing soul spending.',
            style: TextStyle(
                color: Colors.white60, fontSize: 12, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _PrestigeButton extends StatelessWidget {
  const _PrestigeButton({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4a1060),
          foregroundColor: const Color(0xFFffaaff),
          side: const BorderSide(color: Color(0xFFcc44ff), width: 2),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        onPressed: () => _confirmPrestige(context, game),
        child: Text('✦  REBIRTH  (Lv${game.prestigeLevel + 1})',
            style: AppTheme.pixelHeading(
                fontSize: 12, letterSpacing: 1, color: const Color(0xFFffaaff))),
      ),
    );
  }

  void _confirmPrestige(BuildContext context, GameState game) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => const RebirthFlowScreen(),
    ));
  }
}

// ── Zone intro card — shown once on first visit to each zone ──────────────────

class _ZoneIntroCard extends StatefulWidget {
  const _ZoneIntroCard({required this.game, required this.zone});
  final GameState game;
  final WorldZone zone;
  @override State<_ZoneIntroCard> createState() => _ZoneIntroCardState();
}

class _ZoneIntroCardState extends State<_ZoneIntroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 6), _dismiss);
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _dismiss() {
    if (!mounted || _dismissed) return;
    _dismissed = true;
    final zoneIdx = kWorldZones.indexOf(widget.zone);
    widget.game.markZoneIntroSeen(zoneIdx);
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final zoneIdx = kWorldZones.indexOf(widget.zone);
    final lore = zoneLoreFor(zoneIdx);
    if (lore == null || widget.game.seenZoneIntros.contains(zoneIdx)) {
      return const SizedBox.shrink();
    }
    return SizeTransition(
      sizeFactor: _fade,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: widget.zone.color.withValues(alpha: 0.08),
            border: Border(left: BorderSide(color: widget.zone.color, width: 3)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.zone.icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.zone.name.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                      color: widget.zone.color, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text(lore.entry,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textLight,
                      height: 1.5, fontStyle: FontStyle.italic)),
            ])),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _dismiss,
              child: const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.close, size: 14, color: AppTheme.textMuted),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _StarProgressRow extends StatelessWidget {
  const _StarProgressRow({required this.game});
  final GameState game;

  static const _milestones = [10, 25, 50, 100];

  @override
  Widget build(BuildContext context) {
    final total = game.totalThreeStarStages;
    final next  = _milestones.firstWhere((m) => m > total, orElse: () => 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a10),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Text('★', style: TextStyle(fontSize: 13, color: Color(0xFFFFD700))),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$total perfect stage${total == 1 ? '' : 's'}  '
              '${next > 0 ? '• next milestone at $next (+mythril +Z-Coins)' : '• all milestones cleared!'}',
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ),
          // Mini milestone pip row
          Row(
            children: _milestones.map((m) {
              final reached = total >= m;
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '$m',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: reached ? const Color(0xFFFFD700) : Colors.white24,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

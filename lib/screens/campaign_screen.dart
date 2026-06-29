import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/routing/app_router.dart';
import '../data/enemy_data.dart';
import '../data/world_zone_data.dart';
import '../models/damage_type.dart';
import '../models/world_zone.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../screens/main_shell.dart';
import '../widgets/battle_sprites.dart';

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
          if (game.campaignStageIndex >= 50)
            IconButton(
              icon: Icon(
                game.campaignHardMode ? Icons.whatshot : Icons.whatshot_outlined,
                color: game.campaignHardMode ? const Color(0xFFff4444) : AppTheme.textMuted,
                size: 20,
              ),
              tooltip: game.campaignHardMode ? 'Disable Hard Mode' : 'Enable Hard Mode (+50% rewards)',
              onPressed: () => game.toggleHardMode(),
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

          // Current stage card
          _StageCard(
            stageNum: stageNum,
            title: stage.title,
            description: stage.description,
            difficulty: stage.difficulty,
            zone: zone,
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
                    onTap: game.crystals >= 50 ? () { game.buyEnergy(); } : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: game.crystals >= 50 ? const Color(0xFFcc88ff).withValues(alpha: 0.15) : Colors.transparent,
                        border: Border.all(color: game.crystals >= 50 ? const Color(0xFFcc88ff) : AppTheme.cardBorder),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text('💎 50',
                          style: TextStyle(fontSize: 8, color: game.crystals >= 50 ? const Color(0xFFcc88ff) : AppTheme.cardBorder, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 8),

          const SizedBox(height: 14),

          // Full campaign map
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

          const SizedBox(height: 14),
          _LastActionRow(game: game),
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

  // Fixed row height — used to compute initial scroll offset
  static const double _zoneHeaderH = 28.0;
  static const double _nodesH      = 80.0;
  static const double _zoneH       = _zoneHeaderH + _nodesH;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentZone());
  }

  void _scrollToCurrentZone() {
    if (!_scroll.hasClients) return;
    final zoneIdx    = widget.game.campaignStageIndex ~/ 5;
    final targetOffset = (zoneIdx * _zoneH - 32).clamp(0.0, _scroll.position.maxScrollExtent);
    _scroll.animateTo(targetOffset,
        duration: const Duration(milliseconds: 600), curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: const Color(0xFF181614),
            border: Border.all(color: AppTheme.cardBorder),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: ListView.builder(
              controller: _scroll,
              itemCount: kWorldZones.length,
              itemBuilder: (_, i) => _ZoneRow(
                zone: kWorldZones[i],
                currentStageIndex: widget.game.campaignStageIndex,
                selectedReplay: _selectedReplayStage,
                onReplayTap: (stageIdx) => setState(() =>
                    _selectedReplayStage = _selectedReplayStage == stageIdx ? null : stageIdx),
              ),
            ),
          ),
        ),
        if (_selectedReplayStage != null)
          Builder(builder: (_) {
            final stageIdx = _selectedReplayStage!;
            final isCurrent = stageIdx == widget.game.campaignStageIndex;
            final enemy = EnemyData.enemyForStage(stageIdx);
            final label = isCurrent ? '⚔  FIGHT' : '🔄  REPLAY';
            final color = isCurrent ? const Color(0xFF44dd88) : AppTheme.accentGold;
            return Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e),
                border: Border.all(color: color.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(children: [
                SizedBox(width: 36, height: 40,
                    child: StaticEnemySprite(spriteId: EnemyData.spriteIdForStage(stageIdx), size: 34)),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(enemy.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                    Text('Stage ${stageIdx + 1}  •  Lv${enemy.level}  •  HP:${enemy.maxHealth}',
                        style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                  ],
                )),
                ElevatedButton(
                  onPressed: () {
                    if (isCurrent) {
                      widget.game.startBattle();
                    } else {
                      widget.game.startEndlessBattleAtStage(stageIdx);
                    }
                    context.push(Routes.battle);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.withValues(alpha: 0.15),
                    foregroundColor: color,
                    side: BorderSide(color: color),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Text(label, style: AppTheme.pixelHeading(fontSize: 10, color: color)),
                ),
              ]),
            );
          }),
      ],
    );
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
        // Stage nodes — nodes are fixed width, connector lines expand to fill gaps
        SizedBox(
          height: _CampaignMapState._nodesH,
          child: Row(
            children: [
              for (int i = 0; i < 5; i++) ...[
                if (i > 0) Builder(builder: (ctx) {
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
                Builder(builder: (ctx) {
                  final stageIdx  = firstIdx + i;
                  final isBoss    = stageIdx % 5 == 4;
                  final isCleared = stageIdx < currentStageIndex;
                  final isCurrent = stageIdx == currentStageIndex;
                  final game = GameStateProvider.of(ctx);
                  return GestureDetector(
                    onTap: (isCleared || isCurrent) && onReplayTap != null ? () => onReplayTap!(stageIdx) : null,
                    child: _StageNode(
                      stageNum: stageIdx + 1,
                      spriteId: EnemyData.spriteIdForStage(stageIdx),
                      isBoss: isBoss,
                      isCleared: isCleared,
                      isCurrent: isCurrent,
                      color: zone.color,
                      stars: isCleared ? game.starsForStage(stageIdx) : 0,
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
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
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          isBoss ? 'BOSS' : '$stageNum',
          style: TextStyle(
            fontSize: 8,
            letterSpacing: 0.5,
            color: isCurrent
                ? Colors.white
                : isCleared
                    ? color.withValues(alpha: 0.7)
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
  });
  final int stageNum;
  final String title;
  final String description;
  final int difficulty;
  final WorldZone zone;

  @override
  Widget build(BuildContext context) {
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
                child: Text('STAGE $stageNum',
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
    final stage = game.campaignStageIndex + 1;
    final gate  = stage == 100 ? 'THE OMEGA THRONE'  :
                  stage == 75  ? 'THE DARK MATTER'   :
                  stage == 50  ? 'THE ABYSSAL OCEAN' : 'THRONE OF RUIN';
    final soulsPreview = (game.campaignStageIndex / 5).floor().clamp(1, 200);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1814),
        title: Text('✦ REBIRTH — $gate',
            style: const TextStyle(color: Color(0xFFffaaff))),
        content: Text(
          'Reset your campaign and start anew as Rebirth Lv${game.prestigeLevel + 1}.\n\n'
          'You will KEEP:\n'
          '  • Ability upgrades\n'
          '  • Shards  •  Souls (+$soulsPreview)\n\n'
          'You will LOSE:\n'
          '  • Hero level, gold, upgrades, endless perks\n\n'
          'Rebirth Lv${game.prestigeLevel + 1} bonuses:\n'
          '  +${((game.prestigeGoldMult + 0.10 - 1) * 100).round()}% gold income\n'
          '  +${((game.prestigeXpMult + 0.05 - 1) * 100).round()}% XP gain\n'
          '  +${((game.prestigeIdleMult + 0.05 - 1) * 100).round()}% idle gold',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4a1060),
              foregroundColor: const Color(0xFFffaaff),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              game.prestige();
            },
            child: const Text('REBIRTH'),
          ),
        ],
      ),
    );
  }
}

class _LastActionRow extends StatelessWidget {
  const _LastActionRow({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    return Text('Last action: ${game.lastAction}',
        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted));
  }
}

// ── Enemy Preview ────────────────────────────────────────────────────────────

class _EnemyPreview extends StatelessWidget {
  const _EnemyPreview({required this.stageIndex});
  final int stageIndex;

  @override
  Widget build(BuildContext context) {
    final enemy = EnemyData.enemyForStage(stageIndex);
    final isBoss = stageIndex % 5 == 4;
    final res = enemy.resistances.entries
        .where((e) => e.value != 0)
        .toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1818),
        border: Border.all(
            color: isBoss
                ? const Color(0xFFcc44ff).withValues(alpha: 0.5)
                : AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(isBoss ? '☠' : '⚔', style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Text(isBoss ? 'BOSS AHEAD' : 'NEXT ENEMY',
                  style: AppTheme.pixelHeading(
                      fontSize: 9, letterSpacing: 2,
                      color: isBoss ? const Color(0xFFcc44ff) : AppTheme.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 36,
                height: 44,
                child: StaticEnemySprite(spriteId: enemy.id, size: 36),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(enemy.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold,
                          color: isBoss ? const Color(0xFFcc44ff) : AppTheme.textLight,
                          letterSpacing: 1,
                        )),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('LV.${enemy.level}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        const SizedBox(width: 8),
                        Builder(builder: (ctx) {
                          final kills = GameStateProvider.of(ctx).bestiaryKillCount(enemy.id);
                          return kills > 0
                              ? Text('×$kills killed', style: const TextStyle(fontSize: 10, color: Color(0xFF88cc44)))
                              : const Text('NEW', style: TextStyle(fontSize: 10, color: Color(0xFFffcc44), fontWeight: FontWeight.bold));
                        }),
                        const SizedBox(width: 8),
                        Text('HP:${enemy.maxHealth}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        const SizedBox(width: 8),
                        Text('ATK:${enemy.attack}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        const SizedBox(width: 6),
                        Text('${enemy.attackType.emoji} ${enemy.attackType.label}',
                            style: TextStyle(fontSize: 11, color: enemy.attackType.color,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (res.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: res.map((e) {
                final isVuln = e.value < 0;
                final color = isVuln ? const Color(0xFFFF5555) : const Color(0xFF88AACC);
                final sign = isVuln ? '' : '+';
                final tip = isVuln
                    ? '${e.key.label}: Vulnerable — takes ${-e.value}% extra damage'
                    : '${e.key.label}: Resistant — reduces damage by ${e.value}%';
                return Tooltip(
                  message: tip,
                  preferBelow: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      border: Border.all(color: color.withValues(alpha: 0.45)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '${e.key.emoji} $sign${e.value}%',
                      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('No resistances',
                  style: TextStyle(fontSize: 10, color: AppTheme.textMuted.withValues(alpha: 0.5))),
            ),
          if (isBoss && enemy.abilities.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('BOSS ABILITIES', style: AppTheme.pixelHeading(fontSize: 8, color: const Color(0xFFcc44ff), letterSpacing: 1)),
            const SizedBox(height: 4),
            ...enemy.abilities.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text('${a.emoji} ${a.name} — ${a.effect.name} (${a.damageType.label}, CD: ${a.cooldownRounds})',
                  style: const TextStyle(fontSize: 9, color: Color(0xFFcc88ff), height: 1.3)),
            )),
          ],
          if (isBoss) ...[
            const SizedBox(height: 6),
            Text('⚠ Boss: 2× HP, +25% ATK. Enrages at 30% HP (3× damage).',
                style: const TextStyle(fontSize: 9, color: Color(0xFFffcc44), fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }
}

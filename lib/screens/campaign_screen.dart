import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/routing/app_router.dart';
import '../data/world_zone_data.dart';
import '../models/world_zone.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../screens/main_shell.dart';

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
        title: Text('CAMPAIGN', style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
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

          // Full campaign map
          _CampaignMap(game: game),
          const SizedBox(height: 14),

          // Current stage card
          _StageCard(
            stageNum: stageNum,
            title: stage.title,
            description: stage.description,
            difficulty: stage.difficulty,
            zone: zone,
          ),
          const SizedBox(height: 14),

          // Hero stats
          _HeroStatsCard(game: game),
          const SizedBox(height: 14),

          // Enter battle button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: zone.color.withValues(alpha: 0.2),
                foregroundColor: zone.color,
                side: BorderSide(color: zone.color, width: 1.5),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: () {
                game.startBattle();
                context.push(Routes.battle);
              },
              child: Text('⚔  ENTER BATTLE',
                  style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2, color: zone.color)),
            ),
          ),

          // Prestige section
          if (game.prestigeLevel > 0) ...[
            const SizedBox(height: 14),
            _PrestigeCard(game: game),
          ],
          if (game.canPrestige) ...[
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

  // Fixed row height — used to compute initial scroll offset
  static const double _zoneHeaderH = 28.0;
  static const double _nodesH      = 64.0;
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
    return Container(
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
          ),
        ),
      ),
    );
  }
}

// ── One zone row (header + 5 stage nodes) ────────────────────────────────────

class _ZoneRow extends StatelessWidget {
  const _ZoneRow({required this.zone, required this.currentStageIndex});
  final WorldZone zone;
  final int currentStageIndex;

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
              if (isRebirth) ...[
                const SizedBox(width: 5),
                Text('✦', style: TextStyle(fontSize: 10, color: zone.color)),
              ],
            ],
          ),
        ),
        // Stage nodes
        SizedBox(
          height: _CampaignMapState._nodesH,
          child: Row(
            children: List.generate(5, (i) {
              final stageIdx = firstIdx + i;
              final isBoss   = stageIdx % 5 == 4;
              final isCleared  = stageIdx < currentStageIndex;
              final isCurrent  = stageIdx == currentStageIndex;

              // Path line before node (except first node)
              return Expanded(
                child: Row(
                  children: [
                    // Connector line from previous node (skip on first)
                    if (i > 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCleared || isCurrent
                              ? zone.color.withValues(alpha: 0.55)
                              : zone.color.withValues(alpha: 0.12),
                        ),
                      ),
                    _StageNode(
                      stageNum: stageIdx + 1,
                      isBoss: isBoss,
                      isCleared: isCleared,
                      isCurrent: isCurrent,
                      color: zone.color,
                    ),
                    // Connector line after last node in zone
                    if (i == 4)
                      const SizedBox.shrink(),
                  ],
                ),
              );
            }),
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
    required this.isBoss,
    required this.isCleared,
    required this.isCurrent,
    required this.color,
  });

  final int stageNum;
  final bool isBoss, isCleared, isCurrent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final size = isBoss ? 38.0 : 30.0;

    final Color bg     = isCleared
        ? color.withValues(alpha: 0.28)
        : isCurrent
            ? color.withValues(alpha: 0.18)
            : Colors.transparent;
    final Color border = isCleared || isCurrent
        ? color
        : color.withValues(alpha: 0.35);
    final double bw    = isCurrent ? 2.5 : 1.5;

    Widget child;
    if (isCleared) {
      child = Icon(Icons.check, size: isBoss ? 15 : 12, color: color);
    } else if (isBoss) {
      child = Text('☠',
          style: TextStyle(
              fontSize: 16,
              color: isCurrent ? Colors.white : color.withValues(alpha: 0.5)));
    } else {
      child = Text('$stageNum',
          style: TextStyle(
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? Colors.white : color.withValues(alpha: 0.65)));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            border: Border.all(color: border, width: bw),
            boxShadow: isCurrent
                ? [BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 10, spreadRadius: 2)]
                : null,
          ),
          alignment: Alignment.center,
          child: child,
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
                    : color.withValues(alpha: 0.55),
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
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

// ── Hero stats card ───────────────────────────────────────────────────────────

class _HeroStatsCard extends StatelessWidget {
  const _HeroStatsCard({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat('ATK', '+${game.hero.attackBonus}'),
          _Stat('DMG', '1d8+${game.hero.damageMod}'),
          _Stat('AC', '${game.hero.armorClass}'),
          _Stat('LV', '${game.hero.level}'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label,
          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, letterSpacing: 1)),
      const SizedBox(height: 3),
      Text(value, style: AppTheme.pixelHeading(fontSize: 14, color: AppTheme.textLight)),
    ]);
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

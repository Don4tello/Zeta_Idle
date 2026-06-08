import 'package:flutter/material.dart';
import '../models/world_zone.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../screens/main_shell.dart';

class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game  = GameStateProvider.of(context);
    final stage = game.currentCampaignStage;
    final zone  = game.currentZone;
    final stageNum = game.campaignStageIndex + 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0e27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1f3a),
        title: Text('CAMPAIGN', style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TutorialTip(
            tutorialKey: 'campaign',
            game: game,
            text: 'Campaign advances stage by stage. Defeat each boss to unlock the next. '
                'Reach stage 25 to prestige and earn souls for permanent upgrades.',
          ),

          // Zone banner
          _ZoneBanner(zone: zone, currentStageIndex: game.campaignStageIndex),
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
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: zone.color.withValues(alpha: 0.2),
                foregroundColor: zone.color,
                side: BorderSide(color: zone.color, width: 1.5),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: () {
                game.startBattle();
                Navigator.pushNamed(context, '/battle');
              },
              child: Text('⚔  ENTER BATTLE',
                  style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 2, color: zone.color)),
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

// ── Zone banner ───────────────────────────────────────────────────────────────

class _ZoneBanner extends StatelessWidget {
  const _ZoneBanner({required this.zone, required this.currentStageIndex});
  final WorldZone zone;
  final int currentStageIndex;

  @override
  Widget build(BuildContext context) {
    final progress = zone.progressIn(currentStageIndex);
    final total    = zone.stageCount;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: zone.color.withValues(alpha: 0.08),
        border: Border.all(color: zone.color.withValues(alpha: 0.5), width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(zone.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(zone.name.toUpperCase(),
                        style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2, color: zone.color)),
                    const SizedBox(height: 2),
                    Text('Stages ${zone.firstStage}–${zone.lastStage}',
                        style: TextStyle(fontSize: 10, color: zone.color.withValues(alpha: 0.6))),
                  ],
                ),
              ),
              // Stage progress dots
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(total, (i) => Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < progress ? zone.color : Colors.transparent,
                    border: Border.all(
                      color: i < progress ? zone.color : zone.color.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(zone.flavor,
              style: TextStyle(fontSize: 11, color: zone.color.withValues(alpha: 0.75),
                  height: 1.4)),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress / total,
              minHeight: 4,
              backgroundColor: zone.color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(zone.color),
            ),
          ),
          const SizedBox(height: 4),
          Text('$progress / $total stages cleared',
              style: TextStyle(fontSize: 10, color: zone.color.withValues(alpha: 0.5))),
        ],
      ),
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
        color: const Color(0xFF0e1225),
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
                    style: AppTheme.pixelHeading(fontSize: 9, color: zone.color, letterSpacing: 1)),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  difficulty.clamp(1, 10),
                  (i) => Container(
                    width: 6, height: 6,
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                  color: AppTheme.textLight)),
          const SizedBox(height: 6),
          Text(description,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4)),
        ],
      ),
    );
  }

  Color _diffColor(int d) {
    if (d <= 4) return const Color(0xFF44cc66);
    if (d <= 8) return const Color(0xFFffaa33);
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
        color: const Color(0xFF0e1225),
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
      Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1)),
      const SizedBox(height: 3),
      Text(value, style: AppTheme.pixelHeading(fontSize: 13, color: AppTheme.textLight)),
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
        style: const TextStyle(color: Color(0xFFcc88ff), fontSize: 12,
            fontWeight: FontWeight.bold),
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
            style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 1,
                color: const Color(0xFFffaaff))),
      ),
    );
  }

  void _confirmPrestige(BuildContext context, GameState game) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111525),
        title: const Text('✦ REBIRTH', style: TextStyle(color: Color(0xFFffaaff))),
        content: Text(
          'Reset your campaign and start anew as Rebirth Lv${game.prestigeLevel + 1}.\n\n'
          'You will KEEP:\n'
          '  • Ability upgrades\n'
          '  • Shards\n\n'
          'You will LOSE:\n'
          '  • Hero level, gold, upgrades, endless perks\n\n'
          'Rebirth Lv${game.prestigeLevel + 1} bonuses:\n'
          '  +${((game.prestigeGoldMult + 0.10 - 1) * 100).round()}% gold income\n'
          '  +${((game.prestigeXpMult + 0.05 - 1) * 100).round()}% XP gain\n'
          '  +${((game.prestigeIdleMult + 0.05 - 1) * 100).round()}% idle gold',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
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
            onPressed: () { Navigator.pop(ctx); game.prestige(); },
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
        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted));
  }
}

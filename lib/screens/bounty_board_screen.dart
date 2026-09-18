import 'package:flutter/material.dart';
import '../data/boss_hunt_data.dart';
import '../models/class_quest.dart' show QuestReward;
import '../models/equipment.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/battle_sprites.dart';
import '../widgets/zcoin_icon.dart';

class BountyBoardScreen extends StatelessWidget {
  const BountyBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('BOUNTY BOARD',
            style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
      ),
      body: const BountyBoardBody(),
    );
  }
}

/// The bounty list body — reused as the BOUNTIES tab inside the Challenges
/// screen. Lists the boss bounties for the tier you're currently playing.
class BountyBoardBody extends StatelessWidget {
  const BountyBoardBody({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    const accent = Color(0xFFff5566);

    // Gated behind the boss-bounty unlock (stage 20). The BOUNTIES tab is part of
    // the Challenges screen, which opens at stage 5, so without this it would be
    // reachable long before bounties actually unlock.
    if (!game.bossBountiesUnlocked) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('☠', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text('BOSS BOUNTIES LOCKED',
                style: AppTheme.pixelHeading(fontSize: 14, color: accent, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            const Text('Reach campaign stage 20 to start hunting bosses for bounty rewards.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4)),
          ]),
        ),
      );
    }

    final bounties = game.bossBounties;

    // "Done" = slain this run OR already claimed (claims persist through rebirth).
    bool done(BossHunt h) => game.isBossHuntClaimed(h) || game.isBossHuntMet(h);
    final slain = bounties.where(done).length;
    // Show every done boss plus the next one still to hunt.
    final nextIdx = bounties.indexWhere((h) => !done(h));
    final visible = nextIdx < 0 ? bounties : bounties.take(nextIdx + 1).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Tier banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF2a0a12), Color(0xFF231F1B)]),
            border: Border.all(color: accent.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(children: [
            const Text('☠', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BOSS BOUNTIES  •  TIER ${game.activeTier}',
                      style: AppTheme.pixelHeading(
                          fontSize: 12, color: accent, letterSpacing: 1.5)),
                  const SizedBox(height: 2),
                  const Text('Slay each campaign boss for its bounty. Reach a new '
                      'tier for a fresh set with bigger rewards.',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('$slain/${bounties.length}',
                style: AppTheme.pixelHeading(fontSize: 12, color: accent)),
          ]),
        ),
        if (bounties.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Text('No bounties available.',
                  style: TextStyle(color: AppTheme.textMuted)),
            ),
          )
        else
          ...visible.map((h) => _BossBountyCard(hunt: h, game: game)),
      ],
    );
  }
}

class _BossBountyCard extends StatelessWidget {
  const _BossBountyCard({required this.hunt, required this.game});
  final BossHunt hunt;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final slain     = game.isBossHuntMet(hunt);
    final claimed   = game.isBossHuntClaimed(hunt);
    final claimable = game.isBossHuntClaimable(hunt);
    const accent = Color(0xFFff5566);
    final borderColor = claimed
        ? const Color(0xFF44cc66)
        : claimable
            ? accent
            : slain ? accent.withValues(alpha: 0.4) : AppTheme.cardBorder;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: claimable ? const Color(0xFF2a1015) : const Color(0xFF1a1614),
        border: Border.all(color: borderColor.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        SizedBox(
          width: 44, height: 44,
          child: Opacity(
            opacity: slain ? 1.0 : 0.35,
            child: slain
                ? StaticEnemySprite(spriteId: hunt.spriteId, size: 42)
                : const Icon(Icons.lock_outline, size: 22, color: AppTheme.textMuted),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(claimed ? '☠ ${hunt.name} — Slain' : 'Slay the ${hunt.name}',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold,
                  color: claimed ? const Color(0xFF66dd88) : Colors.white)),
          const SizedBox(height: 3),
          Text('Campaign Stage ${hunt.stageNumber}  •  Lv ${hunt.level}',
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 4,
              children: _rewardChips(hunt.reward, game.bossBountyLootRarity(hunt))),
        ])),
        const SizedBox(width: 8),
        if (claimed)
          const Icon(Icons.check_circle, color: Color(0xFF44cc66), size: 22)
        else if (claimable)
          GestureDetector(
            onTap: () {
              game.claimBossHunt(hunt);
              game.audioService.playClaim();
              final loot = game.lastBossBountyLoot;
              final lootMsg = loot != null ? '  🎁 ${loot.name}' : '';
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${hunt.name} slain!  ${hunt.reward.summary}$lootMsg',
                    style: const TextStyle(color: AppTheme.accentGold)),
                backgroundColor: const Color(0xFF2A2623),
                duration: const Duration(seconds: 3),
              ));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                border: Border.all(color: accent),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('CLAIM',
                  style: AppTheme.pixelHeading(fontSize: 11, color: accent, letterSpacing: 1)),
            ),
          )
        else
          Text('Stage ${hunt.stageNumber}',
              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
      ]),
    );
  }

  List<Widget> _rewardChips(QuestReward r, ItemRarity lootRarity) {
    final chips = <Widget>[
      // Guaranteed gear drop — leads the list so the reward reads as loot-first.
      _RewardChip(
        label: '🎁 ${_rarityName(lootRarity)} Gear',
        color: _rarityColor(lootRarity),
      ),
    ];
    if (r.gold > 0)    chips.add(_RewardChip(label: '${r.gold} Gold', color: const Color(0xFFffcc44)));
    if (r.shards > 0)  chips.add(_RewardChip(label: '${r.shards} ◆', color: const Color(0xFF88cc44)));
    if (r.essence > 0) chips.add(_RewardChip(label: '${r.essence} ✦', color: const Color(0xFF66cc88)));
    if (r.zcoins > 0)  chips.add(_RewardChip(label: '${r.zcoins}', color: const Color(0xFF66aaff), prefix: const ZCoinIcon(size: 10, animate: false)));
    if (r.mythril > 0) chips.add(_RewardChip(label: '${r.mythril} ⬡', color: const Color(0xFF8888ff)));
    return chips;
  }

  static String _rarityName(ItemRarity r) => switch (r) {
    ItemRarity.mythic    => 'Mythic',
    ItemRarity.legendary => 'Legendary',
    ItemRarity.epic      => 'Epic',
    ItemRarity.rare      => 'Rare',
    ItemRarity.uncommon  => 'Uncommon',
    _                    => 'Common',
  };

  static Color _rarityColor(ItemRarity r) => switch (r) {
    ItemRarity.common    => const Color(0xFFaaaaaa),
    ItemRarity.uncommon  => const Color(0xFF55cc55),
    ItemRarity.rare      => const Color(0xFF6699ff),
    ItemRarity.epic      => const Color(0xFFcc44ff),
    ItemRarity.legendary => const Color(0xFFFFD700),
    ItemRarity.mythic    => const Color(0xFFDD1111),
    ItemRarity.set       => const Color(0xFF00cc88),
    ItemRarity.unique    => const Color(0xFFE8A0FF),
  };
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({required this.label, required this.color, this.prefix});
  final String  label;
  final Color   color;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (prefix != null) ...[prefix!, const SizedBox(width: 3)],
        Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/bounty.dart';
import '../models/world_zone.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/zcoin_icon.dart';

class BountyBoardScreen extends StatelessWidget {
  const BountyBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('BOUNTY BOARD',
            style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _TimeChip(game: game),
          ),
        ],
      ),
      body: const BountyBoardBody(),
    );
  }
}

/// The bounty list body — reused as the BOUNTIES tab inside the Challenges screen.
class BountyBoardBody extends StatelessWidget {
  const BountyBoardBody({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final bounties = game.dailyBounties;

    return RefreshIndicator(
        color: AppTheme.accentGold,
        backgroundColor: const Color(0xFF2A2623),
        onRefresh: () async {
          game.refreshDaily();
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TimeChip(game: game),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              border: Border.all(color: AppTheme.cardBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Three bounties refresh each day. Complete objectives during normal play — '
              'progress is tracked automatically. Claim rewards when done.',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.5),
            ),
          ),
          _ZoneBannerCard(zone: game.currentZone),
          const SizedBox(height: 12),
          if (bounties.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Text('No bounties available.',
                    style: TextStyle(color: AppTheme.textMuted)),
              ),
            )
          else
            ...bounties.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BountyCard(bounty: b, game: game, zoneName: game.currentZone.name),
                )),
        ],
        ),  // ListView
      );    // RefreshIndicator
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final diff = tomorrow.difference(now);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1a3a1a),
        border: Border.all(color: const Color(0xFF44aa44).withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        'Resets in ${h}h ${m}m',
        style: const TextStyle(fontSize: 10, color: Color(0xFF88cc88)),
      ),
    );
  }
}

class _ZoneBannerCard extends StatelessWidget {
  const _ZoneBannerCard({required this.zone});
  final WorldZone zone;

  @override
  Widget build(BuildContext context) {
    final themes = BountyPool.themesForZone(zone.name);
    final typeIcons = themes.map((t) => BountyPool.typeIcon(t)).where((s) => s.isNotEmpty).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: zone.color.withValues(alpha: 0.08),
        border: Border.all(color: zone.color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(zone.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.name.toUpperCase(),
                  style: TextStyle(
                    color: zone.color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                if (typeIcons.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Featured: ${typeIcons.join('  ')}',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: zone.color.withValues(alpha: 0.15),
              border: Border.all(color: zone.color.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              'CURRENT ZONE',
              style: TextStyle(
                fontSize: 9,
                color: zone.color,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BountyCard extends StatelessWidget {
  const _BountyCard({required this.bounty, required this.game, required this.zoneName});
  final Bounty bounty;
  final GameState game;
  final String zoneName;

  @override
  Widget build(BuildContext context) {
    final def = bounty.def;
    final progress = bounty.progress.clamp(0, def.target);
    final fraction = progress / def.target;
    final isZone = BountyPool.isZoneThemed(def.type, zoneName);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bounty.claimed
            ? const Color(0xFF0e1f0e)
            : bounty.isComplete
                ? def.color.withValues(alpha: 0.06)
                : const Color(0xFF231F1B),
        border: Border.all(
          color: bounty.claimed
              ? const Color(0xFF44aa44).withValues(alpha: 0.4)
              : bounty.isComplete
                  ? def.color.withValues(alpha: 0.7)
                  : AppTheme.cardBorder,
          width: bounty.isComplete && !bounty.claimed ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(def.icon, style: const TextStyle(fontSize: 21)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(def.label,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: bounty.claimed ? Colors.white38 : Colors.white)),
                  const SizedBox(height: 2),
                  Text('$progress / ${def.target}',
                      style: TextStyle(
                          fontSize: 11,
                          color: bounty.claimed ? Colors.white24 : AppTheme.textMuted)),
                ],
              ),
            ),
            if (bounty.claimed)
              const Icon(Icons.check_circle, color: Color(0xFF44aa44), size: 20)
            else if (bounty.isComplete)
              _ClaimButton(onTap: () {
                final r = def.reward;
                game.claimBounty(def.id);
                final parts = <String>[];
                if (r.gold > 0) parts.add('💰 +${r.gold}');
                if (r.shards > 0) parts.add('◆ +${r.shards}');
                if (r.zcoins > 0) parts.add('🪙 +${r.zcoins}');
                if (r.xp > 0) parts.add('⚡ +${r.xp} XP');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${def.label} claimed! ${parts.join("  ")}',
                      style: const TextStyle(color: AppTheme.accentGold)),
                  backgroundColor: const Color(0xFF2A2623),
                  duration: const Duration(seconds: 3),
                ));
              }),
          ]),
          if (isZone) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF1a2a10),
                border: Border.all(color: const Color(0xFF66aa33).withValues(alpha: 0.6)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                '★ ZONE BOUNTY',
                style: const TextStyle(fontSize: 9, color: Color(0xFF88cc55), fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ],
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: bounty.claimed ? 1.0 : fraction,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                  bounty.claimed ? const Color(0xFF44aa44) : def.color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          // Reward chips
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: _rewardChips(def.reward),
          ),
        ],
      ),
    );
  }

  List<Widget> _rewardChips(BountyReward r) {
    final chips = <Widget>[];
    if (r.gold > 0)     chips.add(_RewardChip(label: '${r.gold} Gold', color: const Color(0xFFffcc44)));
    if (r.zcoins > 0) chips.add(_RewardChip(label: '${r.zcoins}', color: const Color(0xFF66aaff), prefix: const ZCoinIcon(size: 10, animate: false)));
    if (r.shards > 0)   chips.add(_RewardChip(label: '${r.shards} ◆', color: const Color(0xFF88cc44)));
    if (r.xp > 0)       chips.add(_RewardChip(label: '${r.xp} XP', color: const Color(0xFFcc88ff)));
    return chips;
  }
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

class _ClaimButton extends StatelessWidget {
  const _ClaimButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.accentGold,
        side: const BorderSide(color: AppTheme.accentGold),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text('CLAIM',
          style: AppTheme.pixelHeading(
              fontSize: 11, letterSpacing: 1, color: AppTheme.accentGold)),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/season_pass.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import 'premium_shop_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SeasonPassScreen — the monthly two-track reward ladder.
//
// Free track: everyone. Premium track: gated behind the Premium Pass
// subscription (game.hasPremium). Both tracks unlock a tier once the player
// has earned enough Season XP to reach it.
// ─────────────────────────────────────────────────────────────────────────────

class SeasonPassScreen extends StatefulWidget {
  const SeasonPassScreen({super.key});

  @override
  State<SeasonPassScreen> createState() => _SeasonPassScreenState();
}

class _SeasonPassScreenState extends State<SeasonPassScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Jump to the player's current tier once laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final game = GameStateProvider.of(context);
      final target = (game.seasonPassTier - 1).clamp(0, SeasonPassTier.tiers.length - 1);
      if (_scroll.hasClients) {
        _scroll.animateTo(
          (target * 92.0).clamp(0.0, _scroll.position.maxScrollExtent),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 15)),
        backgroundColor: AppTheme.panelBg,
        duration: const Duration(milliseconds: 1400),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);

    return AnimatedBuilder(
      animation: game,
      builder: (context, _) {
        final tier = game.seasonPassTier;
        final tiers = SeasonPassTier.tiers;
        return Scaffold(
          backgroundColor: AppTheme.darkBg,
          appBar: AppBar(
            backgroundColor: AppTheme.bgSecondary,
            title: Text('SEASON PASS',
                style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
          ),
          body: Column(
            children: [
              _header(game),
              _trackLabels(),
              const Divider(height: 1, color: AppTheme.cardBorder),
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: tiers.length,
                  itemBuilder: (context, i) {
                    final t = tiers[i];
                    return _TierRow(
                      tier: t,
                      unlocked: tier >= t.tier,
                      isCurrent: t.tier == tier + 1,
                      hasPremium: game.hasPremium,
                      freeClaimed: game.seasonFreeClaimed.contains(t.tier),
                      premiumClaimed: game.seasonPremiumClaimed.contains(t.tier),
                      onClaimFree: () {
                        if (game.claimSeasonFree(t.tier)) {
                          _toast('Claimed ${t.freeReward}');
                        }
                      },
                      onClaimPremium: () {
                        if (game.claimSeasonPremium(t.tier)) {
                          _toast('Claimed ${t.premiumReward}');
                        } else if (!game.hasPremium) {
                          _openPremium();
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPremium() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PremiumShopScreen()),
    );
  }

  Widget _header(GameState game) {
    final tier = game.seasonPassTier;
    final maxed = tier >= SeasonPassTier.tiers.length;
    final unclaimed = game.seasonUnclaimedCount;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      color: AppTheme.bgSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('TIER $tier',
                  style: const TextStyle(
                      color: AppTheme.accentGoldBright,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              const SizedBox(width: 4),
              Text('/ ${SeasonPassTier.tiers.length}',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 16)),
              const Spacer(),
              const Text('📅 Resets monthly',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: game.seasonTierProgress,
              minHeight: 12,
              backgroundColor: AppTheme.darkBg,
              valueColor: const AlwaysStoppedAnimation(AppTheme.accentGold),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            maxed
                ? 'All tiers unlocked — nice work!'
                : '${game.seasonPassXp} / ${game.seasonNextTierXp} XP to Tier ${tier + 1}',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          if (!game.hasPremium) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openPremium,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: AppTheme.darkBg,
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: const Text('👑', style: TextStyle(fontSize: 18)),
                label: const Text('Unlock Premium Pass — 2× XP + premium track',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
          if (unclaimed > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  final n = game.claimAllSeason();
                  _toast(n > 0 ? 'Claimed $n reward${n == 1 ? '' : 's'}' : 'Nothing to claim');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentGoldBright,
                  side: const BorderSide(color: AppTheme.accentGold),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text('CLAIM ALL ($unclaimed)',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _trackLabels() {
    return Container(
      color: AppTheme.bgSecondary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: const [
          SizedBox(width: 44),
          Expanded(
            child: Text('FREE',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ),
          Expanded(
            child: Text('👑 PREMIUM',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.accentGoldBright, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.tier,
    required this.unlocked,
    required this.isCurrent,
    required this.hasPremium,
    required this.freeClaimed,
    required this.premiumClaimed,
    required this.onClaimFree,
    required this.onClaimPremium,
  });

  final SeasonPassTier tier;
  final bool unlocked;
  final bool isCurrent;
  final bool hasPremium;
  final bool freeClaimed;
  final bool premiumClaimed;
  final VoidCallback onClaimFree;
  final VoidCallback onClaimPremium;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.panelBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrent ? AppTheme.accentGold : AppTheme.cardBorder,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          _tierBadge(),
          const SizedBox(width: 8),
          Expanded(
            child: _RewardCell(
              icon: tier.freeIcon,
              label: tier.freeReward,
              unlocked: unlocked,
              claimed: freeClaimed,
              locked: false,
              onClaim: onClaimFree,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _RewardCell(
              icon: tier.premiumIcon ?? '—',
              label: tier.premiumReward ?? '—',
              unlocked: unlocked,
              claimed: premiumClaimed,
              locked: !hasPremium,
              onClaim: onClaimPremium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tierBadge() {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: unlocked ? AppTheme.accentGold : AppTheme.darkBg,
        shape: BoxShape.circle,
        border: Border.all(color: unlocked ? AppTheme.accentGoldBright : AppTheme.cardBorder),
      ),
      child: Text('${tier.tier}',
          style: TextStyle(
            color: unlocked ? AppTheme.darkBg : AppTheme.textMuted,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          )),
    );
  }
}

class _RewardCell extends StatelessWidget {
  const _RewardCell({
    required this.icon,
    required this.label,
    required this.unlocked,
    required this.claimed,
    required this.locked,
    required this.onClaim,
  });

  final String icon;
  final String label;
  final bool unlocked;
  final bool claimed;
  final bool locked; // premium track without a subscription
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final claimable = unlocked && !claimed && !locked;
    final dim = claimed || !unlocked || locked;
    return InkWell(
      onTap: (claimable || locked) ? onClaim : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: claimable ? AppTheme.accentGold.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: claimable ? AppTheme.accentGold : AppTheme.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Opacity(
              opacity: dim ? 0.45 : 1,
              child: Text(icon, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: dim ? AppTheme.textMuted : AppTheme.textLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: claimed ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            const SizedBox(width: 4),
            _statusIcon(claimable),
          ],
        ),
      ),
    );
  }

  Widget _statusIcon(bool claimable) {
    if (claimed) {
      return const Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 20);
    }
    if (locked) {
      return const Icon(Icons.lock, color: AppTheme.textDisabled, size: 18);
    }
    if (claimable) {
      return const Icon(Icons.card_giftcard, color: AppTheme.accentGoldBright, size: 20);
    }
    return const Icon(Icons.lock_outline, color: AppTheme.textDisabled, size: 18);
  }
}

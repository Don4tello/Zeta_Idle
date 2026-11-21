import 'package:flutter/material.dart';
import '../services/game_state.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';
import '../screens/premium_shop_screen.dart';

/// Shared battle-speed selector (bottom-sheet dropdown), used by both the in-
/// battle speed button and the Settings screen so they stay identical.
///
/// 1×/1.5× are free; 2× unlocks via a rewarded ad (or sub/premium); 3×/5× are
/// VIP (subscription → links to the shop). The chosen tier is GLOBAL — every
/// combat mode reads it through GameState.scaledInterval, so it applies across
/// Campaign, Dungeon, Boss Rush, Endless, Gauntlet, Guild War and PvP alike.
void showBattleSpeedMenu(BuildContext context, GameState game) {
  const rows = <({int tier, String label})>[
    (tier: 1, label: '1.0×'),
    (tier: 2, label: '1.5×'),
    (tier: 3, label: '2.0×'),
    (tier: 4, label: '3.0×'),
    (tier: 5, label: '5.0×'),
  ];
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF17150E),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (sheetCtx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(children: [
              const Icon(Icons.bolt, color: Color(0xFF44cc44), size: 18),
              const SizedBox(width: 8),
              Text('BATTLE SPEED',
                  style: AppTheme.pixelHeading(
                      fontSize: 13, letterSpacing: 2, color: AppTheme.accentGold)),
            ]),
          ),
          const Divider(color: Colors.white12, height: 1),
          for (final r in rows) _speedRow(context, sheetCtx, game, r.tier, r.label),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

Widget _speedRow(
    BuildContext context, BuildContext sheetCtx, GameState game, int tier, String label) {
  final unlocked  = tier <= game.maxCampaignSpeedTier;
  final isCurrent = game.effectiveSpeedTier == tier;
  final adTier    = tier == 3 && AdService.instance.isSupported;
  // On the 2× row, surface the time left on an active rewarded-ad boost (not
  // shown for sub/premium, which unlock it permanently).
  final boostLeft = (tier == 3 && !game.hasSpeedSub && !game.hasPremium)
      ? game.speedBoostRemaining
      : null;

  Widget? trailing;
  VoidCallback onTap;
  if (unlocked) {
    trailing = isCurrent
        ? const Icon(Icons.check, color: Color(0xFFffcc44), size: 18)
        : null;
    onTap = () { Navigator.pop(sheetCtx); game.setSpeedTier(tier); };
  } else if (adTier) {
    trailing = const Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.play_circle_outline, size: 15, color: Color(0xFF55cc88)),
      SizedBox(width: 5),
      Text('Watch Ad · 2h',
          style: TextStyle(color: Color(0xFF55cc88), fontSize: 12, fontWeight: FontWeight.bold)),
    ]);
    onTap = () {
      Navigator.pop(sheetCtx);
      AdService.instance.showRewardedAd(
        onRewarded: () { game.grantAdSpeedBoost(); game.setSpeedTier(3); },
        onFailed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Ad not ready — try again in a moment.')));
        },
      );
    };
  } else {
    trailing = const Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.workspace_premium, size: 15, color: Color(0xFFcc88ff)),
      SizedBox(width: 5),
      Text('VIP',
          style: TextStyle(color: Color(0xFFcc88ff), fontSize: 12, fontWeight: FontWeight.bold)),
    ]);
    onTap = () {
      Navigator.pop(sheetCtx);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const PremiumShopScreen(initialTab: PremiumShopScreen.vipTab)));
    };
  }

  return ListTile(
    dense: true,
    leading: Icon(Icons.bolt,
        color: isCurrent
            ? const Color(0xFFffcc44)
            : (unlocked ? const Color(0xFF44cc44) : AppTheme.textMuted),
        size: 18),
    title: Text(label,
        style: TextStyle(
            color: isCurrent
                ? const Color(0xFFffcc44)
                : (unlocked ? Colors.white : AppTheme.textMuted),
            fontSize: 15,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
    subtitle: boostLeft != null
        ? Text('${_fmtDuration(boostLeft)} left',
            style: const TextStyle(color: Color(0xFF55cc88), fontSize: 11))
        : null,
    trailing: trailing,
    onTap: onTap,
  );
}

String _fmtDuration(Duration d) {
  if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
  if (d.inMinutes > 0) return '${d.inMinutes}m';
  return '${d.inSeconds.clamp(0, 59)}s';
}

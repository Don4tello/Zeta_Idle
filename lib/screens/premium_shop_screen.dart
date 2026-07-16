import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../models/shop_catalog.dart';
import '../services/ad_service.dart';
import '../services/game_state.dart';
import '../services/iap_service.dart';
import '../theme/app_theme.dart';
import '../widgets/zcoin_icon.dart';
import 'aura_shop_screen.dart';

// Set false before publishing to stores
const bool _kCheatsEnabled = true;

class PremiumShopScreen extends StatefulWidget {
  const PremiumShopScreen({super.key});

  @override
  State<PremiumShopScreen> createState() => _PremiumShopScreenState();
}

class _PremiumShopScreenState extends State<PremiumShopScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 5, vsync: this);

  static const _tabLabels = ['BUNDLES', 'STARTER', 'SKINS', 'TITLES', 'VIP'];
  static const _tabIcons  = ['💎', '🎁', '🎨', '👑', '⭐'];

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('SHOP', style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const ZCoinIcon(size: 14),
              const SizedBox(width: 4),
              Text('${game.zcoins}',
                  style: AppTheme.pixelHeading(fontSize: 13, color: const Color(0xFFffcc44))),
            ]),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: false,
          tabAlignment: TabAlignment.fill,
          labelStyle: AppTheme.pixelHeading(fontSize: 9, letterSpacing: 1),
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.accentGold,
          tabs: List.generate(_tabLabels.length, (i) =>
            Tab(text: '${_tabIcons[i]} ${_tabLabels[i]}')),
        ),
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.trackpad,
          },
        ),
        child: TabBarView(
        controller: _tabs,
        children: [
          // ── BUNDLES ──────────────────────────────────────────
          ListView(
            padding: const EdgeInsets.all(14),
            children: [
              _SectionLabel('ZCOIN BUNDLES', 'Premium currency for the Shop'),
              if (_kCheatsEnabled) _DebugGrantPanel(game: game),
              _WatchAdCard(game: game),
              const SizedBox(height: 8),
              ...IapService.packages.map((pkg) => _CrystalCard(pkg: pkg, game: game)),
              const SizedBox(height: 24),
            ],
          ),

          // ── STARTER PACK ──────────────────────────────────────
          ListView(
            padding: const EdgeInsets.all(14),
            children: [
              _SectionLabel('STARTER PACKS', 'One-time purchase bundles'),
              ...StarterPack.all.map((pack) => _PackCard(pack: pack, game: game)),
              const SizedBox(height: 24),
            ],
          ),

          // ── SKINS ─────────────────────────────────────────────
          _CosmeticsInlineTab(game: game),

          // ── TITLES ────────────────────────────────────────────
          ListView(
            padding: const EdgeInsets.all(14),
            children: [
              _SectionLabel('TITLES & FRAMES', 'Cosmetic flair for your hero'),
              ...CosmeticItem.all.map((item) => _CosmeticCard(item: item, game: game)),
              const SizedBox(height: 24),
            ],
          ),

          // ── VIP ───────────────────────────────────────────────
          ListView(
            padding: const EdgeInsets.all(14),
            children: [
              _SectionLabel('VIP SUBSCRIPTIONS', 'Recurring perks and benefits'),
              ...SubscriptionTier.all.map((sub) => _SubCard(sub: sub, game: game)),
              const SizedBox(height: 16),
              if (IapService.platformSupported) ...[
                _RestorePurchasesButton(game: game),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title, this.subtitle);
  final String title, subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2, color: AppTheme.accentGold)),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  const _PackCard({required this.pack, required this.game});
  final StarterPack pack;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final bought = game.purchasedPacks.contains(pack.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [pack.color.withValues(alpha: 0.12), const Color(0xFF1a1816)]),
        border: Border.all(color: bought ? const Color(0xFF44cc88) : pack.color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(children: [
        Text(pack.icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(child: Tooltip(
          message: pack.contents.entries.map((e) => '${_icon(e.key)} ${e.value} ${e.key}').join('\n'),
          triggerMode: TooltipTriggerMode.tap,
          preferBelow: false,
          textStyle: const TextStyle(fontSize: 12, color: Colors.white),
          decoration: BoxDecoration(
            color: const Color(0xFF2a2030),
            border: Border.all(color: const Color(0xFFcc88ff).withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(pack.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: pack.color))),
              const Icon(Icons.info_outline, size: 14, color: AppTheme.textMuted),
            ]),
            Text(pack.description, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            const SizedBox(height: 4),
            Wrap(spacing: 8, children: pack.contents.entries.map((e) =>
              Text('${_icon(e.key)} ${e.value}', style: TextStyle(fontSize: 10, color: pack.color)),
            ).toList()),
          ],
        ))),
        if (bought)
          const Text('OWNED', style: TextStyle(fontSize: 10, color: Color(0xFF44cc88), fontWeight: FontWeight.bold))
        else
          ElevatedButton(
            onPressed: () {
              if (pack.productId != null && game.iapService.storeAvailable) {
                game.iapService.buyNonConsumable(pack.productId!);
              } else if (kDebugMode) {
                game.purchaseStarterPack(pack.id);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Store unavailable — try again later.'),
                  backgroundColor: Color(0xFF442222),
                  duration: Duration(seconds: 2),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: pack.color.withValues(alpha: 0.2),
              foregroundColor: pack.color,
              side: BorderSide(color: pack.color),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Builder(builder: (ctx) {
              final storePrice = pack.productId != null ? game.iapService.priceFor(pack.productId!) : '';
              return Text(storePrice.isNotEmpty ? storePrice : pack.price,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold));
            }),
          ),
      ]),
    );
  }

  String _icon(String key) => switch (key) {
    'zcoins'  => '🪙',
    'gold'      => '💰',
    'shards'    => '◆',
    'essence'   => '✦',
    'mythril'   => '⬡',
    'echoes'    => '🔊',
    'gemShards' => '💠',
    _           => '•',
  };
}

class _CrystalCard extends StatelessWidget {
  const _CrystalCard({required this.pkg, required this.game});
  final CrystalPackage pkg;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1225),
        border: Border.all(color: const Color(0xFFffcc44).withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        const ZCoinIcon(size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(pkg.label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFffcc44)))),
        ElevatedButton(
          onPressed: () {
            if (game.iapService.storeAvailable) {
              game.iapService.buyConsumable(pkg.productId);
            } else if (kDebugMode) {
              game.grantCrystals(pkg.zcoins);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Store unavailable — try again later.'),
                backgroundColor: Color(0xFF442222),
                duration: Duration(seconds: 2),
              ));
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFcc88ff).withValues(alpha: 0.15),
            foregroundColor: const Color(0xFFcc88ff),
            side: const BorderSide(color: Color(0xFFcc88ff)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: Builder(builder: (ctx) {
            final storePrice = game.iapService.priceFor(pkg.productId);
            return Text(storePrice.isNotEmpty ? storePrice : pkg.fallbackPrice,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold));
          }),
        ),
      ]),
    );
  }
}

class _SubCard extends StatelessWidget {
  const _SubCard({required this.sub, required this.game});
  final SubscriptionTier sub;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final active = (sub.id == 'sub_premium' && game.hasPremium) ||
                   (sub.id == 'sub_speed' && game.hasSpeedSub);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [sub.color.withValues(alpha: 0.10), const Color(0xFF1a1816)]),
        border: Border.all(color: active ? const Color(0xFF44cc88) : sub.color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(sub.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(child: Text(sub.name,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: sub.color))),
            if (active)
              const Text('ACTIVE', style: TextStyle(fontSize: 10, color: Color(0xFF44cc88), fontWeight: FontWeight.bold))
            else
              Text(sub.price, style: TextStyle(fontSize: 12, color: sub.color, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          ...sub.perks.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(children: [
              Text('✓ ', style: TextStyle(fontSize: 10, color: sub.color)),
              Text(p, style: const TextStyle(fontSize: 10, color: Colors.white70)),
            ]),
          )),
          if (!active) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (sub.productId != null && game.iapService.storeAvailable) {
                    game.iapService.buyNonConsumable(sub.productId!);
                  } else if (kDebugMode) {
                    if (sub.id == 'sub_speed') {
                      game.activateSpeedSub(30);
                    } else {
                      game.activatePremium(30);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Store unavailable — try again later.'),
                      backgroundColor: Color(0xFF442222),
                      duration: Duration(seconds: 2),
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: sub.color.withValues(alpha: 0.15),
                  foregroundColor: sub.color,
                  side: BorderSide(color: sub.color),
                ),
                child: Builder(builder: (ctx) {
                  final storePrice = sub.productId != null ? game.iapService.priceFor(sub.productId!) : '';
                  final displayPrice = storePrice.isNotEmpty ? storePrice : sub.price;
                  return Text('SUBSCRIBE  $displayPrice',
                      style: AppTheme.pixelHeading(fontSize: 11, color: sub.color));
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CosmeticCard extends StatelessWidget {
  const _CosmeticCard({required this.item, required this.game});
  final CosmeticItem item;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final owned = game.ownedCosmetics.contains(item.id);
    final equipped = switch (item.type) {
      CosmeticType.title     => game.activeTitle == item.name,
      CosmeticType.nameColor => game.activeNameColor == item.id,
      CosmeticType.frame     => game.activeFrame == item.id,
    };
    final canAfford = game.zcoins >= item.zcoinCost;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: equipped ? item.color.withValues(alpha: 0.08) : const Color(0xFF1a1816),
        border: Border.all(color: equipped ? item.color : owned ? const Color(0xFF44cc88).withValues(alpha: 0.4) : AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        Text(item.icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: item.color)),
            Text(item.description, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
          ],
        )),
        if (equipped)
          Text('EQUIPPED', style: TextStyle(fontSize: 9, color: item.color, fontWeight: FontWeight.bold))
        else if (owned)
          GestureDetector(
            onTap: () => game.equipCosmetic(item.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF44cc88)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text('EQUIP', style: TextStyle(fontSize: 9, color: Color(0xFF44cc88), fontWeight: FontWeight.bold)),
            ),
          )
        else
          GestureDetector(
            onTap: canAfford ? () => game.purchaseCosmetic(item.id) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: canAfford ? item.color.withValues(alpha: 0.1) : Colors.transparent,
                border: Border.all(color: canAfford ? item.color : AppTheme.cardBorder),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                ZCoinIcon(size: 11, animate: false),
                const SizedBox(width: 3),
                Text('${item.zcoinCost}',
                    style: TextStyle(fontSize: 10, color: canAfford ? item.color : AppTheme.cardBorder, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
      ]),
    );
  }
}

// ─── Watch Ad card ────────────────────────────────────────────────────────────

class _WatchAdCard extends StatefulWidget {
  const _WatchAdCard({required this.game});
  final GameState game;
  @override State<_WatchAdCard> createState() => _WatchAdCardState();
}

class _WatchAdCardState extends State<_WatchAdCard> {
  bool _watching = false;
  bool _cooldown = false;
  int _adsToday = 0;
  static const int _maxAdsPerDay = 5;
  static const int _rewardPerAd  = 20;

  void _watchAd() async {
    if (_watching || _cooldown || _adsToday >= _maxAdsPerDay) return;
    setState(() => _watching = true);

    await AdService.instance.showRewardedAd(
      onRewarded: () {
        if (!mounted) return;
        _adsToday++;
        widget.game.grantCrystals(_rewardPerAd);
        setState(() { _watching = false; _cooldown = true; });
        _showRewardBox();
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) setState(() => _cooldown = false);
        });
      },
      onFailed: () {
        if (mounted) setState(() => _watching = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No ad available right now — try again later.'),
          backgroundColor: Color(0xFF2A2623),
          duration: Duration(seconds: 3),
        ));
      },
    );
  }

  void _showRewardBox() {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _AdRewardDialog(amount: _rewardPerAd),
    );
  }

  @override
  Widget build(BuildContext context) {
    final done = _adsToday >= _maxAdsPerDay;
    final color = done ? AppTheme.cardBorder : const Color(0xFF44dd88);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: done ? AppTheme.cardBg : const Color(0xFF0a1a0a),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        Text(done ? '✓' : '📺', style: TextStyle(fontSize: 22, color: color)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Watch an Ad',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          Text(done
              ? 'Come back tomorrow for more free ZCoins!'
              : 'Earn $_rewardPerAd ZCoins per ad  •  ${_maxAdsPerDay - _adsToday}/$_maxAdsPerDay remaining',
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ])),
        if (!done)
          ElevatedButton(
            onPressed: (_watching || _cooldown) ? null : _watchAd,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0a2a0a),
              foregroundColor: color,
              side: BorderSide(color: color),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              disabledBackgroundColor: AppTheme.cardBg,
            ),
            child: _watching
                ? const SizedBox(width: 14, height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF44dd88)))
                : Text(_cooldown ? 'WAIT...' : 'WATCH',
                    style: AppTheme.pixelHeading(fontSize: 10, color: color)),
          ),
      ]),
    );
  }
}

// ─── Ad Reward Dialog ─────────────────────────────────────────────────────────

class _AdRewardDialog extends StatelessWidget {
  const _AdRewardDialog({required this.amount});
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1A17),
          border: Border.all(color: const Color(0xFFcc8844), width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🪙', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('REWARD EARNED',
              style: AppTheme.pixelHeading(
                  fontSize: 13, letterSpacing: 2, color: AppTheme.accentGold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF2a1f00),
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('+$amount ZCoins',
                style: AppTheme.pixelHeading(
                    fontSize: 22, color: AppTheme.accentGold)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              child: Text('COLLECT',
                  style: AppTheme.pixelHeading(
                      fontSize: 12, letterSpacing: 1, color: Colors.black)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Restore Purchases ────────────────────────────────────────────────────────

class _RestorePurchasesButton extends StatefulWidget {
  const _RestorePurchasesButton({required this.game});
  final GameState game;
  @override State<_RestorePurchasesButton> createState() => _RestorePurchasesButtonState();
}

class _RestorePurchasesButtonState extends State<_RestorePurchasesButton> {
  bool _restoring = false;

  Future<void> _restore() async {
    if (_restoring) return;
    setState(() => _restoring = true);
    await widget.game.iapService.restorePurchases();
    if (mounted) {
      setState(() => _restoring = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Purchases restored. Any active subscriptions or packs have been re-applied.'),
        backgroundColor: Color(0xFF1a2a1a),
        duration: Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: _restoring ? null : _restore,
        child: _restoring
            ? const SizedBox(width: 14, height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.textMuted))
            : const Text('Restore Purchases',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted,
                    decoration: TextDecoration.underline)),
      ),
    );
  }
}

// ─── Cosmetics inline tab (replaces the old "browse" card) ───────────────────

class _CosmeticsInlineTab extends StatelessWidget {
  const _CosmeticsInlineTab({required this.game});
  final GameState game;

  static const _sections = [
    ('✨', 'AURAS',   'Equip a battle aura for your hero',               Color(0xFF66ccff)),
    ('🎨', 'SKINS',   'Palette skins that recolour your hero sprite',    Color(0xFFcc88ff)),
    ('🐾', 'PETS',    'Battle companions with passive bonuses',           Color(0xFF66dd88)),
    ('⚡', 'BOOSTS',  'Waystones, attack effects & character slots',      Color(0xFFffcc44)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      children: [
        _cosmeticSection(context, 0, CosmeticsAurasSection(game: game, scrollable: false)),
        _cosmeticSection(context, 1, CosmeticsSkinsSection(game: game, scrollable: false)),
        _cosmeticSection(context, 2, CosmeticsPetsSection(game: game, scrollable: false)),
        _cosmeticSection(context, 3, CosmeticsBoostsSection(game: game, scrollable: false)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _cosmeticSection(BuildContext context, int idx, Widget content) {
    final (icon, label, sublabel, color) = _sections[idx];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1916),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.18), Colors.transparent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
              border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.25))),
            ),
            child: Row(children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label,
                    style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 2, color: color)),
                Text(sublabel,
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              ]),
            ]),
          ),
          // Section content (no own scroll view)
          Padding(
            padding: const EdgeInsets.all(12),
            child: content,
          ),
        ],
      ),
    );
  }
}

class _DebugGrantPanel extends StatefulWidget {
  const _DebugGrantPanel({required this.game});
  final GameState game;
  @override
  State<_DebugGrantPanel> createState() => _DebugGrantPanelState();
}

class _DebugGrantPanelState extends State<_DebugGrantPanel> {
  GameState get g => widget.game;

  void _do(VoidCallback fn) { fn(); setState(() {}); }

  Widget _section(String label, Color color, List<(String, VoidCallback)> btns) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 10, color: color, letterSpacing: 1, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: btns.map((b) => OutlinedButton(
          onPressed: () => _do(b.$2),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: color),
            foregroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(b.$1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        )).toList()),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1a0d),
        border: Border.all(color: const Color(0xFF44cc88).withValues(alpha: 0.7)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.science, color: Color(0xFF44cc88), size: 14),
          SizedBox(width: 6),
          Text('DEBUG GRANTS', style: TextStyle(fontSize: 11, color: Color(0xFF44cc88), letterSpacing: 2, fontWeight: FontWeight.bold)),
        ]),
        const Divider(color: Color(0xFF44cc88), height: 16),

        _section('CAMPAIGN  (Stage ${g.campaignStageIndex + 1})', const Color(0xFFff6644), [
          ('UNLOCK REBIRTH', () => g.debugSkipToFinalBoss()),
        ]),

        _section('HERO LEVEL  (Lv ${g.hero.level})', const Color(0xFF44cc88), [
          ('+1',   () => g.debugGrantLevels(1)),
          ('+5',   () => g.debugGrantLevels(5)),
          ('+10',  () => g.debugGrantLevels(10)),
          ('→100', () => g.debugGrantLevels(100)),
        ]),

        _section('GOLD  (${g.gold})', const Color(0xFFffcc44), [
          ('+10K',  () => g.debugGrantGold(10000)),
          ('+100K', () => g.debugGrantGold(100000)),
          ('+1M',   () => g.debugGrantGold(1000000)),
          ('+10M',  () => g.debugGrantGold(10000000)),
        ]),

        _section('SHARDS  (${g.shards})', const Color(0xFF6699ff), [
          ('+100',  () => g.debugGrantShards(100)),
          ('+500',  () => g.debugGrantShards(500)),
          ('+2000', () => g.debugGrantShards(2000)),
        ]),

        _section('ECHOES  (${g.echoes})', const Color(0xFFcc88ff), [
          ('+50',  () => g.debugGrantEchoes(50)),
          ('+200', () => g.debugGrantEchoes(200)),
          ('+500', () => g.debugGrantEchoes(500)),
        ]),

        _section('ESSENCE  (${g.essence})', const Color(0xFF88ffcc), [
          ('+50',  () => g.debugGrantEssence(50)),
          ('+200', () => g.debugGrantEssence(200)),
          ('+500', () => g.debugGrantEssence(500)),
        ]),

        _section('MYTHRIL  (${g.mythril})', const Color(0xFFffaa44), [
          ('+10',  () => g.debugGrantMythril(10)),
          ('+50',  () => g.debugGrantMythril(50)),
          ('+200', () => g.debugGrantMythril(200)),
        ]),

        _section('ZCOINS  (${g.zcoins})', const Color(0xFFffcc00), [
          ('+100',  () => g.debugGrantZCoins(100)),
          ('+500',  () => g.debugGrantZCoins(500)),
          ('+2000', () => g.debugGrantZCoins(2000)),
        ]),

        _section('PRESTIGE SOULS  (${g.prestigeSouls})', const Color(0xFFdddddd), [
          ('+10',  () => g.debugGrantPrestigeSouls(10)),
          ('+50',  () => g.debugGrantPrestigeSouls(50)),
          ('+200', () => g.debugGrantPrestigeSouls(200)),
        ]),
        _section('TOWER SHARDS  (${g.towerShards})', const Color(0xFFee88ff), [
          ('+5',   () => g.debugGrantTowerShards(5)),
          ('+20',  () => g.debugGrantTowerShards(20)),
          ('+100', () => g.debugGrantTowerShards(100)),
        ]),
      ]),
    );
  }
}

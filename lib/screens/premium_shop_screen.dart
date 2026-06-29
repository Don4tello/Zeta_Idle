import 'package:flutter/material.dart';
import '../models/shop_catalog.dart';
import '../services/game_state.dart';
import '../services/iap_service.dart';
import '../theme/app_theme.dart';

class PremiumShopScreen extends StatelessWidget {
  const PremiumShopScreen({super.key});

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
              const Text('💎', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text('${game.crystals}',
                  style: AppTheme.pixelHeading(fontSize: 13, color: const Color(0xFFcc88ff))),
            ]),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // ── Starter Packs ──────────────────────────────────────
          _SectionLabel('STARTER PACKS', 'One-time purchase bundles'),
          ...StarterPack.all.map((pack) => _PackCard(pack: pack, game: game)),

          const SizedBox(height: 20),

          // ── Crystal Bundles ────────────────────────────────────
          _SectionLabel('CRYSTAL BUNDLES', 'Premium currency'),
          ...IapService.packages.map((pkg) => _CrystalCard(pkg: pkg, game: game)),

          const SizedBox(height: 20),

          // ── Subscriptions ─────────────────────────────────────
          _SectionLabel('SUBSCRIPTIONS', 'Recurring perks'),
          ...SubscriptionTier.all.map((sub) => _SubCard(sub: sub, game: game)),

          const SizedBox(height: 20),

          // ── Cosmetics ─────────────────────────────────────────
          _SectionLabel('COSMETICS', 'Titles, name colors, and frames'),
          ...CosmeticItem.all.map((item) => _CosmeticCard(item: item, game: game)),

          const SizedBox(height: 24),
        ],
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
      child: Tooltip(
        message: pack.contents.entries.map((e) => '${e.value} ${e.key}').join('\n'),
        child: Row(children: [
        Text(pack.icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pack.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: pack.color)),
            Text(pack.description, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            const SizedBox(height: 4),
            Wrap(spacing: 8, children: pack.contents.entries.map((e) =>
              Text('${_icon(e.key)} ${e.value}', style: TextStyle(fontSize: 10, color: pack.color)),
            ).toList()),
          ],
        )),
        if (bought)
          const Text('OWNED', style: TextStyle(fontSize: 10, color: Color(0xFF44cc88), fontWeight: FontWeight.bold))
        else
          ElevatedButton(
            onPressed: () {
              if (pack.productId != null && game.iapService.storeAvailable) {
                game.iapService.buyNonConsumable(pack.productId!);
              } else {
                game.purchaseStarterPack(pack.id);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: pack.color.withValues(alpha: 0.2),
              foregroundColor: pack.color,
              side: BorderSide(color: pack.color),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(pack.price, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
      ]),
      ),
    );
  }

  String _icon(String key) => switch (key) {
    'crystals'  => '💎',
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
        border: Border.all(color: const Color(0xFFcc88ff).withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        const Text('💎', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(child: Text(pkg.label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFcc88ff)))),
        ElevatedButton(
          onPressed: () {
              if (game.iapService.storeAvailable) {
                game.iapService.buyConsumable(pkg.productId);
              } else {
                game.grantCrystals(pkg.crystals);
              }
            },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFcc88ff).withValues(alpha: 0.15),
            foregroundColor: const Color(0xFFcc88ff),
            side: const BorderSide(color: Color(0xFFcc88ff)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: Text(pkg.fallbackPrice, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
    final active = sub.id == 'sub_premium' && game.hasPremium;
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
                  } else {
                    final days = sub.id == 'sub_speed' ? 7 : 30;
                    game.activatePremium(days);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: sub.color.withValues(alpha: 0.15),
                  foregroundColor: sub.color,
                  side: BorderSide(color: sub.color),
                ),
                child: Text('SUBSCRIBE  ${sub.price}',
                    style: AppTheme.pixelHeading(fontSize: 11, color: sub.color)),
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
    final canAfford = game.crystals >= item.crystalCost;

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
              child: Text('💎 ${item.crystalCost}',
                  style: TextStyle(fontSize: 10, color: canAfford ? item.color : AppTheme.cardBorder, fontWeight: FontWeight.bold)),
            ),
          ),
      ]),
    );
  }
}

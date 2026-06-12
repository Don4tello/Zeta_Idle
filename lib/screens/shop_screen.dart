import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: ItemSlot.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('MERCHANT', style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: _GoldBadge(gold: game.gold),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelStyle: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 1),
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.accentGold,
          tabs: ItemSlot.values.map((s) => Tab(text: s.label.toUpperCase())).toList(),
        ),
      ),
      body: Column(
        children: [
          // Reroll bar
          _RerollBar(game: game, onRerolled: () => setState(() {})),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: ItemSlot.values
                  .map((slot) => _SlotTab(slot: slot, game: game))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reroll bar ────────────────────────────────────────────────────────────────

class _RerollBar extends StatelessWidget {
  const _RerollBar({required this.game, required this.onRerolled});
  final GameState game;
  final VoidCallback onRerolled;

  @override
  Widget build(BuildContext context) {
    final canAfford = game.shards >= GameState.shopRerollCost;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF231F1B),
        border: Border(bottom: BorderSide(color: AppTheme.cardBorder)),
      ),
      child: Row(
        children: [
          const Icon(Icons.sync, color: AppTheme.textMuted, size: 14),
          const SizedBox(width: 6),
          const Text('Stock refreshes daily at midnight.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          const Spacer(),
          TextButton(
            onPressed: canAfford
                ? () {
                    game.rerollShop();
                    onRerolled();
                  }
                : null,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6699ff),
              disabledForegroundColor: AppTheme.cardBorder,
              side: BorderSide(color: canAfford ? const Color(0xFF6699ff) : AppTheme.cardBorder),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('REROLL  ', style: AppTheme.pixelHeading(fontSize: 10,
                    color: canAfford ? const Color(0xFF6699ff) : AppTheme.cardBorder)),
                Text('${GameState.shopRerollCost} ◆',
                    style: TextStyle(fontSize: 11,
                        color: canAfford ? const Color(0xFF6699ff) : AppTheme.cardBorder,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Per-slot tab ──────────────────────────────────────────────────────────────

class _SlotTab extends StatelessWidget {
  const _SlotTab({required this.slot, required this.game});
  final ItemSlot slot;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final items = game.shopItemsForSlot(slot);
    if (items.isEmpty) {
      return const Center(
        child: Text('All items in this category sold out.',
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _ShopItemCard(item: items[i], game: game),
    );
  }
}

// ── Item card ─────────────────────────────────────────────────────────────────

class _ShopItemCard extends StatelessWidget {
  const _ShopItemCard({required this.item, required this.game});
  final EquipmentItem item;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final price     = game.shopPriceFor(item);
    final canAfford = game.gold >= price;
    final bagFull   = game.inventory.bag.length >= game.inventory.bagCapacity;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(color: item.rarityColor.withValues(alpha: 0.5), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Rarity indicator
          Container(
            width: 4,
            height: 56,
            decoration: BoxDecoration(
              color: item.rarityColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(item.name,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                            color: item.rarityColor)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: item.rarityColor.withValues(alpha: 0.12),
                      border: Border.all(color: item.rarityColor.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(item.rarityLabel,
                        style: TextStyle(fontSize: 10, color: item.rarityColor)),
                  ),
                ]),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: item.bonuses.map((b) {
                    final equipped = game.inventory.equipped[item.slot];
                    final equVal   = equipped?.bonuses
                        .where((e) => e.stat == b.stat)
                        .fold(0, (s, e) => s + e.value) ?? 0;
                    final diff     = b.value - equVal;
                    final diffStr  = equipped == null ? '' : (diff > 0 ? ' (+$diff)' : diff < 0 ? ' ($diff)' : ' (=)');
                    final diffColor = diff > 0
                        ? const Color(0xFF66cc44)
                        : diff < 0
                            ? const Color(0xFFcc5544)
                            : AppTheme.textMuted;
                    return RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${_statName(b.stat)} +${b.value}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                          ),
                          if (equipped != null)
                            TextSpan(
                              text: diffStr,
                              style: TextStyle(fontSize: 11, color: diffColor),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                if (item.keyword != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text('✦ ${item.keyword!.label}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFFFD700))),
                  ),
                const SizedBox(height: 2),
                Text('Req. Lv ${item.levelRequired}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              _GoldCost(gold: price, affordable: canAfford),
              const SizedBox(height: 6),
              TextButton(
                onPressed: (canAfford && !bagFull) ? () => _buy(context) : null,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accentGold,
                  disabledForegroundColor: AppTheme.cardBorder,
                  side: BorderSide(
                      color: (canAfford && !bagFull) ? AppTheme.accentGold : AppTheme.cardBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(bagFull ? 'BAG FULL' : 'BUY',
                    style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 1,
                        color: (canAfford && !bagFull) ? AppTheme.accentGold : AppTheme.cardBorder)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _buy(BuildContext context) {
    final success = game.buyShopItem(item);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Purchased ${item.name}!',
            style: const TextStyle(color: AppTheme.accentGold)),
        backgroundColor: const Color(0xFF2A2623),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  String _statName(ItemStat s) => switch (s) {
    ItemStat.strength     => 'STR',
    ItemStat.dexterity    => 'DEX',
    ItemStat.constitution => 'CON',
    ItemStat.intelligence => 'INT',
    ItemStat.wisdom       => 'WIS',
    ItemStat.charisma     => 'CHA',
    ItemStat.attackBonus  => 'ATK',
    ItemStat.damageBonus  => 'DMG',
    ItemStat.armorClass   => 'AC',
    ItemStat.maxHpPct        => 'MaxHP%',
    ItemStat.goldPct         => 'Gold%',
    ItemStat.xpPct           => 'XP%',
    ItemStat.elemPenetration => 'PEN%',
  };
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _GoldBadge extends StatelessWidget {
  const _GoldBadge({required this.gold});
  final int gold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withValues(alpha: 0.08),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💰', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(_fmt(gold),
              style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 0,
                  color: AppTheme.accentGold)),
        ],
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _GoldCost extends StatelessWidget {
  const _GoldCost({required this.gold, required this.affordable});
  final int gold;
  final bool affordable;

  @override
  Widget build(BuildContext context) {
    final color = affordable ? AppTheme.accentGold : const Color(0xFF884444);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('💰', style: TextStyle(fontSize: 13, color: color)),
        const SizedBox(width: 3),
        Text('$gold', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

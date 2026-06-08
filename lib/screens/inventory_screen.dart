import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../models/gem.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key, this.embedded = false});
  final bool embedded;
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with TickerProviderStateMixin {
  late TabController _outerTabs; // EQUIPMENT | BAG
  late TabController _tabs;      // stash pages within BAG

  @override
  void initState() {
    super.initState();
    _outerTabs = TabController(length: 2, vsync: this);
    _tabs      = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _outerTabs.dispose();
    _tabs.dispose();
    super.dispose();
  }

  void _rebuildTabs(int tabCount) {
    if (_tabs.length != tabCount) {
      final old = _tabs;
      _tabs = TabController(
        length: tabCount,
        vsync: this,
        initialIndex: old.index.clamp(0, tabCount - 1),
      );
      old.dispose();
    }
  }

  // ── Shared action header ──────────────────────────────────────────────────

  Widget _actionHeader(BuildContext ctx, GameState game, List<dynamic> bag, int cap) {
    return Container(
      color: const Color(0xFF141828),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Row(children: [
        Text('(${bag.length}/$cap)',
            style: AppTheme.pixelHeading(
                fontSize: 10, letterSpacing: 1, color: AppTheme.accentGold)),
        const Spacer(),
        if (game.canBuyStashTab) ...[
          GestureDetector(
            onTap: () { final ok = game.purchaseStashTab(); if (ok) setState(() {}); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF44ddcc).withValues(alpha: 0.1),
                border: Border.all(color: const Color(0xFF44ddcc).withValues(alpha: 0.6)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('💎', style: TextStyle(fontSize: 10)),
                const SizedBox(width: 4),
                Text('+ TAB  ${game.nextStashTabCost}',
                    style: AppTheme.pixelHeading(fontSize: 8, color: const Color(0xFF44ddcc))),
              ]),
            ),
          ),
          const SizedBox(width: 8),
        ],
        GestureDetector(
          onTap: () { game.autoEquipBestItems(); setState(() {}); },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.08),
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text('AUTO EQUIP',
                style: AppTheme.pixelHeading(fontSize: 8, color: AppTheme.accentGold)),
          ),
        ),
      ]),
    );
  }

  // ── EQUIPMENT tab — scrollable character doll ─────────────────────────────

  Widget _equipmentTab(GameState game) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: _EquippedGrid(game: game),
    );
  }

  // ── BAG tab — stash grid with optional stash-page sub-tabs ───────────────

  Widget _bagTab(GameState game, int tabCount, List<dynamic> bag, int cap) {
    final stashBar = tabCount > 1
        ? TabBar(
            controller: _tabs,
            isScrollable: tabCount > 3,
            labelStyle: AppTheme.pixelHeading(fontSize: 9, letterSpacing: 1),
            unselectedLabelColor: AppTheme.textMuted,
            indicatorColor: AppTheme.accentGold,
            tabs: List.generate(tabCount, (i) {
              final start = i * 20;
              final end   = (start + 20).clamp(0, bag.length);
              return Tab(text: 'TAB ${i + 1}  (${end - start})');
            }),
          )
        : null;

    return Column(children: [
      if (stashBar != null) stashBar,
      Expanded(
        child: tabCount > 1
            ? TabBarView(
                controller: _tabs,
                children: List.generate(tabCount, (i) => _BagGrid(
                  game: game,
                  startIndex: i * 20,
                  endIndex: ((i + 1) * 20).clamp(0, cap),
                )),
              )
            : _BagGrid(game: game, startIndex: 0, endIndex: 20),
      ),
    ]);
  }

  // ── Shared inner tab bar + views ──────────────────────────────────────────

  Widget _tabBody(GameState game, int tabCount, List<dynamic> bag, int cap) {
    return Column(children: [
      Container(
        color: const Color(0xFF0d1122),
        child: TabBar(
          controller: _outerTabs,
          labelStyle: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 1),
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.accentGold,
          tabs: [
            const Tab(text: 'EQUIPMENT'),
            Tab(text: 'BAG  (${bag.length}/$cap)'),
          ],
        ),
      ),
      Expanded(
        child: TabBarView(
          controller: _outerTabs,
          children: [
            _equipmentTab(game),
            _bagTab(game, tabCount, bag, cap),
          ],
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final game     = GameStateProvider.of(context);
    final tabCount = game.stashTabCount;
    _rebuildTabs(tabCount);
    final bag   = game.inventory.bag;
    final cap   = game.inventory.bagCapacity;

    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _actionHeader(context, game, bag, cap),
          Expanded(child: _tabBody(game, tabCount, bag, cap)),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0a0e27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1f3a),
        title: Text('INVENTORY', style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () { game.autoEquipBestItems(); setState(() {}); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.08),
                  border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text('AUTO EQUIP',
                    style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.accentGold)),
              ),
            ),
          ),
          if (game.canBuyStashTab)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () { final ok = game.purchaseStashTab(); if (ok) setState(() {}); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF44ddcc).withValues(alpha: 0.1),
                    border: Border.all(color: const Color(0xFF44ddcc).withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('💎', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Text('+ TAB  ${game.nextStashTabCost}',
                        style: AppTheme.pixelHeading(fontSize: 9, color: const Color(0xFF44ddcc))),
                  ]),
                ),
              ),
            ),
        ],
      ),
      body: _tabBody(game, tabCount, bag, cap),
    );
  }
}

// ── Character doll — equipment slots arranged around an implied silhouette ────
//
//  [hero info]  [helmet]   [amulet]
//  [weapon]     [armor]    [off-hand]
//  [ring]       [pants]    [ring2]
//  [gloves]     [boots]    [relic]

class _EquippedGrid extends StatelessWidget {
  const _EquippedGrid({required this.game});
  final GameState game;

  static const _layout = <ItemSlot?>[
    null,            ItemSlot.helmet, ItemSlot.amulet,
    ItemSlot.weapon, ItemSlot.armor,  ItemSlot.offHand,
    ItemSlot.ring,   ItemSlot.pants,  ItemSlot.ring2,
    ItemSlot.gloves, ItemSlot.boots,  ItemSlot.relic,
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 0.95,
      ),
      itemCount: _layout.length,
      itemBuilder: (ctx, i) {
        final slot = _layout[i];
        if (slot == null) {
          return _HeroCell(game: game);
        }
        final item = game.inventory.equipped[slot];
        return _DollSlot(
          slot: slot,
          item: item,
          onTap: item != null
              ? () => _showEquippedOptions(ctx, slot, item)
              : null,
        );
      },
    );
  }

  void _showEquippedOptions(BuildContext context, ItemSlot slot, EquipmentItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1f3a),
      isScrollControlled: true,
      builder: (_) => _ItemDetailSheet(
        item: item,
        game: game,
        actions: [
          _SheetAction(
            label: 'Unequip',
            color: AppTheme.textMuted,
            onTap: () {
              game.unequipSlot(slot);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _HeroCell extends StatelessWidget {
  const _HeroCell({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final classInfo = game.hero.heroClass.info;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0a0d20),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(classInfo.icon, color: AppTheme.accentGold, size: 22),
          const SizedBox(height: 4),
          Text(
            game.hero.name,
            style: const TextStyle(
              color: AppTheme.accentGold,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            'Lv ${game.hero.level}  ${classInfo.displayName}',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 7),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DollSlot extends StatelessWidget {
  const _DollSlot({required this.slot, required this.item, this.onTap});

  final ItemSlot      slot;
  final EquipmentItem? item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasItem     = item != null;
    final borderColor = hasItem ? item!.rarityColor : const Color(0xFF2a2e3f);
    final bgColor     = hasItem
        ? item!.rarityColor.withValues(alpha: 0.08)
        : const Color(0xFF0d1020);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: hasItem ? 1.5 : 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: hasItem ? _equippedContent() : _emptyContent(),
      ),
    );
  }

  Widget _equippedContent() {
    final rarityColor = item!.rarityColor;
    final isSet       = item!.setId != null;
    final badge       = isSet ? '◈' : item!.rarityLabel[0];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Slot icon + rarity badge in a row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(slot.icon, style: const TextStyle(fontSize: 14)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              color: rarityColor.withValues(alpha: 0.2),
              child: Text(badge,
                  style: TextStyle(fontSize: 7, color: rarityColor)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          item!.name,
          style: TextStyle(
            fontSize: 8,
            color: rarityColor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (item!.bonuses.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            _bonusSummary(),
            style: const TextStyle(fontSize: 7, color: Colors.white54),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _emptyContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(slot.icon,
            style: const TextStyle(fontSize: 22, color: Colors.white24)),
        const SizedBox(height: 4),
        Text(
          slot.label.toUpperCase(),
          style: AppTheme.pixelHeading(
              fontSize: 7, color: Colors.white24, letterSpacing: 0.5),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _bonusSummary() {
    final parts = item!.bonuses.take(2).map((b) => '+${b.value}${_short(b.stat)}').toList();
    if (item!.gem != null) parts.add('${item!.gem!.type.emoji}');
    return parts.join('  ');
  }

  String _short(ItemStat s) => switch (s) {
    ItemStat.attackBonus  => 'ATK',
    ItemStat.damageBonus  => 'DMG',
    ItemStat.armorClass   => 'AC',
    ItemStat.maxHpPct     => '%HP',
    ItemStat.goldPct      => '%G',
    ItemStat.xpPct        => '%XP',
    ItemStat.strength     => 'PWR',
    ItemStat.dexterity    => 'AGI',
    ItemStat.constitution => 'VIT',
    ItemStat.intelligence => 'ARC',
    ItemStat.wisdom       => 'FOC',
    ItemStat.charisma     => 'FOR',
  };
}

class _BagGrid extends StatelessWidget {
  const _BagGrid({required this.game, required this.startIndex, required this.endIndex});
  final GameState game;
  final int startIndex;
  final int endIndex;

  @override
  Widget build(BuildContext context) {
    final bag   = game.inventory.bag;
    // Items in this tab's range
    final items = <EquipmentItem?>[];
    for (var i = startIndex; i < endIndex; i++) {
      items.add(i < bag.length ? bag[i] : null);
    }
    if (items.isEmpty || items.every((e) => e == null)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No items in this tab.', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        if (item == null) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF080c1e),
              border: Border.all(color: AppTheme.cardBorder.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }
        final bagIndex = startIndex + i;
        return GestureDetector(
          onTap: () => _showBagOptions(context, game, bagIndex, item),
          child: _ItemTile(item: item, slotLabel: item.slot.label.toUpperCase()),
        );
      },
    );
  }

  void _showBagOptions(BuildContext context, GameState game, int index, EquipmentItem item) {
    final equipped = game.inventory.equipped[item.slot];

    // Auto-equip immediately when the slot is empty
    if (equipped == null) {
      game.equipItem(item);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Equipped ${item.name}',
          style: TextStyle(color: item.rarityColor, fontWeight: FontWeight.bold),
        ),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: const Color(0xFF1a1f3a),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
      ));
      return;
    }

    // Show comparison sheet when slot already has an item
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1f3a),
      isScrollControlled: true,
      builder: (_) => _ItemDetailSheet(
        item: item,
        game: game,
        compareWith: equipped,
        actions: [
          _SheetAction(
            label: 'Equip',
            color: AppTheme.accentGold,
            onTap: () {
              game.equipItem(item);
              Navigator.pop(context);
            },
          ),
          _SheetAction(
            label: 'Discard',
            color: const Color(0xFFcc4444),
            onTap: () {
              game.discardBagItem(index);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.slotLabel, this.onTap});
  final EquipmentItem? item;
  final String slotLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasItem = item != null;
    final borderColor = hasItem ? item!.rarityColor : AppTheme.cardBorder;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF0e1225),
          border: Border.all(color: borderColor, width: hasItem ? 1.5 : 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: hasItem
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          slotLabel,
                          style: AppTheme.pixelHeading(fontSize: 8, color: AppTheme.textMuted, letterSpacing: 1),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        color: item!.rarityColor.withValues(alpha: 0.2),
                        child: Text(
                          item!.setId != null ? '◈' : item!.rarityLabel[0],
                          style: TextStyle(fontSize: 8, color: item!.rarityColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item!.name,
                    style: TextStyle(fontSize: 10, color: item!.rarityColor, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  ...item!.bonuses.map((b) => Text(
                    '+${b.value} ${_statLabel(b.stat)}',
                    style: const TextStyle(fontSize: 9, color: AppTheme.textLight),
                  )),
                  if (item!.gem != null)
                    Text('${item!.gem!.type.emoji} +${item!.gem!.value}',
                        style: TextStyle(fontSize: 9, color: item!.gem!.color)),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, size: 16, color: AppTheme.cardBorder),
                  const SizedBox(height: 4),
                  Text(slotLabel, style: AppTheme.pixelHeading(fontSize: 8, color: AppTheme.textMuted, letterSpacing: 1)),
                ],
              ),
      ),
    );
  }

  String _statLabel(ItemStat stat) {
    switch (stat) {
      case ItemStat.attackBonus:  return 'ATK';
      case ItemStat.damageBonus:  return 'DMG';
      case ItemStat.armorClass:   return 'AC';
      case ItemStat.maxHpPct:     return '% HP';
      case ItemStat.goldPct:      return '% GOLD';
      case ItemStat.xpPct:        return '% XP';
      case ItemStat.strength:     return 'PWR';
      case ItemStat.dexterity:    return 'AGI';
      case ItemStat.constitution: return 'VIT';
      case ItemStat.intelligence: return 'ARC';
      case ItemStat.wisdom:       return 'FOC';
      case ItemStat.charisma:     return 'FOR';
    }
  }
}

class _SheetAction {
  const _SheetAction({required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _ItemDetailSheet extends StatefulWidget {
  const _ItemDetailSheet({required this.item, required this.actions, required this.game, this.compareWith});
  final EquipmentItem item;
  final List<_SheetAction> actions;
  final GameState game;
  final EquipmentItem? compareWith;
  @override
  State<_ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends State<_ItemDetailSheet> {
  EquipmentItem get item       => widget.item;
  List<_SheetAction> get actions => widget.actions;
  GameState get game            => widget.game;
  EquipmentItem? get compareWith => widget.compareWith;

  @override
  Widget build(BuildContext context) {
    // Build stat maps for comparison
    final newStats  = <ItemStat, int>{for (final b in widget.item.bonuses) b.stat: b.value};
    final equStats  = compareWith != null
        ? <ItemStat, int>{for (final b in compareWith!.bonuses) b.stat: b.value}
        : <ItemStat, int>{};
    // All stats mentioned in either item
    final allStats  = {...newStats.keys, ...equStats.keys}.toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: name + rarity badge
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: item.rarityColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: item.rarityColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(item.rarityLabel,
                    style: TextStyle(fontSize: 10, color: item.rarityColor)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${item.slot.label.toUpperCase()}  ·  Req Lv ${item.levelRequired}',
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),

          // Set badge
          if (item.setId != null && item.itemSet != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.itemSet!.color.withValues(alpha: 0.08),
                border: Border.all(color: item.itemSet!.color.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '◈ ${item.itemSet!.name} Set',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: item.itemSet!.color,
                    ),
                  ),
                  const SizedBox(height: 3),
                  ...item.itemSet!.tiers.map((tier) => Text(
                    tier.label,
                    style: TextStyle(fontSize: 10, color: item.itemSet!.color.withValues(alpha: 0.8)),
                  )),
                ],
              ),
            ),
          ],

          // Keyword badge for legendary
          if (item.keyword != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.08),
                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✦ ${item.keyword!.label}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.keyword!.description,
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Comparison header if applicable
          if (compareWith != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(child: Text('STAT', style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1))),
                  Text('NEW', style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.textLight, letterSpacing: 1)),
                  const SizedBox(width: 32),
                  Text('EQPD', style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1)),
                  const SizedBox(width: 32),
                  SizedBox(width: 36, child: Text('DIFF', style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1), textAlign: TextAlign.right)),
                ],
              ),
            ),

          // Stat rows
          ...allStats.map((stat) {
            final nv   = newStats[stat] ?? 0;
            final ev   = equStats[stat] ?? 0;
            final diff = nv - ev;
            final diffColor = diff > 0
                ? const Color(0xFF66cc44)
                : diff < 0
                    ? const Color(0xFFcc4444)
                    : AppTheme.textMuted;
            final diffStr = diff > 0 ? '+$diff' : '$diff';

            if (compareWith == null) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.add, size: 12, color: Color(0xFF88cc44)),
                    const SizedBox(width: 4),
                    Text('+$nv ${_statName(stat)}',
                        style: const TextStyle(fontSize: 13, color: AppTheme.textLight)),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_statName(stat),
                        style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
                  ),
                  SizedBox(
                    width: 36,
                    child: Text(nv > 0 ? '+$nv' : (nv == 0 && equStats.containsKey(stat) ? '—' : '+$nv'),
                        style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    child: Text(ev > 0 ? '+$ev' : '—',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    child: Text(diff != 0 ? diffStr : '=',
                        style: TextStyle(fontSize: 12, color: diffColor, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right),
                  ),
                ],
              ),
            );
          }),

          // Equipped item keyword (shown below if different)
          if (compareWith?.keyword != null && compareWith!.keyword != item.keyword)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                '✦ Equipped has: ${compareWith!.keyword!.label}',
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
              ),
            ),

          const SizedBox(height: 14),

          // ── Gem socket ────────────────────────────────────────────────
          _GemSocketRow(item: item, game: game, onChanged: () => setState(() {})),

          const SizedBox(height: 14),
          Row(
            children: actions.map((a) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: TextButton(
                onPressed: a.onTap,
                style: TextButton.styleFrom(
                  foregroundColor: a.color,
                  side: BorderSide(color: a.color),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(a.label, style: AppTheme.pixelHeading(fontSize: 11, color: a.color)),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  String _statName(ItemStat s) => switch (s) {
    ItemStat.strength     => 'PWR',
    ItemStat.dexterity    => 'AGI',
    ItemStat.constitution => 'VIT',
    ItemStat.intelligence => 'ARC',
    ItemStat.wisdom       => 'FOC',
    ItemStat.charisma     => 'FOR',
    ItemStat.attackBonus  => 'ATK',
    ItemStat.damageBonus  => 'DMG',
    ItemStat.armorClass   => 'AC',
    ItemStat.maxHpPct     => 'MaxHP%',
    ItemStat.goldPct      => 'Gold%',
    ItemStat.xpPct        => 'XP%',
  };
}

// ── Gem socket row ────────────────────────────────────────────────────────────

class _GemSocketRow extends StatelessWidget {
  const _GemSocketRow({required this.item, required this.game, required this.onChanged});
  final EquipmentItem item;
  final GameState game;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final gem = item.gem;
    final borderColor = gem != null ? gem.color : AppTheme.cardBorder;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: gem != null ? gem.color.withValues(alpha: 0.05) : const Color(0xFF0e1225),
        border: Border.all(color: borderColor.withValues(alpha: gem != null ? 0.5 : 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        Text(gem != null ? gem.type.emoji : '◯',
            style: TextStyle(fontSize: gem != null ? 20 : 16, color: gem != null ? null : AppTheme.textMuted)),
        const SizedBox(width: 10),
        Expanded(child: gem != null
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(gem.name,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: gem.color)),
                Text('+${gem.value} ${gem.type.statDescription.replaceFirst('+', '').trim()}',
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              ])
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Empty Socket',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                Text(game.gemBag.isEmpty
                    ? 'Craft gems in Forge → Gems tab'
                    : '${game.gemBag.length} gem(s) available to socket',
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              ]),
        ),
        if (gem != null) ...[
          GestureDetector(
            onTap: () => _confirmRemove(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFcc4444).withValues(alpha: 0.6)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text('REMOVE', style: TextStyle(fontSize: 9, color: Color(0xFFcc6666))),
            ),
          ),
          const SizedBox(width: 6),
        ],
        if (game.gemBag.isNotEmpty)
          GestureDetector(
            onTap: () => _showGemPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.08),
                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(gem != null ? 'REPLACE' : 'SOCKET',
                  style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.accentGold)),
            ),
          ),
      ]),
    );
  }

  void _showGemPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1f3a),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, ctrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(children: [
                Expanded(child: Text('Choose a gem to socket into ${item.name}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textLight))),
              ]),
            ),
            const Divider(color: AppTheme.cardBorder, height: 1),
            Expanded(
              child: ListView.separated(
                controller: ctrl,
                padding: const EdgeInsets.all(12),
                itemCount: game.gemBag.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (ctx, i) {
                  final gem = game.gemBag[i];
                  return GestureDetector(
                    onTap: () {
                      if (item.gem != null) {
                        // confirm replace
                        Navigator.pop(ctx);
                        _confirmReplace(context, gem);
                      } else {
                        game.socketGem(item, gem);
                        Navigator.pop(ctx);
                        onChanged();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0e1225),
                        border: Border.all(color: gem.color.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(children: [
                        Text(gem.type.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(gem.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: gem.color)),
                            Text(gem.type.statDescription, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                          ],
                        )),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: gem.tier.color.withValues(alpha: 0.12),
                            border: Border.all(color: gem.tier.color.withValues(alpha: 0.4)),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text('+${gem.value}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: gem.tier.color)),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: Text('Remove Gem?', style: AppTheme.pixelHeading(fontSize: 13, color: const Color(0xFFcc4444))),
        content: Text(
          '${item.gem!.name} will be destroyed. Gems cannot be recovered once removed.',
          style: const TextStyle(fontSize: 12, color: AppTheme.textLight, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: AppTheme.pixelHeading(fontSize: 10, color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              game.unsocketGem(item);
              Navigator.pop(context);
              onChanged();
            },
            child: Text('DESTROY', style: AppTheme.pixelHeading(fontSize: 10, color: const Color(0xFFcc4444))),
          ),
        ],
      ),
    );
  }

  void _confirmReplace(BuildContext context, Gem newGem) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: Text('Replace Gem?', style: AppTheme.pixelHeading(fontSize: 13, color: AppTheme.accentGold)),
        content: Text(
          '${item.gem!.name} will be destroyed and replaced with ${newGem.name}.',
          style: const TextStyle(fontSize: 12, color: AppTheme.textLight, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: AppTheme.pixelHeading(fontSize: 10, color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              game.socketGem(item, newGem);
              Navigator.pop(context);
              onChanged();
            },
            child: Text('REPLACE', style: AppTheme.pixelHeading(fontSize: 10, color: const Color(0xFFcc4444))),
          ),
        ],
      ),
    );
  }
}

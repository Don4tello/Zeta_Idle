import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../models/gem.dart';
import '../models/hero_ability.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/item_sprites.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key, this.embedded = false});
  final bool embedded;
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with TickerProviderStateMixin {
  late TabController _outerTabs; // EQUIPMENT | BAG
  late TabController _tabs; // stash pages within BAG

  @override
  void initState() {
    super.initState();
    _outerTabs = TabController(length: 2, vsync: this);
    _tabs = TabController(length: 1, vsync: this);
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

  Widget _actionHeader(
      BuildContext ctx, GameState game, List<dynamic> bag, int cap) {
    return Container(
      color: const Color(0xFF211E1A),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Row(children: [
        Text('(${bag.length}/$cap)',
            style: AppTheme.pixelHeading(
                fontSize: 11, letterSpacing: 1, color: AppTheme.accentGold)),
        const Spacer(),
        if (game.canBuyStashTab) ...[
          GestureDetector(
            onTap: () {
              final ok = game.purchaseStashTab();
              if (ok) setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF44ddcc).withValues(alpha: 0.1),
                border: Border.all(
                    color: const Color(0xFF44ddcc).withValues(alpha: 0.6)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('💎', style: TextStyle(fontSize: 11)),
                const SizedBox(width: 4),
                Text('+ TAB  ${game.nextStashTabCost}',
                    style: AppTheme.pixelHeading(
                        fontSize: 9, color: const Color(0xFF44ddcc))),
              ]),
            ),
          ),
          const SizedBox(width: 8),
        ],
        GestureDetector(
          onTap: () {
            game.autoEquipBestItems();
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.08),
              border:
                  Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text('AUTO EQUIP',
                style: AppTheme.pixelHeading(
                    fontSize: 9, color: AppTheme.accentGold)),
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
            labelStyle: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 1),
            unselectedLabelColor: AppTheme.textMuted,
            indicatorColor: AppTheme.accentGold,
            tabs: List.generate(tabCount, (i) {
              final start = i * 20;
              final end = (start + 20).clamp(0, bag.length);
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
                children: List.generate(
                    tabCount,
                    (i) => _BagGrid(
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
          labelStyle: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 1),
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
    final game = GameStateProvider.of(context);
    final tabCount = game.stashTabCount;
    _rebuildTabs(tabCount);
    final bag = game.inventory.bag;
    final cap = game.inventory.bagCapacity;

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
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('INVENTORY',
            style: AppTheme.pixelHeading(fontSize: 15, letterSpacing: 2)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () {
                game.autoEquipBestItems();
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.08),
                  border: Border.all(
                      color: AppTheme.accentGold.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text('AUTO EQUIP',
                    style: AppTheme.pixelHeading(
                        fontSize: 10, color: AppTheme.accentGold)),
              ),
            ),
          ),
          if (game.canBuyStashTab)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {
                  final ok = game.purchaseStashTab();
                  if (ok) setState(() {});
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF44ddcc).withValues(alpha: 0.1),
                    border: Border.all(
                        color: const Color(0xFF44ddcc).withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('💎', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text('+ TAB  ${game.nextStashTabCost}',
                        style: AppTheme.pixelHeading(
                            fontSize: 10, color: const Color(0xFF44ddcc))),
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

  // Slot positions as fractions of image size (left%, top%, width%, height%)
  // Row 1: weapon(L), helmet(C), amulet(R)
  // Row 2: armor(L), [silhouette], offhand(R)
  // Row 1: weapon(L), helmet(C), amulet(R)
  // Row 2: armor(L), [silhouette], offhand(R)
  // Row 3: gloves(L), [silhouette], legs(R)
  // Row 4: ring1(L), ring2(R)
  // Row 5: relic(L), shoes(R)
  static const _slotPositions = <ItemSlot, (double, double, double, double)>{
    ItemSlot.weapon: (0.10, 0.09, 0.10, 0.10),
    ItemSlot.helmet: (0.45, 0.094, 0.10, 0.10),
    ItemSlot.amulet: (0.80, 0.09, 0.10, 0.10),
    ItemSlot.armor: (0.10, 0.28, 0.10, 0.10),
    ItemSlot.offHand: (0.80, 0.28, 0.10, 0.10),
    ItemSlot.gloves: (0.10, 0.47, 0.10, 0.10),
    ItemSlot.pants: (0.80, 0.47, 0.10, 0.10),
    ItemSlot.ring: (0.10, 0.615, 0.10, 0.10),
    ItemSlot.ring2: (0.80, 0.615, 0.10, 0.10),
    ItemSlot.relic: (0.10, 0.775, 0.10, 0.10),
    ItemSlot.boots: (0.80, 0.775, 0.10, 0.10),
  };

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1440 / 1514,
      child: LayoutBuilder(builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          children: [
            // Background image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset('assets/images/equipment_layout.png',
                    fit: BoxFit.fill,
                    errorBuilder: (_, __, ___) =>
                        Container(color: const Color(0xFF1a1816))),
              ),
            ),
            // Slot overlays
            ..._slotPositions.entries.map((e) {
              final slot = e.key;
              final (lf, tf, wf, hf) = e.value;
              final item = game.inventory.equipped[slot];
              return Positioned(
                left: w * lf,
                top: h * tf,
                width: w * wf,
                height: h * hf,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: item != null
                      ? () => _showEquippedOptions(ctx, slot, item)
                      : null,
                  child: _PaperDollSlot(
                    slot: slot,
                    item: item,
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }

  void _showEquippedOptions(
      BuildContext context, ItemSlot slot, EquipmentItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2623),
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

class _PaperDollSlot extends StatelessWidget {
  const _PaperDollSlot({required this.slot, required this.item});
  final ItemSlot slot;
  final EquipmentItem? item;

  @override
  Widget build(BuildContext context) {
    final hasItem = item != null;
    return hasItem
        ? Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2a2520),
              border: Border.all(
                color: item!.rarityColor.withValues(alpha: 0.7),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.80,
                heightFactor: 0.80,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: Center(
                      child: ItemSprite(
                        slot: slot,
                        rarity: item!.rarity,
                        size: 32,
                        setColor: item!.rarity == ItemRarity.set
                            ? item!.rarityColor
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        : const SizedBox.expand();
  }
}

class _BagGrid extends StatelessWidget {
  const _BagGrid(
      {required this.game, required this.startIndex, required this.endIndex});
  final GameState game;
  final int startIndex;
  final int endIndex;

  @override
  Widget build(BuildContext context) {
    final bag = game.inventory.bag;
    // Items in this tab's range
    final items = <EquipmentItem?>[];
    for (var i = startIndex; i < endIndex; i++) {
      items.add(i < bag.length ? bag[i] : null);
    }
    if (items.isEmpty || items.every((e) => e == null)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No items in this tab.',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        if (item == null) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF080c1e),
              border:
                  Border.all(color: AppTheme.cardBorder.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }
        final bagIndex = startIndex + i;
        return GestureDetector(
          onTap: () => _showBagOptions(context, game, bagIndex, item),
          onLongPress: () async {
            if (item.locked) return;
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppTheme.cardBg,
                title: Text('Disenchant ${item.name}?',
                    style: const TextStyle(
                        color: AppTheme.accentGold, fontSize: 14)),
                content: Text('This will destroy the item for shards.',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('CANCEL',
                          style: TextStyle(color: AppTheme.textMuted))),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('DISENCHANT',
                          style: TextStyle(color: Color(0xFFff4444)))),
                ],
              ),
            );
            if (confirm == true) {
              final shards = game.disenchantItems([item]);
              if (shards > 0 && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Disenchanted ${item.name} → +$shards ◆'),
                  duration: const Duration(seconds: 2),
                ));
              }
            }
          },
          child:
              _ItemTile(item: item, slotLabel: item.slot.label.toUpperCase()),
        );
      },
    );
  }

  void _showBagOptions(
      BuildContext context, GameState game, int index, EquipmentItem item) {
    final equipped = game.inventory.equipped[item.slot];

    final cantEquip = !game.canEquip(item);
    final reason =
        item.requiredClass != null && item.requiredClass != game.hero.heroClass
            ? 'Requires ${item.requiredClass!.displayName}'
            : game.hero.level < item.levelRequired
                ? 'Requires Level ${item.levelRequired}'
                : item.rebirthRequired > 0 &&
                        game.prestigeLevel < item.rebirthRequired
                    ? 'Requires Rebirth ${item.rebirthRequired}'
                    : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2623),
      isScrollControlled: true,
      builder: (_) => _ItemDetailSheet(
        item: item,
        game: game,
        compareWith: equipped,
        actions: [
          _SheetAction(
            label: cantEquip ? (reason ?? 'Cannot Equip') : 'Equip',
            color: cantEquip ? const Color(0xFF884444) : AppTheme.accentGold,
            onTap: cantEquip
                ? null
                : () {
                    game.equipItem(item);
                    Navigator.pop(context);
                  },
          ),
          _SheetAction(
            label: item.locked ? 'Unlock 🔓' : 'Lock 🔒',
            color:
                item.locked ? const Color(0xFF44cc88) : const Color(0xFFffaa44),
            onTap: () {
              item.locked = !item.locked;
              game.saveToLocal();
              Navigator.pop(context);
            },
          ),
          if (!item.locked)
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
  const _ItemTile({required this.item, required this.slotLabel});
  final EquipmentItem? item;
  final String slotLabel;

  @override
  Widget build(BuildContext context) {
    final hasItem = item != null;
    final borderColor = hasItem ? item!.rarityColor : AppTheme.cardBorder;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2a2520),
        border: Border.all(
            color: borderColor.withValues(alpha: hasItem ? 0.7 : 0.3),
            width: 1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: hasItem
          ? Center(
              child: FractionallySizedBox(
                widthFactor: 0.80,
                heightFactor: 0.80,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: Center(
                      child: ItemSprite(
                        slot: item!.slot,
                        rarity: item!.rarity,
                        size: 32,
                        setColor: item!.rarity == ItemRarity.set
                            ? item!.rarityColor
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  String _statLabel(ItemStat stat) {
    switch (stat) {
      case ItemStat.attackBonus:
        return 'ATK';
      case ItemStat.damageBonus:
        return 'DMG';
      case ItemStat.armorClass:
        return 'AC';
      case ItemStat.maxHpPct:
        return '% HP';
      case ItemStat.goldPct:
        return '% GOLD';
      case ItemStat.xpPct:
        return '% XP';
      case ItemStat.strength:
        return 'PWR';
      case ItemStat.dexterity:
        return 'AGI';
      case ItemStat.constitution:
        return 'VIT';
      case ItemStat.intelligence:
        return 'ARC';
      case ItemStat.wisdom:
        return 'FOC';
      case ItemStat.charisma:
        return 'FOR';
      case ItemStat.elemPenetration:
        return 'PEN';
      case ItemStat.hitChance:
        return 'HIT%';
      case ItemStat.damagePercent:
        return 'DMG%';
    }
  }
}

class _SheetAction {
  const _SheetAction({required this.label, required this.color, this.onTap});
  final String label;
  final Color color;
  final VoidCallback? onTap;
}

class _ItemDetailSheet extends StatefulWidget {
  const _ItemDetailSheet(
      {required this.item,
      required this.actions,
      required this.game,
      this.compareWith});
  final EquipmentItem item;
  final List<_SheetAction> actions;
  final GameState game;
  final EquipmentItem? compareWith;
  @override
  State<_ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends State<_ItemDetailSheet> {
  EquipmentItem get item => widget.item;
  List<_SheetAction> get actions => widget.actions;
  GameState get game => widget.game;
  EquipmentItem? get compareWith => widget.compareWith;

  @override
  Widget build(BuildContext context) {
    // Build stat maps for comparison
    final newStats = <ItemStat, int>{
      for (final b in widget.item.bonuses) b.stat: b.value
    };
    final equStats = compareWith != null
        ? <ItemStat, int>{for (final b in compareWith!.bonuses) b.stat: b.value}
        : <ItemStat, int>{};
    // All stats mentioned in either item
    final allStats = {...newStats.keys, ...equStats.keys}.toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
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
                    fontSize: 17,
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
                    style: TextStyle(fontSize: 11, color: item.rarityColor)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${item.slot.label.toUpperCase()}  ·  ${item.requirementLabel}',
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),

          // Set badge
          if (item.setId != null && item.itemSet != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.itemSet!.color.withValues(alpha: 0.08),
                border: Border.all(
                    color: item.itemSet!.color.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '◈ ${item.itemSet!.name} Set',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: item.itemSet!.color,
                    ),
                  ),
                  const SizedBox(height: 3),
                  ...item.itemSet!.tiers.map((tier) => Text(
                        tier.label,
                        style: TextStyle(
                            fontSize: 11,
                            color: item.itemSet!.color.withValues(alpha: 0.8)),
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
                border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✦ ${item.keyword!.label}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.keyword!.description,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
          ],

          // Unique ability mod badge
          if (item.uniqueAbilityId != null) ...[
            const SizedBox(height: 8),
            Builder(builder: (ctx) {
              final wrongClass = item.requiredClass != null &&
                  item.requiredClass != game.hero.heroClass;
              final badgeColor = wrongClass
                  ? const Color(0xFFcc4444)
                  : const Color(0xFFFFD700);
              final classLabel = item.requiredClass?.displayName ?? 'Any';
              final modParts = <String>[];
              if (item.abilityValueMult != 1.0) {
                modParts.add('${item.abilityValueMult}× value');
              }
              if (item.abilityDurationAdd > 0) {
                modParts.add('+${item.abilityDurationAdd}r duration');
              }
              if (item.abilityCooldownFlat > 0) {
                modParts.add('−${item.abilityCooldownFlat} cooldown');
              }
              if (item.abilityExtraEffect != null) {
                final xe = item.abilityExtraEffect!;
                final xv = item.abilityExtraValue;
                final xd = item.abilityExtraDuration;
                modParts.add(switch (xe) {
                  AbilityEffect.stun => 'Stun ${xd}r',
                  AbilityEffect.dot => 'DoT $xv%/r for ${xd}r',
                  AbilityEffect.attackBonus => '+$xv ATK for ${xd}r',
                  AbilityEffect.acBonus => '+$xv AC for ${xd}r',
                  AbilityEffect.aura => 'Aura $xv% HP/r for ${xd}r',
                  AbilityEffect.debuffWeaken => 'Weaken $xv% for ${xd}r',
                  AbilityEffect.debuffVulnerable => 'Vuln $xv% for ${xd}r',
                  AbilityEffect.dodge => 'Dodge next hit',
                  AbilityEffect.heal => 'Heal $xv% HP',
                  AbilityEffect.bonusDamage => '+$xv bonus dmg',
                });
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.08),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('★ Unique — $classLabel only',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: badgeColor)),
                      if (wrongClass) ...[
                        const SizedBox(width: 6),
                        const Text('(wrong class)',
                            style: TextStyle(
                                fontSize: 10, color: Color(0xFFcc4444))),
                      ],
                    ]),
                    const SizedBox(height: 2),
                    Text(
                      'Enhances: ${item.uniqueAbilityId!.replaceAll('_', ' ')}',
                      style: TextStyle(
                          fontSize: 11,
                          color: badgeColor.withValues(alpha: 0.8)),
                    ),
                    if (modParts.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        modParts.join(' • '),
                        style: TextStyle(
                            fontSize: 11,
                            color: badgeColor.withValues(alpha: 0.8)),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 12),

          // Comparison header if applicable
          if (compareWith != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1612),
                border: Border.all(color: const Color(0xFF3a3020)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                children: [
                  Expanded(
                      child: Text('STAT',
                          style: AppTheme.pixelHeading(
                              fontSize: 9,
                              color: AppTheme.textMuted,
                              letterSpacing: 1))),
                  SizedBox(
                      width: 38,
                      child: Text('THIS',
                          style: AppTheme.pixelHeading(
                              fontSize: 9,
                              color: item.rarityColor,
                              letterSpacing: 1),
                          textAlign: TextAlign.center)),
                  const SizedBox(width: 6),
                  SizedBox(
                      width: 38,
                      child: Text('EQPD',
                          style: AppTheme.pixelHeading(
                              fontSize: 9,
                              color: AppTheme.textMuted,
                              letterSpacing: 1),
                          textAlign: TextAlign.center)),
                  const SizedBox(width: 6),
                  SizedBox(
                      width: 44,
                      child: Text('DIFF',
                          style: AppTheme.pixelHeading(
                              fontSize: 9,
                              color: AppTheme.textMuted,
                              letterSpacing: 1),
                          textAlign: TextAlign.right)),
                ],
              ),
            ),
            const SizedBox(height: 6),
          ],

          // Stat rows
          ...allStats.map((stat) {
            final nv = newStats[stat] ?? 0;
            final ev = equStats[stat] ?? 0;
            final diff = nv - ev;
            final diffColor = diff > 0
                ? const Color(0xFF55ee66)
                : diff < 0
                    ? const Color(0xFFee4444)
                    : AppTheme.textMuted;
            final diffStr = diff > 0 ? '+$diff' : '$diff';
            final diffIcon = diff > 0
                ? '▲'
                : diff < 0
                    ? '▼'
                    : '=';

            if (compareWith == null) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.add, size: 12, color: Color(0xFF88cc44)),
                    const SizedBox(width: 4),
                    Text('+$nv ${_statName(stat)}',
                        style: const TextStyle(
                            fontSize: 14, color: AppTheme.textLight)),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_statName(stat),
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textLight)),
                  ),
                  SizedBox(
                    width: 38,
                    child: Text(
                        nv > 0
                            ? '+$nv'
                            : (nv == 0 && equStats.containsKey(stat)
                                ? '—'
                                : '+$nv'),
                        style: TextStyle(
                            fontSize: 13,
                            color: nv > ev
                                ? const Color(0xFF55ee66)
                                : AppTheme.textLight,
                            fontWeight:
                                nv > ev ? FontWeight.bold : FontWeight.normal),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 38,
                    child: Text(ev > 0 ? '+$ev' : '—',
                        style: TextStyle(
                            fontSize: 13,
                            color: ev > nv
                                ? const Color(0xFF55ee66)
                                : AppTheme.textMuted),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 44,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: diff != 0
                        ? BoxDecoration(
                            color: diffColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(3),
                          )
                        : null,
                    child: Text(diff != 0 ? '$diffIcon $diffStr' : '=',
                        style: TextStyle(
                            fontSize: 11,
                            color: diffColor,
                            fontWeight: diff != 0
                                ? FontWeight.bold
                                : FontWeight.normal),
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            );
          }),

          // Equipped item keyword (shown below if different)
          if (compareWith?.keyword != null &&
              compareWith!.keyword != item.keyword)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                '✦ Equipped has: ${compareWith!.keyword!.label}',
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ),

          const SizedBox(height: 14),

          // ── Gem socket ────────────────────────────────────────────────
          _GemSocketRow(
              item: item, game: game, onChanged: () => setState(() {})),

          const SizedBox(height: 14),
          Row(
            children: actions
                .map((a) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: TextButton(
                        onPressed: a.onTap,
                        style: TextButton.styleFrom(
                          foregroundColor: a.color,
                          side: BorderSide(color: a.color),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: Text(a.label,
                            style: AppTheme.pixelHeading(
                                fontSize: 12, color: a.color)),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  String _statName(ItemStat s) => switch (s) {
        ItemStat.strength => 'PWR',
        ItemStat.dexterity => 'AGI',
        ItemStat.constitution => 'VIT',
        ItemStat.intelligence => 'ARC',
        ItemStat.wisdom => 'FOC',
        ItemStat.charisma => 'FOR',
        ItemStat.attackBonus => 'ATK',
        ItemStat.damageBonus => 'DMG',
        ItemStat.armorClass => 'AC',
        ItemStat.maxHpPct => 'MaxHP%',
        ItemStat.goldPct => 'Gold%',
        ItemStat.xpPct => 'XP%',
        ItemStat.elemPenetration => 'PEN%',
        ItemStat.hitChance => 'HIT%',
        ItemStat.damagePercent => 'DMG%',
      };
}

// ── Gem socket row ────────────────────────────────────────────────────────────

class _GemSocketRow extends StatelessWidget {
  const _GemSocketRow(
      {required this.item, required this.game, required this.onChanged});
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
        color: gem != null
            ? gem.color.withValues(alpha: 0.05)
            : const Color(0xFF231F1B),
        border: Border.all(
            color: borderColor.withValues(alpha: gem != null ? 0.5 : 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        Text(gem != null ? gem.type.emoji : '◯',
            style: TextStyle(
                fontSize: gem != null ? 20 : 16,
                color: gem != null ? null : AppTheme.textMuted)),
        const SizedBox(width: 10),
        Expanded(
          child: gem != null
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(gem.name,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: gem.color)),
                  Text(gem.bonusLabelFor(item.slot),
                      style: TextStyle(
                          fontSize: 11,
                          color: (item.slot == ItemSlot.weapon ||
                                  item.slot == ItemSlot.offHand)
                              ? const Color(0xFFff6644)
                              : const Color(0xFF66aaff))),
                ])
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Empty Socket',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.bold)),
                  Text(
                      game.gemBag.isEmpty
                          ? 'Craft gems in Forge → Gems tab'
                          : '${game.gemBag.length} gem(s) available to socket',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textMuted)),
                ]),
        ),
        if (gem != null) ...[
          GestureDetector(
            onTap: () => _confirmRemove(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(
                    color: const Color(0xFFcc4444).withValues(alpha: 0.6)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text('REMOVE',
                  style: TextStyle(fontSize: 10, color: Color(0xFFcc6666))),
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
                border: Border.all(
                    color: AppTheme.accentGold.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(gem != null ? 'REPLACE' : 'SOCKET',
                  style: AppTheme.pixelHeading(
                      fontSize: 10, color: AppTheme.accentGold)),
            ),
          ),
      ]),
    );
  }

  void _showGemPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2623),
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
                Expanded(
                    child: Text('Choose a gem to socket into ${item.name}',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textLight))),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF231F1B),
                        border:
                            Border.all(color: gem.color.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(children: [
                        Text(gem.type.emoji,
                            style: const TextStyle(fontSize: 21)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(gem.name,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: gem.color)),
                            Text(gem.type.elementLabel,
                                style: const TextStyle(
                                    fontSize: 11, color: AppTheme.textMuted)),
                          ],
                        )),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: gem.tier.color.withValues(alpha: 0.12),
                            border: Border.all(
                                color: gem.tier.color.withValues(alpha: 0.4)),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text('+${gem.value}',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: gem.tier.color)),
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
        backgroundColor: const Color(0xFF2A2623),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: Text('Remove Gem?',
            style: AppTheme.pixelHeading(
                fontSize: 14, color: const Color(0xFFcc4444))),
        content: Text(
          '${item.gem!.name} will be destroyed. Gems cannot be recovered once removed.',
          style: const TextStyle(
              fontSize: 13, color: AppTheme.textLight, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL',
                style: AppTheme.pixelHeading(
                    fontSize: 11, color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              game.unsocketGem(item);
              Navigator.pop(context);
              onChanged();
            },
            child: Text('DESTROY',
                style: AppTheme.pixelHeading(
                    fontSize: 11, color: const Color(0xFFcc4444))),
          ),
        ],
      ),
    );
  }

  void _confirmReplace(BuildContext context, Gem newGem) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2623),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: Text('Replace Gem?',
            style: AppTheme.pixelHeading(
                fontSize: 14, color: AppTheme.accentGold)),
        content: Text(
          '${item.gem!.name} will be destroyed and replaced with ${newGem.name}.',
          style: const TextStyle(
              fontSize: 13, color: AppTheme.textLight, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL',
                style: AppTheme.pixelHeading(
                    fontSize: 11, color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              game.socketGem(item, newGem);
              Navigator.pop(context);
              onChanged();
            },
            child: Text('REPLACE',
                style: AppTheme.pixelHeading(
                    fontSize: 11, color: const Color(0xFFcc4444))),
          ),
        ],
      ),
    );
  }
}

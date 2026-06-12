import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../models/gem.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class ForgeScreen extends StatefulWidget {
  const ForgeScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<ForgeScreen> createState() => _ForgeScreenState();
}

class _ForgeScreenState extends State<ForgeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);

    final tabBar = TabBar(
      controller: _tabs,
      labelStyle: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 1),
      unselectedLabelColor: AppTheme.textMuted,
      indicatorColor: AppTheme.accentGold,
      tabs: const [Tab(text: 'COMBINE'), Tab(text: 'DISENCHANT'), Tab(text: 'GEMS'), Tab(text: 'REFORGE')],
    );

    final tabView = TabBarView(
      controller: _tabs,
      children: [
        _CombineTab(game: game),
        _DisenchantTab(game: game),
        _GemsTab(game: game),
        _ReforgeTab(game: game),
      ],
    );

    if (widget.embedded) {
      return Container(
        color: const Color(0xFF1B1A17),
        child: Column(children: [
          Container(color: const Color(0xFF2A2623), child: tabBar),
          Expanded(child: tabView),
        ]),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('FORGE', style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
        bottom: tabBar,
      ),
      body: tabView,
    );
  }
}

// ── Combine tab ───────────────────────────────────────────────────────────────

class _CombineTab extends StatefulWidget {
  const _CombineTab({required this.game});
  final GameState game;

  @override
  State<_CombineTab> createState() => _CombineTabState();
}

class _CombineTabState extends State<_CombineTab> {
  ItemSlot _slot     = ItemSlot.weapon;
  ItemRarity _rarity = ItemRarity.common;
  final Set<String> _selected = {};

  List<EquipmentItem> get _eligible => widget.game.inventory.bag
      .where((i) => i.slot == _slot && i.rarity == _rarity)
      .toList();

  int get _needed => _rarity == ItemRarity.common
      ? widget.game.forgeCommonToRareCount
      : 2;

  bool get _canForge => _selected.length == _needed;

  @override
  void didUpdateWidget(covariant _CombineTab old) {
    super.didUpdateWidget(old);
    _selected.clear();
  }

  @override
  Widget build(BuildContext context) {
    final eligible = _eligible;
    final target   = _rarity == ItemRarity.common ? ItemRarity.rare : ItemRarity.epic;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe info banner
          _RecipeBanner(
            from: _rarity, to: target, needed: _needed,
            hasMasterForger: widget.game.prestigeShop.isUnlocked('forge_bonus'),
          ),
          const SizedBox(height: 14),

          // Slot picker
          Text('SLOT', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: ItemSlot.values.map((s) => _ChoiceChip(
              label: s.label.toUpperCase(),
              selected: _slot == s,
              onTap: () => setState(() { _slot = s; _selected.clear(); }),
            )).toList(),
          ),
          const SizedBox(height: 8),

          // Rarity picker
          Row(children: [
            Text('FROM  ', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
            _ChoiceChip(
              label: 'COMMON → RARE',
              selected: _rarity == ItemRarity.common,
              onTap: () => setState(() { _rarity = ItemRarity.common; _selected.clear(); }),
            ),
            const SizedBox(width: 8),
            _ChoiceChip(
              label: 'RARE → EPIC',
              selected: _rarity == ItemRarity.rare,
              onTap: () => setState(() { _rarity = ItemRarity.rare; _selected.clear(); }),
            ),
          ]),
          const SizedBox(height: 14),

          // Progress bar
          _SelectionProgress(selected: _selected.length, needed: _needed),
          const SizedBox(height: 12),

          // Item list
          if (eligible.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: Text(
                'No ${_rarity.name} ${_slot.name}s in your bag.',
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
            )
          else
            ...eligible.map((item) {
              final sel = _selected.contains(item.id);
              return _ForgeItemTile(
                item: item,
                selected: sel,
                onTap: () => setState(() {
                  if (sel) {
                    _selected.remove(item.id);
                  } else if (_selected.length < _needed) {
                    _selected.add(item.id);
                  }
                }),
              );
            }),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canForge ? () => _forge(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1a2a0a),
                foregroundColor: AppTheme.accentGold,
                disabledBackgroundColor: const Color(0xFF231F1B),
                disabledForegroundColor: AppTheme.cardBorder,
                side: BorderSide(color: _canForge ? AppTheme.accentGold : AppTheme.cardBorder),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                _canForge ? '🔥  FORGE  (${_selected.length}/$_needed selected)' : 'SELECT $_needed ITEMS TO FORGE',
                style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 1,
                    color: _canForge ? AppTheme.accentGold : AppTheme.cardBorder),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _forge(BuildContext context) {
    final items = widget.game.inventory.bag
        .where((i) => _selected.contains(i.id))
        .toList();
    final result = widget.game.forgeItems(items);
    setState(() => _selected.clear());
    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Forged: ${result.name} (${result.rarityLabel})!',
              style: const TextStyle(color: AppTheme.accentGold)),
          backgroundColor: const Color(0xFF2A2623),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

// ── Disenchant tab ────────────────────────────────────────────────────────────

class _DisenchantTab extends StatefulWidget {
  const _DisenchantTab({required this.game});
  final GameState game;

  @override
  State<_DisenchantTab> createState() => _DisenchantTabState();
}

class _DisenchantTabState extends State<_DisenchantTab> {
  final Set<String> _selected = {};

  int get _shardPreview => widget.game.inventory.bag
      .where((i) => _selected.contains(i.id))
      .fold(0, (sum, i) => sum + switch (i.rarity) {
        ItemRarity.common    => 3,
        ItemRarity.rare      => 8,
        ItemRarity.epic      => 20,
        ItemRarity.legendary => 60,
        ItemRarity.set       => 100,
      });

  @override
  Widget build(BuildContext context) {
    final bag = widget.game.inventory.bag;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2623),
              border: Border.all(color: AppTheme.cardBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DISENCHANT RATES',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted,
                        fontWeight: FontWeight.bold, letterSpacing: 1)),
                SizedBox(height: 6),
                Wrap(spacing: 8, runSpacing: 4, children: const [
                  _RateChip(label: 'Common',    value: '3 ◆',   color: Color(0xFFaaaaaa)),
                  _RateChip(label: 'Rare',      value: '8 ◆',   color: Color(0xFF6699ff)),
                  _RateChip(label: 'Epic',      value: '20 ◆',  color: Color(0xFFcc44ff)),
                  _RateChip(label: 'Legendary', value: '60 ◆',  color: Color(0xFFFFD700)),
                  _RateChip(label: 'Set',       value: '100 ◆', color: Color(0xFF00cc88)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (bag.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: const Text('Your bag is empty.',
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
            )
          else ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('BAG  (${bag.length} items)',
                  style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2)),
              TextButton(
                onPressed: () => setState(() {
                  if (_selected.length == bag.length) {
                    _selected.clear();
                  } else {
                    _selected.addAll(bag.map((i) => i.id));
                  }
                }),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textMuted,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _selected.length == bag.length ? 'Deselect all' : 'Select all',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            ...bag.map((item) {
              final sel = _selected.contains(item.id);
              return _ForgeItemTile(
                item: item,
                selected: sel,
                showShardValue: true,
                onTap: () => setState(() {
                  if (sel) _selected.remove(item.id);
                  else _selected.add(item.id);
                }),
              );
            }),
          ],
          const SizedBox(height: 16),
          // Confirm button
          if (_selected.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2623),
                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(children: [
                const Text('◆ ', style: TextStyle(fontSize: 17, color: AppTheme.accentGold)),
                Text('You will receive $_shardPreview shards',
                    style: const TextStyle(fontSize: 14, color: AppTheme.accentGold,
                        fontWeight: FontWeight.bold)),
              ]),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _disenchant(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1a0a0a),
                  foregroundColor: const Color(0xFFcc4444),
                  side: const BorderSide(color: Color(0xFFcc4444)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('DISENCHANT  ${_selected.length} ITEM(S)',
                    style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 1,
                        color: const Color(0xFFcc4444))),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _disenchant(BuildContext context) {
    final items = widget.game.inventory.bag
        .where((i) => _selected.contains(i.id))
        .toList();
    final earned = widget.game.disenchantItems(items);
    setState(() => _selected.clear());
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Disenchanted: +$earned ◆',
              style: const TextStyle(color: AppTheme.accentGold)),
          backgroundColor: const Color(0xFF2A2623),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _RecipeBanner extends StatelessWidget {
  const _RecipeBanner({
    required this.from, required this.to, required this.needed,
    required this.hasMasterForger,
  });
  final ItemRarity from;
  final ItemRarity to;
  final int needed;
  final bool hasMasterForger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2623),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          _RarityDot(rarity: from),
          Text(' ×$needed', style: const TextStyle(fontSize: 14, color: AppTheme.textLight)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.arrow_forward, size: 18, color: AppTheme.textMuted),
          ),
          _RarityDot(rarity: to),
          Text('  ×1 (random)',
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
          if (hasMasterForger && from == ItemRarity.common) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFcc8844).withValues(alpha: 0.15),
                border: Border.all(color: const Color(0xFFcc8844)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('Master Forger',
                  style: AppTheme.pixelHeading(fontSize: 9, color: const Color(0xFFcc8844))),
            ),
          ],
        ],
      ),
    );
  }
}

class _RarityDot extends StatelessWidget {
  const _RarityDot({required this.rarity});
  final ItemRarity rarity;

  static const _labels = {
    ItemRarity.common: 'Common',
    ItemRarity.rare:   'Rare',
    ItemRarity.epic:   'Epic',
  };
  static const _colors = {
    ItemRarity.common: Color(0xFFaaaaaa),
    ItemRarity.rare:   Color(0xFF6699ff),
    ItemRarity.epic:   Color(0xFFcc44ff),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[rarity]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(_labels[rarity]!, style: TextStyle(fontSize: 12, color: color)),
    );
  }
}

class _SelectionProgress extends StatelessWidget {
  const _SelectionProgress({required this.selected, required this.needed});
  final int selected;
  final int needed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('SELECTED', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2)),
          Text('$selected / $needed',
              style: TextStyle(
                  fontSize: 13,
                  color: selected == needed ? AppTheme.accentGold : AppTheme.textMuted,
                  fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: needed > 0 ? selected / needed : 0,
            minHeight: 4,
            backgroundColor: AppTheme.cardBorder,
            valueColor: AlwaysStoppedAnimation<Color>(
                selected == needed ? AppTheme.accentGold : const Color(0xFF4466cc)),
          ),
        ),
      ],
    );
  }
}

class _ForgeItemTile extends StatelessWidget {
  const _ForgeItemTile({
    required this.item,
    required this.selected,
    required this.onTap,
    this.showShardValue = false,
  });
  final EquipmentItem item;
  final bool selected;
  final VoidCallback onTap;
  final bool showShardValue;

  int get _shards => switch (item.rarity) {
    ItemRarity.common    => 3,
    ItemRarity.rare      => 8,
    ItemRarity.epic      => 20,
    ItemRarity.legendary => 60,
    ItemRarity.set       => 100,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? item.rarityColor.withValues(alpha: 0.08) : const Color(0xFF231F1B),
          border: Border.all(
            color: selected ? item.rarityColor : AppTheme.cardBorder,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: [
            // Rarity dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.rarityColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: TextStyle(fontSize: 14, color: item.rarityColor,
                          fontWeight: FontWeight.bold)),
                  Text(
                    item.bonuses.map((b) => '${b.stat.name} +${b.value}').join('  '),
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            if (showShardValue)
              Text('$_shards ◆',
                  style: const TextStyle(fontSize: 12, color: AppTheme.accentGold)),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.check_box : Icons.check_box_outline_blank,
              size: 18,
              color: selected ? item.rarityColor : AppTheme.cardBorder,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accentGold.withValues(alpha: 0.12) : const Color(0xFF231F1B),
          border: Border.all(color: selected ? AppTheme.accentGold : AppTheme.cardBorder),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                color: selected ? AppTheme.accentGold : AppTheme.textMuted,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}

class _RateChip extends StatelessWidget {
  const _RateChip({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 8, height: 8,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
      const SizedBox(width: 4),
      Text('$label → $value', style: TextStyle(fontSize: 11, color: color)),
    ]);
  }
}

// ── Gems tab ──────────────────────────────────────────────────────────────────

class _GemsTab extends StatefulWidget {
  const _GemsTab({required this.game});
  final GameState game;
  @override
  State<_GemsTab> createState() => _GemsTabState();
}

class _GemsTabState extends State<_GemsTab> {
  GemType _type = GemType.ruby;
  GemTier _tier = GemTier.flawed;

  @override
  Widget build(BuildContext context) {
    final game    = widget.game;
    final canCraft = game.gemShards >= _tier.shardCost && game.gemBag.length < GameState.gemBagMax;
    final previewGem = Gem(type: _type, tier: _tier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Shard counter ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF231F1B),
              border: Border.all(color: const Color(0xFF6688aa)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(children: [
              const Text('💠', style: TextStyle(fontSize: 19)),
              const SizedBox(width: 10),
              Text('GEM SHARDS',
                  style: AppTheme.pixelHeading(fontSize: 11, color: const Color(0xFF88aacc), letterSpacing: 2)),
              const Spacer(),
              Text('${game.gemShards}',
                  style: AppTheme.pixelHeading(fontSize: 17, color: const Color(0xFF88ddee))),
            ]),
          ),
          const SizedBox(height: 16),

          // ── Gem type picker ───────────────────────────────────────────
          Text('GEM TYPE', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1.1,
            children: GemType.values.map((t) {
              final sel = _type == t;
              return GestureDetector(
                onTap: () => setState(() => _type = t),
                child: Container(
                  decoration: BoxDecoration(
                    color: sel ? t.color.withValues(alpha: 0.15) : const Color(0xFF231F1B),
                    border: Border.all(color: sel ? t.color : AppTheme.cardBorder, width: sel ? 1.5 : 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t.emoji, style: const TextStyle(fontSize: 19)),
                      const SizedBox(height: 2),
                      Text(t.label, style: TextStyle(fontSize: 10, color: sel ? t.color : AppTheme.textMuted)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // ── Tier picker ───────────────────────────────────────────────
          Text('TIER', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          Row(children: GemTier.values.map((t) {
            final sel = _tier == t;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => setState(() => _tier = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? t.color.withValues(alpha: 0.12) : const Color(0xFF231F1B),
                      border: Border.all(color: sel ? t.color : AppTheme.cardBorder, width: sel ? 1.5 : 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        Text(t.label, style: TextStyle(fontSize: 10, color: sel ? t.color : AppTheme.textMuted),
                            textAlign: TextAlign.center),
                        Text('${t.shardCost} 💠', style: TextStyle(fontSize: 10, color: sel ? t.color : AppTheme.textMuted)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList()),
          const SizedBox(height: 14),

          // ── Preview card ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF231F1B),
              border: Border.all(color: _type.color.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(children: [
              Text(_type.emoji, style: const TextStyle(fontSize: 25)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(previewGem.name,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _type.color)),
                  Text(_type.statDescription,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
                  Text('+${previewGem.value}  •  ${_tier.shardCost} 💠 to craft',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                ],
              )),
            ]),
          ),
          const SizedBox(height: 10),

          // ── Craft button ──────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canCraft ? () {
                final ok = game.craftGem(_type, _tier);
                if (ok) setState(() {});
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0e1a0e),
                foregroundColor: AppTheme.accentGold,
                disabledBackgroundColor: const Color(0xFF231F1B),
                disabledForegroundColor: AppTheme.cardBorder,
                side: BorderSide(color: canCraft ? AppTheme.accentGold : AppTheme.cardBorder),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                game.gemBag.length >= GameState.gemBagMax
                    ? 'GEM BAG FULL (${game.gemBag.length}/${GameState.gemBagMax})'
                    : game.gemShards < _tier.shardCost
                        ? 'NEED ${_tier.shardCost - game.gemShards} MORE 💠'
                        : '✦  CRAFT  ${_tier.shardCost} 💠',
                style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 1,
                    color: canCraft ? AppTheme.accentGold : AppTheme.cardBorder),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Gem bag ───────────────────────────────────────────────────
          if (game.gemBag.isNotEmpty) ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('GEM BAG  (${game.gemBag.length}/${GameState.gemBagMax})',
                  style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2)),
              Text('Tap a gem to socket it into an item',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            ]),
            const SizedBox(height: 8),
            ...game.gemBag.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _GemBagTile(
                gem: e.value,
                index: e.key,
                game: game,
                onSocket: () => setState(() {}),
              ),
            )),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: const Text('No gems crafted yet. Craft one above!',
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
            ),
          ],

          // ── Gem info ──────────────────────────────────────────────────
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF231F1B),
              border: Border.all(color: AppTheme.cardBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HOW GEMS WORK', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
                const SizedBox(height: 6),
                const Text('• Gem shards drop from combat kills (25% chance) and bosses.\n'
                    '• Each item can hold 1 gem in its socket.\n'
                    '• Socket gems from this bag via the Inventory screen.\n'
                    '• Replacing or removing a gem destroys the old one.',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GemBagTile extends StatelessWidget {
  const _GemBagTile({required this.gem, required this.index, required this.game, required this.onSocket});
  final Gem gem;
  final int index;
  final GameState game;
  final VoidCallback onSocket;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSocketDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF231F1B),
          border: Border.all(color: gem.color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(children: [
          Text(gem.type.emoji, style: const TextStyle(fontSize: 21)),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(gem.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: gem.color)),
              Text(gem.type.statDescription, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            ],
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: gem.tier.color.withValues(alpha: 0.1),
              border: Border.all(color: gem.tier.color.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text('+${gem.value}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: gem.tier.color)),
          ),
          const SizedBox(width: 8),
          Icon(Icons.open_in_new, size: 14, color: AppTheme.textMuted),
        ]),
      ),
    );
  }

  void _showSocketDialog(BuildContext context) {
    final allItems = [
      ...game.inventory.equipped.values,
      ...game.inventory.bag,
    ];
    if (allItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No items to socket into.', style: TextStyle(color: AppTheme.accentGold)),
        backgroundColor: Color(0xFF2A2623),
      ));
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2623),
      isScrollControlled: true,
      builder: (_) => _SocketPickerSheet(gem: gem, items: allItems, game: game, onDone: onSocket),
    );
  }
}

class _SocketPickerSheet extends StatelessWidget {
  const _SocketPickerSheet({
    required this.gem,
    required this.items,
    required this.game,
    required this.onDone,
  });
  final Gem gem;
  final List<EquipmentItem> items;
  final GameState game;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, ctrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(children: [
              Text(gem.type.emoji, style: const TextStyle(fontSize: 23)),
              const SizedBox(width: 8),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Socket ${gem.name}',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: gem.color)),
                  Text('Choose an item to socket this gem into.',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                ],
              )),
            ]),
          ),
          const Divider(color: AppTheme.cardBorder, height: 1),
          Expanded(
            child: ListView.separated(
              controller: ctrl,
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (ctx, i) {
                final item = items[i];
                final hasGem = item.gem != null;
                return GestureDetector(
                  onTap: () {
                    if (hasGem) {
                      _confirmReplace(ctx, item);
                    } else {
                      game.socketGem(item, gem);
                      Navigator.pop(ctx);
                      onDone();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF231F1B),
                      border: Border.all(color: item.rarityColor.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: item.rarityColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style: TextStyle(fontSize: 13, color: item.rarityColor, fontWeight: FontWeight.bold)),
                          Text(item.slot.label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      )),
                      if (hasGem)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.gem!.color.withValues(alpha: 0.1),
                            border: Border.all(color: item.gem!.color.withValues(alpha: 0.4)),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text('${item.gem!.type.emoji} ${item.gem!.tier.label}',
                              style: TextStyle(fontSize: 10, color: item.gem!.color)),
                        )
                      else
                        const Icon(Icons.radio_button_unchecked, size: 14, color: AppTheme.textMuted),
                    ]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReplace(BuildContext context, EquipmentItem item) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2623),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: Text('Replace Gem?',
            style: AppTheme.pixelHeading(fontSize: 14, color: AppTheme.accentGold)),
        content: Text(
          '${item.gem!.name} will be destroyed and replaced with ${gem.name}. This cannot be undone.',
          style: const TextStyle(fontSize: 13, color: AppTheme.textLight, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              game.socketGem(item, gem);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close sheet
              onDone();
            },
            child: Text('REPLACE', style: AppTheme.pixelHeading(fontSize: 11, color: const Color(0xFFcc4444))),
          ),
        ],
      ),
    );
  }
}

// ── Reforge tab ───────────────────────────────────────────────────────────────

class _ReforgeTab extends StatefulWidget {
  const _ReforgeTab({required this.game});
  final GameState game;
  @override
  State<_ReforgeTab> createState() => _ReforgeTabState();
}

class _ReforgeTabState extends State<_ReforgeTab> {
  EquipmentItem? _selected;

  List<EquipmentItem> get _reforgeableItems {
    final all = <EquipmentItem>[
      ...widget.game.inventory.equipped.values,
      ...widget.game.inventory.bag,
    ];
    return all.where((i) => ItemLootTable.canReforge(i.rarity)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final items = _reforgeableItems;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1225),
            border: Border.all(color: const Color(0xFFaa66ff).withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('REFORGE', style: AppTheme.pixelHeading(fontSize: 12, color: const Color(0xFFaa66ff), letterSpacing: 2)),
              const SizedBox(height: 6),
              const Text('Reroll all stat values on an item. Stats stay the same — only the numbers change.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              const SizedBox(height: 8),
              for (final r in [ItemRarity.rare, ItemRarity.epic, ItemRarity.legendary]) ...[
                _CostRow(rarity: r),
                if (r != ItemRarity.legendary) const SizedBox(height: 3),
              ],
            ],
          ),
        ),

        // Item picker
        if (items.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No rare, epic, or legendary items in inventory.',
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted), textAlign: TextAlign.center),
            ),
          )
        else ...[
          Text('SELECT ITEM', style: AppTheme.pixelHeading(fontSize: 10, color: AppTheme.textMuted, letterSpacing: 1)),
          const SizedBox(height: 8),
          ...items.map((item) {
            final isSelected = _selected?.id == item.id;
            return GestureDetector(
              onTap: () => setState(() => _selected = item),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? item.rarityColor.withValues(alpha: 0.12) : const Color(0xFF231F1B),
                  border: Border.all(
                    color: isSelected ? item.rarityColor : item.rarityColor.withValues(alpha: 0.3),
                    width: isSelected ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Container(width: 3, height: 36,
                        decoration: BoxDecoration(color: item.rarityColor, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: item.rarityColor)),
                          const SizedBox(height: 2),
                          Text(item.bonuses.map((b) => '${_sn(b.stat)} +${b.value}').join('  '),
                              style: const TextStyle(fontSize: 11, color: Colors.white54)),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: item.rarityColor, size: 16),
                  ],
                ),
              ),
            );
          }),

          // Reforge button
          if (_selected != null) ...[
            const SizedBox(height: 16),
            _ReforgeButton(
              item: _selected!,
              game: game,
              onReforged: (item) => setState(() => _selected = item),
            ),
          ],
        ],
      ],
    );
  }

  String _sn(ItemStat s) => switch (s) {
    ItemStat.attackBonus  => 'ATK',
    ItemStat.damageBonus  => 'DMG',
    ItemStat.armorClass   => 'AC',
    ItemStat.strength     => 'PWR',
    ItemStat.dexterity    => 'AGI',
    ItemStat.constitution => 'VIT',
    ItemStat.intelligence => 'ARC',
    ItemStat.wisdom       => 'FOC',
    ItemStat.charisma     => 'FOR',
    ItemStat.maxHpPct        => 'HP%',
    ItemStat.goldPct         => 'Gold%',
    ItemStat.xpPct           => 'XP%',
    ItemStat.elemPenetration => 'PEN%',
  };
}

class _CostRow extends StatelessWidget {
  const _CostRow({required this.rarity});
  final ItemRarity rarity;

  @override
  Widget build(BuildContext context) {
    final cost = ItemLootTable.reforgeCost(rarity);
    final label = switch (rarity) {
      ItemRarity.rare      => 'Rare',
      ItemRarity.epic      => 'Epic',
      ItemRarity.legendary => 'Legendary',
      _ => '',
    };
    final color = switch (rarity) {
      ItemRarity.rare      => const Color(0xFF6699ff),
      ItemRarity.epic      => const Color(0xFFcc44ff),
      ItemRarity.legendary => const Color(0xFFFFD700),
      _ => Colors.white,
    };
    return Row(children: [
      Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
      const SizedBox(width: 6),
      Text('$label:', style: TextStyle(fontSize: 11, color: color)),
      const SizedBox(width: 6),
      Text('💰 ${cost.gold}  ◆ ${cost.shards}',
          style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
    ]);
  }
}

class _ReforgeButton extends StatefulWidget {
  const _ReforgeButton({required this.item, required this.game, required this.onReforged});
  final EquipmentItem item;
  final GameState game;
  final void Function(EquipmentItem) onReforged;
  @override
  State<_ReforgeButton> createState() => _ReforgeButtonState();
}

class _ReforgeButtonState extends State<_ReforgeButton> {
  bool _confirm = false;

  @override
  Widget build(BuildContext context) {
    final cost = ItemLootTable.reforgeCost(widget.item.rarity);
    final canAfford = widget.game.gold >= cost.gold && widget.game.shards >= cost.shards;

    if (_confirm) {
      return Row(children: [
        Expanded(
          child: TextButton(
            onPressed: canAfford ? () {
              widget.game.reforgeItem(widget.item);
              widget.onReforged(widget.item);
              setState(() => _confirm = false);
            } : null,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFaa66ff).withValues(alpha: 0.15),
              side: const BorderSide(color: Color(0xFFaa66ff)),
            ),
            child: Text('CONFIRM REFORGE', style: AppTheme.pixelHeading(fontSize: 11, color: const Color(0xFFaa66ff))),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => setState(() => _confirm = false),
          style: TextButton.styleFrom(side: const BorderSide(color: AppTheme.cardBorder)),
          child: Text('CANCEL', style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.textMuted)),
        ),
      ]);
    }

    return TextButton(
      onPressed: canAfford ? () => setState(() => _confirm = true) : null,
      style: TextButton.styleFrom(
        backgroundColor: canAfford ? const Color(0xFFaa66ff).withValues(alpha: 0.08) : Colors.transparent,
        side: BorderSide(color: canAfford ? const Color(0xFFaa66ff) : AppTheme.cardBorder),
        minimumSize: const Size(double.infinity, 44),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('REFORGE', style: AppTheme.pixelHeading(fontSize: 12,
            color: canAfford ? const Color(0xFFaa66ff) : AppTheme.cardBorder)),
        const SizedBox(height: 2),
        Text('💰 ${cost.gold}  ◆ ${cost.shards}',
            style: TextStyle(fontSize: 11,
                color: canAfford ? const Color(0xFFaa66ff).withValues(alpha: 0.7) : AppTheme.cardBorder)),
      ]),
    );
  }
}

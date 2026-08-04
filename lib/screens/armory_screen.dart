import 'package:flutter/material.dart';
import '../data/unique_items_data.dart';
import '../models/artifact.dart';
import '../models/dnd_class.dart';
import '../models/equipment.dart';
import '../models/hero_ability.dart' show AbilityEffect;
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/item_sprites.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ArmoryScreen — legendary & set item database for the current class
// ─────────────────────────────────────────────────────────────────────────────

class ArmoryScreen extends StatefulWidget {
  const ArmoryScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<ArmoryScreen> createState() => _ArmoryScreenState();
}

class _ArmoryScreenState extends State<ArmoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  EquipmentItem? _expanded;
  String? _expandedSet;
  String? _expandedArtifactSet;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final cls  = game.hero.heroClass;

    final body = Column(children: [
      Container(
        color: const Color(0xFF1C1916),
        child: TabBar(
          controller: _tabs,
          isScrollable: true,
          indicatorColor: AppTheme.accentGold,
          labelColor: AppTheme.accentGold,
          unselectedLabelColor: AppTheme.textMuted,
          labelStyle: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 1),
          tabs: const [
            Tab(text: 'UNIQUES'),
            Tab(text: 'MYTHIC'),
            Tab(text: 'SET ITEMS'),
            Tab(text: 'ARTIFACTS'),
          ],
        ),
      ),
      Expanded(
        child: TabBarView(
          controller: _tabs,
          children: [
            _LegendaryList(cls: cls, game: game,
                expanded: _expanded,
                onExpand: (i) => setState(() => _expanded = _expanded?.id == i?.id ? null : i)),
            _MythicList(game: game),
            _SetList(game: game,
                expanded: _expandedSet,
                onExpand: (id) => setState(() => _expandedSet = _expandedSet == id ? null : id)),
            _ArtifactSetList(game: game,
                expanded: _expandedArtifactSet,
                onExpand: (id) => setState(() =>
                    _expandedArtifactSet = _expandedArtifactSet == id ? null : id)),
          ],
        ),
      ),
    ]);

    if (widget.embedded) return body;
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('ARMORY',
            style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(cls.info.icon, size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 5),
              Text(cls.displayName.toUpperCase(),
                  style: AppTheme.pixelHeading(fontSize: 10, color: AppTheme.textMuted)),
            ]),
          ),
        ],
      ),
      body: body,
    );
  }
}

// ── Legendary list ────────────────────────────────────────────────────────────

class _LegendaryList extends StatelessWidget {
  const _LegendaryList({required this.cls, required this.game,
      required this.expanded, required this.onExpand});
  final DndClass cls;
  final GameState game;
  final EquipmentItem? expanded;
  final ValueChanged<EquipmentItem?> onExpand;

  @override
  Widget build(BuildContext context) {
    // Filter to class-specific items (includes class-neutral ones too if any)
    final items = UniqueItemsData.all
        .where((i) => i.requiredClass == null || i.requiredClass == cls)
        .toList()
      ..sort((a, b) => a.levelRequired.compareTo(b.levelRequired));

    if (items.isEmpty) {
      return const Center(
        child: Text('No legendaries for this class.',
            style: TextStyle(color: AppTheme.textMuted)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length + 1,
      itemBuilder: (ctx, i) {
        if (i == 0) return _legendaryHeader(items.length);
        final item = items[i - 1];
        final isOpen = expanded?.id == item.id;
        return _LegendaryCard(
          item: item,
          game: game,
          isOpen: isOpen,
          onTap: () => onExpand(isOpen ? null : item),
        );
      },
    );
  }

  Widget _legendaryHeader(int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a0a20),
        border: Border.all(color: const Color(0xFFE8A0FF).withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.auto_awesome, size: 18, color: Color(0xFFE8A0FF)),
          const SizedBox(width: 8),
          Text('$count Class Uniques',
              style: AppTheme.pixelHeading(fontSize: 12, color: const Color(0xFFE8A0FF))),
        ]),
        const SizedBox(height: 6),
        const Text(
          'Unique items are class-bound and dramatically enhance your abilities. '
          'Each amplifies a specific class ability. Drop rate: 2% per boss kill.',
          style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.5),
        ),
      ]),
    );
  }
}

class _LegendaryCard extends StatelessWidget {
  const _LegendaryCard({required this.item, required this.game,
      required this.isOpen, required this.onTap});
  final EquipmentItem item;
  final GameState game;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = const Color(0xFFE8A0FF); // unique lavender
    final ownedInBag = game.inventory.bag.any(
        (b) => b is EquipmentItem && b.rarity == ItemRarity.unique &&
            b.requiredClass == item.requiredClass &&
            b.name == item.name);
    final ownedEquipped = game.inventory.equipped.values.any(
        (e) => e.rarity == ItemRarity.unique && e.name == item.name);
    final owned = ownedInBag || ownedEquipped;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isOpen ? const Color(0xFF1a0820) : AppTheme.cardBg,
          border: Border.all(
              color: isOpen ? color : color.withValues(alpha: 0.3),
              width: isOpen ? 1.5 : 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header row
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              SizedBox(width: 32, height: 36,
                  child: ItemSprite(slot: item.slot, rarity: item.rarity, size: 30)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(item.name,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color))),
                  if (owned)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF44cc88).withValues(alpha: 0.15),
                        border: Border.all(color: const Color(0xFF44cc88)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text('OWNED',
                          style: TextStyle(fontSize: 7, color: Color(0xFF44cc88), fontWeight: FontWeight.bold)),
                    ),
                ]),
                Text('${item.slot.label}  •  Req. Level ${item.levelRequired}',
                    style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
              ])),
              Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 16, color: AppTheme.textMuted),
            ]),
          ),

          // Collapsed: just show first stat
          if (!isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(52, 0, 10, 10),
              child: Text(
                item.bonuses.map((b) => '${b.stat.shortLabel}: +${b.value}').join('  •  '),
                style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.7)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Expanded detail
          if (isOpen) ...[
            const Divider(height: 1, color: Color(0xFF2a2010)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Stats
                Text('STATS', style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8, runSpacing: 4,
                  children: item.bonuses.map((b) => _StatPill(
                    label: b.stat.shortLabel,
                    value: '+${b.value}',
                    color: color,
                  )).toList(),
                ),

                // Ability enhancement
                if (item.uniqueAbilityId != null) ...[
                  const SizedBox(height: 10),
                  Text('ABILITY ENHANCEMENT', style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.06),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (item.abilityValueMult != 1.0)
                        Text('• Ability damage ×${item.abilityValueMult.toStringAsFixed(1)}',
                            style: TextStyle(fontSize: 11, color: color, height: 1.5)),
                      if (item.abilityDurationAdd != 0)
                        Text('• +${item.abilityDurationAdd} rounds duration',
                            style: TextStyle(fontSize: 11, color: color, height: 1.5)),
                      if (item.abilityCooldownFlat != 0)
                        Text('• ${item.abilityCooldownFlat < 0 ? "" : "-"}${item.abilityCooldownFlat.abs()} rounds cooldown',
                            style: TextStyle(fontSize: 11, color: color, height: 1.5)),
                      if (item.abilityExtraEffect != null)
                        Text('• On cast: ${_extraEffectDesc(item)}',
                            style: TextStyle(fontSize: 11, color: color, height: 1.5)),
                    ]),
                  ),
                ],

                // Drop info
                const SizedBox(height: 10),
                Text('HOW TO FIND', style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1)),
                const SizedBox(height: 6),
                _DropRow('Campaign bosses', '2% per boss kill'),
                _DropRow('Tower Ascension bosses', '2% per boss kill'),
                _DropRow('Boss Rush runs', '2% per boss kill'),
                _DropRow('Gauntlet clear', 'Rare bonus drop'),
                const SizedBox(height: 4),
                const Text(
                  'Drops are class-specific — only items for your class can drop.',
                  style: TextStyle(fontSize: 9, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                ),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  String _extraEffectDesc(EquipmentItem item) {
    final val = item.abilityExtraValue;
    final dur = item.abilityExtraDuration;
    return switch (item.abilityExtraEffect!) {
      AbilityEffect.dot          => 'Apply $val% DoT for $dur rounds',
      AbilityEffect.stun         => 'Stun enemy for $dur rounds',
      AbilityEffect.heal         => 'Heal $val HP',
      AbilityEffect.attackBonus  => '+$val DMG for $dur rounds',
      AbilityEffect.acBonus      => '+$val Armor for $dur rounds',
      AbilityEffect.bonusDamage  => '$val% bonus damage',
      AbilityEffect.debuffWeaken => 'Weaken enemy $val% for $dur rounds',
      AbilityEffect.debuffVulnerable => '+$val% damage taken for $dur rounds',
      AbilityEffect.dodge        => 'Dodge next hit',
      AbilityEffect.aura         => '+$val HP/round for $dur rounds',
      AbilityEffect.silence      => 'Silence $dur rounds',
      AbilityEffect.absorbShield => '$val HP barrier',
      AbilityEffect.missChance   => '$val% miss chance for $dur rounds',
    };
  }
}

// ── Mythic list ───────────────────────────────────────────────────────────────

class _MythicList extends StatelessWidget {
  const _MythicList({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final mythicItems = [
      ...game.inventory.bag.whereType<EquipmentItem>()
          .where((i) => i.rarity == ItemRarity.mythic),
      ...game.inventory.equipped.values
          .where((i) => i.rarity == ItemRarity.mythic),
    ]..sort((a, b) => b.levelRequired.compareTo(a.levelRequired));

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _mythicHeader(),
        if (mythicItems.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              border: Border.all(color: const Color(0xFFDD1111).withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Column(children: [
              Icon(Icons.local_fire_department, size: 32, color: Color(0xFFDD1111)),
              SizedBox(height: 8),
              Text('No Mythic items yet',
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
              SizedBox(height: 4),
              Text('Defeat campaign bosses for a 0.5% chance per kill.',
                  style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                  textAlign: TextAlign.center),
            ]),
          )
        else
          ...mythicItems.map((item) => _MythicCard(item: item)),
      ],
    );
  }

  Widget _mythicHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a0000),
        border: Border.all(color: const Color(0xFFDD1111).withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.local_fire_department, size: 18, color: Color(0xFFDD1111)),
          SizedBox(width: 8),
          Text('Mythic Items',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                  color: Color(0xFFDD1111))),
        ]),
        const SizedBox(height: 6),
        const Text(
          'The rarest procedurally-generated tier. Mythic items have 3 stats '
          'with the highest possible values and a powerful keyword effect. '
          'Drop rate: 0.5% per boss kill.',
          style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.5),
        ),
      ]),
    );
  }
}

class _MythicCard extends StatelessWidget {
  const _MythicCard({required this.item});
  final EquipmentItem item;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFDD1111);
    final equipped = GameStateProvider.of(context).inventory.equipped.values
        .any((e) => e.id == item.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1a0000),
        border: Border.all(color: color.withValues(alpha: equipped ? 0.9 : 0.4), width: equipped ? 1.5 : 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            SizedBox(width: 32, height: 36,
                child: ItemSprite(slot: item.slot, rarity: item.rarity, size: 30)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                      color: Color(0xFFDD1111))),
              Text('${item.slot.label}  •  Lv${item.levelRequired}',
                  style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
            ])),
            if (equipped)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text('EQUIPPED',
                    style: TextStyle(fontSize: 7, color: Color(0xFFDD1111),
                        fontWeight: FontWeight.bold)),
              ),
          ]),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6, runSpacing: 4,
            children: item.bonuses.map((b) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                border: Border.all(color: color.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text('${b.stat.shortLabel} +${b.value}',
                  style: const TextStyle(fontSize: 10, color: Color(0xFFFF4444))),
            )).toList(),
          ),
          if (item.keyword != null) ...[
            const SizedBox(height: 6),
            Text('${item.keyword!.name.toUpperCase()} keyword',
                style: const TextStyle(fontSize: 9, color: Color(0xFFDD1111),
                    fontStyle: FontStyle.italic)),
          ],
        ]),
      ),
    );
  }
}

// ── Set list ─────────────────────────────────────────────────────────────────

class _SetList extends StatelessWidget {
  const _SetList({required this.game, required this.expanded, required this.onExpand});
  final GameState game;
  final String? expanded;
  final ValueChanged<String?> onExpand;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: kSetCatalog.length + 1,
      itemBuilder: (ctx, i) {
        if (i == 0) return _setHeader();
        final set = kSetCatalog[i - 1];
        final pieces = game.inventory.equipped.values
            .where((e) => e.setId == set.id).length;
        final isOpen = expanded == set.id;
        return _SetCard(
          set: set,
          equippedCount: pieces,
          isOpen: isOpen,
          onTap: () => onExpand(isOpen ? null : set.id),
        );
      },
    );
  }

  Widget _setHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0a1020),
        border: Border.all(color: const Color(0xFF4455aa).withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.layers_outlined, size: 18, color: Color(0xFF88aaff)),
          SizedBox(width: 8),
          Text('Set Items', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF88aaff))),
        ]),
        const SizedBox(height: 6),
        const Text(
          'Collect multiple pieces of the same set to unlock powerful bonuses. '
          'Sets now require 6 pieces for the full bonus. Drop rate: 0.3% per boss kill.',
          style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.5),
        ),
      ]),
    );
  }
}

class _SetCard extends StatelessWidget {
  const _SetCard({required this.set, required this.equippedCount,
      required this.isOpen, required this.onTap});
  final ItemSet set;
  final int equippedCount;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final maxPieces = set.slots.length;
    final color = set.color;
    final progress = equippedCount / maxPieces;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isOpen ? color.withValues(alpha: 0.06) : AppTheme.cardBg,
          border: Border.all(
              color: equippedCount > 0 ? color : color.withValues(alpha: 0.3),
              width: isOpen ? 1.5 : 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              // Color dot
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(set.name,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                Text('${set.slots.map((s) => s.label).join(' · ')}',
                    style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('$equippedCount / $maxPieces',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                        color: equippedCount >= maxPieces ? color : AppTheme.textMuted)),
                Text('equipped', style: const TextStyle(fontSize: 8, color: AppTheme.textMuted)),
              ]),
              const SizedBox(width: 6),
              Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 16, color: AppTheme.textMuted),
            ]),
          ),

          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              const SizedBox(height: 4),
              // Active tier label
              if (equippedCount > 0) ...[
                Builder(builder: (_) {
                  final activeTier = set.tiers.lastWhere(
                      (t) => t.piecesRequired <= equippedCount,
                      orElse: () => set.tiers.first);
                  if (activeTier.piecesRequired > equippedCount) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    '${activeTier.piecesRequired}pc active: ${activeTier.bonuses.map((b) => "${b.stat.shortLabel} +${b.value}").join(", ")}',
                    style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  );
                }),
              ],
            ]),
          ),

          // Expanded tiers + slots
          if (isOpen) ...[
            const Divider(height: 1, color: Color(0xFF2a2520)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Tier bonuses
                Text('SET BONUSES', style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1)),
                const SizedBox(height: 8),
                ...set.tiers.map((tier) {
                  final active = equippedCount >= tier.piecesRequired;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: active
                          ? color.withValues(alpha: 0.10)
                          : AppTheme.cardBg,
                      border: Border.all(
                          color: active ? color : AppTheme.cardBorder,
                          width: active ? 1.5 : 1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 28, height: 20,
                        alignment: Alignment.center,
                        child: Text('${tier.piecesRequired}pc',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold,
                                color: active ? color : AppTheme.textMuted)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          spacing: 6, runSpacing: 4,
                          children: tier.bonuses.map((b) => _StatPill(
                            label: b.stat.shortLabel,
                            value: '+${b.value}',
                            color: active ? color : AppTheme.textMuted,
                          )).toList(),
                        ),
                      ),
                      if (active)
                        const Icon(Icons.check_circle, size: 14, color: Color(0xFF44cc88)),
                    ]),
                  );
                }),

                const SizedBox(height: 10),

                // Slots
                Text('SET PIECES', style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: set.slots.map((slot) {
                    final slotEquipped = equippedCount > 0 &&
                        GameStateProvider.of(context).inventory.equipped[slot]?.setId == set.id;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: slotEquipped
                            ? color.withValues(alpha: 0.20)
                            : color.withValues(alpha: 0.06),
                        border: Border.all(
                            color: slotEquipped ? color : color.withValues(alpha: 0.35),
                            width: slotEquipped ? 1.5 : 1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        if (slotEquipped) ...[
                          Icon(Icons.check, size: 10, color: color),
                          const SizedBox(width: 3),
                        ],
                        Text(slot.label,
                            style: TextStyle(fontSize: 9, color: color,
                                fontWeight: slotEquipped ? FontWeight.bold : FontWeight.normal)),
                      ]),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 10),

                // Drop info
                Text('HOW TO FIND', style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1)),
                const SizedBox(height: 6),
                _DropRow('Campaign bosses', '0.3% per boss kill'),
                _DropRow('Tower Ascension bosses', '0.3% per boss kill'),
                _DropRow('Boss Rush runs', '0.3% per boss kill'),
                const SizedBox(height: 4),
                const Text(
                  'Set items can drop any piece from the set at random.',
                  style: TextStyle(fontSize: 9, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                ),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}

// ── Artifact sets ─────────────────────────────────────────────────────────────

class _ArtifactSetList extends StatelessWidget {
  const _ArtifactSetList({required this.game, required this.expanded, required this.onExpand});
  final GameState game;
  final String? expanded;
  final ValueChanged<String?> onExpand;

  @override
  Widget build(BuildContext context) {
    final equipped = game.equippedSetPieceCounts;
    // Distinct owned pieces per set (whether equipped or not).
    final ownedIdx = <String, Set<int>>{};
    for (final a in game.ownedArtifacts) {
      if (!a.isSetPiece) continue;
      ownedIdx.putIfAbsent(a.setId!, () => <int>{}).add(a.setPieceIndex);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: ArtifactSet.all.length + 1,
      itemBuilder: (ctx, i) {
        if (i == 0) return _header();
        final set = ArtifactSet.all[i - 1];
        final isOpen = expanded == set.id;
        return _ArtifactSetCard(
          set: set,
          equippedCount: equipped[set.id] ?? 0,
          ownedCount: ownedIdx[set.id]?.length ?? 0,
          isOpen: isOpen,
          onTap: () => onExpand(isOpen ? null : set.id),
        );
      },
    );
  }

  Widget _header() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kArtifactSetColor.withValues(alpha: 0.06),
        border: Border.all(color: kArtifactSetColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.auto_awesome, size: 18, color: kArtifactSetColor),
          SizedBox(width: 8),
          Text('Artifact Sets', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kArtifactSetColor)),
        ]),
        const SizedBox(height: 6),
        Text(
          '${ArtifactSet.all.length} three-piece artifact sets. Equip 2 matching green pieces on '
          'the artifact grid for a partial bonus, all 3 for the full bonus. Set pieces drop from '
          'Dungeons, Boss Rush, and Campaign bosses.',
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.5),
        ),
      ]),
    );
  }
}

class _ArtifactSetCard extends StatelessWidget {
  const _ArtifactSetCard({
    required this.set,
    required this.equippedCount,
    required this.ownedCount,
    required this.isOpen,
    required this.onTap,
  });
  final ArtifactSet set;
  final int equippedCount;
  final int ownedCount;
  final bool isOpen;
  final VoidCallback onTap;

  static const _c = kArtifactSetColor;

  @override
  Widget build(BuildContext context) {
    final progress = equippedCount / set.pieces.length;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isOpen ? _c.withValues(alpha: 0.06) : AppTheme.cardBg,
          border: Border.all(
              color: equippedCount > 0 ? _c : _c.withValues(alpha: 0.3),
              width: isOpen ? 1.5 : 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(width: 10, height: 10,
                  decoration: const BoxDecoration(color: _c, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(set.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _c)),
                Text(set.pieces.map((p) => p.type.label).join(' · '),
                    style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('$equippedCount / ${set.pieces.length}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                        color: equippedCount >= set.pieces.length ? _c : AppTheme.textMuted)),
                const Text('equipped', style: TextStyle(fontSize: 8, color: AppTheme.textMuted)),
              ]),
              const SizedBox(width: 6),
              Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 16, color: AppTheme.textMuted),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: _c.withValues(alpha: 0.12),
                valueColor: const AlwaysStoppedAnimation(_c),
              ),
            ),
          ),
          if (isOpen) ...[
            const Divider(height: 1, color: Color(0xFF2a2520)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('SET BONUSES', style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1)),
                const SizedBox(height: 8),
                _bonusTier('2', set.twoPieceBonus.summary, equippedCount >= 2),
                const SizedBox(height: 6),
                _bonusTier('3', set.threePieceBonus.summary, equippedCount >= 3),
                const SizedBox(height: 12),
                Text('SET PIECES', style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1)),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final p in set.pieces)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _c.withValues(alpha: 0.06),
                        border: Border.all(color: _c.withValues(alpha: 0.35)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text('${p.name}  (${p.type.label})',
                          style: const TextStyle(fontSize: 9, color: _c)),
                    ),
                ]),
                const SizedBox(height: 10),
                Text('COLLECTED  $ownedCount / ${set.pieces.length} distinct pieces owned',
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontStyle: FontStyle.italic)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _bonusTier(String pcs, String summary, bool active) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: active ? _c.withValues(alpha: 0.10) : AppTheme.cardBg,
        border: Border.all(color: active ? _c : AppTheme.cardBorder, width: active ? 1.5 : 1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 28,
            child: Text('${pcs}pc',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold,
                    color: active ? _c : AppTheme.textMuted))),
        const SizedBox(width: 8),
        Expanded(
          child: Text(summary,
              style: TextStyle(fontSize: 11,
                  color: active ? _c : AppTheme.textMuted,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
        ),
        if (active) const Icon(Icons.check_circle, size: 14, color: _c),
      ]),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.10),
      border: Border.all(color: color.withValues(alpha: 0.4)),
      borderRadius: BorderRadius.circular(3),
    ),
    child: RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '$label ', style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.7))),
          TextSpan(text: value, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}

class _DropRow extends StatelessWidget {
  const _DropRow(this.source, this.rate);
  final String source;
  final String rate;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      Expanded(child: Text(source,
          style: const TextStyle(fontSize: 10, color: AppTheme.textLight))),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e),
          border: Border.all(color: AppTheme.cardBorder),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(rate, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
      ),
    ]),
  );
}

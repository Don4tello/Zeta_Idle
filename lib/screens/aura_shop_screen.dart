import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'dart:math' show pi, sin;
import '../models/attack_effect.dart';
import '../models/hero_aura.dart';
import '../models/palette_skin.dart';
import '../models/pet.dart';
import '../models/waystone.dart';
import '../services/game_state.dart';
import '../services/iap_service.dart';
import '../theme/app_theme.dart';
import '../widgets/battle_sprites.dart';

const _kCrystalSources = [
  ('🏆', 'Achievements — claim unlocked achievements for crystal rewards'),
  ('⚔️', 'Gauntlet — clear all 10 enemies in a Challenge Gauntlet run'),
  ('🗝️', 'Dungeons — complete a dungeon for a small crystal bonus'),
  ('🌟', 'Prestige & Ascension — first prestige and ascension grant crystals'),
  ('📅', 'Daily Login — day 7 login streak reward includes crystals'),
];

class AuraShopScreen extends StatefulWidget {
  const AuraShopScreen({super.key});

  @override
  State<AuraShopScreen> createState() => _AuraShopScreenState();
}

class _AuraShopScreenState extends State<AuraShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
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
      backgroundColor: const Color(0xFF0a0e27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1f3a),
        title: Text('COSMETICS', style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: _CrystalBadge(crystals: game.crystals),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppTheme.accentGold,
          labelColor: AppTheme.accentGold,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: [
            Tab(child: Text('AURAS', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 1))),
            Tab(child: Text('SKINS', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 1))),
            Tab(child: Text('PETS', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 1))),
            Tab(child: Text('CRYSTALS', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 1))),
            Tab(child: Text('BOOSTS', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 1))),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _AurasTab(game: game),
          _SkinsTab(game: game),
          _PetsTab(game: game),
          _CrystalsTab(game: game),
          _BoostsTab(game: game),
        ],
      ),
    );
  }
}

// ─── Auras tab ────────────────────────────────────────────────────────────────

class _AurasTab extends StatelessWidget {
  const _AurasTab({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (game.equippedAuraId != null) ...[
            Text('EQUIPPED', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.accentGold)),
            const SizedBox(height: 8),
            _buildAuraCard(context, kAuraCatalog.firstWhere((a) => a.id == game.equippedAuraId)),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ALL AURAS', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2)),
              if (game.equippedAuraId != null)
                TextButton(
                  onPressed: () => game.equipAura(null),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textMuted,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('Remove aura', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ...kAuraCatalog.map((aura) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildAuraCard(context, aura),
          )),
        ],
      ),
    );
  }

  Widget _buildAuraCard(BuildContext context, HeroAura aura) {
    final owned    = game.ownedAuraIds.contains(aura.id);
    final equipped = game.equippedAuraId == aura.id;
    final canAfford = game.crystals >= aura.crystalCost;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0e1225),
        border: Border.all(
          color: equipped ? aura.color : AppTheme.cardBorder,
          width: equipped ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          _AuraOrb(aura: aura, size: 52),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(aura.name,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: aura.color)),
                    if (equipped) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: aura.color.withValues(alpha: 0.15),
                          border: Border.all(color: aura.color, width: 1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text('ON', style: TextStyle(fontSize: 8, color: aura.color)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(aura.description,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: aura.color.withValues(alpha: 0.10),
                    border: Border.all(color: aura.color.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '✦ ${aura.bonusLabel}',
                    style: TextStyle(fontSize: 10, color: aura.color, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                if (owned)
                  _ActionButton(
                    label: equipped ? 'EQUIPPED' : 'EQUIP',
                    color: equipped ? AppTheme.textMuted : AppTheme.accentGold,
                    onTap: equipped ? null : () => game.equipAura(aura.id),
                  )
                else
                  Row(
                    children: [
                      _CrystalCost(crystals: aura.crystalCost, affordable: canAfford),
                      const SizedBox(width: 10),
                      _ActionButton(
                        label: 'UNLOCK',
                        color: canAfford ? aura.color : AppTheme.cardBorder,
                        onTap: canAfford
                            ? () => _confirmPurchase(context, aura)
                            : null,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmPurchase(BuildContext context, HeroAura aura) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        title: Text('Unlock ${aura.name}?',
            style: AppTheme.pixelHeading(fontSize: 13, color: aura.color)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AuraOrb(aura: aura, size: 72),
            const SizedBox(height: 12),
            Text('Cost: ${aura.crystalCost} crystals',
                style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: AppTheme.pixelHeading(fontSize: 10, color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              game.purchaseAura(aura.id);
            },
            child: Text('CONFIRM', style: AppTheme.pixelHeading(fontSize: 10, color: AppTheme.accentGold)),
          ),
        ],
      ),
    );
  }
}

// ─── Skins tab ────────────────────────────────────────────────────────────────

class _SkinsTab extends StatelessWidget {
  const _SkinsTab({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (game.equippedSkinId != null) ...[
            Text('EQUIPPED', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.accentGold)),
            const SizedBox(height: 8),
            _buildSkinCard(context, kSkinCatalog.firstWhere((s) => s.id == game.equippedSkinId)),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ALL SKINS', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2)),
              if (game.equippedSkinId != null)
                TextButton(
                  onPressed: () => game.equipSkin(null),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textMuted,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Remove skin', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ...kSkinCatalog.map((skin) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildSkinCard(context, skin),
          )),
        ],
      ),
    );
  }

  Widget _buildSkinCard(BuildContext context, PaletteSkin skin) {
    final owned     = game.ownedSkinIds.contains(skin.id);
    final equipped  = game.equippedSkinId == skin.id;
    final canAfford = game.crystals >= skin.crystalCost;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0e1225),
        border: Border.all(
          color: equipped ? AppTheme.accentGold : AppTheme.cardBorder,
          width: equipped ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Before / After sprite previews
          _SkinPreview(spriteId: game.hero.spriteId, skin: skin),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(skin.name,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: skin.previewColor)),
                    if (equipped) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withValues(alpha: 0.15),
                          border: Border.all(color: AppTheme.accentGold),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text('ON', style: AppTheme.pixelHeading(fontSize: 8, color: AppTheme.accentGold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(skin.description,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: skin.previewColor.withValues(alpha: 0.12),
                    border: Border.all(color: skin.previewColor.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '✦ ${skin.bonusLabel}',
                    style: TextStyle(fontSize: 10, color: skin.previewColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                if (owned)
                  _ActionButton(
                    label: equipped ? 'EQUIPPED' : 'EQUIP',
                    color: equipped ? AppTheme.textMuted : AppTheme.accentGold,
                    onTap: equipped ? null : () => game.equipSkin(skin.id),
                  )
                else
                  Row(
                    children: [
                      _CrystalCost(crystals: skin.crystalCost, affordable: canAfford),
                      const SizedBox(width: 10),
                      _ActionButton(
                        label: 'UNLOCK',
                        color: canAfford ? skin.previewColor : AppTheme.cardBorder,
                        onTap: canAfford ? () => _confirmPurchase(context, skin) : null,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmPurchase(BuildContext context, PaletteSkin skin) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        title: Text('Unlock ${skin.name}?',
            style: AppTheme.pixelHeading(fontSize: 13, color: skin.previewColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SkinPreview(spriteId: game.hero.spriteId, skin: skin, showLabel: true),
            const SizedBox(height: 12),
            Text('Cost: ${skin.crystalCost} crystals',
                style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: AppTheme.pixelHeading(fontSize: 10, color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              game.purchaseSkin(skin.id);
            },
            child: Text('CONFIRM', style: AppTheme.pixelHeading(fontSize: 10, color: AppTheme.accentGold)),
          ),
        ],
      ),
    );
  }
}

class _SkinPreview extends StatelessWidget {
  const _SkinPreview({required this.spriteId, required this.skin, this.showLabel = false});
  final String spriteId;
  final PaletteSkin skin;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Side-by-side: original → skinned
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _spriteBox(null),
            const SizedBox(width: 6),
            const Text('→', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
            const SizedBox(width: 6),
            _spriteBox(skin.toColorFilter()),
          ],
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text('Before / After', style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
        ],
      ],
    );
  }

  Widget _spriteBox(ColorFilter? filter) {
    return Container(
      width: 44,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF0a0c18),
        border: Border.all(color: AppTheme.cardBorder, width: 1),
      ),
      child: Center(
        child: SizedBox(
          width: 32,
          height: 42,
          child: BattleSprite(spriteId: spriteId, colorFilter: filter),
        ),
      ),
    );
  }
}

// ─── Pets tab ─────────────────────────────────────────────────────────────────

class _PetsTab extends StatelessWidget {
  const _PetsTab({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (game.equippedPetId != null) ...[
            Text('COMPANION', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.accentGold)),
            const SizedBox(height: 8),
            _buildPetCard(context, kPetCatalog.firstWhere((p) => p.id == game.equippedPetId)),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ALL PETS', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2)),
              if (game.equippedPetId != null)
                TextButton(
                  onPressed: () => game.equipPet(null),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textMuted,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Dismiss pet', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text('One companion can be active at a time. Each grants a small passive bonus.',
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 12),
          ...kPetCatalog.map((pet) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildPetCard(context, pet),
          )),
        ],
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, PetDefinition pet) {
    final owned     = game.ownedPetIds.contains(pet.id);
    final equipped  = game.equippedPetId == pet.id;
    final canAfford = game.crystals >= pet.crystalCost;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0e1225),
        border: Border.all(
          color: equipped ? pet.color : AppTheme.cardBorder,
          width: equipped ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet avatar
          _PetAvatar(pet: pet, equipped: equipped),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(pet.name,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: pet.color)),
                    ),
                    if (equipped)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: pet.color.withValues(alpha: 0.15),
                          border: Border.all(color: pet.color),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text('ON', style: TextStyle(fontSize: 8, color: pet.color)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(pet.flavorLine,
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                Text(pet.description,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                const SizedBox(height: 6),
                // Bonus chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: pet.color.withValues(alpha: 0.10),
                    border: Border.all(color: pet.color.withValues(alpha: 0.45)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '✦ ${pet.bonusLabel}',
                    style: TextStyle(fontSize: 10, color: pet.color, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                if (owned) ...[
                  _ActionButton(
                    label: equipped ? 'ACTIVE' : 'SEND OUT',
                    color: equipped ? AppTheme.textMuted : pet.color,
                    onTap: equipped ? null : () => game.equipPet(pet.id),
                  ),
                  _PetEvolutionRow(game: game, petId: pet.id, petColor: pet.color),
                ] else
                  Row(
                    children: [
                      _CrystalCost(crystals: pet.crystalCost, affordable: canAfford),
                      const SizedBox(width: 10),
                      _ActionButton(
                        label: 'ADOPT',
                        color: canAfford ? pet.color : AppTheme.cardBorder,
                        onTap: canAfford ? () => _confirmAdopt(context, pet) : null,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmAdopt(BuildContext context, PetDefinition pet) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        title: Text('Adopt ${pet.name}?',
            style: AppTheme.pixelHeading(fontSize: 13, color: pet.color)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(pet.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: pet.color.withValues(alpha: 0.08),
                border: Border.all(color: pet.color.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('✦ ${pet.bonusLabel}',
                  style: TextStyle(fontSize: 12, color: pet.color, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Text('Cost: ${pet.crystalCost} crystals',
                style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: AppTheme.pixelHeading(fontSize: 10, color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              game.purchasePet(pet.id);
            },
            child: Text('ADOPT', style: AppTheme.pixelHeading(fontSize: 10, color: pet.color)),
          ),
        ],
      ),
    );
  }
}

class _PetAvatar extends StatelessWidget {
  const _PetAvatar({required this.pet, required this.equipped});
  final PetDefinition pet;
  final bool equipped;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: pet.color.withValues(alpha: 0.10),
        border: Border.all(
          color: pet.color.withValues(alpha: equipped ? 0.8 : 0.4),
          width: equipped ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(pet.emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}

// ─── Crystals tab ─────────────────��───────────────────────────────────────────

class _CrystalsTab extends StatelessWidget {
  const _CrystalsTab({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final supported = IapService.platformSupported;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _CrystalBadge(crystals: game.crystals, large: true)),
          const SizedBox(height: 20),
          if (!supported) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1f3a),
                border: Border.all(color: const Color(0xFF3a4a6a)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Text('💎', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 10),
                    Text('EARNING CRYSTALS',
                        style: TextStyle(color: Color(0xFF88aaff),
                            fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ]),
                  const SizedBox(height: 12),
                  const Text(
                    'On PC, crystals are earned through gameplay:',
                    style: TextStyle(color: AppTheme.textLight, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  ..._kCrystalSources.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.$1, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(s.$2,
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, height: 1.4))),
                    ]),
                  )),
                ],
              ),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 16),
              Text('DEV MODE', style: AppTheme.pixelHeading(fontSize: 9, color: const Color(0xFFcc4444), letterSpacing: 2)),
              const SizedBox(height: 8),
              ...IapService.packages.map((pkg) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PackageCard(pkg: pkg, game: game, devMode: true),
              )),
            ],
          ] else ...[
            Text('CRYSTAL PACKS', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2)),
            const SizedBox(height: 10),
            ...IapService.packages.map((pkg) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PackageCard(pkg: pkg, game: game, devMode: false),
            )),
          ],
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.pkg, required this.game, required this.devMode});
  final CrystalPackage pkg;
  final GameState game;
  final bool devMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0e1225),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Text('💎', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pkg.label,
                    style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 0)),
                Text(devMode ? 'Debug grant (free)' : pkg.fallbackPrice,
                    style: TextStyle(
                        fontSize: 11,
                        color: devMode ? const Color(0xFFcc4444) : AppTheme.accentGold)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (devMode) {
                game.iapService.devGrant(pkg.crystals);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('+${pkg.crystals} crystals granted (debug)'),
                    backgroundColor: const Color(0xFF1a1f3a),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                game.iapService.buy(pkg.productId);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: devMode ? const Color(0xFF442222) : const Color(0xFF1a2a4a),
              foregroundColor: devMode ? const Color(0xFFcc4444) : AppTheme.accentGold,
              side: BorderSide(color: devMode ? const Color(0xFFcc4444) : AppTheme.accentGold),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: Text(devMode ? 'GRANT' : 'BUY',
                style: AppTheme.pixelHeading(fontSize: 10)),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _AuraOrb extends StatefulWidget {
  const _AuraOrb({required this.aura, required this.size});
  final HeroAura aura;
  final double size;

  @override
  State<_AuraOrb> createState() => _AuraOrbState();
}

class _AuraOrbState extends State<_AuraOrb> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final pulse = 0.5 + 0.5 * sin(_ctrl.value * pi * 2);
        final intensity = widget.aura.intensity;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.aura.color.withValues(alpha: 0.12),
            border: Border.all(
              color: widget.aura.color.withValues(alpha: 0.6 + pulse * 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.aura.color.withValues(alpha: (0.3 + pulse * 0.35) * intensity),
                blurRadius: (8 + pulse * 10) * intensity,
                spreadRadius: (1 + pulse * 3) * intensity,
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.aura.name[0],
              style: TextStyle(
                fontSize: widget.size * 0.36,
                fontWeight: FontWeight.bold,
                color: widget.aura.color,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CrystalBadge extends StatelessWidget {
  const _CrystalBadge({required this.crystals, this.large = false});
  final int crystals;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 16 : 10, vertical: large ? 10 : 5),
      decoration: BoxDecoration(
        color: const Color(0xFF0e1225),
        border: Border.all(color: const Color(0xFF6688ff), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('💎', style: TextStyle(fontSize: large ? 20 : 14)),
          const SizedBox(width: 6),
          Text(
            '$crystals',
            style: AppTheme.pixelHeading(
              fontSize: large ? 16 : 11,
              color: const Color(0xFF88aaff),
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _CrystalCost extends StatelessWidget {
  const _CrystalCost({required this.crystals, required this.affordable});
  final int crystals;
  final bool affordable;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('💎', style: TextStyle(fontSize: 13)),
        const SizedBox(width: 4),
        Text(
          '$crystals',
          style: TextStyle(
            fontSize: 12,
            color: affordable ? const Color(0xFF88aaff) : AppTheme.cardBorder,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.color, this.onTap});
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        disabledForegroundColor: AppTheme.cardBorder,
        side: BorderSide(color: onTap != null ? color : AppTheme.cardBorder),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 1, color: onTap != null ? color : AppTheme.cardBorder)),
    );
  }
}

// ── Pet Evolution ─────────────────────────────────────────────────────────────

class _PetEvolutionRow extends StatelessWidget {
  const _PetEvolutionRow({required this.game, required this.petId, required this.petColor});
  final GameState game;
  final String petId;
  final Color petColor;

  @override
  Widget build(BuildContext context) {
    final evo  = game.petEvolutionLevel(petId);
    if (evo >= 2) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text('★★ MAX EVOLUTION',
            style: TextStyle(fontSize: 9, color: petColor, fontWeight: FontWeight.bold)),
      );
    }
    final cost      = game.evolutionCost(petId);
    final canAfford = game.crystals >= cost;
    final starLabel = evo == 0 ? '○○' : '★○';
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(children: [
        Text(starLabel,
            style: TextStyle(fontSize: 12, color: petColor.withValues(alpha: 0.7))),
        const SizedBox(width: 6),
        Text(evo == 0 ? 'Evo I: 1.5× bonus' : 'Evo II: 2× bonus',
            style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
        const SizedBox(width: 8),
        _CrystalCost(crystals: cost, affordable: canAfford),
        const SizedBox(width: 6),
        _ActionButton(
          label: 'EVOLVE',
          color: canAfford ? petColor : AppTheme.cardBorder,
          onTap: canAfford ? () => game.evolvePet(petId) : null,
        ),
      ]),
    );
  }
}

// ── Boosts Tab ────────────────────────────────────────────────────────────────

class _BoostsTab extends StatelessWidget {
  const _BoostsTab({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Waystones ─────────────────────────────────────────────────────
          Text('WAYSTONES', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.accentGold)),
          const SizedBox(height: 4),
          const Text(
            'Multiply idle gold income while active. Activate one before closing '
            'the app to boost offline earnings. Only one can be active at a time.',
            style: TextStyle(fontSize: 10, color: AppTheme.textMuted, height: 1.5),
          ),
          const SizedBox(height: 8),
          if (game.waystoneActive)
            _WaystoneActiveBanner(game: game),
          const SizedBox(height: 8),
          ...WaystoneType.all.map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _WaystoneCard(game: game, waystone: w),
          )),
          const SizedBox(height: 20),

          // ── Attack Effects ─────────────────────────────────────────────────
          Text('ATTACK EFFECTS', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.accentGold)),
          const SizedBox(height: 4),
          const Text(
            'Cosmetic visual effects on your attacks. Purely decorative — no gameplay impact.',
            style: TextStyle(fontSize: 10, color: AppTheme.textMuted, height: 1.5),
          ),
          const SizedBox(height: 8),
          ...AttackEffect.all.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _AttackEffectCard(game: game, effect: e),
          )),
          const SizedBox(height: 20),

          // ── Extra Character Slots ──────────────────────────────────────────
          Text('CHARACTER SLOTS', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.accentGold)),
          const SizedBox(height: 4),
          Text(
            'Unlock additional character save slots. You currently have '
            '${3 + game.extraCharacterSlots} of 5.',
            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, height: 1.5),
          ),
          const SizedBox(height: 8),
          if (game.extraCharacterSlots >= 2)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0e1225),
                border: Border.all(color: const Color(0xFF44cc66).withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(children: [
                Text('✓ ', style: TextStyle(color: Color(0xFF44cc66))),
                Text('All 5 slots unlocked.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF44cc66))),
              ]),
            )
          else
            _SlotUnlockCard(game: game),
        ],
      ),
    );
  }
}

class _WaystoneActiveBanner extends StatelessWidget {
  const _WaystoneActiveBanner({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final remaining = game.waystoneExpiresAtMs - DateTime.now().millisecondsSinceEpoch;
    final mins = (remaining / 60000).ceil();
    final mult = game.waystoneMult;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF66aaff).withValues(alpha: 0.08),
        border: Border.all(color: const Color(0xFF66aaff).withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        const Text('🌀', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Waystone active — ${mult.toStringAsFixed(1)}× idle income  ·  '
            '$mins min remaining',
            style: const TextStyle(fontSize: 11, color: Color(0xFF66aaff)),
          ),
        ),
      ]),
    );
  }
}

class _WaystoneCard extends StatelessWidget {
  const _WaystoneCard({required this.game, required this.waystone});
  final GameState game;
  final WaystoneType waystone;

  @override
  Widget build(BuildContext context) {
    final isGrand  = waystone.id == 'grand';
    final count    = isGrand ? game.grandWaystoneCount : game.basicWaystoneCount;
    final canBuy   = game.crystals >= waystone.crystalCost;
    final canUse   = count > 0 && !game.waystoneActive;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0e1225),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(waystone.icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(waystone.name,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: waystone.color)),
              const Spacer(),
              Text('Owned: $count',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            ]),
            const SizedBox(height: 2),
            Text('${waystone.durationHours}h  ·  ${waystone.multiplier.toStringAsFixed(1)}× idle income',
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            Row(children: [
              _CrystalCost(crystals: waystone.crystalCost, affordable: canBuy),
              const SizedBox(width: 8),
              _ActionButton(
                label: 'BUY',
                color: canBuy ? waystone.color : AppTheme.cardBorder,
                onTap: canBuy ? () => game.buyWaystone(grand: isGrand) : null,
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                _ActionButton(
                  label: canUse ? 'ACTIVATE' : (game.waystoneActive ? 'ONE ACTIVE' : 'NONE'),
                  color: canUse ? const Color(0xFF44cc66) : AppTheme.cardBorder,
                  onTap: canUse ? () => game.activateWaystone(grand: isGrand) : null,
                ),
              ],
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _AttackEffectCard extends StatelessWidget {
  const _AttackEffectCard({required this.game, required this.effect});
  final GameState game;
  final AttackEffect effect;

  @override
  Widget build(BuildContext context) {
    final owned    = game.ownedAttackEffects.contains(effect.id);
    final equipped = game.equippedAttackEffectId == effect.id;
    final canBuy   = game.crystals >= effect.crystalCost;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: equipped ? effect.color.withValues(alpha: 0.05) : const Color(0xFF0e1225),
        border: Border.all(
            color: equipped ? effect.color.withValues(alpha: 0.6) : AppTheme.cardBorder,
            width: equipped ? 1.5 : 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        Text(effect.icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(effect.name,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: effect.color)),
            const SizedBox(height: 2),
            Text('"${effect.hitText}" on every hit',
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontStyle: FontStyle.italic)),
          ]),
        ),
        const SizedBox(width: 8),
        if (owned)
          _ActionButton(
            label: equipped ? 'ACTIVE' : 'EQUIP',
            color: equipped ? AppTheme.textMuted : effect.color,
            onTap: equipped ? null : () => game.equipAttackEffect(effect.id),
          )
        else
          Row(children: [
            _CrystalCost(crystals: effect.crystalCost, affordable: canBuy),
            const SizedBox(width: 6),
            _ActionButton(
              label: 'BUY',
              color: canBuy ? effect.color : AppTheme.cardBorder,
              onTap: canBuy ? () => game.buyAttackEffect(effect.id) : null,
            ),
          ]),
      ]),
    );
  }
}

class _SlotUnlockCard extends StatelessWidget {
  const _SlotUnlockCard({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    const cost     = 100;
    final canAfford = game.crystals >= cost;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0e1225),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        const Text('🔓', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Slot ${4 + game.extraCharacterSlots}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 2),
            const Text('Add one more character save slot.',
                style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            Row(children: [
              _CrystalCost(crystals: cost, affordable: canAfford),
              const SizedBox(width: 8),
              _ActionButton(
                label: 'UNLOCK',
                color: canAfford ? AppTheme.accentGold : AppTheme.cardBorder,
                onTap: canAfford ? () {
                  game.buyExtraCharacterSlot();
                } : null,
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

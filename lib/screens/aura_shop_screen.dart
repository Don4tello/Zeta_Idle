import 'package:flutter/material.dart';
import 'dart:math' show pi, sin;
import '../models/attack_effect.dart';
import '../models/hero_aura.dart';
import '../models/palette_skin.dart';
import '../models/pet.dart';
import '../models/waystone.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/battle_sprites.dart';
import '../widgets/zcoin_icon.dart';


// ─── Small "bonuses stack" info banner ───────────────────────────────────────
class _StackNote extends StatelessWidget {
  const _StackNote(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF44cc66).withValues(alpha: 0.08),
        border: Border.all(color: const Color(0xFF44cc66).withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✨', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFFaaddaa), height: 1.4)),
          ),
        ],
      ),
    );
  }
}

// ─── Auras section (used in AuraShopScreen and inline in premium shop) ────────

class CosmeticsAurasSection extends StatelessWidget {
  const CosmeticsAurasSection({required this.game, this.scrollable = true, super.key});
  final GameState game;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StackNote('Bonuses from every aura you OWN stack automatically — '
            'you keep them all. Equip one just to choose which glow you show.'),
        const SizedBox(height: 12),
        if (game.equippedAuraId != null) ...[
          Text('EQUIPPED', style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2, color: AppTheme.accentGold)),
          const SizedBox(height: 8),
          _buildAuraCard(context, kAuraCatalog.firstWhere((a) => a.id == game.equippedAuraId)),
          const SizedBox(height: 16),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ALL AURAS', style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2)),
            if (game.equippedAuraId != null)
              TextButton(
                onPressed: () => game.equipAura(null),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textMuted,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('Remove aura', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ...kAuraCatalog.map((aura) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildAuraCard(context, aura),
        )),
      ],
    );
    if (!scrollable) return col;
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: col);
  }

  Widget _buildAuraCard(BuildContext context, HeroAura aura) {
    final owned    = game.ownedAuraIds.contains(aura.id);
    final equipped = game.equippedAuraId == aura.id;
    final canAfford = game.zcoins >= aura.zcoinCost;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
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
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: aura.color)),
                    if (equipped) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: aura.color.withValues(alpha: 0.15),
                          border: Border.all(color: aura.color, width: 1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text('ON', style: TextStyle(fontSize: 9, color: aura.color)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(aura.description,
                    style: const TextStyle(fontSize: 14, color: AppTheme.textMuted)),
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
                    style: TextStyle(fontSize: 11, color: aura.color, fontWeight: FontWeight.bold),
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
                      _CrystalCost(zcoins: aura.zcoinCost, affordable: canAfford),
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
        backgroundColor: const Color(0xFF2A2623),
        title: Text('Unlock ${aura.name}?',
            style: AppTheme.pixelHeading(fontSize: 14, color: aura.color)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AuraOrb(aura: aura, size: 72),
            const SizedBox(height: 12),
            Text('Cost: ${aura.zcoinCost} zcoins',
                style: const TextStyle(color: AppTheme.textLight, fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              game.purchaseAura(aura.id);
              game.audioService.playClaim();
            },
            child: Text('CONFIRM', style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.accentGold)),
          ),
        ],
      ),
    );
  }
}

// ─── Skins section ────────────────────────────────────────────────────────────

class CosmeticsSkinsSection extends StatelessWidget {
  const CosmeticsSkinsSection({required this.game, this.scrollable = true, super.key});
  final GameState game;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StackNote('Bonuses from every skin you OWN stack automatically — '
            'you keep them all. Equip one just to choose which look you wear.'),
        const SizedBox(height: 12),
        if (game.equippedSkinId != null) ...[
          Text('EQUIPPED', style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2, color: AppTheme.accentGold)),
          const SizedBox(height: 8),
          _buildSkinCard(context, kSkinCatalog.firstWhere((s) => s.id == game.equippedSkinId)),
          const SizedBox(height: 16),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ALL SKINS', style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2)),
            if (game.equippedSkinId != null)
              TextButton(
                onPressed: () => game.equipSkin(null),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textMuted,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Remove skin', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ...kSkinCatalog.map((skin) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildSkinCard(context, skin),
        )),
      ],
    );
    if (!scrollable) return col;
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: col);
  }

  Widget _buildSkinCard(BuildContext context, PaletteSkin skin) {
    final owned     = game.ownedSkinIds.contains(skin.id);
    final equipped  = game.equippedSkinId == skin.id;
    final canAfford = game.zcoins >= skin.zcoinCost;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
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
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: skin.previewColor)),
                    if (equipped) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withValues(alpha: 0.15),
                          border: Border.all(color: AppTheme.accentGold),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text('ON', style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.accentGold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(skin.description,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
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
                    style: TextStyle(fontSize: 11, color: skin.previewColor, fontWeight: FontWeight.bold),
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
                      _CrystalCost(zcoins: skin.zcoinCost, affordable: canAfford),
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
        backgroundColor: const Color(0xFF2A2623),
        title: Text('Unlock ${skin.name}?',
            style: AppTheme.pixelHeading(fontSize: 14, color: skin.previewColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SkinPreview(spriteId: game.hero.spriteId, skin: skin, showLabel: true),
            const SizedBox(height: 12),
            Text('Cost: ${skin.zcoinCost} zcoins',
                style: const TextStyle(color: AppTheme.textLight, fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              game.purchaseSkin(skin.id);
              game.audioService.playClaim();
            },
            child: Text('CONFIRM', style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.accentGold)),
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
    if (!showLabel) {
      return _spriteBox(skin.toColorFilter());
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _spriteBox(null),
            const SizedBox(width: 6),
            const Text('→', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            const SizedBox(width: 6),
            _spriteBox(skin.toColorFilter()),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Before / After', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
      ],
    );
  }

  Widget _spriteBox(ColorFilter? filter) {
    return Container(
      width: 44,
      height: 56,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xFF17150E),
        border: Border.all(color: AppTheme.cardBorder, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        // Scale the full-size battle sprite down to fit neatly inside the box.
        child: FittedBox(
          fit: BoxFit.contain,
          child: BattleSprite(spriteId: spriteId, colorFilter: filter),
        ),
      ),
    );
  }
}

// ─── Pets section ─────────────────────────────────────────────────────────────

class CosmeticsPetsSection extends StatelessWidget {
  const CosmeticsPetsSection({required this.game, this.scrollable = true, super.key});
  final GameState game;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All owned pets grant their passive bonus automatically. Use SEND OUT to choose which pet accompanies you in battle.',
          style: const TextStyle(fontSize: 14, color: AppTheme.textMuted, height: 1.4),
        ),
        const SizedBox(height: 12),
        if (game.equippedPetId != null) ...[
          Text('BATTLE COMPANION', style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2, color: AppTheme.accentGold)),
          const SizedBox(height: 8),
          _buildPetCard(context, kPetCatalog.firstWhere((p) => p.id == game.equippedPetId)),
          const SizedBox(height: 16),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ALL PETS', style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2)),
            if (game.equippedPetId != null)
              TextButton(
                onPressed: () => game.equipPet(null),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textMuted,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Dismiss pet', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text('One companion can be active at a time. Each grants a small passive bonus.',
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        const SizedBox(height: 12),
        ...kPetCatalog.map((pet) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildPetCard(context, pet),
        )),
      ],
    );
    if (!scrollable) return col;
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: col);
  }

  Widget _buildPetCard(BuildContext context, PetDefinition pet) {
    final owned     = game.ownedPetIds.contains(pet.id);
    final equipped  = game.equippedPetId == pet.id;
    final canAfford = game.zcoins >= pet.zcoinCost;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
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
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: pet.color)),
                    ),
                    if (equipped)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: pet.color.withValues(alpha: 0.15),
                          border: Border.all(color: pet.color),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text('ON', style: TextStyle(fontSize: 9, color: pet.color)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(pet.flavorLine,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                Text(pet.description,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
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
                    style: TextStyle(fontSize: 11, color: pet.color, fontWeight: FontWeight.bold),
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
                      _CrystalCost(zcoins: pet.zcoinCost, affordable: canAfford),
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
        backgroundColor: const Color(0xFF2A2623),
        title: Text('Adopt ${pet.name}?',
            style: AppTheme.pixelHeading(fontSize: 14, color: pet.color)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(pet.emoji, style: const TextStyle(fontSize: 49)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: pet.color.withValues(alpha: 0.08),
                border: Border.all(color: pet.color.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('✦ ${pet.bonusLabel}',
                  style: TextStyle(fontSize: 13, color: pet.color, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Text('Cost: ${pet.zcoinCost} zcoins',
                style: const TextStyle(color: AppTheme.textLight, fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (game.purchasePet(pet.id)) game.audioService.playCoin();
            },
            child: Text('ADOPT', style: AppTheme.pixelHeading(fontSize: 11, color: pet.color)),
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
        child: Text(pet.emoji, style: const TextStyle(fontSize: 29)),
      ),
    );
  }
}

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

class _CrystalCost extends StatelessWidget {
  const _CrystalCost({required this.zcoins, required this.affordable});
  final int zcoins;
  final bool affordable;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ZCoinIcon(size: 14),
        const SizedBox(width: 4),
        Text(
          '$zcoins',
          style: TextStyle(
            fontSize: 13,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        minimumSize: const Size(64, 44),
      ),
      child: Text(label, style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 1, color: onTap != null ? color : AppTheme.cardBorder)),
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
            style: TextStyle(fontSize: 10, color: petColor, fontWeight: FontWeight.bold)),
      );
    }
    final cost      = game.evolutionCost(petId);
    final canAfford = game.zcoins >= cost;
    final starLabel = evo == 0 ? '○○' : '★○';
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(children: [
        Text(starLabel,
            style: TextStyle(fontSize: 13, color: petColor.withValues(alpha: 0.7))),
        const SizedBox(width: 6),
        Text(evo == 0 ? 'Evo I: 1.5× bonus' : 'Evo II: 2× bonus',
            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
        const SizedBox(width: 8),
        _CrystalCost(zcoins: cost, affordable: canAfford),
        const SizedBox(width: 6),
        _ActionButton(
          label: 'EVOLVE',
          color: canAfford ? petColor : AppTheme.cardBorder,
          onTap: canAfford
              ? () { if (game.evolvePet(petId)) game.audioService.playCoin(); }
              : null,
        ),
      ]),
    );
  }
}

// ── Boosts section ────────────────────────────────────────────────────────────

class CosmeticsBoostsSection extends StatelessWidget {
  const CosmeticsBoostsSection({required this.game, this.scrollable = true, super.key});
  final GameState game;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Waystones ─────────────────────────────────────────────────────
        Text('WAYSTONES', style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2, color: AppTheme.accentGold)),
        const SizedBox(height: 4),
        const Text(
          'Multiply idle gold income while active. Activate one before closing '
          'the app to boost offline earnings. Only one can be active at a time.',
          style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.5),
        ),
        const SizedBox(height: 8),
        if (game.waystoneActive)
          _WaystoneActiveBanner(game: game),
        const SizedBox(height: 8),
        ...WaystoneType.all.map((w) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _WaystoneCard(game: game, waystone: w),
        )),
      ],
    );
    if (!scrollable) return col;
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: col);
  }
}

// ── Attack Effects section (own section — replaces your basic attack visual) ──
class AttackEffectsSection extends StatelessWidget {
  const AttackEffectsSection({required this.game, this.scrollable = true, super.key});
  final GameState game;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ATTACK EFFECTS', style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2, color: AppTheme.accentGold)),
        const SizedBox(height: 4),
        const Text(
          'Replace your basic attack with a flashy elemental effect — shown in '
          'battle across every mode. Equip one to see it take over your hits.',
          style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.5),
        ),
        const SizedBox(height: 8),
        ...AttackEffect.all.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _AttackEffectCard(game: game, effect: e),
        )),
      ],
    );
    if (!scrollable) return col;
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: col);
  }
}

// ─── Misc section (character slots & other odds and ends) ────────────────────
class CosmeticsMiscSection extends StatelessWidget {
  const CosmeticsMiscSection({required this.game, this.scrollable = true, super.key});
  final GameState game;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Extra Character Slots ──────────────────────────────────────────
        Text('CHARACTER SLOTS', style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2, color: AppTheme.accentGold)),
        const SizedBox(height: 4),
        Text(
          'Unlock additional character save slots. You currently have '
          '${3 + game.extraCharacterSlots} of 5.',
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.5),
        ),
        const SizedBox(height: 8),
        if (game.extraCharacterSlots >= 2)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF231F1B),
              border: Border.all(color: const Color(0xFF44cc66).withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(children: [
              Text('✓ ', style: TextStyle(color: Color(0xFF44cc66))),
              Text('All 5 slots unlocked.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF44cc66))),
            ]),
          )
        else
          _SlotUnlockCard(game: game),
      ],
    );
    if (!scrollable) return col;
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: col);
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
        const Text('🌀', style: TextStyle(fontSize: 17)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Waystone active — ${mult.toStringAsFixed(1)}× idle income  ·  '
            '$mins min remaining',
            style: const TextStyle(fontSize: 12, color: Color(0xFF66aaff)),
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
    final canBuy   = game.zcoins >= waystone.zcoinCost;
    final canUse   = count > 0 && !game.waystoneActive;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(waystone.icon, style: const TextStyle(fontSize: 25)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(waystone.name,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: waystone.color)),
              const Spacer(),
              Text('Owned: $count',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            ]),
            const SizedBox(height: 2),
            Text('${waystone.durationHours}h  ·  ${waystone.multiplier.toStringAsFixed(1)}× idle income',
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            Row(children: [
              _CrystalCost(zcoins: waystone.zcoinCost, affordable: canBuy),
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
    final canBuy   = game.zcoins >= effect.zcoinCost;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: equipped ? effect.color.withValues(alpha: 0.05) : const Color(0xFF231F1B),
        border: Border.all(
            color: equipped ? effect.color.withValues(alpha: 0.6) : AppTheme.cardBorder,
            width: equipped ? 1.5 : 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        Text(effect.icon, style: const TextStyle(fontSize: 23)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(effect.name,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: effect.color)),
            const SizedBox(height: 2),
            Text('"${effect.hitText}" on every hit',
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontStyle: FontStyle.italic)),
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
            _CrystalCost(zcoins: effect.zcoinCost, affordable: canBuy),
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
    final canAfford = game.zcoins >= cost;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        const Text('🔓', style: TextStyle(fontSize: 23)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Slot ${4 + game.extraCharacterSlots}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 2),
            const Text('Add one more character save slot.',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            Row(children: [
              _CrystalCost(zcoins: cost, affordable: canAfford),
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

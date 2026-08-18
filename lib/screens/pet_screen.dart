import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/pet.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/pet_battle_sprite.dart';
import '../widgets/zcoin_icon.dart';
import 'main_shell.dart' show TutorialTip;

// -----------------------------------------------------------------------------
// PetScreen
//
// Lets the player browse, purchase, equip, and evolve their 12 pet companions.
// Unlocks at campaign stage 18.  Embedded in the HeroHub tab strip.
// -----------------------------------------------------------------------------

class PetScreen extends StatelessWidget {
  const PetScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final game     = GameStateProvider.of(context);
    final owned    = game.ownedPetIds;
    final ownedCnt = owned.length;

    final body = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TutorialTip(
          tutorialKey: 'pets',
          game: game,
          text: 'Pet companions join you in battle and stack their bonuses '
              'passively � even ones not equipped. ??  Equip one to have it '
              'appear at your side during fights.  Evolve owned pets twice '
              'to double their bonus value.',
        ),

        // -- Active bonus summary --------------------------------------------
        if (owned.isNotEmpty) ...[
          _BonusSummary(game: game),
          const SizedBox(height: 16),
        ],

        // -- Equipped slot ---------------------------------------------------
        _EquippedSlot(game: game),
        const SizedBox(height: 20),

        // -- Roster ---------------------------------------------------------
        Row(
          children: [
            Text('ROSTER',
                style: AppTheme.pixelHeading(
                    fontSize: 11, letterSpacing: 2, color: AppTheme.textMuted)),
            const Spacer(),
            Text('$ownedCnt / ${kPetCatalog.length}  owned',
                style: AppTheme.pixelHeading(
                    fontSize: 11, color: AppTheme.accentGold)),
          ],
        ),
        const SizedBox(height: 10),

        ...List.generate(kPetCatalog.length, (i) {
          final pet = kPetCatalog[i];
          return _PetCard(pet: pet, game: game)
              .animate(delay: Duration(milliseconds: 40 * i))
              .fadeIn(duration: 280.ms)
              .slideY(begin: 0.04, duration: 280.ms, curve: Curves.easeOut);
        }),
        const SizedBox(height: 8),
      ],
    );

    if (embedded) {
      return Container(color: const Color(0xFF1B1A17), child: body);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('COMPANIONS',
            style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const ZCoinIcon(size: 16),
                Text(game.zcoins.toString(),
                    style: AppTheme.pixelHeading(
                        fontSize: 13, color: const Color(0xFF66aaff))),
              ],
            ),
          ),
        ],
      ),
      body: body,
    );
  }
}

// -- Active bonus summary bar --------------------------------------------------

class _BonusSummary extends StatelessWidget {
  const _BonusSummary({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final chips = <({String label, String value})>[];
    void add(String lbl, int v, String suffix) {
      if (v > 0) chips.add((label: lbl, value: '+$v$suffix'));
    }

    add('Gold',   game.petGoldPct,     '%');
    add('XP',     game.petXpPct,       '%');
    add('HP',     game.petHpRegen,     ' regen');
    add('Idle',   game.petIdleRate,    ' rate');
    add('Atk',    game.petAttackBonus, '');
    add('Dmg',    game.petDamage,      '');
    add('AC',     game.petArmor,       '');
    add('Shards', game.petShards,      '');
    add('Dodge',  game.petDodgeChance, '%');
    add('Ess',    game.petEssenceGain, '%');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a2010),
        border: Border.all(color: const Color(0xFF446633)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ACTIVE BONUSES (all owned pets)',
              style: AppTheme.pixelHeading(
                  fontSize: 10, letterSpacing: 1, color: const Color(0xFF88cc66))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: chips.map((c) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF223318),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF446633)),
              ),
              child: Text('${c.label}  ${c.value}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFFaaddaa))),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// -- Equipped pet slot ---------------------------------------------------------

class _EquippedSlot extends StatelessWidget {
  const _EquippedSlot({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final pet = game.equippedPet;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(
            color: pet != null ? AppTheme.accentGold : AppTheme.cardBorder,
            width: pet != null ? 1.5 : 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: pet == null
          ? Row(
              children: [
                const Text('??', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('No companion equipped',
                          style: AppTheme.pixelHeading(
                              fontSize: 13, color: AppTheme.textMuted)),
                      const SizedBox(height: 4),
                      const Text('Equip a pet to have it appear in battle.',
                          style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              children: [
                SizedBox(
                  width: 64, height: 64,
                  child: PetBattleSprite(pet: pet),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(pet.name,
                            style: AppTheme.pixelHeading(
                                fontSize: 14, color: AppTheme.accentGold)),
                        const SizedBox(width: 8),
                        _EvoStars(level: game.petEvolutionLevel(pet.id)),
                      ]),
                      const SizedBox(height: 2),
                      Text(pet.flavorLine,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textMuted,
                              fontStyle: FontStyle.italic)),
                      const SizedBox(height: 4),
                      Text(_bonusLabel(pet, game),
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFFaaddaa))),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    game.equipPet(null);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textMuted,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: const Size(0, 36),
                  ),
                  child: const Text('UNEQUIP',
                      style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
    );
  }
}

// -- Individual pet card -------------------------------------------------------

class _PetCard extends StatelessWidget {
  const _PetCard({required this.pet, required this.game});
  final PetDefinition pet;
  final GameState     game;

  @override
  Widget build(BuildContext context) {
    final isOwned    = game.ownedPetIds.contains(pet.id);
    final isEquipped = game.equippedPetId == pet.id;
    final evoLevel   = game.petEvolutionLevel(pet.id);
    final evoCost    = game.evolutionCost(pet.id);
    final canEvolve  = isOwned && evoLevel < 10;
    final canAffordEvo = game.zcoins >= evoCost;
    final canBuy     = !isOwned && game.zcoins >= pet.zcoinCost;

    final premium = pet.isPremium;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Premium pets get a golden gradient + glow so they stand out like the
        // premium class skins.
        gradient: premium
            ? LinearGradient(
                colors: [pet.color.withValues(alpha: 0.22), AppTheme.accentGold.withValues(alpha: 0.14)],
                begin: Alignment.topLeft, end: Alignment.bottomRight)
            : null,
        color: premium
            ? null
            : (isEquipped ? const Color(0xFF2a2516) : const Color(0xFF231F1B)),
        border: Border.all(
            color: premium
                ? AppTheme.accentGold
                : isEquipped
                    ? AppTheme.accentGold
                    : isOwned
                        ? const Color(0xFF446633)
                        : AppTheme.cardBorder,
            width: premium ? 1.5 : 1),
        borderRadius: BorderRadius.circular(6),
        boxShadow: premium
            ? [BoxShadow(color: AppTheme.accentGold.withValues(alpha: 0.35), blurRadius: 10)]
            : null,
      ),
      child: Row(
        children: [
          // -- Sprite / emoji ----------------------------------------------
          SizedBox(
            width: 56, height: 56,
            child: isOwned
                ? PetBattleSprite(pet: pet)
                : ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      0.3, 0.3, 0.3, 0, 0,
                      0.3, 0.3, 0.3, 0, 0,
                      0.3, 0.3, 0.3, 0, 0,
                      0,   0,   0,   1, 0,
                    ]),
                    child: PetBattleSprite(pet: pet),
                  ),
          ),
          const SizedBox(width: 12),

          // -- Info --------------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(
                    child: Text(pet.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: premium
                                ? AppTheme.accentGoldBright
                                : (isOwned ? AppTheme.textLight : AppTheme.textMuted))),
                  ),
                  if (premium) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text('★ PREMIUM',
                          style: AppTheme.pixelHeading(fontSize: 8, color: AppTheme.accentGoldBright)),
                    ),
                  ],
                  if (isOwned) ...[
                    const SizedBox(width: 6),
                    _EvoStars(level: evoLevel),
                  ],
                  if (isEquipped) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3a2e10),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.accentGold),
                      ),
                      child: Text('IN BATTLE',
                          style: AppTheme.pixelHeading(
                              fontSize: 9, color: AppTheme.accentGold)),
                    ),
                  ],
                ]),
                const SizedBox(height: 3),
                Text(_bonusLabel(pet, game),
                    style: TextStyle(
                        fontSize: 13,
                        color: isOwned
                            ? const Color(0xFFaaddaa)
                            : AppTheme.textMuted)),
                if (!isOwned)
                  Text(pet.description,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textMuted,
                          fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // -- Actions -----------------------------------------------------
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isOwned && pet.isPremium)
                Builder(builder: (_) {
                  final storePrice = game.iapService.priceFor(pet.productId!);
                  final ready = game.iapService.storeAvailable && storePrice.isNotEmpty;
                  return _ActionButton(
                    label: ready
                        ? storePrice
                        : (pet.fallbackPrice.isNotEmpty ? pet.fallbackPrice : 'REAL MONEY'),
                    enabled: ready,
                    color: const Color(0xFF663322),
                    onTap: () => game.iapService.buyNonConsumable(pet.productId!),
                  );
                })
              else if (!isOwned)
                _ActionButton(
                  label: '${pet.zcoinCost}',
                  prefixIcon: const ZCoinIcon(size: 12, animate: false),
                  enabled: canBuy,
                  color: const Color(0xFF334466),
                  onTap: () => _confirmBuy(context, game),
                )
              else if (!isEquipped)
                _ActionButton(
                  label: 'EQUIP',
                  enabled: true,
                  color: const Color(0xFF335533),
                  onTap: () => game.equipPet(pet.id),
                )
              else
                _ActionButton(
                  label: 'EQUIPPED',
                  enabled: false,
                  color: const Color(0xFF2a2516),
                  onTap: () {},
                ),
              if (isOwned && canEvolve) ...[
                const SizedBox(height: 6),
                _EvolveButton(
                  nextEvoLevel: evoLevel + 1,
                  cost: evoCost,
                  canAfford: canAffordEvo,
                  onTap: () => _confirmEvolve(context, game, evoCost),
                ),
              ],
              if (isOwned && evoLevel >= 10) ...[
                const SizedBox(height: 4),
                Text('MAX', style: AppTheme.pixelHeading(
                    fontSize: 10, color: AppTheme.accentGold)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _confirmBuy(BuildContext context, GameState game) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('Recruit ${pet.name}?',
            style: AppTheme.pixelHeading(
                fontSize: 13, color: AppTheme.accentGold)),
        content: Text(
          '${pet.description}\n\nBonus: ${pet.bonusLabel}\n\nCost: ${pet.zcoinCost} ZCoins',
          style: const TextStyle(fontSize: 14, color: AppTheme.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL',
                style: AppTheme.pixelHeading(
                    fontSize: 12, color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              game.purchasePet(pet.id);
            },
            child: Text('RECRUIT',
                style: AppTheme.pixelHeading(
                    fontSize: 12, color: AppTheme.accentGold)),
          ),
        ],
      ),
    );
  }

  void _confirmEvolve(BuildContext context, GameState game, int cost) {
    final nextLevel = game.petEvolutionLevel(pet.id) + 1;
    final nextBonus = _evolvedBonus(pet.bonusValue, nextLevel);
    final suffix    = _bonusSuffix(pet.bonusType);

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('Evolve ${pet.name}?',
            style: AppTheme.pixelHeading(
                fontSize: 13, color: AppTheme.accentGold)),
        content: Text(
          'Upgrade to Evolution $nextLevel.\n\n'
          'New bonus: +$nextBonus$suffix\nCost: $cost ZCoins',
          style: const TextStyle(fontSize: 14, color: AppTheme.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL',
                style: AppTheme.pixelHeading(
                    fontSize: 12, color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              game.evolvePet(pet.id);
            },
            child: Text('EVOLVE',
                style: AppTheme.pixelHeading(
                    fontSize: 12, color: AppTheme.accentGold)),
          ),
        ],
      ),
    );
  }
}

// -- Small helpers -------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.enabled,
    required this.color,
    required this.onTap,
    this.prefixIcon,
  });
  final String       label;
  final bool         enabled;
  final Color        color;
  final VoidCallback onTap;
  final Widget?      prefixIcon;

  @override
  Widget build(BuildContext context) {
    final textColor = enabled ? Colors.white : AppTheme.textMuted;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: enabled ? color : const Color(0xFF1e1e1e),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
              color: enabled ? color.withValues(alpha: 1) : AppTheme.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefixIcon != null) ...[prefixIcon!, const SizedBox(width: 4)],
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
          ],
        ),
      ),
    );
  }
}

class _EvoStars extends StatelessWidget {
  const _EvoStars({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    if (level == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2200),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5)),
      ),
      child: Text(
        '★$level',
        style: const TextStyle(fontSize: 10, color: AppTheme.accentGold, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _EvolveButton extends StatelessWidget {
  const _EvolveButton({
    required this.nextEvoLevel,
    required this.cost,
    required this.canAfford,
    required this.onTap,
  });

  final int nextEvoLevel;
  final int cost;
  final bool canAfford;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor  = const Color(0xFFffaa44);
    final borderColor  = canAfford ? activeColor.withValues(alpha: 0.7) : AppTheme.cardBorder;
    final bgColor      = canAfford ? const Color(0xFF2a1e00) : const Color(0xFF1e1e1e);

    return GestureDetector(
      onTap: canAfford ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tier image
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Image.asset(
                'assets/images/tier_$nextEvoLevel.png',
                width: 28,
                height: 32,
                fit: BoxFit.cover,
                opacity: AlwaysStoppedAnimation(canAfford ? 1.0 : 0.35),
                errorBuilder: (_, __, ___) => Container(
                  width: 28, height: 32,
                  color: canAfford
                      ? activeColor.withValues(alpha: 0.2)
                      : Colors.transparent,
                  child: Center(
                    child: Text('T$nextEvoLevel',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: canAfford ? activeColor : AppTheme.textMuted)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('EVOLVE  Evo $nextEvoLevel',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: canAfford ? activeColor : AppTheme.textMuted)),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ZCoinIcon(size: 11, animate: false),
                    const SizedBox(width: 3),
                    Text('$cost',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: canAfford ? Colors.white : AppTheme.textMuted)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -- Pure helpers (no widget state) -------------------------------------------

int _evolvedBonus(int base, int evoLevel) =>
    (base * (1.0 + evoLevel * 0.3)).round();

String _bonusSuffix(PetBonusType type) => switch (type) {
  PetBonusType.goldPct     => '% gold',
  PetBonusType.xpPct       => '% XP',
  PetBonusType.essenceGain => '% essence',
  PetBonusType.dodgeChance => '% dodge',
  PetBonusType.hpRegen     => ' HP regen',
  PetBonusType.idleRate    => ' idle rate',
  PetBonusType.attackBonus => ' crit dmg',
  PetBonusType.armor       => ' AC',
  PetBonusType.damage      => ' damage',
  PetBonusType.shardBonus  => ' shards',
};

String _bonusLabel(PetDefinition pet, GameState game) {
  final evoLevel = game.petEvolutionLevel(pet.id);
  final isOwned  = game.ownedPetIds.contains(pet.id);
  // Omni pet (dragon): show a couple of headline bonuses + "ALL".
  if (pet.omniBonuses != null) {
    final g = isOwned ? _evolvedBonus(pet.omniBonuses![PetBonusType.goldPct] ?? 0, evoLevel)
                      : pet.omniBonuses![PetBonusType.goldPct] ?? 0;
    final d = isOwned ? _evolvedBonus(pet.omniBonuses![PetBonusType.damage] ?? 0, evoLevel)
                      : pet.omniBonuses![PetBonusType.damage] ?? 0;
    return 'ALL bonuses — e.g. +$g% gold, +$d damage';
  }
  final bonus    = isOwned ? _evolvedBonus(pet.bonusValue, evoLevel) : pet.bonusValue;
  return '+$bonus${_bonusSuffix(pet.bonusType)}';
}

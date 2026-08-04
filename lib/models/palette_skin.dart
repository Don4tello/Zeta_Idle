import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'pet.dart' show PetBonusType;
import 'dnd_class.dart';

/// Build a 4×5 colour matrix that rotates hue, scales saturation and offsets
/// brightness — shared by cosmetic skins and subclass tints.
List<double> buildPaletteMatrix(double hueShift, double saturation, double brightness) {
  final rad  = hueShift * math.pi / 180.0;
  final cosA = math.cos(rad);
  final sinA = math.sin(rad);

  final rr = 0.213 + cosA * 0.787 - sinA * 0.213;
  final rg = 0.715 - cosA * 0.715 - sinA * 0.715;
  final rb = 0.072 - cosA * 0.072 + sinA * 0.928;
  final gr = 0.213 - cosA * 0.213 + sinA * 0.143;
  final gg = 0.715 + cosA * 0.285 + sinA * 0.140;
  final gb = 0.072 - cosA * 0.072 - sinA * 0.283;
  final br = 0.213 - cosA * 0.213 - sinA * 0.787;
  final bg = 0.715 - cosA * 0.715 + sinA * 0.715;
  final bb = 0.072 + cosA * 0.928 + sinA * 0.072;

  const lR = 0.2126, lG = 0.7152, lB = 0.0722;
  final s   = saturation;
  final srR = lR + s * (1 - lR);   final srG = lG - s * lG;           final srB = lB - s * lB;
  final sgR = lR - s * lR;          final sgG = lG + s * (1 - lG);     final sgB = lB - s * lB;
  final sbR = lR - s * lR;          final sbG = lG - s * lG;           final sbB = lB + s * (1 - lB);

  final bv = brightness;
  return [
    srR*rr + srG*gr + srB*br,  srR*rg + srG*gg + srB*bg,  srR*rb + srG*gb + srB*bb,  0, bv,
    sgR*rr + sgG*gr + sgB*br,  sgR*rg + sgG*gg + sgB*bg,  sgR*rb + sgG*gb + sgB*bb,  0, bv,
    sbR*rr + sbG*gr + sbB*br,  sbR*rg + sbG*gg + sbB*bg,  sbR*rb + sbG*gb + sbB*bb,  0, bv,
    0,                         0,                          0,                          1, 0,
  ];
}

class PaletteSkin {
  const PaletteSkin({
    required this.id,
    required this.name,
    required this.description,
    required this.zcoinCost,
    required this.hueShift,
    required this.saturation,
    required this.brightness,
    required this.previewColor,
    required this.bonusType,
    required this.bonusValue,
  });

  final String id;
  final String name;
  final String description;
  final int zcoinCost;
  final double hueShift;    // degrees 0–360 rotates the hue wheel
  final double saturation;  // 0 = grayscale, 1 = original, >1 = vivid
  final double brightness;  // channel offset −128 to +128
  final Color previewColor; // representative swatch color shown in shop
  final PetBonusType bonusType;
  final int bonusValue;

  String get bonusLabel {
    final v = bonusValue;
    return switch (bonusType) {
      PetBonusType.goldPct     => '+$v% gold per kill',
      PetBonusType.xpPct       => '+$v% XP per kill',
      PetBonusType.hpRegen     => '+$v HP after each victory',
      PetBonusType.idleRate    => '+$v idle rate',
      PetBonusType.attackBonus => '+$v critical damage',
      PetBonusType.armor       => '+$v AC',
      PetBonusType.damage      => '+$v damage',
      PetBonusType.shardBonus  => '+$v shard per kill',
      PetBonusType.dodgeChance => '+$v% dodge chance',
      PetBonusType.essenceGain => '+$v% essence from kills',
    };
  }

  ColorFilter toColorFilter() =>
      ColorFilter.matrix(buildPaletteMatrix(hueShift, saturation, brightness));
}

const kSkinCatalog = <PaletteSkin>[
  PaletteSkin(
    id: 'bone_knight',
    name: 'Bone Knight',
    description: 'Bleached pale as ancient bone and funeral ivory.',
    zcoinCost: 300,
    hueShift: 0,
    saturation: 0.12,
    brightness: 50,
    previewColor: Color(0xFFe8e0d0),
    bonusType: PetBonusType.armor,
    bonusValue: 1,
  ),
  PaletteSkin(
    id: 'shadowblood',
    name: 'Shadowblood',
    description: 'Dark as midnight, red as fresh wounds.',
    zcoinCost: 350,
    hueShift: 345,
    saturation: 1.7,
    brightness: -35,
    previewColor: Color(0xFF880022),
    bonusType: PetBonusType.damage,
    bonusValue: 1,
  ),
  PaletteSkin(
    id: 'gilded',
    name: 'Gilded',
    description: "Armour worth a kingdom's ransom.",
    zcoinCost: 400,
    hueShift: 38,
    saturation: 1.4,
    brightness: 15,
    previewColor: Color(0xFFcc9922),
    bonusType: PetBonusType.goldPct,
    bonusValue: 3,
  ),
  PaletteSkin(
    id: 'void_walker',
    name: 'Void Walker',
    description: 'Imbued with the swirling colours of the abyss.',
    zcoinCost: 450,
    hueShift: 265,
    saturation: 1.5,
    brightness: -20,
    previewColor: Color(0xFF6600cc),
    bonusType: PetBonusType.xpPct,
    bonusValue: 2,
  ),
  PaletteSkin(
    id: 'frost',
    name: 'Frost',
    description: 'Cold as the eternal northern wastes.',
    zcoinCost: 350,
    hueShift: 200,
    saturation: 1.25,
    brightness: 10,
    previewColor: Color(0xFF44aacc),
    bonusType: PetBonusType.hpRegen,
    bonusValue: 2,
  ),
  PaletteSkin(
    id: 'infernal',
    name: 'Infernal',
    description: 'Forged where the bedrock itself burns.',
    zcoinCost: 400,
    hueShift: 18,
    saturation: 1.6,
    brightness: -5,
    previewColor: Color(0xFFdd4400),
    bonusType: PetBonusType.attackBonus,
    bonusValue: 1,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Premium class skins — hand-painted endgame-armour variants.
//
// Unlike PaletteSkin (a colour-matrix recolour of the base sprite), a premium
// skin swaps in a bespoke class painter ('premium_<class>'). Real-money only
// ($4.99), one per class. Purely cosmetic — no gameplay bonus.
// ─────────────────────────────────────────────────────────────────────────────
class PremiumSkinDef {
  const PremiumSkinDef({
    required this.id,
    required this.name,
    required this.heroClass,
    required this.description,
    required this.previewColor,
    required this.accentColor,
  });

  final String id;              // == painter key, e.g. 'premium_druid'
  final String name;
  final DndClass heroClass;
  final String description;
  final Color previewColor;     // dominant material colour
  final Color accentColor;      // gem / glow accent

  /// Store product id for the real-money purchase.
  String get productId => 'skin_$id';
  /// Fallback price shown when the store hasn't returned a localized price.
  String get fallbackPrice => '\$4.99';
}

const kPremiumSkinCatalog = <PremiumSkinDef>[
  PremiumSkinDef(
    id: 'premium_barbarian', name: 'Ragescale Warlord', heroClass: DndClass.barbarian,
    description: 'Obsidian horns and bronze war-plate wreathed in living rage-fire.',
    previewColor: Color(0xFF9a6a28), accentColor: Color(0xFFff5028),
  ),
  PremiumSkinDef(
    id: 'premium_bard', name: 'Gilded Maestro', heroClass: DndClass.bard,
    description: 'Royal violet brocade, gold frogging and a jewelled peacock plume.',
    previewColor: Color(0xFF6a2ea8), accentColor: Color(0xFFffe880),
  ),
  PremiumSkinDef(
    id: 'premium_cleric', name: 'Radiant Hierophant', heroClass: DndClass.cleric,
    description: 'Ivory-and-gold vestments crowned by a living halo of light.',
    previewColor: Color(0xFFf0ecdc), accentColor: Color(0xFFffe880),
  ),
  PremiumSkinDef(
    id: 'premium_druid', name: 'Worldroot Archdruid', heroClass: DndClass.druid,
    description: 'Living-wood armour, gilded antlers and a glowing heartwood staff.',
    previewColor: Color(0xFF2e5424), accentColor: Color(0xFF3affa0),
  ),
  PremiumSkinDef(
    id: 'premium_fighter', name: 'Dragonguard Champion', heroClass: DndClass.fighter,
    description: 'Winged dragon-crest plate, a ruby heart and a runed greatsword.',
    previewColor: Color(0xFF8a94a8), accentColor: Color(0xFFcc2028),
  ),
  PremiumSkinDef(
    id: 'premium_monk', name: 'Celestial Ascendant', heroClass: DndClass.monk,
    description: 'Jade-and-gold silk with chi-lit wraps and an enlightened aura.',
    previewColor: Color(0xFF1f8a70), accentColor: Color(0xFF80ffe0),
  ),
  PremiumSkinDef(
    id: 'premium_ranger', name: 'Emerald Warden', heroClass: DndClass.ranger,
    description: 'Silver-studded emerald leathers and quiver of glowing arrows.',
    previewColor: Color(0xFF1e5a3c), accentColor: Color(0xFF60ffb0),
  ),
  PremiumSkinDef(
    id: 'premium_rogue', name: 'Umbral Nightblade', heroClass: DndClass.rogue,
    description: 'Obsidian leather and silver edges lit by twin amethyst blades.',
    previewColor: Color(0xFF1c1a2e), accentColor: Color(0xFFb060ff),
  ),
  PremiumSkinDef(
    id: 'premium_sorcerer', name: 'Astral Archon', heroClass: DndClass.sorcerer,
    description: 'Sapphire-and-gold robes, starlit hair and a radiant astral orb.',
    previewColor: Color(0xFF243aa8), accentColor: Color(0xFFb070ff),
  ),
  PremiumSkinDef(
    id: 'premium_warlock', name: 'Voidbound Herald', heroClass: DndClass.warlock,
    description: 'Crowned demonic helm and gold-edged robes seething with eldritch fire.',
    previewColor: Color(0xFF6a20c8), accentColor: Color(0xFF40ff70),
  ),
  PremiumSkinDef(
    id: 'premium_wizard', name: 'Astral Archmage', heroClass: DndClass.wizard,
    description: 'Indigo star-robes with a constellation trim and radiant gem-staff.',
    previewColor: Color(0xFF262098), accentColor: Color(0xFF80d0ff),
  ),
  PremiumSkinDef(
    id: 'premium_paladin', name: 'Dawnbringer', heroClass: DndClass.paladin,
    description: 'Winged radiant plate, sapphire sun-cross and a halo of dawnlight.',
    previewColor: Color(0xFFeef2fb), accentColor: Color(0xFF90c8ff),
  ),
];

PremiumSkinDef? premiumSkinById(String? id) {
  if (id == null) return null;
  for (final s in kPremiumSkinCatalog) {
    if (s.id == id) return s;
  }
  return null;
}

PremiumSkinDef? premiumSkinForClass(DndClass cls) {
  for (final s in kPremiumSkinCatalog) {
    if (s.heroClass == cls) return s;
  }
  return null;
}

/// Premium skins bundle the bonuses of EVERY ZCoin skin in the shop.
/// Derived from kSkinCatalog so it stays in sync if those skins change.
List<String> premiumSkinBonusLabels() =>
    kSkinCatalog.map((s) => s.bonusLabel).toList();

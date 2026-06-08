import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'pet.dart' show PetBonusType;

class PaletteSkin {
  const PaletteSkin({
    required this.id,
    required this.name,
    required this.description,
    required this.crystalCost,
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
  final int crystalCost;
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
      PetBonusType.attackBonus => '+$v to attack rolls',
      PetBonusType.armor       => '+$v AC',
      PetBonusType.damage      => '+$v damage',
      PetBonusType.shardBonus  => '+$v shard per kill',
      PetBonusType.dodgeChance => '+$v% dodge chance',
      PetBonusType.essenceGain => '+$v% essence from kills',
    };
  }

  ColorFilter toColorFilter() => ColorFilter.matrix(_buildMatrix());

  List<double> _buildMatrix() {
    final rad  = hueShift * math.pi / 180.0;
    final cosA = math.cos(rad);
    final sinA = math.sin(rad);

    // Hue rotation coefficients
    final rr = 0.213 + cosA * 0.787 - sinA * 0.213;
    final rg = 0.715 - cosA * 0.715 - sinA * 0.715;
    final rb = 0.072 - cosA * 0.072 + sinA * 0.928;
    final gr = 0.213 - cosA * 0.213 + sinA * 0.143;
    final gg = 0.715 + cosA * 0.285 + sinA * 0.140;
    final gb = 0.072 - cosA * 0.072 - sinA * 0.283;
    final br = 0.213 - cosA * 0.213 - sinA * 0.787;
    final bg = 0.715 - cosA * 0.715 + sinA * 0.715;
    final bb = 0.072 + cosA * 0.928 + sinA * 0.072;

    // Saturation rows (applied on top of hue rotation)
    const lR = 0.2126, lG = 0.7152, lB = 0.0722;
    final s   = saturation;
    final srR = lR + s * (1 - lR);   final srG = lG - s * lG;           final srB = lB - s * lB;
    final sgR = lR - s * lR;          final sgG = lG + s * (1 - lG);     final sgB = lB - s * lB;
    final sbR = lR - s * lR;          final sbG = lG - s * lG;           final sbB = lB + s * (1 - lB);

    // Composed C = Saturation × Hue
    final bv = brightness;
    return [
      srR*rr + srG*gr + srB*br,  srR*rg + srG*gg + srB*bg,  srR*rb + srG*gb + srB*bb,  0, bv,
      sgR*rr + sgG*gr + sgB*br,  sgR*rg + sgG*gg + sgB*bg,  sgR*rb + sgG*gb + sgB*bb,  0, bv,
      sbR*rr + sbG*gr + sbB*br,  sbR*rg + sbG*gg + sbB*bg,  sbR*rb + sbG*gb + sbB*bb,  0, bv,
      0,                         0,                          0,                          1, 0,
    ];
  }
}

const kSkinCatalog = <PaletteSkin>[
  PaletteSkin(
    id: 'bone_knight',
    name: 'Bone Knight',
    description: 'Bleached pale as ancient bone and funeral ivory.',
    crystalCost: 300,
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
    crystalCost: 350,
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
    crystalCost: 400,
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
    crystalCost: 450,
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
    crystalCost: 350,
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
    crystalCost: 400,
    hueShift: 18,
    saturation: 1.6,
    brightness: -5,
    previewColor: Color(0xFFdd4400),
    bonusType: PetBonusType.attackBonus,
    bonusValue: 1,
  ),
];

import 'package:flutter/material.dart' show Color;

enum HeroRace {
  human,
  elf,
  dwarf,
  halfling,
  gnome,
  halfElf,
  halfOrc,
  tiefling,
  dragonborn,
  aasimar,
}

class HeroRaceInfo {
  const HeroRaceInfo({
    required this.displayName,
    required this.icon,
    required this.description,
    required this.traitName,
    required this.color,
  });

  final String displayName;
  final String icon;
  final String description;
  final String traitName;
  final Color  color;
}

const _kRaceInfo = <HeroRace, HeroRaceInfo>{
  HeroRace.human: HeroRaceInfo(
    displayName: 'Human',
    icon: '👤',
    description: 'Ambitious and adaptable, humans rise everywhere.',
    traitName: 'Indomitable Will',
    color: Color(0xFFcc9944),   // warm amber
  ),
  HeroRace.elf: HeroRaceInfo(
    displayName: 'Elf',
    icon: '🌿',
    description: 'Ancient, perceptive, and touched by the Feywild.',
    traitName: 'Fey Sight',
    color: Color(0xFF44cc88),   // emerald
  ),
  HeroRace.dwarf: HeroRaceInfo(
    displayName: 'Dwarf',
    icon: '⚒',
    description: 'Stout and stubborn, built from stone and iron.',
    traitName: 'Ironblood',
    color: Color(0xFF8899bb),   // steel blue
  ),
  HeroRace.halfling: HeroRaceInfo(
    displayName: 'Halfling',
    icon: '🍀',
    description: 'Small in stature, big in luck and heart.',
    traitName: "Fortune's Favor",
    color: Color(0xFF88dd44),   // lucky lime
  ),
  HeroRace.gnome: HeroRaceInfo(
    displayName: 'Gnome',
    icon: '⚙',
    description: 'Clever tinkerers with a knack for magic.',
    traitName: 'Eureka',
    color: Color(0xFF44aaff),   // electric blue
  ),
  HeroRace.halfElf: HeroRaceInfo(
    displayName: 'Half-Elf',
    icon: '🌙',
    description: 'Blending human drive with elven grace.',
    traitName: 'Dual Heritage',
    color: Color(0xFF9966cc),   // soft purple
  ),
  HeroRace.halfOrc: HeroRaceInfo(
    displayName: 'Half-Orc',
    icon: '💀',
    description: 'Raw power tempered by brutal endurance.',
    traitName: 'Savage Endurance',
    color: Color(0xFFcc4444),   // blood red
  ),
  HeroRace.tiefling: HeroRaceInfo(
    displayName: 'Tiefling',
    icon: '🔥',
    description: 'Infernal blood runs through their veins.',
    traitName: 'Hellfire Pact',
    color: Color(0xFFcc44aa),   // infernal magenta
  ),
  HeroRace.dragonborn: HeroRaceInfo(
    displayName: 'Dragonborn',
    icon: '🐉',
    description: 'Draconic blood grants breath and scale.',
    traitName: 'Draconic Legacy',
    color: Color(0xFFdd7722),   // dragon orange
  ),
  HeroRace.aasimar: HeroRaceInfo(
    displayName: 'Aasimar',
    icon: '✨',
    description: 'Touched by celestial grace and divine light.',
    traitName: 'Celestial Grace',
    color: Color(0xFF88ccff),   // celestial blue
  ),
};

extension HeroRaceExt on HeroRace {
  HeroRaceInfo get info => _kRaceInfo[this]!;
}

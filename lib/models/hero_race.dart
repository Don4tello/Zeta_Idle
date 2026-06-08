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
    required this.tags,
  });

  final String displayName;
  final String icon;
  final String description;
  final String tags; // compact D&D trait labels shown on the race card
}

const _kRaceInfo = <HeroRace, HeroRaceInfo>{
  HeroRace.human: HeroRaceInfo(
    displayName: 'Human',
    icon: '👤',
    description: 'Ambitious and adaptable, humans rise everywhere.',
    tags: 'Versatile • Determined',
  ),
  HeroRace.elf: HeroRaceInfo(
    displayName: 'Elf',
    icon: '🌿',
    description: 'Ancient, perceptive, and touched by the Feywild.',
    tags: 'Fey Ancestry • Keen Senses',
  ),
  HeroRace.dwarf: HeroRaceInfo(
    displayName: 'Dwarf',
    icon: '⚒',
    description: 'Stout and stubborn, built from stone and iron.',
    tags: 'Resilience • Stonecunning',
  ),
  HeroRace.halfling: HeroRaceInfo(
    displayName: 'Halfling',
    icon: '🍀',
    description: 'Small in stature, big in luck and heart.',
    tags: 'Lucky • Brave',
  ),
  HeroRace.gnome: HeroRaceInfo(
    displayName: 'Gnome',
    icon: '⚙',
    description: 'Clever tinkerers with a knack for magic.',
    tags: 'Gnome Cunning • Tinker',
  ),
  HeroRace.halfElf: HeroRaceInfo(
    displayName: 'Half-Elf',
    icon: '🌙',
    description: 'Blending human drive with elven grace.',
    tags: 'Fey Heritage • Charismatic',
  ),
  HeroRace.halfOrc: HeroRaceInfo(
    displayName: 'Half-Orc',
    icon: '💀',
    description: 'Raw power tempered by brutal endurance.',
    tags: 'Relentless • Savage Attacks',
  ),
  HeroRace.tiefling: HeroRaceInfo(
    displayName: 'Tiefling',
    icon: '🔥',
    description: 'Infernal blood runs through their veins.',
    tags: 'Hellish Resistance • Infernal Legacy',
  ),
  HeroRace.dragonborn: HeroRaceInfo(
    displayName: 'Dragonborn',
    icon: '🐉',
    description: 'Draconic blood grants breath and scale.',
    tags: 'Breath Weapon • Draconic Scales',
  ),
  HeroRace.aasimar: HeroRaceInfo(
    displayName: 'Aasimar',
    icon: '✨',
    description: 'Touched by celestial grace and divine light.',
    tags: 'Celestial Resistance • Divine Strike',
  ),
};

extension HeroRaceExt on HeroRace {
  HeroRaceInfo get info => _kRaceInfo[this]!;
}

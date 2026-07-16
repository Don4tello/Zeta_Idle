enum RebirthBoonEffect {
  tripleGold,
  bonusShards,
  bonusSouls,
  rareWeapon,
  mythrilCache,
  bonusXpThisRun,
}

class RebirthBoon {
  const RebirthBoon({
    required this.id,
    required this.name,
    required this.icon,
    required this.tagline,
    required this.description,
    required this.effect,
  });

  final String id;
  final String name;
  final String icon;
  final String tagline;
  final String description;
  final RebirthBoonEffect effect;

  static const all = <RebirthBoon>[
    RebirthBoon(
      id: 'warchest',
      name: 'Warchest',
      icon: '💰',
      tagline: '3× Starting Gold',
      description: 'Your starting gold is tripled — coin from blood spilled in a previous life.',
      effect: RebirthBoonEffect.tripleGold,
    ),
    RebirthBoon(
      id: 'shard_windfall',
      name: 'Shard Windfall',
      icon: '◆',
      tagline: '+300 Bonus Shards',
      description: 'Crystal shards fall from the ether — legacy of a life well-fought.',
      effect: RebirthBoonEffect.bonusShards,
    ),
    RebirthBoon(
      id: 'soul_surge',
      name: 'Soul Surge',
      icon: '☠',
      tagline: '+30 Extra Souls',
      description: 'The cycle condenses — claim thirty extra souls from this rebirth.',
      effect: RebirthBoonEffect.bonusSouls,
    ),
    RebirthBoon(
      id: 'blood_sigil',
      name: 'Blood Sigil',
      icon: '⚔',
      tagline: 'Start with a Rare Weapon',
      description: 'A weapon from a former life materialises in your hands, still sharp.',
      effect: RebirthBoonEffect.rareWeapon,
    ),
    RebirthBoon(
      id: 'mythril_cache',
      name: 'Mythril Cache',
      icon: '⬡',
      tagline: '+25 Mythril',
      description: 'Ancient veins remember you — a cache of Mythril awaits your return.',
      effect: RebirthBoonEffect.mythrilCache,
    ),
    RebirthBoon(
      id: 'ancestral_wisdom',
      name: 'Ancestral Wisdom',
      icon: '📚',
      tagline: '+60% XP This Run',
      description: 'Memories of past lives accelerate your growth — for one run only.',
      effect: RebirthBoonEffect.bonusXpThisRun,
    ),
  ];
}

enum RebirthChallenge { none, ruthless, pauper, ascetic }

extension RebirthChallengeInfo on RebirthChallenge {
  String get icon => switch (this) {
        RebirthChallenge.none     => '',
        RebirthChallenge.ruthless => '💀',
        RebirthChallenge.pauper   => '🩸',
        RebirthChallenge.ascetic  => '⛓',
      };

  String get label => switch (this) {
        RebirthChallenge.none     => 'No Challenge',
        RebirthChallenge.ruthless => 'Ruthless',
        RebirthChallenge.pauper   => 'Bloodpact',
        RebirthChallenge.ascetic  => 'Ascetic',
      };

  String get description => switch (this) {
        RebirthChallenge.none     => '',
        RebirthChallenge.ruthless => 'Your max HP is reduced by 25%. Enemies hit harder.',
        RebirthChallenge.pauper   => 'Starting gold bonuses from the prestige shop are disabled.',
        RebirthChallenge.ascetic  => 'Campaign battle gold income is reduced by 30%.',
      };

  int get bonusSouls => switch (this) {
        RebirthChallenge.none     => 0,
        RebirthChallenge.ruthless => 35,
        RebirthChallenge.pauper   => 30,
        RebirthChallenge.ascetic  => 25,
      };
}

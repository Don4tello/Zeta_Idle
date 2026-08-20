import 'dart:math' as math;
import 'equipment.dart' show ItemRarity;

/// Display helpers for the boon rarity tiers (Uncommon → Legendary), matching
/// the item rarity palette.
extension BoonRarityDisplay on ItemRarity {
  String get boonLabel => switch (this) {
        ItemRarity.uncommon  => 'Uncommon',
        ItemRarity.rare      => 'Rare',
        ItemRarity.epic      => 'Epic',
        ItemRarity.legendary => 'Legendary',
        _                    => 'Common',
      };
  int get boonColorValue => switch (this) {
        ItemRarity.uncommon  => 0xFF55cc55,
        ItemRarity.rare      => 0xFF6699ff,
        ItemRarity.epic      => 0xFFcc44ff,
        ItemRarity.legendary => 0xFFFFD700,
        _                    => 0xFFaaaaaa,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Rebirth Boons — a gift you keep into your next life, chosen at Rebirth.
// 27 boons across 4 rarities (Uncommon → Legendary), mirroring item rarity.
// Higher rarities become more likely the further you are (Rebirths + AP).
// ─────────────────────────────────────────────────────────────────────────────

enum RebirthBoonEffect {
  startingGold,   // value = gold multiplier
  bonusShards,    // value = shards granted
  bonusSouls,     // value = extra prestige souls
  bonusEchoes,    // value = echoes granted
  bonusEssence,   // value = essence granted
  bonusZcoins,    // value = zcoins granted
  startWeapon,    // value = ItemRarity index of the granted weapon
  xpThisRun,      // value = XP multiplier for the run (1.4 = +40%)
}

class RebirthBoon {
  const RebirthBoon({
    required this.id,
    required this.name,
    required this.icon,
    required this.effect,
    required this.rarity,
    required this.value,
    required this.tagline,
  });

  final String id;
  final String name;
  final String icon;
  final RebirthBoonEffect effect;
  final ItemRarity rarity;
  final num value;
  final String tagline;

  /// Flavour + explicit rarity, shown in the boon card body.
  String get description => '${rarity.boonLabel} boon. $_flavor';

  String get _flavor => switch (effect) {
        RebirthBoonEffect.startingGold => 'Start your new life with a hoard of gold from a former one.',
        RebirthBoonEffect.bonusShards  => 'Crystal shards fall from the ether — legacy of a life well-fought.',
        RebirthBoonEffect.bonusSouls   => 'The cycle condenses — claim extra souls from this rebirth.',
        RebirthBoonEffect.bonusEchoes  => 'Echoes of past battles resonate into your new journey.',
        RebirthBoonEffect.bonusEssence => 'Raw essence lingers from the life you left behind.',
        RebirthBoonEffect.bonusZcoins  => 'A cache of ZCoins, untouched across the cycle.',
        RebirthBoonEffect.startWeapon  => 'A weapon from a former life materialises in your hands.',
        RebirthBoonEffect.xpThisRun    => 'Memories of past lives accelerate your growth this run.',
      };

  // ── Pool of 27 ──────────────────────────────────────────────────────────────
  static const all = <RebirthBoon>[
    // Starting gold (×)
    RebirthBoon(id: 'gold_u', name: 'Coin Purse',   icon: '💰', effect: RebirthBoonEffect.startingGold, rarity: ItemRarity.uncommon,  value: 2,  tagline: '2× Starting Gold'),
    RebirthBoon(id: 'gold_r', name: 'Warchest',     icon: '💰', effect: RebirthBoonEffect.startingGold, rarity: ItemRarity.rare,      value: 3,  tagline: '3× Starting Gold'),
    RebirthBoon(id: 'gold_e', name: 'Dragon Hoard', icon: '💰', effect: RebirthBoonEffect.startingGold, rarity: ItemRarity.epic,      value: 5,  tagline: '5× Starting Gold'),
    RebirthBoon(id: 'gold_l', name: 'Midas Legacy', icon: '👑', effect: RebirthBoonEffect.startingGold, rarity: ItemRarity.legendary, value: 10, tagline: '10× Starting Gold'),
    // Shards (+)
    RebirthBoon(id: 'shard_u', name: 'Shard Pouch',    icon: '◆', effect: RebirthBoonEffect.bonusShards, rarity: ItemRarity.uncommon,  value: 150,  tagline: '+150 Shards'),
    RebirthBoon(id: 'shard_r', name: 'Shard Windfall', icon: '◆', effect: RebirthBoonEffect.bonusShards, rarity: ItemRarity.rare,      value: 400,  tagline: '+400 Shards'),
    RebirthBoon(id: 'shard_e', name: 'Shard Trove',    icon: '◆', effect: RebirthBoonEffect.bonusShards, rarity: ItemRarity.epic,      value: 1000, tagline: '+1,000 Shards'),
    RebirthBoon(id: 'shard_l', name: 'Crystal Vault',  icon: '💠', effect: RebirthBoonEffect.bonusShards, rarity: ItemRarity.legendary, value: 2500, tagline: '+2,500 Shards'),
    // XP this run (×)
    RebirthBoon(id: 'xp_u', name: 'Fond Memories',    icon: '📖', effect: RebirthBoonEffect.xpThisRun, rarity: ItemRarity.uncommon,  value: 1.4, tagline: '+40% XP this run'),
    RebirthBoon(id: 'xp_r', name: 'Ancestral Wisdom', icon: '📚', effect: RebirthBoonEffect.xpThisRun, rarity: ItemRarity.rare,      value: 1.75, tagline: '+75% XP this run'),
    RebirthBoon(id: 'xp_e', name: 'Enlightenment',    icon: '🌟', effect: RebirthBoonEffect.xpThisRun, rarity: ItemRarity.epic,      value: 2.5, tagline: '+150% XP this run'),
    RebirthBoon(id: 'xp_l', name: 'Transcendence',    icon: '✨', effect: RebirthBoonEffect.xpThisRun, rarity: ItemRarity.legendary, value: 4.0, tagline: '+300% XP this run'),
    // Souls (+)
    RebirthBoon(id: 'soul_u', name: 'Soul Ember',   icon: '☠', effect: RebirthBoonEffect.bonusSouls, rarity: ItemRarity.uncommon,  value: 20,  tagline: '+20 Souls'),
    RebirthBoon(id: 'soul_r', name: 'Soul Surge',   icon: '☠', effect: RebirthBoonEffect.bonusSouls, rarity: ItemRarity.rare,      value: 50,  tagline: '+50 Souls'),
    RebirthBoon(id: 'soul_e', name: 'Soul Torrent', icon: '☠', effect: RebirthBoonEffect.bonusSouls, rarity: ItemRarity.epic,      value: 120, tagline: '+120 Souls'),
    RebirthBoon(id: 'soul_l', name: 'Soulfire',     icon: '🔥', effect: RebirthBoonEffect.bonusSouls, rarity: ItemRarity.legendary, value: 300, tagline: '+300 Souls'),
    // Echoes (+)
    RebirthBoon(id: 'echo_u', name: 'Faint Echo',    icon: '🔊', effect: RebirthBoonEffect.bonusEchoes, rarity: ItemRarity.uncommon, value: 80,  tagline: '+80 Echoes'),
    RebirthBoon(id: 'echo_r', name: 'Echo Cluster',  icon: '🔊', effect: RebirthBoonEffect.bonusEchoes, rarity: ItemRarity.rare,     value: 200, tagline: '+200 Echoes'),
    RebirthBoon(id: 'echo_e', name: 'Echo Cascade',  icon: '🔊', effect: RebirthBoonEffect.bonusEchoes, rarity: ItemRarity.epic,     value: 500, tagline: '+500 Echoes'),
    // Essence (+)
    RebirthBoon(id: 'ess_u', name: 'Essence Vial',   icon: '✦', effect: RebirthBoonEffect.bonusEssence, rarity: ItemRarity.uncommon,  value: 100,  tagline: '+100 Essence'),
    RebirthBoon(id: 'ess_e', name: 'Essence Font',   icon: '✦', effect: RebirthBoonEffect.bonusEssence, rarity: ItemRarity.epic,      value: 400,  tagline: '+400 Essence'),
    RebirthBoon(id: 'ess_l', name: 'Essence Nexus',  icon: '✦', effect: RebirthBoonEffect.bonusEssence, rarity: ItemRarity.legendary, value: 1200, tagline: '+1,200 Essence'),
    // ZCoins (+)
    RebirthBoon(id: 'zc_r', name: 'ZCoin Stash', icon: '🪙', effect: RebirthBoonEffect.bonusZcoins, rarity: ItemRarity.rare,      value: 25,  tagline: '+25 ZCoins'),
    RebirthBoon(id: 'zc_l', name: 'ZCoin Vault', icon: '🪙', effect: RebirthBoonEffect.bonusZcoins, rarity: ItemRarity.legendary, value: 100, tagline: '+100 ZCoins'),
    // Starting weapon (rarity)
    RebirthBoon(id: 'wep_r', name: 'Blood Sigil',   icon: '⚔', effect: RebirthBoonEffect.startWeapon, rarity: ItemRarity.rare,      value: 2, tagline: 'Start with a Rare weapon'),
    RebirthBoon(id: 'wep_e', name: 'Ancestral Arm', icon: '⚔', effect: RebirthBoonEffect.startWeapon, rarity: ItemRarity.epic,      value: 3, tagline: 'Start with an Epic weapon'),
    RebirthBoon(id: 'wep_l', name: 'Relic Blade',   icon: '🗡', effect: RebirthBoonEffect.startWeapon, rarity: ItemRarity.legendary, value: 4, tagline: 'Start with a Legendary weapon'),
  ];

  static RebirthBoon? byId(String? id) {
    if (id == null) return null;
    for (final b in all) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// Roll 3 distinct boons, weighted by rarity. Higher rarities grow more likely
  /// as the player's endgame progress (Rebirths + total Ascension Points) rises.
  static List<RebirthBoon> rollBoons(int rebirths, int ascensionAp, math.Random rng) {
    final score = rebirths + ascensionAp;
    double weightFor(ItemRarity r) => switch (r) {
          ItemRarity.uncommon  => (120 - score * 6).clamp(5, 120).toDouble(),
          ItemRarity.rare      => (55 + score * 2).clamp(10, 130).toDouble(),
          ItemRarity.epic      => (score * 4 - 15).clamp(0, 150).toDouble() + 4,
          ItemRarity.legendary => (score * 3 - 65).clamp(0, 120).toDouble() + 1,
          _ => 0,
        };
    final pool = List<RebirthBoon>.from(all);
    final picks = <RebirthBoon>[];
    while (picks.length < 3 && pool.isNotEmpty) {
      final weights = pool.map((b) => weightFor(b.rarity)).toList();
      final total = weights.fold(0.0, (a, b) => a + b);
      var roll = rng.nextDouble() * total;
      var idx = 0;
      for (var i = 0; i < pool.length; i++) {
        roll -= weights[i];
        if (roll <= 0) { idx = i; break; }
      }
      picks.add(pool.removeAt(idx));
    }
    return picks;
  }
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

import 'dart:math';

enum LocationBiome {
  graveyard, cave, temple, fortress, ruin, dungeon, catacombs, sanctum, barrows, highPass;

  String get displayName => switch (this) {
    LocationBiome.graveyard  => 'Graveyard',
    LocationBiome.cave       => 'Cave',
    LocationBiome.temple     => 'Temple',
    LocationBiome.fortress   => 'Fortress',
    LocationBiome.ruin       => 'Ruin',
    LocationBiome.dungeon    => 'Dungeon',
    LocationBiome.catacombs  => 'Catacombs',
    LocationBiome.sanctum    => 'Sanctum',
    LocationBiome.barrows    => 'Barrows',
    LocationBiome.highPass   => 'High Pass',
  };

  String get icon => switch (this) {
    LocationBiome.graveyard  => '🪦',
    LocationBiome.cave       => '🗻',
    LocationBiome.temple     => '🏛',
    LocationBiome.fortress   => '🏰',
    LocationBiome.ruin       => '🏚',
    LocationBiome.dungeon    => '⛓',
    LocationBiome.catacombs  => '💀',
    LocationBiome.sanctum    => '✨',
    LocationBiome.barrows    => '⚰',
    LocationBiome.highPass   => '🏔',
  };

  String get imagePath => switch (this) {
    LocationBiome.graveyard  => 'assets/images/exp_graveyard.png',
    LocationBiome.cave       => 'assets/images/exp_cave.png',
    LocationBiome.temple     => 'assets/images/exp_temple.png',
    LocationBiome.fortress   => 'assets/images/exp_fortress.png',
    LocationBiome.ruin       => 'assets/images/exp_ruin.png',
    LocationBiome.dungeon    => 'assets/images/exp_dungeon.png',
    LocationBiome.catacombs  => 'assets/images/exp_catacombs.png',
    LocationBiome.sanctum    => 'assets/images/exp_sanctum.png',
    LocationBiome.barrows    => 'assets/images/exp_barrows.png',
    LocationBiome.highPass   => 'assets/images/exp_highpass.png',
  };

  String get rewardFocus => switch (this) {
    LocationBiome.graveyard  => '💰 Gold · ◆ Shards',
    LocationBiome.cave       => '◆ Shards · 💰 Gold',
    LocationBiome.temple     => '◆ Shards · 💰 Gold',
    LocationBiome.fortress   => '💰 Gold · ⬡ Mythril',
    LocationBiome.ruin       => 'All resources (balanced)',
    LocationBiome.dungeon    => '◆ Shards · 🪙 ZCoins',
    LocationBiome.catacombs  => '◆ Shards · 💰 Gold',
    LocationBiome.sanctum    => '◆ Shards · 🪙 ZCoins',
    LocationBiome.barrows    => '💰 Gold · ◆ Shards',
    LocationBiome.highPass   => '⬡ Mythril · 🔊 Echoes',
  };
}

class ExpeditionLocation {
  const ExpeditionLocation({
    required this.name,
    required this.biome,
    required this.seed,
  });

  final String name;
  final LocationBiome biome;
  final int seed;

  static const _prefixes = [
    'Tomb of',   'Ruins of',  'Shadow',   'Forsaken',
    'Ancient',   'Cursed',    'Lost',     'Dark',
    'Sunken',    'Haunted',   'Fallen',   'Blighted',
  ];

  static const _nouns = [
    'Graveyard', 'Cave',      'Temple',   'Fortress',
    'Ruin',      'Dungeon',   'Catacombs','Sanctum',
    'Crypt',     'Citadel',   'Barrows',  'Vault',
    'High Pass', 'Grounds',
  ];

  static const _biomeMap = <String, LocationBiome>{
    'Graveyard':  LocationBiome.graveyard,
    'Cave':       LocationBiome.cave,
    'Temple':     LocationBiome.temple,
    'Fortress':   LocationBiome.fortress,
    'Ruin':       LocationBiome.ruin,
    'Dungeon':    LocationBiome.dungeon,
    'Catacombs':  LocationBiome.catacombs,
    'Sanctum':    LocationBiome.sanctum,
    'Crypt':      LocationBiome.catacombs,
    'Citadel':    LocationBiome.fortress,
    'Barrows':    LocationBiome.barrows,
    'Vault':      LocationBiome.dungeon,
    'High Pass':  LocationBiome.highPass,
    'Grounds':    LocationBiome.barrows,
  };

  static List<ExpeditionLocation> daily(int daySeed, {int count = 4}) {
    final rng = Random(daySeed * 7919);
    final used = <LocationBiome>{};
    final result = <ExpeditionLocation>[];
    var attempts = 0;
    while (result.length < count && attempts < 80) {
      attempts++;
      final prefix = _prefixes[rng.nextInt(_prefixes.length)];
      final noun   = _nouns[rng.nextInt(_nouns.length)];
      final biome  = _biomeMap[noun] ?? LocationBiome.ruin;
      if (used.contains(biome)) continue;
      used.add(biome);
      result.add(ExpeditionLocation(
        name:  '$prefix $noun',
        biome: biome,
        seed:  rng.nextInt(10000),
      ));
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
    'name':  name,
    'biome': biome.name,
    'seed':  seed,
  };

  factory ExpeditionLocation.fromJson(Map<String, dynamic> json) =>
      ExpeditionLocation(
        name:  json['name']  as String,
        biome: LocationBiome.values.byName(json['biome'] as String),
        seed:  json['seed']  as int,
      );
}

enum ExpeditionDuration { short, medium, long }

extension ExpeditionDurationInfo on ExpeditionDuration {
  String get label => switch (this) {
    ExpeditionDuration.short  => '30 min',
    ExpeditionDuration.medium => '2 hr',
    ExpeditionDuration.long   => '8 hr',
  };
  int get ms => switch (this) {
    ExpeditionDuration.short  => 30 * 60 * 1000,
    ExpeditionDuration.medium => 2 * 60 * 60 * 1000,
    ExpeditionDuration.long   => 8 * 60 * 60 * 1000,
  };
  int get mult => switch (this) {
    ExpeditionDuration.short  => 1,
    ExpeditionDuration.medium => 4,
    ExpeditionDuration.long   => 14,
  };
}

class Expedition {
  const Expedition({
    required this.mercId,
    required this.location,
    required this.duration,
    required this.startEpochMs,
  });

  final String mercId;
  final ExpeditionLocation location;
  final ExpeditionDuration duration;
  final int startEpochMs;

  bool get isComplete =>
      DateTime.now().millisecondsSinceEpoch >= startEpochMs + duration.ms;

  double get progress =>
      ((DateTime.now().millisecondsSinceEpoch - startEpochMs) / duration.ms)
          .clamp(0.0, 1.0);

  Duration get remaining {
    final ms = (startEpochMs + duration.ms) -
        DateTime.now().millisecondsSinceEpoch;
    return Duration(milliseconds: ms.clamp(0, duration.ms));
  }

  Map<String, dynamic> toJson() => {
    'mercId':       mercId,
    'location':     location.toJson(),
    'duration':     duration.name,
    'startEpochMs': startEpochMs,
  };

  factory Expedition.fromJson(Map<String, dynamic> json) => Expedition(
    mercId:   json['mercId']       as String? ?? 'greybeard',
    location: json['location'] != null
        ? ExpeditionLocation.fromJson(json['location'] as Map<String, dynamic>)
        : const ExpeditionLocation(name: 'Lost Ruin', biome: LocationBiome.ruin, seed: 0),
    duration:     ExpeditionDuration.values.byName(json['duration'] as String),
    startEpochMs: json['startEpochMs'] as int,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Guild System — Tier 1 MVP
//
// Data lives in Firestore. Local model mirrors cloud state.
// Guild boss resets weekly (Monday 00:00 UTC).
// ─────────────────────────────────────────────────────────────────────────────

class Guild {
  Guild({
    required this.id,
    required this.name,
    required this.leaderId,
    this.description = '',
    this.icon = '⚔',
    this.level = 1,
    this.xp = 0,
    this.members = const [],
    this.messages = const [],
    this.weeklyBoss,
    this.createdAt,
    this.territories = const [],
    this.ownedCosmetics = const [],
    this.equippedBanner,
    this.equippedFrame,
  });

  final String id;
  String name;
  String leaderId;
  String description;
  String icon;
  int level;
  int xp;
  List<GuildMember> members;
  List<GuildMessage> messages;
  GuildBoss? weeklyBoss;
  DateTime? createdAt;
  List<String> territories;
  List<String> ownedCosmetics;
  String? equippedBanner;
  String? equippedFrame;

  static const int baseMaxMembers = 20;
  int get maxMembers => level >= 20 ? 30 : baseMaxMembers;
  static const int maxMessages = 50;

  int get memberCount => members.length;
  bool get isFull => memberCount >= maxMembers;

  // XP needed to level up: 500 × current level
  int get xpToNextLevel => 500 * level;

  // Guild-wide passive bonuses scale with level
  double get goldBonus    => 1.0 + level * 0.02;  // +2% per level
  double get xpBonus      => 1.0 + level * 0.015; // +1.5% per level
  double get idleBonus    => 1.0 + level * 0.01;  // +1% per level
  double get shardBonus   => level >= 5  ? 1.0 + (level - 4) * 0.01 : 1.0;
  double get essenceBonus => level >= 8  ? 1.0 + (level - 7) * 0.01 : 1.0;
  double get dmgBonus     => level >= 12 ? 1.0 + (level - 11) * 0.005 : 1.0;

  // Unlockable perks at milestone levels
  List<GuildPerk> get unlockedPerks => GuildPerk.all.where((p) => level >= p.levelRequired).toList();
  List<GuildPerk> get nextPerks => GuildPerk.all.where((p) => level < p.levelRequired).take(2).toList();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'leaderId': leaderId,
    'description': description,
    'icon': icon,
    'level': level,
    'xp': xp,
    'members': members.map((m) => m.toJson()).toList(),
    'messages': messages.map((m) => m.toJson()).toList(),
    if (weeklyBoss != null) 'weeklyBoss': weeklyBoss!.toJson(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    'territories': territories,
    'ownedCosmetics': ownedCosmetics,
    if (equippedBanner != null) 'equippedBanner': equippedBanner,
    if (equippedFrame != null) 'equippedFrame': equippedFrame,
  };

  static Guild fromJson(Map<String, dynamic> json) => Guild(
    id: json['id'] as String,
    name: json['name'] as String,
    leaderId: json['leaderId'] as String,
    description: (json['description'] as String?) ?? '',
    icon: (json['icon'] as String?) ?? '⚔',
    level: (json['level'] as int?) ?? 1,
    xp: (json['xp'] as int?) ?? 0,
    members: (json['members'] as List<dynamic>?)
        ?.map((m) => GuildMember.fromJson(m as Map<String, dynamic>))
        .toList() ?? [],
    messages: (json['messages'] as List<dynamic>?)
        ?.map((m) => GuildMessage.fromJson(m as Map<String, dynamic>))
        .toList() ?? [],
    weeklyBoss: json['weeklyBoss'] != null
        ? GuildBoss.fromJson(json['weeklyBoss'] as Map<String, dynamic>)
        : null,
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String)
        : null,
    territories: (json['territories'] as List<dynamic>?)?.cast<String>() ?? [],
    ownedCosmetics: (json['ownedCosmetics'] as List<dynamic>?)?.cast<String>() ?? [],
    equippedBanner: json['equippedBanner'] as String?,
    equippedFrame: json['equippedFrame'] as String?,
  );
}

class GuildMember {
  const GuildMember({
    required this.userId,
    required this.name,
    required this.heroClass,
    required this.level,
    this.role = GuildRole.member,
    this.weeklyDamage = 0,
    this.totalDonated = 0,
    this.guildCoins = 0,
    this.lastActive,
  });

  final String userId;
  final String name;
  final String heroClass;
  final int level;
  final GuildRole role;
  final int weeklyDamage;
  final int totalDonated;
  final int guildCoins;
  final DateTime? lastActive;

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'heroClass': heroClass,
    'level': level,
    'role': role.name,
    'weeklyDamage': weeklyDamage,
    'totalDonated': totalDonated,
    'guildCoins': guildCoins,
    if (lastActive != null) 'lastActive': lastActive!.toIso8601String(),
  };

  static GuildMember fromJson(Map<String, dynamic> json) => GuildMember(
    userId: json['userId'] as String,
    name: json['name'] as String,
    heroClass: (json['heroClass'] as String?) ?? 'fighter',
    level: (json['level'] as int?) ?? 1,
    role: GuildRole.values.firstWhere(
        (r) => r.name == json['role'], orElse: () => GuildRole.member),
    weeklyDamage: (json['weeklyDamage'] as int?) ?? 0,
    totalDonated: (json['totalDonated'] as int?) ?? 0,
    guildCoins: (json['guildCoins'] as int?) ?? 0,
    lastActive: json['lastActive'] != null
        ? DateTime.tryParse(json['lastActive'] as String) : null,
  );
}

enum GuildRole { leader, officer, member }

class GuildMessage {
  const GuildMessage({
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isSystem = false,
  });

  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isSystem;

  Map<String, dynamic> toJson() => {
    'senderId': senderId,
    'senderName': senderName,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'isSystem': isSystem,
  };

  static GuildMessage fromJson(Map<String, dynamic> json) => GuildMessage(
    senderId: json['senderId'] as String,
    senderName: json['senderName'] as String,
    text: json['text'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    isSystem: (json['isSystem'] as bool?) ?? false,
  );
}

// ── Weekly Guild Boss ────────────────────────────────────────────────────────

class GuildBoss {
  GuildBoss({
    required this.name,
    required this.maxHp,
    required this.weekStartEpoch,
    this.currentHp,
    this.defeated = false,
    this.spriteId = 'lich',
  });

  final String name;
  final int maxHp;
  final int weekStartEpoch;
  int? currentHp;
  bool defeated;
  final String spriteId;

  int get hp => currentHp ?? maxHp;
  double get hpRatio => maxHp > 0 ? hp / maxHp : 1.0;

  void takeDamage(int dmg) {
    currentHp = (hp - dmg).clamp(0, maxHp);
    if (currentHp == 0) defeated = true;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'maxHp': maxHp,
    'weekStartEpoch': weekStartEpoch,
    'currentHp': currentHp,
    'defeated': defeated,
    'spriteId': spriteId,
  };

  static GuildBoss fromJson(Map<String, dynamic> json) => GuildBoss(
    name: json['name'] as String,
    maxHp: json['maxHp'] as int,
    weekStartEpoch: json['weekStartEpoch'] as int,
    currentHp: json['currentHp'] as int?,
    defeated: (json['defeated'] as bool?) ?? false,
    spriteId: (json['spriteId'] as String?) ?? 'lich',
  );

  // Generate a boss scaled to member count
  static GuildBoss generate(int memberCount, int guildLevel) {
    final names = [
      'Ancient Wyrm', 'Void Colossus', 'Plague Emperor',
      'Storm Titan', 'Shadow Sovereign', 'Infernal Archon',
    ];
    final sprites = ['hydra', 'golem', 'chimera', 'phoenix', 'lich', 'minotaur'];
    final week = DateTime.now().millisecondsSinceEpoch ~/ (7 * 24 * 60 * 60 * 1000);
    final idx = week % names.length;
    final hp = (5000 + memberCount * 2000) * guildLevel;

    return GuildBoss(
      name: names[idx],
      maxHp: hp,
      weekStartEpoch: week,
      spriteId: sprites[idx],
    );
  }
}

// ── Guild Perks ──────────────────────────────────────────────────────────────

class GuildPerk {
  const GuildPerk({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.levelRequired,
  });

  final String id, name, icon, description;
  final int levelRequired;

  static const all = [
    GuildPerk(id: 'shard_boost', name: 'Shard Affinity', icon: '◆',
        description: '+1% Shard drops per guild level above 5', levelRequired: 5),
    GuildPerk(id: 'essence_boost', name: 'Essence Flow', icon: '✦',
        description: '+1% Essence gains per guild level above 8', levelRequired: 8),
    GuildPerk(id: 'guild_exp', name: 'Guild Expeditions', icon: '🗺',
        description: 'Unlock shared guild expeditions', levelRequired: 10),
    GuildPerk(id: 'dmg_boost', name: 'War Banner', icon: '🚩',
        description: '+0.5% all damage per guild level above 12', levelRequired: 12),
    GuildPerk(id: 'echo_boost', name: 'Echo Resonance', icon: '🔊',
        description: '+2% Echo drops from Gauntlet and Boss Rush', levelRequired: 15),
    GuildPerk(id: 'boss_coins', name: 'Plunder', icon: '🪙',
        description: 'Double guild coins from weekly boss', levelRequired: 18),
    GuildPerk(id: 'extra_slot', name: 'Expanded Ranks', icon: '👥',
        description: 'Guild capacity increases to 30 members', levelRequired: 20),
  ];
}

// ── Guild Expeditions ────────────────────────────────────────────────────────

class GuildExpedition {
  GuildExpedition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredMembers,
    required this.durationHours,
    required this.rewards,
    this.participants = const [],
    this.startEpoch = 0,
  });

  final String id, name, description, icon;
  final int requiredMembers;
  final int durationHours;
  final Map<String, int> rewards;
  List<String> participants;
  int startEpoch;

  bool get isActive => startEpoch > 0;
  bool get isComplete => isActive &&
      DateTime.now().millisecondsSinceEpoch - startEpoch >= durationHours * 3600 * 1000;
  bool get isFull => participants.length >= requiredMembers;

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'description': description, 'icon': icon,
    'requiredMembers': requiredMembers, 'durationHours': durationHours,
    'rewards': rewards, 'participants': participants, 'startEpoch': startEpoch,
  };

  static GuildExpedition fromJson(Map<String, dynamic> json) => GuildExpedition(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    icon: json['icon'] as String,
    requiredMembers: json['requiredMembers'] as int,
    durationHours: json['durationHours'] as int,
    rewards: Map<String, int>.from(json['rewards'] as Map),
    participants: (json['participants'] as List<dynamic>?)?.cast<String>() ?? [],
    startEpoch: (json['startEpoch'] as int?) ?? 0,
  );

  static List<GuildExpedition> get catalog => [
    GuildExpedition(id: 'guild_gold_run', name: 'Gold Rush',
        description: 'Raid a forgotten treasury together.',
        icon: '💰', requiredMembers: 3, durationHours: 4,
        rewards: {'gold': 10000, 'guildCoins': 15}),
    GuildExpedition(id: 'guild_shard_mine', name: 'Shard Mine',
        description: 'Excavate ancient crystal veins.',
        icon: '◆', requiredMembers: 4, durationHours: 6,
        rewards: {'shards': 80, 'guildCoins': 20}),
    GuildExpedition(id: 'guild_essence_rift', name: 'Essence Rift',
        description: 'Tap into a rift leaking raw essence.',
        icon: '✦', requiredMembers: 5, durationHours: 8,
        rewards: {'essence': 200, 'echoes': 50, 'guildCoins': 25}),
    GuildExpedition(id: 'guild_mythril_forge', name: 'Mythril Forge',
        description: 'Reclaim a dwarven mythril forge.',
        icon: '⬡', requiredMembers: 6, durationHours: 12,
        rewards: {'mythril': 20, 'guildCoins': 35}),
  ];
}

// ── Guild Raid Bosses ─────────────────────────────────────────────────────────

class GuildRaid {
  GuildRaid({
    required this.id,
    required this.boss,
    required this.phases,
    this.currentPhase = 0,
    this.participants = const {},
    this.startEpoch = 0,
    this.completed = false,
    this.lootClaimed = const [],
  });

  final String id;
  final RaidBossInfo boss;
  final List<RaidPhase> phases;
  int currentPhase;
  Map<String, RaidParticipant> participants;
  int startEpoch;
  bool completed;
  List<String> lootClaimed;

  RaidPhase get activePhase => phases[currentPhase.clamp(0, phases.length - 1)];
  bool get isActive => startEpoch > 0 && !completed;
  int get totalHp => phases.fold(0, (s, p) => s + p.maxHp);
  int get totalDamageDealt => participants.values.fold(0, (s, p) => s + p.totalDamage);
  int get currentPhaseHp => activePhase.currentHp;

  void dealDamage(String userId, String userName, int damage) {
    final p = participants[userId] ?? RaidParticipant(userId: userId, name: userName);
    participants[userId] = RaidParticipant(
      userId: p.userId,
      name: p.name,
      totalDamage: p.totalDamage + damage,
      attacks: p.attacks + 1,
      lastAttackEpoch: DateTime.now().millisecondsSinceEpoch,
    );

    var remaining = damage;
    while (remaining > 0 && currentPhase < phases.length) {
      final phase = phases[currentPhase];
      final dealt = remaining.clamp(0, phase.currentHp);
      phase.currentHp -= dealt;
      remaining -= dealt;
      if (phase.currentHp <= 0 && currentPhase < phases.length - 1) {
        currentPhase++;
      } else if (phase.currentHp <= 0) {
        completed = true;
        break;
      }
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'boss': boss.toJson(),
    'phases': phases.map((p) => p.toJson()).toList(),
    'currentPhase': currentPhase,
    'participants': participants.map((k, v) => MapEntry(k, v.toJson())),
    'startEpoch': startEpoch,
    'completed': completed,
    'lootClaimed': lootClaimed,
  };

  static GuildRaid fromJson(Map<String, dynamic> json) => GuildRaid(
    id: json['id'] as String,
    boss: RaidBossInfo.fromJson(json['boss'] as Map<String, dynamic>),
    phases: (json['phases'] as List<dynamic>)
        .map((p) => RaidPhase.fromJson(p as Map<String, dynamic>)).toList(),
    currentPhase: (json['currentPhase'] as int?) ?? 0,
    participants: (json['participants'] as Map<String, dynamic>?)
        ?.map((k, v) => MapEntry(k, RaidParticipant.fromJson(v as Map<String, dynamic>))) ?? {},
    startEpoch: (json['startEpoch'] as int?) ?? 0,
    completed: (json['completed'] as bool?) ?? false,
    lootClaimed: (json['lootClaimed'] as List<dynamic>?)?.cast<String>() ?? [],
  );
}

class RaidBossInfo {
  const RaidBossInfo({
    required this.name,
    required this.title,
    required this.spriteId,
    required this.element,
    required this.tier,
  });

  final String name, title, spriteId, element;
  final int tier;

  Map<String, dynamic> toJson() => {
    'name': name, 'title': title, 'spriteId': spriteId,
    'element': element, 'tier': tier,
  };

  static RaidBossInfo fromJson(Map<String, dynamic> json) => RaidBossInfo(
    name: json['name'] as String,
    title: json['title'] as String,
    spriteId: json['spriteId'] as String,
    element: json['element'] as String,
    tier: (json['tier'] as int?) ?? 1,
  );
}

class RaidPhase {
  RaidPhase({
    required this.name,
    required this.maxHp,
    required this.mechanic,
    required this.mechanicDesc,
    int? currentHp,
  }) : currentHp = currentHp ?? maxHp;

  final String name, mechanic, mechanicDesc;
  final int maxHp;
  int currentHp;

  double get hpRatio => maxHp > 0 ? currentHp / maxHp : 0;
  bool get isDefeated => currentHp <= 0;

  Map<String, dynamic> toJson() => {
    'name': name, 'maxHp': maxHp, 'mechanic': mechanic,
    'mechanicDesc': mechanicDesc, 'currentHp': currentHp,
  };

  static RaidPhase fromJson(Map<String, dynamic> json) => RaidPhase(
    name: json['name'] as String,
    maxHp: json['maxHp'] as int,
    mechanic: json['mechanic'] as String,
    mechanicDesc: json['mechanicDesc'] as String,
    currentHp: json['currentHp'] as int?,
  );
}

class RaidParticipant {
  const RaidParticipant({
    required this.userId,
    required this.name,
    this.totalDamage = 0,
    this.attacks = 0,
    this.lastAttackEpoch = 0,
  });

  final String userId, name;
  final int totalDamage, attacks, lastAttackEpoch;

  Map<String, dynamic> toJson() => {
    'userId': userId, 'name': name, 'totalDamage': totalDamage,
    'attacks': attacks, 'lastAttackEpoch': lastAttackEpoch,
  };

  static RaidParticipant fromJson(Map<String, dynamic> json) => RaidParticipant(
    userId: json['userId'] as String,
    name: json['name'] as String,
    totalDamage: (json['totalDamage'] as int?) ?? 0,
    attacks: (json['attacks'] as int?) ?? 0,
    lastAttackEpoch: (json['lastAttackEpoch'] as int?) ?? 0,
  );
}

// ── Raid Boss Catalog ────────────────────────────────────────────────────────

class RaidCatalog {
  // Mon=1..Sat=6 → index 0..5, Sun=7 → no raid
  static int? todayRaidIndex() {
    final weekday = DateTime.now().weekday; // 1=Mon..7=Sun
    if (weekday == 7) return null; // Sunday — rest day
    return weekday - 1;
  }

  static final _bosses = [
    // Monday — Fire
    (
      id: 'raid_ancient_drake', element: 'fire', tier: 1,
      name: 'Ancient Drake', title: 'Terror of the Old World',
      spriteId: 'hydra', emoji: '🔥',
      phases: [
        ('Awakening', 5000, 'burn', 'Fire breath — fire resistance reduces damage taken'),
        ('Fury', 8000, 'enrage', 'Enraged — deals 2× damage, takes 50% more'),
        ('Last Stand', 3000, 'shield', 'Scales harden — only crits deal full damage'),
      ],
    ),
    // Tuesday — Cold
    (
      id: 'raid_frost_titan', element: 'cold', tier: 1,
      name: 'Frost Titan', title: 'Herald of Endless Winter',
      spriteId: 'golem', emoji: '❄',
      phases: [
        ('Frozen Advance', 6000, 'freeze', 'Blizzard — cold resistance reduces incoming freeze'),
        ('Glacial Core', 7000, 'absorb', 'Ice armor absorbs first 50 damage per hit'),
        ('Shatter', 4000, 'nova', 'Shatters — AoE burst, high damage but low HP'),
      ],
    ),
    // Wednesday — Lightning
    (
      id: 'raid_storm_emperor', element: 'lightning', tier: 2,
      name: 'Storm Emperor', title: 'Lord of Tempests',
      spriteId: 'phoenix', emoji: '⚡',
      phases: [
        ('Thunder Call', 8000, 'chain', 'Chain lightning — spreads damage to weaken attackers'),
        ('Eye of Storm', 12000, 'dodge', 'Evasive — 30% chance to negate attacks'),
        ('Supercell', 10000, 'overcharge', 'Overcharged — penetration bonus damage doubled'),
        ('Judgement', 5000, 'berserk', 'Final discharge — all damage doubled both ways'),
      ],
    ),
    // Thursday — Poison
    (
      id: 'raid_plague_mother', element: 'poison', tier: 2,
      name: 'Plague Mother', title: 'Source of All Rot',
      spriteId: 'chimera', emoji: '☠',
      phases: [
        ('Infection', 7000, 'dot', 'Toxic aura — poison DoT ticks on all attackers'),
        ('Mutation', 14000, 'regen', 'Regenerates 2% HP per round — burst damage key'),
        ('Epidemic', 9000, 'weaken', 'Weakens attackers — reduces damage by 15%'),
        ('Decomposition', 6000, 'final', 'Falling apart — takes 50% more damage'),
      ],
    ),
    // Friday — Void
    (
      id: 'raid_void_sovereign', element: 'void', tier: 3,
      name: 'Void Sovereign', title: 'Eater of Stars',
      spriteId: 'mind_flayer', emoji: '🌑',
      phases: [
        ('Manifestation', 10000, 'drain', 'Void drain — steals 10% of damage dealt as healing'),
        ('Rift Tear', 15000, 'portal', 'Summons portals — only penetration ignores void shield'),
        ('Collapse', 8000, 'instakill', 'Collapsing reality — attacks below 100 damage negated'),
        ('Oblivion', 5000, 'berserk', 'Final form — all damage doubled both ways'),
      ],
    ),
    // Saturday — Physical
    (
      id: 'raid_world_eater', element: 'physical', tier: 3,
      name: 'World Eater', title: 'The End of All Things',
      spriteId: 'minotaur', emoji: '⚔',
      phases: [
        ('Arrival', 12000, 'quake', 'Earthquake — physical resistance key'),
        ('Consumption', 20000, 'absorb', 'Absorbs elements — only physical damage works'),
        ('Rampage', 18000, 'reflect', 'Reflects 20% of damage back to attacker'),
        ('Armageddon', 10000, 'desperation', 'Desperate — all attacks pierce resistance'),
        ('Death Throes', 8000, 'final', 'Dying — takes 50% more damage'),
      ],
    ),
  ];

  static GuildRaid? todayRaid(int guildLevel, int memberCount) {
    final idx = todayRaidIndex();
    if (idx == null) return null;
    final b = _bosses[idx];
    final scale = (guildLevel * memberCount).clamp(1, 9999);
    return GuildRaid(
      id: b.id,
      boss: RaidBossInfo(
        name: b.name, title: b.title,
        spriteId: b.spriteId, element: b.element, tier: b.tier,
      ),
      phases: b.phases.map((p) => RaidPhase(
        name: p.$1, maxHp: p.$2 * scale,
        mechanic: p.$3, mechanicDesc: p.$4,
      )).toList(),
    );
  }

  static String get todayLabel {
    final idx = todayRaidIndex();
    if (idx == null) return 'REST DAY — No raid today';
    final b = _bosses[idx];
    return '${b.emoji} ${b.name} — ${b.title}';
  }

  static Map<String, int> rewardsForTier(int tier) => switch (tier) {
    1 => {'guildCoins': 250, 'gold': 75000, 'shards': 500, 'echoes': 200, 'zcoins': 25},
    2 => {'guildCoins': 500, 'gold': 150000, 'shards': 1000, 'echoes': 400, 'mythril': 50, 'zcoins': 50},
    3 => {'guildCoins': 1000, 'gold': 300000, 'shards': 2000, 'echoes': 750, 'mythril': 125, 'zcoins': 150},
    _ => {'guildCoins': 150, 'gold': 25000, 'zcoins': 25},
  };
}

// ── Guild Territories (GvG) ───────────────────────────────────────────────────

class GuildTerritory {
  const GuildTerritory({
    required this.id,
    required this.name,
    required this.icon,
    required this.bonus,
    required this.bonusLabel,
  });

  final String id, name, icon, bonus, bonusLabel;

  static const zones = [
    GuildTerritory(id: 'gold_mine',     name: 'Gold Mine',       icon: '💰', bonus: 'gold',    bonusLabel: '+10% Gold for all members'),
    GuildTerritory(id: 'shard_quarry',  name: 'Shard Quarry',    icon: '◆',  bonus: 'shards',  bonusLabel: '+10% Shards for all members'),
    GuildTerritory(id: 'echo_chamber',  name: 'Echo Chamber',    icon: '🔊', bonus: 'echoes',  bonusLabel: '+10% Echoes for all members'),
    GuildTerritory(id: 'essence_well',  name: 'Essence Well',    icon: '✦',  bonus: 'essence', bonusLabel: '+10% Essence for all members'),
    GuildTerritory(id: 'mythril_vein',  name: 'Mythril Vein',    icon: '⬡',  bonus: 'mythril', bonusLabel: '+15% Mythril from Boss Rush'),
    GuildTerritory(id: 'training_arena',name: 'Training Arena',   icon: '⚔',  bonus: 'xp',     bonusLabel: '+5% XP for all members'),
  ];
}

class GuildWarResult {
  const GuildWarResult({
    required this.territoryId,
    required this.attackingGuildId,
    required this.defendingGuildId,
    required this.attackerScore,
    required this.defenderScore,
    required this.weekEpoch,
  });

  final String territoryId, attackingGuildId, defendingGuildId;
  final int attackerScore, defenderScore, weekEpoch;

  bool get attackerWon => attackerScore > defenderScore;

  Map<String, dynamic> toJson() => {
    'territoryId': territoryId,
    'attackingGuildId': attackingGuildId,
    'defendingGuildId': defendingGuildId,
    'attackerScore': attackerScore,
    'defenderScore': defenderScore,
    'weekEpoch': weekEpoch,
  };

  static GuildWarResult fromJson(Map<String, dynamic> json) => GuildWarResult(
    territoryId: json['territoryId'] as String,
    attackingGuildId: json['attackingGuildId'] as String,
    defendingGuildId: json['defendingGuildId'] as String,
    attackerScore: json['attackerScore'] as int,
    defenderScore: json['defenderScore'] as int,
    weekEpoch: json['weekEpoch'] as int,
  );
}

// ── Guild Cosmetics & Titles ─────────────────────────────────────────────────

class GuildTitle {
  const GuildTitle({
    required this.id,
    required this.name,
    required this.requirement,
    required this.color,
  });

  final String id, name, requirement;
  final int color;

  static const all = [
    GuildTitle(id: 'founder',       name: 'Guild Founder',        requirement: 'Create a guild',                  color: 0xFFffcc33),
    GuildTitle(id: 'veteran',       name: 'Guild Veteran',        requirement: 'Donate 10,000+ gold total',       color: 0xFF66aaff),
    GuildTitle(id: 'champion',      name: 'Guild Champion',       requirement: 'Top damage on weekly boss',       color: 0xFFcc44ff),
    GuildTitle(id: 'conqueror',     name: 'Territory Conqueror',  requirement: 'Win a territory war',             color: 0xFFff6644),
    GuildTitle(id: 'warlord',       name: 'Guild Warlord',        requirement: 'Hold 3+ territories',             color: 0xFFff4444),
    GuildTitle(id: 'legend',        name: 'Guild Legend',         requirement: 'Guild reaches level 20',          color: 0xFFFFD700),
    GuildTitle(id: 'season_champ',  name: 'Seasonal Champion',    requirement: 'Win a seasonal tournament',       color: 0xFF44ffaa),
  ];
}

class GuildCosmetic {
  const GuildCosmetic({
    required this.id,
    required this.name,
    required this.icon,
    required this.cost,
    required this.type,
  });

  final String id, name, icon;
  final int cost;
  final GuildCosmeticType type;

  static const catalog = [
    GuildCosmetic(id: 'banner_fire',     name: 'Fire Banner',     icon: '🔥', cost: 100, type: GuildCosmeticType.banner),
    GuildCosmetic(id: 'banner_ice',      name: 'Ice Banner',      icon: '❄',  cost: 100, type: GuildCosmeticType.banner),
    GuildCosmetic(id: 'banner_void',     name: 'Void Banner',     icon: '🌑', cost: 100, type: GuildCosmeticType.banner),
    GuildCosmetic(id: 'banner_gold',     name: 'Golden Banner',   icon: '👑', cost: 200, type: GuildCosmeticType.banner),
    GuildCosmetic(id: 'frame_iron',      name: 'Iron Frame',      icon: '🛡',  cost: 150, type: GuildCosmeticType.frame),
    GuildCosmetic(id: 'frame_crystal',   name: 'Crystal Frame',   icon: '💎', cost: 250, type: GuildCosmeticType.frame),
    GuildCosmetic(id: 'aura_purple',     name: 'Purple Aura',     icon: '🟣', cost: 300, type: GuildCosmeticType.aura),
    GuildCosmetic(id: 'aura_golden',     name: 'Golden Aura',     icon: '✨', cost: 500, type: GuildCosmeticType.aura),
  ];
}

enum GuildCosmeticType { banner, frame, aura }

// ── Seasonal Tournament ──────────────────────────────────────────────────────

class GuildTournament {
  GuildTournament({
    required this.seasonId,
    required this.startEpoch,
    required this.endEpoch,
    this.entries = const [],
  });

  final String seasonId;
  final int startEpoch, endEpoch;
  List<TournamentEntry> entries;

  bool get isActive {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now >= startEpoch && now < endEpoch;
  }

  bool get isEnded => DateTime.now().millisecondsSinceEpoch >= endEpoch;

  Map<String, dynamic> toJson() => {
    'seasonId': seasonId,
    'startEpoch': startEpoch,
    'endEpoch': endEpoch,
    'entries': entries.map((e) => e.toJson()).toList(),
  };

  static GuildTournament fromJson(Map<String, dynamic> json) => GuildTournament(
    seasonId: json['seasonId'] as String,
    startEpoch: json['startEpoch'] as int,
    endEpoch: json['endEpoch'] as int,
    entries: (json['entries'] as List<dynamic>?)
        ?.map((e) => TournamentEntry.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
  );
}

class TournamentEntry {
  const TournamentEntry({
    required this.guildId,
    required this.guildName,
    required this.score,
    required this.guildLevel,
  });

  final String guildId, guildName;
  final int score, guildLevel;

  Map<String, dynamic> toJson() => {
    'guildId': guildId, 'guildName': guildName,
    'score': score, 'guildLevel': guildLevel,
  };

  static TournamentEntry fromJson(Map<String, dynamic> json) => TournamentEntry(
    guildId: json['guildId'] as String,
    guildName: json['guildName'] as String,
    score: (json['score'] as int?) ?? 0,
    guildLevel: (json['guildLevel'] as int?) ?? 1,
  );
}

// ── Guild War (Weekly GvG) ────────────────────────────────────────────────────

class GuildWar {
  GuildWar({
    required this.weekEpoch,
    required this.guildAId,
    required this.guildAName,
    required this.guildBId,
    required this.guildBName,
    this.guildAScore = 0,
    this.guildBScore = 0,
    this.guildAContributions = const {},
    this.guildBContributions = const {},
    this.phase = GuildWarPhase.preparation,
    this.territoryStakes = const [],
  });

  final int weekEpoch;
  final String guildAId, guildAName, guildBId, guildBName;
  int guildAScore, guildBScore;
  Map<String, int> guildAContributions; // userId → damage
  Map<String, int> guildBContributions;
  GuildWarPhase phase;
  List<String> territoryStakes; // territory IDs at stake

  bool get isPrep => phase == GuildWarPhase.preparation;
  bool get isActive => phase == GuildWarPhase.battle;
  bool get isEnded => phase == GuildWarPhase.ended;
  String? get winnerId => isEnded
      ? (guildAScore > guildBScore ? guildAId
          : guildBScore > guildAScore ? guildBId : null)
      : null;

  void contribute(String guildId, String userId, int damage) {
    if (guildId == guildAId) {
      guildAScore += damage;
      guildAContributions = Map.from(guildAContributions)
        ..update(userId, (v) => v + damage, ifAbsent: () => damage);
    } else if (guildId == guildBId) {
      guildBScore += damage;
      guildBContributions = Map.from(guildBContributions)
        ..update(userId, (v) => v + damage, ifAbsent: () => damage);
    }
  }

  Map<String, dynamic> toJson() => {
    'weekEpoch': weekEpoch,
    'guildAId': guildAId, 'guildAName': guildAName,
    'guildBId': guildBId, 'guildBName': guildBName,
    'guildAScore': guildAScore, 'guildBScore': guildBScore,
    'guildAContributions': guildAContributions,
    'guildBContributions': guildBContributions,
    'phase': phase.name,
    'territoryStakes': territoryStakes,
  };

  static GuildWar fromJson(Map<String, dynamic> json) => GuildWar(
    weekEpoch: json['weekEpoch'] as int,
    guildAId: json['guildAId'] as String,
    guildAName: json['guildAName'] as String,
    guildBId: json['guildBId'] as String,
    guildBName: json['guildBName'] as String,
    guildAScore: (json['guildAScore'] as int?) ?? 0,
    guildBScore: (json['guildBScore'] as int?) ?? 0,
    guildAContributions: (json['guildAContributions'] as Map<String, dynamic>?)
        ?.map((k, v) => MapEntry(k, v as int)) ?? {},
    guildBContributions: (json['guildBContributions'] as Map<String, dynamic>?)
        ?.map((k, v) => MapEntry(k, v as int)) ?? {},
    phase: GuildWarPhase.values.firstWhere(
        (p) => p.name == json['phase'], orElse: () => GuildWarPhase.preparation),
    territoryStakes: (json['territoryStakes'] as List<dynamic>?)?.cast<String>() ?? [],
  );

  // Rewards scale with contribution rank
  static Map<String, int> rewardsForRank(int rank, bool won) {
    final base = won ? 2 : 1;
    return switch (rank) {
      1 => {'guildCoins': 300 * base, 'gold': 50000 * base, 'echoes': 200 * base, 'zcoins': 40 * base},
      2 => {'guildCoins': 200 * base, 'gold': 35000 * base, 'echoes': 150 * base, 'zcoins': 25 * base},
      3 => {'guildCoins': 150 * base, 'gold': 25000 * base, 'echoes': 100 * base, 'zcoins': 15 * base},
      _ => {'guildCoins': 100 * base, 'gold': 15000 * base, 'echoes': 50 * base, 'zcoins': 10 * base},
    };
  }
}

enum GuildWarPhase { preparation, battle, ended }

// ── Guild War Schedule ───────────────────────────────────────────────────────
// Monday-Tuesday: Preparation (sign up, pick territories to contest)
// Wednesday-Friday: Battle (contribute damage via attacks)
// Saturday: Results + rewards distributed
// Sunday: Rest

class GuildWarSchedule {
  static GuildWarPhase currentPhase() {
    final weekday = DateTime.now().weekday;
    if (weekday <= 2) return GuildWarPhase.preparation;
    if (weekday <= 5) return GuildWarPhase.battle;
    return GuildWarPhase.ended;
  }

  static String get phaseLabel => switch (currentPhase()) {
    GuildWarPhase.preparation => '🛡 PREPARATION — Sign up & stake territories',
    GuildWarPhase.battle      => '⚔ BATTLE — Attack to earn points for your guild',
    GuildWarPhase.ended       => '🏆 RESULTS — War ended, claim rewards',
  };

  static int currentWeekEpoch() =>
      DateTime.now().millisecondsSinceEpoch ~/ (7 * 24 * 60 * 60 * 1000);
}

// ── Guild Shop Items ─────────────────────────────────────────────────────────

class GuildShopItem {
  const GuildShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final int cost;
  final String icon;

  static const catalog = [
    GuildShopItem(id: 'guild_xp_scroll', name: 'XP Scroll',
        description: '+50% XP for 1 hour', cost: 50, icon: '📜'),
    GuildShopItem(id: 'guild_gold_bag', name: 'Gold Pouch',
        description: '+5000 Gold', cost: 30, icon: '💰'),
    GuildShopItem(id: 'guild_shard_box', name: 'Shard Box',
        description: '+50 Shards', cost: 40, icon: '◆'),
    GuildShopItem(id: 'guild_echo_crystal', name: 'Echo Crystal',
        description: '+30 Echoes', cost: 60, icon: '🔊'),
    GuildShopItem(id: 'guild_mythril_ore', name: 'Mythril Ore',
        description: '+10 Mythril', cost: 80, icon: '⬡'),
    GuildShopItem(id: 'guild_gem_dust', name: 'Gem Dust',
        description: '+25 Gem Shards', cost: 45, icon: '💠'),
    GuildShopItem(id: 'guild_essence_vial', name: 'Essence Vial',
        description: '+100 Essence', cost: 55, icon: '✦'),
    GuildShopItem(id: 'guild_crystal_chest', name: 'ZCoin Chest',
        description: '+20 ZCoins', cost: 70, icon: '🪙'),
  ];
}

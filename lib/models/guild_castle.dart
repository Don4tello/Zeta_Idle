import 'dart:math';

// ─────────────────────────────────────────────────────────────────────────────
// Guild Castle — a gold-built 10-tier construction track layered on top of the
// existing XP-driven guild levels (see guild.dart). Members donate gold for
// Construction Points (CP); CP is capped per member per day so activity beats
// wealth. The castle tier is the visible expression of the track.
//
// Gameplay code must read GuildBuffs, never CastleState.tier directly.
// ─────────────────────────────────────────────────────────────────────────────

class CastleTier {
  /// CP required to advance FROM (t-1) TO t, for t = 2..10.
  /// marginalCP(t) = round(1000 × 1.6^(t-2)).  Tier 1 is the free starting plot.
  static const Map<int, int> marginalCP = {
    2: 1000,
    3: 1600,
    4: 2560,
    5: 4096,
    6: 6554,
    7: 10486,
    8: 16777,
    9: 26844,
    10: 42950,
  };

  static const int maxTier = 10;

  /// Per-member daily contribution cap (CP). The key tuning dial (see design §2).
  static const int dailyCpCap = 100;

  /// Gold cost of one CP at a given castle tier: 250 × 1.9^(tier-1).
  static int goldPerCP(int tier) => (250 * pow(1.9, tier - 1)).round();

  /// Weekly upkeep (CP) skimmed before progress counts, for tiers >= 5.
  static int weeklyUpkeepCP(int tier) => tier >= 5 ? tier * 40 : 0;

  /// Cumulative CP poured in to REACH a given tier from tier 1.
  static int cumulativeCP(int tier) {
    var sum = 0;
    for (var t = 2; t <= tier; t++) {
      sum += marginalCP[t] ?? 0;
    }
    return sum;
  }
}

/// Guild-wide castle state. Additive to the existing Guild object.
class CastleState {
  CastleState({
    this.tier = 1,
    this.storedCP = 0,
    this.lifetimeCP = 0,
    this.lastUpkeepWeek = 0,
    List<String>? decor,
  }) : decor = List.of(decor ?? const []);

  int tier;              // 1..10 — the visible castle
  int storedCP;          // CP banked toward the next tier (post-upkeep)
  int lifetimeCP;        // total CP ever poured in (guild-wide prestige)
  int lastUpkeepWeek;    // week-epoch upkeep was last charged
  List<String> decor;    // unlocked cosmetic décor ids

  int get cpToNextTier => tier >= CastleTier.maxTier
      ? 0
      : (CastleTier.marginalCP[tier + 1] ?? 0);

  double get progress => tier >= CastleTier.maxTier
      ? 1.0
      : (cpToNextTier == 0 ? 0.0 : (storedCP / cpToNextTier).clamp(0.0, 1.0));

  bool get isMaxTier => tier >= CastleTier.maxTier;
  int get goldPerCP => CastleTier.goldPerCP(tier);
  int get weeklyUpkeepCP => CastleTier.weeklyUpkeepCP(tier);

  /// Add CP toward construction, advancing the tier when the threshold is met.
  /// Returns the number of tiers gained (0 or more).
  int addCP(int cp) {
    if (cp <= 0 || isMaxTier) return 0;
    lifetimeCP += cp;
    storedCP += cp;
    var gained = 0;
    while (!isMaxTier && storedCP >= cpToNextTier && cpToNextTier > 0) {
      storedCP -= cpToNextTier;
      tier++;
      gained++;
    }
    if (isMaxTier) storedCP = 0;
    return gained;
  }

  Map<String, dynamic> toJson() => {
    'tier': tier,
    'storedCP': storedCP,
    'lifetimeCP': lifetimeCP,
    'lastUpkeepWeek': lastUpkeepWeek,
    'decor': decor,
  };

  static CastleState fromJson(Map<String, dynamic>? json) {
    if (json == null) return CastleState();
    return CastleState(
      tier: (json['tier'] as int?) ?? 1,
      storedCP: (json['storedCP'] as int?) ?? 0,
      lifetimeCP: (json['lifetimeCP'] as int?) ?? 0,
      lastUpkeepWeek: (json['lastUpkeepWeek'] as int?) ?? 0,
      decor: (json['decor'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }
}

/// One member's construction contribution. Extends the existing GuildMember,
/// which already tracks totalDonated (gold). This tracks CP + caps.
class GuildContribution {
  const GuildContribution({
    required this.userId,
    this.lifetimeCP = 0,
    this.weeklyCP = 0,
    this.todayCP = 0,
    this.lastContribDay = 0,
  });

  final String userId;
  final int lifetimeCP; // forfeited on leave (anti-hop)
  final int weeklyCP;   // resets Monday — gates the weekly Construction Goal
  final int todayCP;    // gates the daily cap
  final int lastContribDay; // epoch-day; a change resets todayCP

  /// CP this member can still contribute today (respects a day rollover).
  int cpRemainingToday(int epochToday) {
    final spentToday = lastContribDay == epochToday ? todayCP : 0;
    return (CastleTier.dailyCpCap - spentToday).clamp(0, CastleTier.dailyCpCap);
  }

  GuildContribution addCP(int cp, int epochToday, int weekEpoch, {required bool newWeek}) {
    final rolledDay = lastContribDay != epochToday;
    return GuildContribution(
      userId: userId,
      lifetimeCP: lifetimeCP + cp,
      weeklyCP: (newWeek ? 0 : weeklyCP) + cp,
      todayCP: (rolledDay ? 0 : todayCP) + cp,
      lastContribDay: epochToday,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'lifetimeCP': lifetimeCP,
    'weeklyCP': weeklyCP,
    'todayCP': todayCP,
    'lastContribDay': lastContribDay,
  };

  static GuildContribution fromJson(Map<String, dynamic> json) => GuildContribution(
    userId: json['userId'] as String,
    lifetimeCP: (json['lifetimeCP'] as int?) ?? 0,
    weeklyCP: (json['weeklyCP'] as int?) ?? 0,
    todayCP: (json['todayCP'] as int?) ?? 0,
    lastContribDay: (json['lastContribDay'] as int?) ?? 0,
  );
}

/// Result of a construction contribution (returned by GuildService).
class CastleContribResult {
  const CastleContribResult(this.cpAdded, this.tiersGained, this.newTier,
      {this.goldSpent = 0, this.capReached = false});
  final int cpAdded;      // CP actually added
  final int tiersGained;  // castle tiers gained (0+)
  final int newTier;      // resulting castle tier
  final int goldSpent;    // gold actually consumed (caller deducts this)
  final bool capReached;  // true if the daily cap blocked the contribution
}

/// Resolved castle benefits the rest of the game reads. Gameplay code must use
/// this and never branch on tier numbers. See design §3 for the exact table.
class GuildBuffs {
  const GuildBuffs({
    this.goldPct = 0,
    this.allResPct = 0,
    this.echoPctGauntlet = 0,
    this.craftCostPct = 0,
    this.allDamagePct = 0,
    this.rosterBonus = 0,
    this.stashTabs = 0,
    this.shopSlots = 0,
    this.expeditionSlots = 1,
    this.bossAttacks = 0,
    this.weeklyGoalUnlocked = false,
  });

  final double goldPct;        // +% gold (additive with XP-level goldBonus)
  final double allResPct;      // +% all resources (gold/shards/echoes/essence)
  final double echoPctGauntlet;// +% echoes from Gauntlet & Boss Rush
  final double craftCostPct;   // gold craft/upgrade cost reduction (%)
  final double allDamagePct;   // +% all damage (T10, scales with weekly actives)
  final int rosterBonus;       // extra member slots
  final int stashTabs;         // shared stash tabs
  final int shopSlots;         // extra guild-shop stock slots
  final int expeditionSlots;   // concurrent expeditions (base 1)
  final int bossAttacks;       // extra guild-boss attacks per member
  final bool weeklyGoalUnlocked;

  /// Total effective gold % including the all-resource bonus.
  double get effectiveGoldPct => goldPct + allResPct;

  /// Resolve the cumulative benefits for a castle. [activeThisWeek] scales the
  /// tier-10 damage buff (capped at +15%).
  factory GuildBuffs.fromCastle(CastleState c, {required int activeThisWeek}) {
    final t = c.tier;
    return GuildBuffs(
      goldPct:          t >= 3 ? 5 : 0,
      allResPct:        t >= 9 ? 5 : 0,
      echoPctGauntlet:  t >= 7 ? 10 : 0,
      craftCostPct:     t >= 6 ? 8 : 0,
      allDamagePct:     t >= 10 ? (activeThisWeek * 0.5).clamp(0, 15).toDouble() : 0,
      rosterBonus:      (t >= 5 ? 2 : 0) + (t >= 8 ? 3 : 0),
      stashTabs:        t >= 2 ? 1 : 0,
      shopSlots:        t >= 4 ? 2 : 0,
      expeditionSlots:  t >= 8 ? 2 : 1,
      bossAttacks:      t >= 5 ? 1 : 0,
      weeklyGoalUnlocked: t >= 3,
    );
  }

  /// The headline unlock string for a given tier (for "what you unlock next").
  static String headlineFor(int tier) => switch (tier) {
    1 => 'Foundation — Construction unlocked',
    2 => 'Keep raised — +1 shared stash tab',
    3 => 'Gatehouse — +5% gold, weekly Construction Goal',
    4 => 'Curtain wall — +2 guild-shop slots',
    5 => 'Portcullis — +1 guild-boss attack, roster +2',
    6 => 'Great Keep — craft/upgrade cost −8% gold',
    7 => 'Moat & drawbridge — +10% Echoes (Gauntlet/Boss Rush)',
    8 => 'Outer bailey — +1 expedition slot, roster +3',
    9 => 'Great hall — +5% all resources',
    10 => 'Citadel — +0.5% all damage per active member (cap +15%)',
    _ => '',
  };
}

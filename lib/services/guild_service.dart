import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/guild.dart';
import '../models/guild_castle.dart';

class GuildService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  static const _collection = 'guilds';

  static bool get isAvailable {
    try {
      final fs = FirebaseFirestore.instance;
      // Check if Firebase app is actually initialized, not just the SDK linked
      fs.app.name; // throws if no app
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Create ──────────────────────────────────────────────────────────────────

  Future<Guild> createGuild({
    required String name,
    required String leaderId,
    required String leaderName,
    required String leaderClass,
    required int leaderLevel,
    String description = '',
    String icon = '⚔',
  }) async {
    final doc = _db.collection(_collection).doc();
    final member = GuildMember(
      userId: leaderId,
      name: leaderName,
      heroClass: leaderClass,
      level: leaderLevel,
      role: GuildRole.leader,
      lastActive: DateTime.now(),
    );
    final guild = Guild(
      id: doc.id,
      name: name,
      leaderId: leaderId,
      description: description,
      icon: icon,
      members: [member],
      createdAt: DateTime.now(),
    );
    await doc.set(guild.toJson());
    return guild;
  }

  // ── Join ────────────────────────────────────────────────────────────────────

  Future<bool> joinGuild(String guildId, GuildMember member) async {
    final doc = _db.collection(_collection).doc(guildId);
    final snap = await doc.get();
    if (!snap.exists) return false;
    final guild = Guild.fromJson(snap.data()!);
    if (guild.isFull) return false;
    if (guild.members.any((m) => m.userId == member.userId)) return false;

    guild.members.add(member);
    await doc.update({'members': guild.members.map((m) => m.toJson()).toList()});
    return true;
  }

  // ── Leave ───────────────────────────────────────────────────────────────────

  Future<void> leaveGuild(String guildId, String userId) async {
    final doc = _db.collection(_collection).doc(guildId);
    final snap = await doc.get();
    if (!snap.exists) return;
    final guild = Guild.fromJson(snap.data()!);
    guild.members.removeWhere((m) => m.userId == userId);

    if (guild.members.isEmpty) {
      await doc.delete();
    } else {
      if (guild.leaderId == userId && guild.members.isNotEmpty) {
        guild.leaderId = guild.members.first.userId;
      }
      await doc.update({
        'members': guild.members.map((m) => m.toJson()).toList(),
        'leaderId': guild.leaderId,
      });
    }
  }

  // ── Fetch ───────────────────────────────────────────────────────────────────

  Future<Guild?> fetchGuild(String guildId) async {
    final snap = await _db.collection(_collection).doc(guildId).get();
    if (!snap.exists) return null;
    return Guild.fromJson(snap.data()!);
  }

  // For MVP, guild membership is tracked via guildId on the user's game state.
  // Firestore nested-object queries aren't practical for member lookup.

  Future<List<Guild>> listGuilds({int limit = 20}) async {
    final snap = await _db.collection(_collection)
        .orderBy('level', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => Guild.fromJson(d.data())).toList();
  }

  Future<List<Guild>> searchGuilds(String query) async {
    final snap = await _db.collection(_collection)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '${query}z')
        .limit(10)
        .get();
    return snap.docs.map((d) => Guild.fromJson(d.data())).toList();
  }

  // ── Chat ────────────────────────────────────────────────────────────────────

  Future<void> sendMessage(String guildId, GuildMessage message) async {
    final doc = _db.collection(_collection).doc(guildId);
    final snap = await doc.get();
    if (!snap.exists) return;
    final guild = Guild.fromJson(snap.data()!);
    guild.messages.add(message);
    if (guild.messages.length > Guild.maxMessages) {
      guild.messages.removeRange(0, guild.messages.length - Guild.maxMessages);
    }
    await doc.update({'messages': guild.messages.map((m) => m.toJson()).toList()});
  }

  // ── Boss Damage ─────────────────────────────────────────────────────────────

  Future<void> dealBossDamage(String guildId, String userId, int damage) async {
    final doc = _db.collection(_collection).doc(guildId);
    final snap = await doc.get();
    if (!snap.exists) return;
    final guild = Guild.fromJson(snap.data()!);
    if (guild.weeklyBoss == null || guild.weeklyBoss!.defeated) return;

    guild.weeklyBoss!.takeDamage(damage);

    final memberIdx = guild.members.indexWhere((m) => m.userId == userId);
    if (memberIdx >= 0) {
      final old = guild.members[memberIdx];
      guild.members[memberIdx] = GuildMember(
        userId: old.userId,
        name: old.name,
        heroClass: old.heroClass,
        level: old.level,
        role: old.role,
        weeklyDamage: old.weeklyDamage + damage,
        totalDonated: old.totalDonated,
        guildCoins: old.guildCoins + (damage ~/ 100).clamp(1, 50),
        lastActive: DateTime.now(),
      );
    }

    // Guild XP from boss damage
    guild.xp += (damage ~/ 50).clamp(1, 100);
    if (guild.xp >= guild.xpToNextLevel) {
      guild.xp -= guild.xpToNextLevel;
      guild.level++;
    }

    await doc.update({
      'weeklyBoss': guild.weeklyBoss!.toJson(),
      'members': guild.members.map((m) => m.toJson()).toList(),
      'xp': guild.xp,
      'level': guild.level,
    });
  }

  // ── Donate Gold ─────────────────────────────────────────────────────────────

  Future<void> donateGold(String guildId, String userId, int amount) async {
    final doc = _db.collection(_collection).doc(guildId);
    final snap = await doc.get();
    if (!snap.exists) return;
    final guild = Guild.fromJson(snap.data()!);

    guild.xp += (amount ~/ 100).clamp(1, 50);
    if (guild.xp >= guild.xpToNextLevel) {
      guild.xp -= guild.xpToNextLevel;
      guild.level++;
    }

    final memberIdx = guild.members.indexWhere((m) => m.userId == userId);
    if (memberIdx >= 0) {
      final old = guild.members[memberIdx];
      guild.members[memberIdx] = GuildMember(
        userId: old.userId,
        name: old.name,
        heroClass: old.heroClass,
        level: old.level,
        role: old.role,
        weeklyDamage: old.weeklyDamage,
        totalDonated: old.totalDonated + amount,
        guildCoins: old.guildCoins + (amount ~/ 200).clamp(1, 20),
        lastActive: DateTime.now(),
      );
    }

    await doc.update({
      'members': guild.members.map((m) => m.toJson()).toList(),
      'xp': guild.xp,
      'level': guild.level,
    });
  }

  // ── Castle Construction ─────────────────────────────────────────────────────

  /// Result of a construction contribution.
  static int _epochToday() =>
      DateTime.now().millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000);

  /// Contribute [goldSpent] gold to the guild castle. Converts to CP at the
  /// current tier's rate, capped by the member's remaining daily CP. Applies
  /// weekly upkeep first. Returns (cpAdded, tiersGained, newTier) or null if
  /// nothing could be contributed (cap hit / no guild). Gold is deducted by the
  /// caller (GameState) only when this returns a non-null cpAdded > 0.
  Future<CastleContribResult?> contributeConstruction(
      String guildId, String userId, String userName, int goldSpent) async {
    final doc = _db.collection(_collection).doc(guildId);
    final snap = await doc.get();
    if (!snap.exists) return null;
    final data = snap.data()!;
    final guild = Guild.fromJson(data);
    final castle = guild.castle;

    final today = _epochToday();
    final week = GuildWarSchedule.currentWeekEpoch();

    // Weekly upkeep — skim once per week before progress counts.
    if (castle.lastUpkeepWeek != week) {
      final upkeep = castle.weeklyUpkeepCP;
      castle.storedCP = (castle.storedCP - upkeep).clamp(0, 1 << 30);
      castle.lastUpkeepWeek = week;
    }

    // Load per-member construction contributions.
    final contribs = ((data['constructions'] as List<dynamic>?) ?? [])
        .map((e) => GuildContribution.fromJson(e as Map<String, dynamic>))
        .toList();
    var idx = contribs.indexWhere((g) => g.userId == userId);
    var mine = idx >= 0 ? contribs[idx] : GuildContribution(userId: userId);

    final remaining = mine.cpRemainingToday(today);
    if (remaining <= 0) return CastleContribResult(0, 0, castle.tier, capReached: true);

    // Gold → CP, capped by the daily remaining CP.
    final affordableCP = goldSpent ~/ castle.goldPerCP;
    final cp = affordableCP.clamp(0, remaining);
    if (cp <= 0) return CastleContribResult(0, 0, castle.tier);

    mine = mine.addCP(cp, today, week,
        newWeek: _isNewContribWeek(mine.lastContribDay, today));
    if (idx >= 0) {
      contribs[idx] = mine;
    } else {
      contribs.add(mine);
    }

    final gained = castle.addCP(cp);
    final goldSpentActual = cp * castle.goldPerCP;

    await doc.update({
      'castle': castle.toJson(),
      'constructions': contribs.map((e) => e.toJson()).toList(),
    });
    return CastleContribResult(cp, gained, castle.tier, goldSpent: goldSpentActual);
  }

  // A member's weeklyCP resets on the ISO-week boundary. We approximate by
  // resetting when the day-of-contribution crosses into a new 7-day block.
  bool _isNewContribWeek(int lastDay, int today) {
    if (lastDay == 0) return false;
    return (today ~/ 7) != (lastDay ~/ 7);
  }

  /// Load the castle construction leaderboard (top lifetime contributors).
  Future<List<GuildContribution>> fetchConstructions(String guildId) async {
    final snap = await _db.collection(_collection).doc(guildId).get();
    if (!snap.exists) return [];
    final contribs = ((snap.data()!['constructions'] as List<dynamic>?) ?? [])
        .map((e) => GuildContribution.fromJson(e as Map<String, dynamic>))
        .toList();
    contribs.sort((a, b) => b.lifetimeCP.compareTo(a.lifetimeCP));
    return contribs;
  }

  // ── Ensure Weekly Boss ──────────────────────────────────────────────────────

  Future<void> ensureWeeklyBoss(String guildId) async {
    final doc = _db.collection(_collection).doc(guildId);
    final snap = await doc.get();
    if (!snap.exists) return;
    final guild = Guild.fromJson(snap.data()!);
    final currentWeek = DateTime.now().millisecondsSinceEpoch ~/ (7 * 24 * 60 * 60 * 1000);

    if (guild.weeklyBoss == null || guild.weeklyBoss!.weekStartEpoch != currentWeek) {
      guild.weeklyBoss = GuildBoss.generate(guild.memberCount, guild.level);
      // Reset weekly damage for all members
      guild.members = guild.members.map((m) => GuildMember(
        userId: m.userId, name: m.name, heroClass: m.heroClass,
        level: m.level, role: m.role, weeklyDamage: 0,
        totalDonated: m.totalDonated, guildCoins: m.guildCoins,
        lastActive: m.lastActive,
      )).toList();
      await doc.update({
        'weeklyBoss': guild.weeklyBoss!.toJson(),
        'members': guild.members.map((m) => m.toJson()).toList(),
      });
    }
  }

  // ── Rank Management ─────────────────────────────────────────────────────────

  Future<void> promoteMember(String guildId, String leaderId, String targetId, GuildRole newRole) async {
    final doc = _db.collection(_collection).doc(guildId);
    final snap = await doc.get();
    if (!snap.exists) return;
    final guild = Guild.fromJson(snap.data()!);
    if (guild.leaderId != leaderId) return;

    final idx = guild.members.indexWhere((m) => m.userId == targetId);
    if (idx < 0) return;
    final old = guild.members[idx];
    guild.members[idx] = GuildMember(
      userId: old.userId, name: old.name, heroClass: old.heroClass,
      level: old.level, role: newRole, weeklyDamage: old.weeklyDamage,
      totalDonated: old.totalDonated, guildCoins: old.guildCoins,
      lastActive: old.lastActive,
    );
    await doc.update({'members': guild.members.map((m) => m.toJson()).toList()});
  }

  Future<void> kickMember(String guildId, String officerId, String targetId) async {
    final doc = _db.collection(_collection).doc(guildId);
    final snap = await doc.get();
    if (!snap.exists) return;
    final guild = Guild.fromJson(snap.data()!);
    final kicker = guild.members.where((m) => m.userId == officerId).firstOrNull;
    if (kicker == null) return;
    if (kicker.role != GuildRole.leader && kicker.role != GuildRole.officer) return;
    if (targetId == guild.leaderId) return;

    guild.members.removeWhere((m) => m.userId == targetId);
    await doc.update({'members': guild.members.map((m) => m.toJson()).toList()});
  }

  // ── Guild Expeditions ───────────────────────────────────────────────────────

  Future<void> startGuildExpedition(String guildId, String expeditionId, String userId) async {
    final doc = _db.collection(_collection).doc(guildId);
    final snap = await doc.get();
    if (!snap.exists) return;
    final data = snap.data()!;
    final expeditions = (data['guildExpeditions'] as List<dynamic>?)
        ?.map((e) => GuildExpedition.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    var exp = expeditions.where((e) => e.id == expeditionId).firstOrNull;
    if (exp == null) {
      exp = GuildExpedition.catalog.where((e) => e.id == expeditionId).firstOrNull;
      if (exp == null) return;
      expeditions.add(exp);
    }
    if (exp.participants.contains(userId) || exp.isFull) return;
    exp.participants.add(userId);
    if (exp.isFull) exp.startEpoch = DateTime.now().millisecondsSinceEpoch;

    await doc.update({
      'guildExpeditions': expeditions.map((e) => e.toJson()).toList(),
    });
  }

  Future<Map<String, int>?> collectGuildExpedition(String guildId, String expeditionId) async {
    final doc = _db.collection(_collection).doc(guildId);
    final snap = await doc.get();
    if (!snap.exists) return null;
    final data = snap.data()!;
    final expeditions = (data['guildExpeditions'] as List<dynamic>?)
        ?.map((e) => GuildExpedition.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    final exp = expeditions.where((e) => e.id == expeditionId).firstOrNull;
    if (exp == null || !exp.isComplete) return null;

    final rewards = Map<String, int>.from(exp.rewards);
    expeditions.removeWhere((e) => e.id == expeditionId);
    await doc.update({
      'guildExpeditions': expeditions.map((e) => e.toJson()).toList(),
    });
    return rewards;
  }

  // ── Raid Bosses ─────────────────────────────────────────────────────────────

  Future<List<GuildRaid>> getAvailableRaids(String guildId) async {
    final doc = _db.collection(_collection).doc(guildId);
    final snap = await doc.get();
    if (!snap.exists) return [];
    final guild = Guild.fromJson(snap.data()!);
    final today = RaidCatalog.todayRaid(guild.level, guild.memberCount);
    if (today == null) return [];
    final raids = [today];
    // Load active raids from Firestore
    final activeSnap = await _db.collection('$_collection/$guildId/raids').get();
    final active = <String, GuildRaid>{};
    for (final d in activeSnap.docs) {
      active[d.id] = GuildRaid.fromJson(d.data());
    }
    // Merge: replace catalog entries with active ones
    return raids.map((r) => active[r.id] ?? r).toList();
  }

  Future<void> startRaid(String guildId, GuildRaid raid) async {
    raid.startEpoch = DateTime.now().millisecondsSinceEpoch;
    await _db.collection('$_collection/$guildId/raids').doc(raid.id).set(raid.toJson());
  }

  Future<GuildRaid?> attackRaid(String guildId, String raidId, String userId, String userName, int damage) async {
    final doc = _db.collection('$_collection/$guildId/raids').doc(raidId);
    final snap = await doc.get();
    if (!snap.exists) return null;
    final raid = GuildRaid.fromJson(snap.data()!);
    if (raid.completed) return raid;

    raid.dealDamage(userId, userName, damage);
    await doc.update(raid.toJson());

    // If completed, award guild XP
    if (raid.completed) {
      final guildDoc = _db.collection(_collection).doc(guildId);
      final guildSnap = await guildDoc.get();
      if (guildSnap.exists) {
        final guild = Guild.fromJson(guildSnap.data()!);
        guild.xp += 50 * raid.boss.tier;
        if (guild.xp >= guild.xpToNextLevel) {
          guild.xp -= guild.xpToNextLevel;
          guild.level++;
        }
        await guildDoc.update({'xp': guild.xp, 'level': guild.level});
      }
    }
    return raid;
  }

  Future<void> claimRaidLoot(String guildId, String raidId, String userId) async {
    final doc = _db.collection('$_collection/$guildId/raids').doc(raidId);
    final snap = await doc.get();
    if (!snap.exists) return;
    final raid = GuildRaid.fromJson(snap.data()!);
    if (!raid.completed || raid.lootClaimed.contains(userId)) return;
    raid.lootClaimed.add(userId);
    await doc.update({'lootClaimed': raid.lootClaimed});
  }

  // ── Guild War (Weekly GvG) ───────────────────────────────────────────────────

  Future<GuildWar?> findOrCreateWar(String guildId, String guildName) async {
    final week = GuildWarSchedule.currentWeekEpoch();
    final warCol = _db.collection('guild_wars');

    // Check if this guild already has a war this week
    final existing = await warCol
        .where('weekEpoch', isEqualTo: week)
        .get();
    for (final doc in existing.docs) {
      final war = GuildWar.fromJson(doc.data());
      if (war.guildAId == guildId || war.guildBId == guildId) return war;
    }

    // Find an open war to join (one side empty)
    for (final doc in existing.docs) {
      final war = GuildWar.fromJson(doc.data());
      if (war.guildBId.isEmpty) {
        war.guildBContributions = {};
        await doc.reference.update({
          'guildBId': guildId,
          'guildBName': guildName,
        });
        return GuildWar.fromJson({...doc.data(), 'guildBId': guildId, 'guildBName': guildName});
      }
    }

    // Create a new open war
    final warDoc = warCol.doc();
    final war = GuildWar(
      weekEpoch: week,
      guildAId: guildId,
      guildAName: guildName,
      guildBId: '',
      guildBName: '',
      phase: GuildWarSchedule.currentPhase(),
      territoryStakes: GuildTerritory.zones.take(3).map((z) => z.id).toList(),
    );
    await warDoc.set(war.toJson());
    return war;
  }

  Future<GuildWar?> getActiveWar(String guildId) async {
    final week = GuildWarSchedule.currentWeekEpoch();
    final snap = await _db.collection('guild_wars')
        .where('weekEpoch', isEqualTo: week)
        .get();
    for (final doc in snap.docs) {
      final war = GuildWar.fromJson(doc.data());
      if (war.guildAId == guildId || war.guildBId == guildId) return war;
    }
    return null;
  }

  Future<void> contributeToWar(String guildId, String userId, int damage) async {
    final week = GuildWarSchedule.currentWeekEpoch();
    final snap = await _db.collection('guild_wars')
        .where('weekEpoch', isEqualTo: week)
        .get();
    for (final doc in snap.docs) {
      final war = GuildWar.fromJson(doc.data());
      if (war.guildAId != guildId && war.guildBId != guildId) continue;
      if (!war.isActive && !war.isPrep) continue;

      war.contribute(guildId, userId, damage);
      war.phase = GuildWarSchedule.currentPhase();
      await doc.reference.update(war.toJson());
      return;
    }
  }

  Future<Map<String, int>?> claimWarRewards(String guildId, String userId) async {
    final week = GuildWarSchedule.currentWeekEpoch();
    final snap = await _db.collection('guild_wars')
        .where('weekEpoch', isEqualTo: week)
        .get();
    for (final doc in snap.docs) {
      final war = GuildWar.fromJson(doc.data());
      if (war.guildAId != guildId && war.guildBId != guildId) continue;
      if (!war.isEnded) continue;

      final won = war.winnerId == guildId;
      final contribs = guildId == war.guildAId ? war.guildAContributions : war.guildBContributions;
      if (!contribs.containsKey(userId)) return null;

      // Rank by contribution
      final sorted = contribs.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final rank = sorted.indexWhere((e) => e.key == userId) + 1;

      return GuildWar.rewardsForRank(rank.clamp(1, 99), won);
    }
    return null;
  }

  // ── Territory Wars ──────────────────────────────────────────────────────────

  Future<void> claimTerritory(String guildId, String territoryId) async {
    final doc = _db.collection(_collection).doc(guildId);
    final snap = await doc.get();
    if (!snap.exists) return;
    final guild = Guild.fromJson(snap.data()!);
    if (guild.territories.contains(territoryId)) return;
    guild.territories.add(territoryId);
    await doc.update({'territories': guild.territories});
  }

  Future<void> loseTerritory(String guildId, String territoryId) async {
    final doc = _db.collection(_collection).doc(guildId);
    final snap = await doc.get();
    if (!snap.exists) return;
    final guild = Guild.fromJson(snap.data()!);
    guild.territories.remove(territoryId);
    await doc.update({'territories': guild.territories});
  }

  // ── Cosmetics ───────────────────────────────────────────────────────────────

  Future<void> buyCosmetic(String guildId, String cosmeticId) async {
    final doc = _db.collection(_collection).doc(guildId);
    final snap = await doc.get();
    if (!snap.exists) return;
    final guild = Guild.fromJson(snap.data()!);
    if (guild.ownedCosmetics.contains(cosmeticId)) return;
    guild.ownedCosmetics.add(cosmeticId);
    await doc.update({'ownedCosmetics': guild.ownedCosmetics});
  }

  Future<void> equipCosmetic(String guildId, String cosmeticId, GuildCosmeticType type) async {
    final doc = _db.collection(_collection).doc(guildId);
    final update = <String, dynamic>{};
    switch (type) {
      case GuildCosmeticType.banner: update['equippedBanner'] = cosmeticId;
      case GuildCosmeticType.frame:  update['equippedFrame'] = cosmeticId;
      case GuildCosmeticType.aura:   break;
    }
    if (update.isNotEmpty) await doc.update(update);
  }
}

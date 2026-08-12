import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Which leaderboard a query/submission targets. Each board is its own
/// Firestore collection, keyed by the player's uid (one best-entry per player).
enum LeaderboardBoard { campaign, dungeon, endless, bossRush, gauntlet }

extension LeaderboardBoardInfo on LeaderboardBoard {
  String get collection => switch (this) {
        LeaderboardBoard.campaign => 'campaign_leaderboard',
        LeaderboardBoard.dungeon  => 'dungeon_leaderboard',
        LeaderboardBoard.endless  => 'endless_leaderboard',
        LeaderboardBoard.bossRush => 'boss_rush_leaderboard',
        LeaderboardBoard.gauntlet => 'gauntlet_leaderboard',
      };
  String get title => switch (this) {
        LeaderboardBoard.campaign => 'CAMPAIGN LEADERBOARD',
        LeaderboardBoard.dungeon  => 'DUNGEON LEADERBOARD',
        LeaderboardBoard.endless  => 'ENDLESS LEADERBOARD',
        LeaderboardBoard.bossRush => 'BOSS RUSH LEADERBOARD',
        LeaderboardBoard.gauntlet => 'GAUNTLET LEADERBOARD',
      };
}

/// One player's best entry on a board.
///
/// [score] is the single sortable key. For multi-dimension boards we pack the
/// dimensions into one number so Firestore can orderBy/count efficiently:
///   Campaign → rebirths × 1,000,000 + stage   (rebirths dominate, stage breaks ties)
///   Endless  → stage
/// The raw [rebirths]/[stage] are kept for display.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.uid,
    required this.name,
    required this.heroClass,
    required this.subclass,
    required this.rebirths,
    required this.stage,
    required this.score,
    required this.updatedAt,
  });

  final String uid;
  final String name;
  final String heroClass;
  final String? subclass; // level-50 subclass, e.g. "Oath of the Watchers"
  final int rebirths;
  final int stage;
  final int score;
  final DateTime updatedAt;

  /// Class label with the subclass in brackets, e.g. "Paladin (Oath of the Watchers)".
  String get classLabel =>
      (subclass != null && subclass!.isNotEmpty) ? '$heroClass ($subclass)' : heroClass;

  factory LeaderboardEntry.fromDoc(Map<String, dynamic> data, String uid) {
    // Tolerate legacy Endless docs that only stored 'floor'.
    final stage = (data['stage'] as int?) ?? (data['floor'] as int?) ?? 0;
    final rebirths = (data['rebirths'] as int?) ?? 0;
    return LeaderboardEntry(
      uid: uid,
      name: data['name'] as String? ?? 'Unknown',
      heroClass: data['heroClass'] as String? ?? '',
      subclass: data['subclass'] as String?,
      rebirths: rebirths,
      stage: stage,
      score: (data['score'] as int?) ?? stage,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

class LeaderboardService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static const int _rebirthWeight = 1000000; // stage is always < this

  static CollectionReference<Map<String, dynamic>> _col(LeaderboardBoard b) =>
      _db.collection(b.collection);

  /// Composite sort key for a board.
  ///   Campaign/Dungeon → rebirths dominate, then the within-run metric (stage/tier)
  ///   Endless/BossRush/Gauntlet → the raw score (stage carries floor/score)
  static int _computeScore(LeaderboardBoard board, int rebirths, int stage) {
    return switch (board) {
      LeaderboardBoard.campaign ||
      LeaderboardBoard.dungeon =>
        rebirths * _rebirthWeight + stage.clamp(0, _rebirthWeight - 1),
      LeaderboardBoard.endless ||
      LeaderboardBoard.bossRush ||
      LeaderboardBoard.gauntlet => stage,
    };
  }

  /// Write the player's entry if it beats their stored best (personal-best only).
  static Future<void> submitScore({
    required LeaderboardBoard board,
    required String heroName,
    required String heroClass,
    String? subclass,
    required int rebirths,
    required int stage,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      final score = _computeScore(board, rebirths, stage);
      final doc = _col(board).doc(uid);
      final existing = await doc.get();
      final currentBest = (existing.data()?['score'] as int?)
          ?? (existing.data()?['floor'] as int?) ?? -1;
      if (score <= currentBest) return; // only update on improvement
      await doc.set({
        'name':      heroName,
        'heroClass': heroClass,
        'subclass':  subclass,
        'rebirths':  rebirths,
        'stage':     stage,
        'score':     score,
        // Keep 'floor' mirrored so any legacy reader still works.
        'floor':     stage,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // leaderboard is non-critical — silently ignore errors
    }
  }

  static Future<List<LeaderboardEntry>> fetchTop50(LeaderboardBoard board) async {
    try {
      final snap = await _col(board)
          .orderBy('score', descending: true)
          .limit(50)
          .get();
      return snap.docs
          .map((d) => LeaderboardEntry.fromDoc(d.data(), d.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<LeaderboardEntry?> fetchPersonalBest(LeaderboardBoard board) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;
      final doc = await _col(board).doc(uid).get();
      if (!doc.exists) return null;
      return LeaderboardEntry.fromDoc(doc.data()!, uid);
    } catch (_) {
      return null;
    }
  }

  /// The player's global rank (1-based) = players strictly above them + 1.
  /// Uses Firestore's count() aggregation — one cheap query, no full scan.
  /// Returns null if the player has no entry yet.
  static Future<int?> fetchPersonalRank(LeaderboardBoard board, int myScore) async {
    try {
      final agg = await _col(board)
          .where('score', isGreaterThan: myScore)
          .count()
          .get();
      return (agg.count ?? 0) + 1;
    } catch (_) {
      return null;
    }
  }

  /// Remove this user's entries from every board (account deletion).
  static Future<void> deleteEntry(String uid) async {
    for (final b in LeaderboardBoard.values) {
      try { await _col(b).doc(uid).delete(); } catch (_) {}
    }
  }
}

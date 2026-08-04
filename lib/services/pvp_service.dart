import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pvp.dart';

class PvpService {
  static PvpService? _instance;
  factory PvpService() => _instance ??= PvpService._();
  PvpService._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('pvp_players');

  static const int winDelta  = 25;
  static const int lossDelta = 15;

  static int updatedRating(int current, bool won) =>
      (current + (won ? winDelta : -lossDelta)).clamp(100, 9999);

  Future<void> uploadSnapshot(String userId, PvpSnapshot snap) async {
    final data = snap.toMap();
    data['lastUpdated'] = FieldValue.serverTimestamp();
    await _col.doc(userId).set(data, SetOptions(merge: true));
  }

  /// Remove this user's PvP snapshot (used by account deletion).
  Future<void> deleteSnapshot(String userId) async {
    try { await _col.doc(userId).delete(); } catch (_) {}
  }

  Future<List<PvpSnapshot>> fetchLeaderboard({int limit = 25}) async {
    final q = await _col
        .orderBy('rating', descending: true)
        .limit(limit)
        .get();
    return q.docs
        .map((d) => PvpSnapshot.fromMap(d.id, d.data()))
        .toList();
  }

  Future<PvpSnapshot?> findOpponent(String myUserId, int myRating) async {
    for (final spread in [300, 700, 9999]) {
      final lo = (myRating - spread).clamp(100, 9999);
      final hi = (myRating + spread).clamp(100, 9999);
      try {
        final q = await _col
            .where('rating', isGreaterThanOrEqualTo: lo)
            .where('rating', isLessThanOrEqualTo: hi)
            .limit(50)
            .get();
        final pool = q.docs.where((d) => d.id != myUserId).toList();
        if (pool.isNotEmpty) {
          final pick =
              pool[DateTime.now().millisecondsSinceEpoch % pool.length];
          return PvpSnapshot.fromMap(pick.id, pick.data());
        }
      } catch (_) {}
    }
    return null;
  }

  Future<void> recordResult({
    required String userId,
    required bool won,
    required int newRating,
  }) async {
    final update = <String, dynamic>{
      'rating':      newRating,
      'lastUpdated': FieldValue.serverTimestamp(),
      if (won) 'wins': FieldValue.increment(1)
      else     'losses': FieldValue.increment(1),
    };
    try {
      await _col.doc(userId).update(update);
    } catch (_) {
      // Doc may not exist yet if upload failed; create it
      await _col.doc(userId).set(update, SetOptions(merge: true));
    }
  }
}

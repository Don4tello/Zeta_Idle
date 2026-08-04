import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.uid,
    required this.name,
    required this.floor,
    required this.heroClass,
    required this.updatedAt,
  });
  final String uid;
  final String name;
  final int floor;
  final String heroClass;
  final DateTime updatedAt;

  factory LeaderboardEntry.fromDoc(Map<String, dynamic> data, String uid) {
    return LeaderboardEntry(
      uid: uid,
      name: data['name'] as String? ?? 'Unknown',
      floor: data['floor'] as int? ?? 0,
      heroClass: data['heroClass'] as String? ?? '',
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

class LeaderboardService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('endless_leaderboard');

  /// Remove this user's leaderboard entry (used by account deletion).
  static Future<void> deleteEntry(String uid) async {
    try { await _col.doc(uid).delete(); } catch (_) {}
  }

  static Future<void> submitScore({
    required String heroName,
    required int floor,
    required String heroClass,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      final existing = await _col.doc(uid).get();
      final currentBest = existing.data()?['floor'] as int? ?? 0;
      if (floor <= currentBest) return; // only update if new personal best
      await _col.doc(uid).set({
        'name':      heroName,
        'floor':     floor,
        'heroClass': heroClass,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // leaderboard is non-critical — silently ignore errors
    }
  }

  static Future<List<LeaderboardEntry>> fetchTop50() async {
    try {
      final snap = await _col
          .orderBy('floor', descending: true)
          .limit(50)
          .get();
      return snap.docs
          .map((d) => LeaderboardEntry.fromDoc(d.data(), d.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<LeaderboardEntry?> fetchPersonalBest() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;
      final doc = await _col.doc(uid).get();
      if (!doc.exists) return null;
      return LeaderboardEntry.fromDoc(doc.data()!, uid);
    } catch (_) {
      return null;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// Per-account cloud saves. Each save SLOT is stored independently within the
/// single account document (doc id == uid, so Firestore rules stay unchanged),
/// under the field keys `slot_<n>` / `ts_<n>`. This keeps characters isolated —
/// loading slot 3 never pulls slot 1's cloud data.
class CloudSaveService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('zeta_idle_saves');

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> syncSave(String uid, int slot, Map<String, dynamic> saveData) async {
    try {
      // merge:true so writing one slot never wipes the others.
      await _col.doc(uid).set({
        'slot_$slot': saveData,
        'ts_$slot': FieldValue.serverTimestamp(),
        '_clientVersion': 1,
      }, SetOptions(merge: true));
    } catch (_) {
      // non-critical — silently ignore network errors
    }
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> fetchSave(String uid, int slot) async {
    try {
      final doc = await _col.doc(uid).get();
      if (!doc.exists) return null;
      final s = doc.data()?['slot_$slot'];
      return s is Map<String, dynamic> ? Map<String, dynamic>.from(s) : null;
    } catch (_) {
      return null;
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  /// Permanently delete this user's cloud save document (all slots).
  Future<void> deleteSave(String uid) async {
    try {
      await _col.doc(uid).delete();
    } catch (_) {
      // best-effort; caller may still delete the auth account
    }
  }

  // Server-side timestamp of the last cloud save for a specific slot, or null.
  Future<DateTime?> fetchLastSyncTime(String uid, int slot) async {
    try {
      final doc = await _col.doc(uid).get();
      if (!doc.exists) return null;
      final ts = doc.data()?['ts_$slot'];
      if (ts is Timestamp) return ts.toDate();
      return null;
    } catch (_) {
      return null;
    }
  }
}

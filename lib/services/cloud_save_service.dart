import 'package:cloud_firestore/cloud_firestore.dart';

class CloudSaveService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('zeta_idle_saves');

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> syncSave(String uid, Map<String, dynamic> saveData) async {
    try {
      final payload = Map<String, dynamic>.from(saveData)
        ..['_syncedAt'] = FieldValue.serverTimestamp()
        ..['_clientVersion'] = 1;
      await _col.doc(uid).set(payload);
    } catch (_) {
      // non-critical — silently ignore network errors
    }
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> fetchSave(String uid) async {
    try {
      final doc = await _col.doc(uid).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  // Returns the server-side timestamp of the last cloud save, or null.
  Future<DateTime?> fetchLastSyncTime(String uid) async {
    try {
      final doc = await _col.doc(uid).get();
      if (!doc.exists) return null;
      final ts = doc.data()?['_syncedAt'];
      if (ts is Timestamp) return ts.toDate();
      return null;
    } catch (_) {
      return null;
    }
  }
}

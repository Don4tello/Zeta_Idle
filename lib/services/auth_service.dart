import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  // Desktop client ID from Firebase Console → Project Settings → Your apps → Web app
  // Also needs to be set in Google Cloud Console as an OAuth 2.0 Desktop client.
  // Replace with your actual client ID before shipping.
  static const _desktopClientId =
      'YOUR_DESKTOP_OAUTH_CLIENT_ID.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: _desktopClientId,
    scopes: ['email', 'profile'],
  );

  // ── Current user ──────────────────────────────────────────────────────────

  // All getters guard against Firebase not being initialized (e.g. no valid
  // google-services config yet), so calls to these never throw.
  User? get currentUser {
    try { return _auth.currentUser; } catch (_) { return null; }
  }

  Stream<User?> get authStateChanges {
    try { return _auth.authStateChanges(); } catch (_) { return const Stream.empty(); }
  }

  bool get isGoogleSignedIn {
    try {
      final u = _auth.currentUser;
      return u != null && !u.isAnonymous;
    } catch (_) {
      return false;
    }
  }

  String? get userEmail       => currentUser?.email;
  String? get userDisplayName => currentUser?.displayName;
  String? get userPhotoUrl    => currentUser?.photoURL;

  // ── Google Sign-In ────────────────────────────────────────────────────────

  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );

      // If currently anonymous, link rather than creating a new account —
      // this preserves any cloud data already written under the anonymous uid.
      final current = _auth.currentUser;
      if (current != null && current.isAnonymous) {
        try {
          final result = await current.linkWithCredential(credential);
          return result.user;
        } on FirebaseAuthException catch (e) {
          // credential already in use — fall through to normal sign-in
          if (e.code == 'credential-already-in-use') {
            final result = await _auth.signInWithCredential(credential);
            return result.user;
          }
          rethrow;
        }
      }

      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (_) {
      return null;
    }
  }

  // ── Anonymous ─────────────────────────────────────────────────────────────

  Future<User?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      return credential.user;
    } catch (_) {
      return null;
    }
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

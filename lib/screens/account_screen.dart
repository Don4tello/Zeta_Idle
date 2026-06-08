import 'package:flutter/material.dart';
import '../services/game_state.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _loading = false;

  Future<void> _signIn(GameState game) async {
    setState(() => _loading = true);
    final ok = await game.googleSignIn();
    if (mounted) {
      setState(() => _loading = false);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-in cancelled or failed.')),
        );
      }
    }
  }

  Future<void> _signOut(GameState game) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Sign out?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Your local save is kept. Cloud sync will pause until you sign in again.',
          style: TextStyle(color: Color(0xFFaaaaaa)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out',
                style: TextStyle(color: Color(0xFFff6644))),
          ),
        ],
      ),
    );
    if (confirm == true) await game.googleSignOut();
  }

  Future<void> _forceSync(GameState game) async {
    setState(() => _loading = true);
    await game.forceSyncToCloud();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final game    = GameStateProvider.of(context);
    final auth    = game.authService;
    final signedIn = auth.isGoogleSignedIn;

    return Scaffold(
      backgroundColor: const Color(0xFF0d0d1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('ACCOUNT',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF66aaff)))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (signedIn) ...[
                  _AvatarTile(
                    photoUrl:    auth.userPhotoUrl,
                    displayName: auth.userDisplayName ?? 'Player',
                    email:       auth.userEmail       ?? '',
                  ),
                  const SizedBox(height: 24),
                  _SyncStatus(lastSyncAt: game.lastCloudSyncAt),
                  const SizedBox(height: 16),
                  _ActionButton(
                    label: 'SYNC NOW',
                    color: const Color(0xFF44ccaa),
                    icon:  Icons.cloud_upload_outlined,
                    onTap: () => _forceSync(game),
                  ),
                  const SizedBox(height: 12),
                  _ActionButton(
                    label: 'SIGN OUT',
                    color: const Color(0xFFff6644),
                    icon:  Icons.logout,
                    onTap: () => _signOut(game),
                  ),
                ] else ...[
                  const _SignedOutHero(),
                  const SizedBox(height: 32),
                  _ActionButton(
                    label: 'SIGN IN WITH GOOGLE',
                    color: const Color(0xFF66aaff),
                    icon:  Icons.login,
                    onTap: () => _signIn(game),
                  ),
                ],
                const SizedBox(height: 32),
                const _InfoSection(),
              ],
            ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _AvatarTile extends StatelessWidget {
  const _AvatarTile({
    required this.photoUrl,
    required this.displayName,
    required this.email,
  });
  final String? photoUrl;
  final String  displayName;
  final String  email;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: const Color(0xFF2a2a3e),
          backgroundImage:
              photoUrl != null ? NetworkImage(photoUrl!) : null,
          child: photoUrl == null
              ? const Icon(Icons.person, color: Colors.white54, size: 36)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(email,
                  style: const TextStyle(
                      color: Color(0xFF888888), fontSize: 13)),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(Icons.cloud_done, color: Color(0xFF44ccaa), size: 14),
                  SizedBox(width: 4),
                  Text('Google account linked',
                      style: TextStyle(
                          color: Color(0xFF44ccaa), fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SyncStatus extends StatelessWidget {
  const _SyncStatus({required this.lastSyncAt});
  final DateTime? lastSyncAt;

  @override
  Widget build(BuildContext context) {
    final label = lastSyncAt == null
        ? 'Not synced yet this session'
        : 'Last synced: ${_fmt(lastSyncAt!)}';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2a2a3e)),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Color(0xFF888888), size: 16),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(color: Color(0xFFaaaaaa), fontSize: 13)),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) {
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')} '
        '${local.day}/${local.month}/${local.year}';
  }
}

class _SignedOutHero extends StatelessWidget {
  const _SignedOutHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF2a2a3e), width: 2),
          ),
          child: const Icon(Icons.cloud_off,
              color: Color(0xFF444466), size: 56),
        ),
        const SizedBox(height: 20),
        const Text('No account linked',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
          'Sign in with Google to sync your progress\nacross devices automatically.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF888888), fontSize: 14, height: 1.5),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });
  final String  label;
  final Color   color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.15),
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(icon),
        label: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        onPressed: onTap,
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ABOUT CLOUD SAVES',
            style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 11,
                letterSpacing: 2,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _InfoRow(Icons.sync,
            'Your progress syncs automatically every 5 minutes when signed in.'),
        _InfoRow(Icons.devices,
            'Play on any Windows device with the same Google account.'),
        _InfoRow(Icons.shield_outlined,
            'Cloud saves are stored securely with your Google account.'),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF555577), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: Color(0xFF777799), fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/routing/app_router.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('SETTINGS', style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account section
            _SectionHeader('ACCOUNT'),
            _SettingsTile(
              title: game.authService.isGoogleSignedIn
                  ? (game.authService.userDisplayName ?? 'Google Account')
                  : 'Sign in with Google',
              subtitle: game.authService.isGoogleSignedIn
                  ? (game.authService.userEmail ?? 'Signed in')
                  : 'Sync saves across devices',
              trailing: TextButton(
                onPressed: () => context.push(Routes.account),
                child: const Text('MANAGE',
                    style: TextStyle(color: Color(0xFF66aaff))),
              ),
            ),
            const SizedBox(height: 16),

            // Audio section
            _SectionHeader('AUDIO'),
            _SettingsTile(
              title: 'Sound Effects',
              subtitle: game.audioService.muted ? 'Muted' : 'On',
              trailing: Switch(
                value: !game.audioService.muted,
                onChanged: (_) => setState(() => game.audioService.toggleMute()),
                activeColor: AppTheme.accentGold,
                inactiveTrackColor: AppTheme.cardBorder,
              ),
            ),
            const SizedBox(height: 16),

            // Save section
            _SectionHeader('SAVE'),
            _SettingsTile(
              title: 'Cloud Save',
              subtitle: 'Sync your progress to the cloud',
              trailing: TextButton(
                onPressed: () async {
                  await game.saveToCloud();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Cloud save complete.'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Color(0xFF2A2623),
                    ));
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6699ff),
                  side: const BorderSide(color: Color(0xFF6699ff)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(64, 44),
                ),
                child: Text('SAVE', style: AppTheme.pixelHeading(fontSize: 10,
                    color: const Color(0xFF6699ff))),
              ),
            ),
            _SettingsTile(
              title: 'Load from Cloud',
              subtitle: 'Overwrite local save with cloud data',
              trailing: TextButton(
                onPressed: () => _confirmCloudLoad(context, game),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textMuted,
                  side: const BorderSide(color: AppTheme.cardBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(64, 44),
                ),
                child: Text('LOAD', style: AppTheme.pixelHeading(fontSize: 10,
                    color: AppTheme.textMuted)),
              ),
            ),
            const SizedBox(height: 16),

            // Danger zone
            _SectionHeader('DANGER ZONE', color: const Color(0xFFcc4444)),
            _SettingsTile(
              title: 'Reset Progress',
              subtitle: 'Delete all save data for this slot. Irreversible.',
              trailing: TextButton(
                onPressed: () => _confirmReset(context, game),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFcc4444),
                  side: const BorderSide(color: Color(0xFFcc4444)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(64, 44),
                ),
                child: Text('RESET', style: AppTheme.pixelHeading(fontSize: 10,
                    color: const Color(0xFFcc4444))),
              ),
            ),
            const SizedBox(height: 24),

            // Help
            _SectionHeader('HELP'),
            _SettingsTile(
              title: 'Knowledge Base',
              subtitle: 'Keywords, systems, currencies explained',
              trailing: TextButton(
                onPressed: () => context.push(Routes.knowledgeBase),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accentGold,
                  side: const BorderSide(color: AppTheme.accentGold),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(64, 44),
                ),
                child: Text('OPEN', style: AppTheme.pixelHeading(
                    fontSize: 10, color: AppTheme.accentGold)),
              ),
            ),
            const SizedBox(height: 16),

            // About
            _SectionHeader('ABOUT'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF231F1B),
                border: Border.all(color: AppTheme.cardBorder),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ZETA IDLE',
                      style: AppTheme.pixelHeading(fontSize: 15, letterSpacing: 2,
                          color: AppTheme.accentGold)),
                  const SizedBox(height: 6),
                  const Text('A dark medieval idle RPG.',
                      style: TextStyle(fontSize: 14, color: AppTheme.textMuted,
                          fontStyle: FontStyle.italic)),
                  const SizedBox(height: 10),
                  const Divider(color: AppTheme.cardBorder, height: 1),
                  const SizedBox(height: 10),
                  _AboutRow('Hero', game.hero.name),
                  _AboutRow('Class', game.hero.heroClass.displayName),
                  _AboutRow('Level', '${game.hero.level}'),
                  _AboutRow('Prestige', 'Lv ${game.prestigeLevel}'),
                  _AboutRow('Achievements', '${game.achievements.where((a) => a.claimed).length} / ${game.achievements.length}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCloudLoad(BuildContext context, GameState game) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('Load from Cloud?',
            style: AppTheme.pixelHeading(fontSize: 14, color: AppTheme.accentGold)),
        content: const Text(
          'This will overwrite your local save with cloud data. Local progress not yet synced will be lost.',
          style: TextStyle(fontSize: 15, color: AppTheme.textLight),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('CANCEL', style: AppTheme.pixelHeading(fontSize: 14, color: AppTheme.textMuted))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await game.loadFromCloud();
            },
            child: Text('LOAD', style: AppTheme.pixelHeading(fontSize: 14, color: AppTheme.accentGold)),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, GameState game) {
    final nameController = TextEditingController(text: game.hero.name);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('Reset all progress?',
            style: AppTheme.pixelHeading(fontSize: 14, color: const Color(0xFFcc4444))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All progress, gold, items, prestige levels, and achievements will be permanently deleted. This cannot be undone.',
              style: TextStyle(fontSize: 15, color: AppTheme.textLight),
            ),
            const SizedBox(height: 14),
            const Text('New hero name:', style: TextStyle(fontSize: 14, color: AppTheme.textMuted)),
            const SizedBox(height: 6),
            TextField(
              controller: nameController,
              maxLength: 20,
              style: const TextStyle(fontSize: 16, color: AppTheme.textLight),
              decoration: const InputDecoration(
                counterStyle: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.cardBorder)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accentGold)),
                filled: true,
                fillColor: Color(0xFF1B1A17),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () { nameController.dispose(); Navigator.pop(context); },
            child: Text('CANCEL', style: AppTheme.pixelHeading(fontSize: 14, color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim().isEmpty ? 'The Warden' : nameController.text.trim();
              nameController.dispose();
              Navigator.pop(context);
              Navigator.pop(context);
              game.loadSlot(0, newName: name);
            },
            child: Text('RESET', style: AppTheme.pixelHeading(fontSize: 14, color: const Color(0xFFcc4444))),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {this.color = AppTheme.textMuted});
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: TextStyle(fontSize: 14, color: color,
              fontWeight: FontWeight.bold, letterSpacing: 2)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.title, required this.subtitle, required this.trailing});
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 16, color: AppTheme.textLight,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 14, color: AppTheme.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(fontSize: 14, color: AppTheme.textMuted)),
          ),
          Text(value,
              style: const TextStyle(fontSize: 14, color: AppTheme.textLight,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

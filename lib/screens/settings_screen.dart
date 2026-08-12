import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/routing/app_router.dart';
import '../models/equipment.dart';
import '../services/game_state.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../utils/profanity_filter.dart';

Color _salvageColor(ItemRarity r) => switch (r) {
  ItemRarity.common   => const Color(0xFFaaaaaa),
  ItemRarity.uncommon => const Color(0xFF55cc55),
  ItemRarity.rare     => const Color(0xFF6699ff),
  ItemRarity.epic     => const Color(0xFFcc44ff),
  _                   => Colors.white,
};

String _salvageLabel(ItemRarity r) => switch (r) {
  ItemRarity.common   => 'Common',
  ItemRarity.uncommon => 'Uncommon',
  ItemRarity.rare     => 'Rare',
  ItemRarity.epic     => 'Epic',
  _                   => r.name,
};

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _showRenameDialog(GameState game) async {
    final controller = TextEditingController(text: game.hero.name);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF231F1B),
        title: Text('RENAME HERO',
            style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 1)),
        content: TextField(
          controller: controller,
          maxLength: 20,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textLight, fontSize: 18),
          decoration: const InputDecoration(
            hintText: 'Enter a hero name',
            counterStyle: TextStyle(color: AppTheme.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (ProfanityFilter.isProfane(name)) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                  content: Text('Please choose a different name — that one isn\'t allowed.'),
                  backgroundColor: Color(0xFF8a2a2a),
                  behavior: SnackBarBehavior.floating,
                ));
                return;
              }
              if (game.renameHero(name)) {
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            child: const Text('SAVE', style: TextStyle(color: Color(0xFF66aaff))),
          ),
        ],
      ),
    );
  }

  Future<void> _sendFeedback(GameState game) async {
    // Pre-fill an email with diagnostic context so bug reports are actionable.
    final body = StringBuffer()
      ..writeln('Please describe the bug or feedback here:')
      ..writeln()
      ..writeln()
      ..writeln('--- Please keep the details below ---')
      ..writeln('App: Zeta Idle')
      ..writeln('Hero: ${game.hero.name} (Lv ${game.hero.level} ${game.hero.heroClass.displayName})')
      ..writeln('Prestige: ${game.prestigeLevel}')
      ..writeln('Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
    final uri = Uri(
      scheme: 'mailto',
      path: 'razorintegrations@gmail.com',
      query: 'subject=${Uri.encodeComponent('Zeta Idle — Bug Report / Feedback')}'
          '&body=${Uri.encodeComponent(body.toString())}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No email app found. Reach us at razorintegrations@gmail.com'),
        duration: Duration(seconds: 4),
      ));
    }
  }

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
              trailing: game.authService.isGoogleSignedIn
                ? TextButton(
                    onPressed: () => context.push(Routes.account),
                    child: const Text('MANAGE',
                        style: TextStyle(color: Color(0xFF66aaff))),
                  )
                : ElevatedButton.icon(
                    onPressed: () async {
                      await game.authService.signInWithGoogle();
                      if (context.mounted) setState(() {});
                    },
                    icon: const Text('G', style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF4285F4))),
                    label: const Text('SIGN IN'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2a2a3a),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF4285F4)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
            ),
            _SettingsTile(
              title: 'Hero Name',
              subtitle: game.hero.name,
              trailing: TextButton(
                onPressed: () => _showRenameDialog(game),
                child: const Text('RENAME',
                    style: TextStyle(color: Color(0xFF66aaff))),
              ),
            ),
            const SizedBox(height: 16),

            // Audio section
            _SectionHeader('AUDIO'),
            _SettingsTile(
              title: 'Sound Effects',
              subtitle: game.audioService.sfxMuted ? 'Muted' : 'On',
              trailing: Switch(
                value: !game.audioService.sfxMuted,
                onChanged: (_) => setState(() => game.audioService.toggleSfxMute()),
                activeColor: AppTheme.accentGold,
                inactiveTrackColor: AppTheme.cardBorder,
              ),
            ),
            _SettingsTile(
              title: 'Background Music',
              subtitle: game.audioService.musicMuted ? 'Muted' : 'On',
              trailing: Switch(
                value: !game.audioService.musicMuted,
                onChanged: (_) => setState(() => game.audioService.toggleMusicMute()),
                activeColor: AppTheme.accentGold,
                inactiveTrackColor: AppTheme.cardBorder,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(children: [
                const Text('Volume', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                Expanded(
                  child: Slider(
                    value: game.audioService.musicVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    activeColor: AppTheme.accentGold,
                    inactiveColor: AppTheme.cardBorder,
                    onChanged: (v) => setState(() => game.audioService.setMusicVolume(v)),
                  ),
                ),
                Text('${(game.audioService.musicVolume * 100).round()}%',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ]),
            ),
            const SizedBox(height: 16),

            // Haptics
            _SectionHeader('HAPTICS'),
            _SettingsTile(
              title: 'Vibration',
              subtitle: game.hapticsEnabled
                  ? 'Vibrates on crits, level-ups, victories & rewards'
                  : 'Off',
              trailing: Switch(
                value: game.hapticsEnabled,
                onChanged: (_) => setState(() => game.toggleHaptics()),
                activeColor: AppTheme.accentGold,
                inactiveTrackColor: AppTheme.cardBorder,
              ),
            ),

            const SizedBox(height: 16),

            // Notifications
            _SectionHeader('NOTIFICATIONS'),
            _SettingsTile(
              title: 'Reminders',
              subtitle: game.notificationsEnabled
                  ? 'Get "come back" reminders while you\'re away'
                  : 'Off',
              trailing: Switch(
                value: game.notificationsEnabled,
                onChanged: (_) async {
                  game.toggleNotifications();
                  if (game.notificationsEnabled) {
                    await NotificationService.instance.requestPermission();
                  } else {
                    await NotificationService.instance.cancelAll();
                  }
                  if (mounted) setState(() {});
                },
                activeColor: AppTheme.accentGold,
                inactiveTrackColor: AppTheme.cardBorder,
              ),
            ),

            const SizedBox(height: 16),

            // Display
            _SectionHeader('DISPLAY'),
            _SettingsTile(
              title: 'Damage Numbers',
              subtitle: game.showDamageNumbers
                  ? 'Floating numbers shown in battle'
                  : 'Hidden',
              trailing: Switch(
                value: game.showDamageNumbers,
                onChanged: (_) => setState(() => game.toggleDamageNumbers()),
                activeColor: AppTheme.accentGold,
                inactiveTrackColor: AppTheme.cardBorder,
              ),
            ),
            _SettingsTile(
              title: 'Reduced Particles',
              subtitle: game.reducedParticles
                  ? 'Fewer background effects (better performance)'
                  : 'Full effects',
              trailing: Switch(
                value: game.reducedParticles,
                onChanged: (_) => setState(() => game.toggleReducedParticles()),
                activeColor: AppTheme.accentGold,
                inactiveTrackColor: AppTheme.cardBorder,
              ),
            ),

            const SizedBox(height: 16),

            // Stats
            _SectionHeader('STATS'),
            _SettingsTile(
              title: 'Total Playtime',
              subtitle: game.playtimeLabel,
              trailing: const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // Auto-Loot
            _SectionHeader('AUTO-LOOT'),
            _SettingsTile(
              title: 'Auto-Salvage',
              subtitle: game.autoSalvageThreshold == null
                  ? 'Tap to enable auto-salvage for drops'
                  : 'Auto-salvages ${_salvageLabel(game.autoSalvageThreshold!)} and below',
              trailing: GestureDetector(
                onTap: () { setState(() { game.cycleAutoSalvageThreshold(); }); game.audioService.playUiClick(); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: game.autoSalvageThreshold == null
                        ? const Color(0xFF1a1a1a)
                        : _salvageColor(game.autoSalvageThreshold!).withValues(alpha: 0.15),
                    border: Border.all(
                      color: game.autoSalvageThreshold == null
                          ? AppTheme.cardBorder
                          : _salvageColor(game.autoSalvageThreshold!),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    game.autoSalvageThreshold == null
                        ? 'OFF'
                        : '≤ ${_salvageLabel(game.autoSalvageThreshold!)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: game.autoSalvageThreshold == null
                          ? AppTheme.textMuted
                          : _salvageColor(game.autoSalvageThreshold!),
                    ),
                  ),
                ),
              ),
            ),
            _SettingsTile(
              title: 'Auto-Equip Upgrades',
              subtitle: 'Automatically equip items better than current gear',
              trailing: Switch(
                value: game.autoEquipUpgrades,
                onChanged: (_) { setState(() => game.toggleAutoEquipUpgrades()); game.audioService.playUiClick(); },
                activeColor: AppTheme.accentGold,
                inactiveTrackColor: AppTheme.cardBorder,
              ),
            ),

            const SizedBox(height: 16),

            // Battle
            _SectionHeader('BATTLE'),
            _SettingsTile(
              title: 'Battle Speed',
              subtitle: game.battleSpeedLabel,
              trailing: TextButton(
                onPressed: () { setState(() => game.cycleBattleSpeed()); game.audioService.playUiClick(); },
                child: Text(game.battleSpeedLabel,
                    style: AppTheme.pixelHeading(fontSize: 14, color: AppTheme.accentGold)),
              ),
            ),
            _SettingsTile(
              title: 'Auto-Campaign',
              subtitle: 'Automatically fight campaign battles in the background',
              trailing: Switch(
                value: game.autoCampaign,
                onChanged: (_) { setState(() => game.toggleAutoCampaign()); game.audioService.playUiClick(); },
                activeColor: const Color(0xFF44cc88),
                inactiveTrackColor: AppTheme.cardBorder,
              ),
            ),

            const SizedBox(height: 16),

            // Daily Reset
            _SectionHeader('DAILY RESET'),
            _SettingsTile(
              title: 'Reset Time',
              subtitle: game.canChangeResetHour
                  ? 'Daily limits reset at ${_formatResetHour(game.resetHour)}. Tap to change (once per year).'
                  : 'Resets at ${_formatResetHour(game.resetHour)} · Already changed this year.',
              trailing: game.canChangeResetHour
                  ? TextButton(
                      onPressed: () => _showResetHourPicker(context, game),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.accentGold,
                        side: const BorderSide(color: AppTheme.accentGold),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: const Size(64, 44),
                      ),
                      child: Text('CHANGE', style: AppTheme.pixelHeading(
                          fontSize: 10, color: AppTheme.accentGold)),
                    )
                  : const SizedBox.shrink(),
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
                  const SizedBox(height: 10),
                  const Divider(color: AppTheme.cardBorder, height: 1),
                  const SizedBox(height: 10),
                  _AboutRow('Developer', 'Razor Integrations'),
                  _AboutRow('Contact', 'razorintegrations@gmail.com'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _SettingsTile(
              title: 'Privacy Policy',
              subtitle: 'How we handle your data',
              trailing: TextButton(
                onPressed: () => context.push(Routes.privacyPolicy),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textMuted,
                  side: const BorderSide(color: AppTheme.cardBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(64, 44),
                ),
                child: Text('VIEW', style: AppTheme.pixelHeading(
                    fontSize: 10, color: AppTheme.textMuted)),
              ),
            ),
            const SizedBox(height: 10),
            _SettingsTile(
              title: 'Report a Bug / Feedback',
              subtitle: 'Email us — device info is added automatically',
              trailing: TextButton(
                onPressed: () => _sendFeedback(game),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF66aaff),
                  side: const BorderSide(color: Color(0xFF335577)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(64, 44),
                ),
                child: Text('EMAIL', style: AppTheme.pixelHeading(
                    fontSize: 10, color: const Color(0xFF66aaff))),
              ),
            ),
            const SizedBox(height: 10),
            _SettingsTile(
              title: 'Replay Tips',
              subtitle: 'Show the in-game tutorial tips again',
              trailing: TextButton(
                onPressed: () {
                  game.resetTutorials();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Tutorial tips reset — they\'ll reappear as you explore.'),
                    duration: Duration(seconds: 3),
                  ));
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF44cc88),
                  side: const BorderSide(color: Color(0xFF337755)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(64, 44),
                ),
                child: Text('RESET', style: AppTheme.pixelHeading(
                    fontSize: 10, color: const Color(0xFF44cc88))),
              ),
            ),
            const SizedBox(height: 16),

            // Dev tools — desktop only, used for exporting sprites as PNG
            _SectionHeader('DEV TOOLS', color: const Color(0xFF445566)),
            _SettingsTile(
              title: 'Export Sprites',
              subtitle: 'Render all class sprites & race icons to exported_sprites/',
              trailing: TextButton(
                onPressed: () => context.push(Routes.spriteExport),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6699aa),
                  side: const BorderSide(color: Color(0xFF445566)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(64, 44),
                ),
                child: Text('OPEN', style: AppTheme.pixelHeading(
                    fontSize: 10, color: const Color(0xFF6699aa))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatResetHour(int h) {
    final period = h < 12 ? 'AM' : 'PM';
    final displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$displayH:00 $period';
  }

  void _showResetHourPicker(BuildContext context, GameState game) {
    int selected = game.resetHour;
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: const Color(0xFF2A2623),
          title: Text('Daily Reset Time',
              style: AppTheme.pixelHeading(fontSize: 14, color: AppTheme.accentGold)),
          content: SizedBox(
            width: 240,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Choose the hour when daily limits reset.',
                    style: const TextStyle(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 12),
                DropdownButton<int>(
                  value: selected,
                  dropdownColor: const Color(0xFF2A2623),
                  isExpanded: true,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                  items: List.generate(24, (h) => DropdownMenuItem(
                    value: h,
                    child: Text(_formatResetHour(h)),
                  )),
                  onChanged: (v) { if (v != null) setLocal(() => selected = v); },
                ),
                const SizedBox(height: 8),
                const Text('Warning: you can only change this once per year.',
                    style: TextStyle(fontSize: 11, color: Colors.redAccent)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(fontSize: 12, color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                game.setResetHour(selected);
                Navigator.pop(ctx);
              },
              child: Text('CONFIRM', style: TextStyle(fontSize: 12, color: AppTheme.accentGold)),
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

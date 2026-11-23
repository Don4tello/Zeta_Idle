import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/routing/app_router.dart';
import '../models/equipment.dart';
import '../services/game_state.dart';
import '../widgets/battle_speed_menu.dart';
import '../services/notification_service.dart';
import '../services/locale_controller.dart';
import '../l10n/app_localizations.dart';
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
  final TextEditingController _promoCtrl = TextEditingController();
  String? _promoMsg;
  bool _promoOk = false;

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  void _redeemPromo(GameState game) {
    final res = game.redeemPromoCode(_promoCtrl.text);
    setState(() { _promoMsg = res.message; _promoOk = res.ok; });
    if (res.ok) {
      _promoCtrl.clear();
      game.audioService.playClaim();
    }
  }

  Future<void> _showRenameDialog(GameState game) async {
    final controller = TextEditingController(text: game.hero.name);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF231F1B),
        title: Text(AppLocalizations.of(ctx).setRenameHeroTitle,
            style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 1)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              maxLength: 20,
              autofocus: true,
              style: const TextStyle(color: AppTheme.textLight, fontSize: 18),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(ctx).setHeroNameHint,
                counterStyle: const TextStyle(color: AppTheme.textMuted),
              ),
            ),
            Text(AppLocalizations.of(ctx).setRenameCost(game.renameHeroCost, game.zcoins),
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx).csCancel, style: const TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              if (ProfanityFilter.isProfane(name)) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(ctx).ccNameNotAllowed),
                  backgroundColor: const Color(0xFF8a2a2a),
                  behavior: SnackBarBehavior.floating,
                ));
                return;
              }
              if (game.zcoins < game.renameHeroCost) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(ctx).setRenameNotEnough(game.renameHeroCost)),
                  backgroundColor: const Color(0xFF8a2a2a),
                  behavior: SnackBarBehavior.floating,
                ));
                return;
              }
              if (game.renameHero(name)) {
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            child: Text(AppLocalizations.of(ctx).setSave, style: const TextStyle(color: Color(0xFF66aaff))),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).setNoEmailApp),
        duration: const Duration(seconds: 4),
      ));
    }
  }

  /// Subtitle for the language tile: the active language's native name, or the
  /// localized "System default" when no override is set.
  String _localeLabel(BuildContext context, Locale? current) {
    if (current == null) return AppLocalizations.of(context).settingsLanguageSystem;
    return _nativeLanguageName(current.languageCode);
  }

  /// Native name for a language code (endonym), so each option reads naturally
  /// to a speaker of that language. Extend as locales are added.
  String _nativeLanguageName(String code) {
    switch (code) {
      case 'de': return 'Deutsch';
      case 'es': return 'Español';
      case 'fr': return 'Français';
      case 'pt': return 'Português';
      case 'pl': return 'Polski';
      case 'ko': return '한국어';
      case 'en': return 'English';
      default:   return code.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text(AppLocalizations.of(context).setTitle, style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account section
            _SectionHeader(AppLocalizations.of(context).setSecAccount),
            _SettingsTile(
              title: game.authService.isGoogleSignedIn
                  ? (game.authService.userDisplayName ?? AppLocalizations.of(context).setGoogleAccount)
                  : AppLocalizations.of(context).setSignInGoogle,
              subtitle: game.authService.isGoogleSignedIn
                  ? (game.authService.userEmail ?? AppLocalizations.of(context).setSignedIn)
                  : AppLocalizations.of(context).setSyncSaves,
              trailing: game.authService.isGoogleSignedIn
                ? TextButton(
                    onPressed: () => context.push(Routes.account),
                    child: Text(AppLocalizations.of(context).setManage,
                        style: const TextStyle(color: Color(0xFF66aaff))),
                  )
                : ElevatedButton.icon(
                    onPressed: () async {
                      await game.authService.signInWithGoogle();
                      if (context.mounted) setState(() {});
                    },
                    icon: const Text('G', style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF4285F4))),
                    label: Text(AppLocalizations.of(context).setSignIn),
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
              title: AppLocalizations.of(context).setHeroName,
              subtitle: game.hero.name,
              trailing: TextButton(
                onPressed: () => _showRenameDialog(game),
                child: Text(AppLocalizations.of(context).setRename(game.renameHeroCost),
                    style: const TextStyle(color: Color(0xFF66aaff))),
              ),
            ),
            const SizedBox(height: 16),

            // Promo code section
            _SectionHeader(AppLocalizations.of(context).setSecPromo),
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF231F1B),
                border: Border.all(color: AppTheme.cardBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(AppLocalizations.of(context).setPromoHint,
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _promoCtrl,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(color: AppTheme.textLight, fontSize: 14, letterSpacing: 1),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).setEnterCode,
                        hintStyle: const TextStyle(color: AppTheme.textDisabled, letterSpacing: 1),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.cardBorder)),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accentGold)),
                      ),
                      onSubmitted: (_) => _redeemPromo(game),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _redeemPromo(game),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: AppTheme.accentGold,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: Text(AppLocalizations.of(context).setRedeem, style: AppTheme.pixelHeading(fontSize: 12, color: Colors.black)),
                  ),
                ]),
                if (_promoMsg != null) ...[
                  const SizedBox(height: 8),
                  Text(_promoMsg!,
                      style: TextStyle(
                          fontSize: 11,
                          color: _promoOk ? const Color(0xFF55cc66) : const Color(0xFFcc5544),
                          fontWeight: FontWeight.bold)),
                ],
              ]),
            ),
            const SizedBox(height: 16),

            // Audio section
            _SectionHeader(AppLocalizations.of(context).setSecAudio),
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
                Text(AppLocalizations.of(context).setVolume, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
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
            _SectionHeader(AppLocalizations.of(context).setSecHaptics),
            _SettingsTile(
              title: AppLocalizations.of(context).setVibration,
              subtitle: game.hapticsEnabled
                  ? AppLocalizations.of(context).setVibrationOn
                  : AppLocalizations.of(context).setOff,
              trailing: Switch(
                value: game.hapticsEnabled,
                onChanged: (_) => setState(() => game.toggleHaptics()),
                activeColor: AppTheme.accentGold,
                inactiveTrackColor: AppTheme.cardBorder,
              ),
            ),

            const SizedBox(height: 16),

            // Notifications
            _SectionHeader(AppLocalizations.of(context).setSecNotifications),
            _SettingsTile(
              title: AppLocalizations.of(context).setReminders,
              subtitle: game.notificationsEnabled
                  ? AppLocalizations.of(context).setRemindersOn
                  : AppLocalizations.of(context).setOff,
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

            // Language
            _SectionHeader(AppLocalizations.of(context).settingsLanguage.toUpperCase()),
            ValueListenableBuilder<Locale?>(
              valueListenable: LocaleController.instance,
              builder: (context, current, _) => _SettingsTile(
                title: AppLocalizations.of(context).settingsLanguage,
                subtitle: _localeLabel(context, current),
                trailing: DropdownButton<String>(
                  value: current?.languageCode ?? '',
                  dropdownColor: AppTheme.cardBg,
                  underline: const SizedBox.shrink(),
                  iconEnabledColor: AppTheme.accentGold,
                  style: const TextStyle(color: AppTheme.textLight, fontSize: 16),
                  items: [
                    DropdownMenuItem(
                      value: '',
                      child: Text(AppLocalizations.of(context).settingsLanguageSystem),
                    ),
                    for (final loc in LocaleController.supported)
                      DropdownMenuItem(
                        value: loc.languageCode,
                        child: Text(_nativeLanguageName(loc.languageCode)),
                      ),
                  ],
                  onChanged: (code) => LocaleController.instance.setLocale(
                      (code == null || code.isEmpty) ? null : Locale(code)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Display
            _SectionHeader(AppLocalizations.of(context).setSecDisplay),
            _SettingsTile(
              title: AppLocalizations.of(context).setDamageNumbers,
              subtitle: game.showDamageNumbers
                  ? AppLocalizations.of(context).setDamageOn
                  : AppLocalizations.of(context).setHidden,
              trailing: Switch(
                value: game.showDamageNumbers,
                onChanged: (_) => setState(() => game.toggleDamageNumbers()),
                activeColor: AppTheme.accentGold,
                inactiveTrackColor: AppTheme.cardBorder,
              ),
            ),
            _SettingsTile(
              title: AppLocalizations.of(context).setReducedParticles,
              subtitle: game.reducedParticles
                  ? AppLocalizations.of(context).setParticlesOn
                  : AppLocalizations.of(context).setParticlesOff,
              trailing: Switch(
                value: game.reducedParticles,
                onChanged: (_) => setState(() => game.toggleReducedParticles()),
                activeColor: AppTheme.accentGold,
                inactiveTrackColor: AppTheme.cardBorder,
              ),
            ),

            const SizedBox(height: 16),

            // Stats
            _SectionHeader(AppLocalizations.of(context).setSecStats),
            _SettingsTile(
              title: AppLocalizations.of(context).setTotalPlaytime,
              subtitle: game.playtimeLabel,
              trailing: const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // Auto-Loot
            _SectionHeader(AppLocalizations.of(context).setSecAutoLoot),
            _SettingsTile(
              title: AppLocalizations.of(context).setAutoSalvage,
              subtitle: game.autoSalvageThreshold == null
                  ? AppLocalizations.of(context).setSalvageOff
                  : AppLocalizations.of(context).setSalvageOn(_salvageLabel(game.autoSalvageThreshold!)),
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    game.autoSalvageThreshold == null
                        ? AppLocalizations.of(context).setOffCaps
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
              title: AppLocalizations.of(context).setAutoEquip,
              subtitle: AppLocalizations.of(context).setAutoEquipSub,
              trailing: Switch(
                value: game.autoEquipUpgrades,
                onChanged: (_) { setState(() => game.toggleAutoEquipUpgrades()); game.audioService.playUiClick(); },
                activeColor: AppTheme.accentGold,
                inactiveTrackColor: AppTheme.cardBorder,
              ),
            ),

            const SizedBox(height: 16),

            // Battle
            _SectionHeader(AppLocalizations.of(context).setSecBattle),
            _SettingsTile(
              title: AppLocalizations.of(context).setBattleSpeed,
              subtitle: game.battleSpeedLabel,
              trailing: TextButton(
                onPressed: () {
                  game.audioService.playUiClick();
                  showBattleSpeedMenu(context, game);
                },
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(game.battleSpeedLabel,
                      style: AppTheme.pixelHeading(fontSize: 14, color: AppTheme.accentGold)),
                  const Icon(Icons.arrow_drop_down, size: 18, color: AppTheme.accentGold),
                ]),
              ),
            ),
            // Auto-Campaign is now an always-on default feature (no toggle).

            const SizedBox(height: 16),

            // Daily Reset
            _SectionHeader(AppLocalizations.of(context).setSecDailyReset),
            _SettingsTile(
              title: AppLocalizations.of(context).setResetTime,
              subtitle: game.canChangeResetHour
                  ? AppLocalizations.of(context).setResetTimeOn(_formatResetHour(game.resetHour))
                  : AppLocalizations.of(context).setResetTimeLocked(_formatResetHour(game.resetHour)),
              trailing: game.canChangeResetHour
                  ? TextButton(
                      onPressed: () => _showResetHourPicker(context, game),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.accentGold,
                        side: const BorderSide(color: AppTheme.accentGold),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: const Size(64, 44),
                      ),
                      child: Text(AppLocalizations.of(context).hubChange, style: AppTheme.pixelHeading(
                          fontSize: 10, color: AppTheme.accentGold)),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // Save section
            _SectionHeader(AppLocalizations.of(context).setSecSave),
            _SettingsTile(
              title: AppLocalizations.of(context).setCloudSave,
              subtitle: AppLocalizations.of(context).setCloudSaveSub,
              trailing: TextButton(
                onPressed: () async {
                  await game.saveToCloud();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(AppLocalizations.of(context).setCloudSaveComplete),
                      duration: const Duration(seconds: 2),
                      backgroundColor: const Color(0xFF2A2623),
                    ));
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6699ff),
                  side: const BorderSide(color: Color(0xFF6699ff)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(64, 44),
                ),
                child: Text(AppLocalizations.of(context).setSave, style: AppTheme.pixelHeading(fontSize: 10,
                    color: const Color(0xFF6699ff))),
              ),
            ),
            _SettingsTile(
              title: AppLocalizations.of(context).setLoadCloud,
              subtitle: AppLocalizations.of(context).setLoadCloudSub,
              trailing: TextButton(
                onPressed: () => _confirmCloudLoad(context, game),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textMuted,
                  side: const BorderSide(color: AppTheme.cardBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(64, 44),
                ),
                child: Text(AppLocalizations.of(context).setLoad, style: AppTheme.pixelHeading(fontSize: 10,
                    color: AppTheme.textMuted)),
              ),
            ),
            const SizedBox(height: 16),

            // Danger zone
            _SectionHeader(AppLocalizations.of(context).setSecDanger, color: const Color(0xFFcc4444)),
            _SettingsTile(
              title: AppLocalizations.of(context).setResetProgress,
              subtitle: AppLocalizations.of(context).setResetProgressSub,
              trailing: TextButton(
                onPressed: () => _confirmReset(context, game),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFcc4444),
                  side: const BorderSide(color: Color(0xFFcc4444)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(64, 44),
                ),
                child: Text(AppLocalizations.of(context).setReset, style: AppTheme.pixelHeading(fontSize: 10,
                    color: const Color(0xFFcc4444))),
              ),
            ),
            const SizedBox(height: 24),

            // Help
            _SectionHeader(AppLocalizations.of(context).setSecHelp),
            _SettingsTile(
              title: AppLocalizations.of(context).setKnowledgeBase,
              subtitle: AppLocalizations.of(context).setKnowledgeBaseSub,
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
            _SectionHeader(AppLocalizations.of(context).setSecAbout),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF231F1B),
                border: Border.all(color: AppTheme.cardBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ZETA IDLE',
                      style: AppTheme.pixelHeading(fontSize: 15, letterSpacing: 2,
                          color: AppTheme.accentGold)),
                  const SizedBox(height: 6),
                  Text(AppLocalizations.of(context).setTagline,
                      style: TextStyle(fontSize: 14, color: AppTheme.textMuted,
                          fontStyle: FontStyle.italic)),
                  const SizedBox(height: 10),
                  const Divider(color: AppTheme.cardBorder, height: 1),
                  const SizedBox(height: 10),
                  _AboutRow(AppLocalizations.of(context).setAboutHero, game.hero.name),
                  _AboutRow(AppLocalizations.of(context).setAboutClass, game.hero.heroClass.displayName),
                  _AboutRow(AppLocalizations.of(context).setAboutLevel, '${game.hero.level}'),
                  _AboutRow(AppLocalizations.of(context).setAboutPrestige, 'Lv ${game.prestigeLevel}'),
                  _AboutRow(AppLocalizations.of(context).setAboutAchievements, '${game.achievements.where((a) => a.claimed).length} / ${game.achievements.length}'),
                  const SizedBox(height: 10),
                  const Divider(color: AppTheme.cardBorder, height: 1),
                  const SizedBox(height: 10),
                  _AboutRow(AppLocalizations.of(context).setAboutDeveloper, 'Razor Integrations'),
                  _AboutRow(AppLocalizations.of(context).setAboutContact, 'razorintegrations@gmail.com'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _SettingsTile(
              title: AppLocalizations.of(context).setPrivacy,
              subtitle: AppLocalizations.of(context).setPrivacySub,
              trailing: TextButton(
                onPressed: () => context.push(Routes.privacyPolicy),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textMuted,
                  side: const BorderSide(color: AppTheme.cardBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(64, 44),
                ),
                child: Text(AppLocalizations.of(context).setView, style: AppTheme.pixelHeading(
                    fontSize: 10, color: AppTheme.textMuted)),
              ),
            ),
            const SizedBox(height: 10),
            _SettingsTile(
              title: AppLocalizations.of(context).setReportBug,
              subtitle: AppLocalizations.of(context).setReportBugSub,
              trailing: TextButton(
                onPressed: () => _sendFeedback(game),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF66aaff),
                  side: const BorderSide(color: Color(0xFF335577)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(64, 44),
                ),
                child: Text(AppLocalizations.of(context).setEmail, style: AppTheme.pixelHeading(
                    fontSize: 10, color: const Color(0xFF66aaff))),
              ),
            ),
            const SizedBox(height: 10),
            _SettingsTile(
              title: AppLocalizations.of(context).setReplayTips,
              subtitle: AppLocalizations.of(context).setReplayTipsSub,
              trailing: TextButton(
                onPressed: () {
                  game.resetTutorials();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(AppLocalizations.of(context).setTipsReset),
                    duration: const Duration(seconds: 3),
                  ));
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF44cc88),
                  side: const BorderSide(color: Color(0xFF337755)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(64, 44),
                ),
                child: Text(AppLocalizations.of(context).setReset, style: AppTheme.pixelHeading(
                    fontSize: 10, color: const Color(0xFF44cc88))),
              ),
            ),
            // Dev tools — hidden in release builds. These are testing cheats
            // (Max Character, Level +100) and the sprite exporter; they must
            // never be reachable by players, or they'd wreck the economy and
            // leaderboards. `kDebugMode` is false in `flutter build --release`.
            if (kDebugMode) ...[
            const SizedBox(height: 16),
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
            _SettingsTile(
              title: 'Replay Tutorials',
              subtitle: 'Re-show every guided tutorial from your current progress.',
              trailing: TextButton(
                onPressed: () {
                  game.debugResetTutorials();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Tutorials reset — they\'ll re-trigger as you play.'),
                    behavior: SnackBarBehavior.floating));
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6699aa),
                  side: const BorderSide(color: Color(0xFF445566)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(64, 44),
                ),
                child: Text('RESET', style: AppTheme.pixelHeading(
                    fontSize: 10, color: const Color(0xFF6699aa))),
              ),
            ),
            _SettingsTile(
              title: 'Max Character',
              subtitle: 'Tier 10, Lv 1000, all passives/paragon/gear/pets/mercs — '
                  'for top-down difficulty testing.',
              trailing: TextButton(
                onPressed: () {
                  game.debugMaxCharacter();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Character maxed — Tier 10, Lv 1000. Go fight the Tier 10 boss.'),
                    behavior: SnackBarBehavior.floating));
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFcc7744),
                  side: const BorderSide(color: Color(0xFF884422)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(64, 44),
                ),
                child: Text('MAX', style: AppTheme.pixelHeading(
                    fontSize: 10, color: const Color(0xFFcc7744))),
              ),
            ),
            _SettingsTile(
              title: 'Level +100',
              subtitle: 'Jump the current hero 100 levels — for XP-curve / pacing '
                  'measurement.',
              trailing: TextButton(
                onPressed: () {
                  game.debugAddLevels(100);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Level → ${game.hero.level}.'),
                    behavior: SnackBarBehavior.floating));
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6699aa),
                  side: const BorderSide(color: Color(0xFF445566)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(64, 44),
                ),
                child: Text('+100', style: AppTheme.pixelHeading(
                    fontSize: 10, color: const Color(0xFF6699aa))),
              ),
            ),
            ], // end if (kDebugMode) DEV TOOLS
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
          title: Text(AppLocalizations.of(ctx).setDailyResetTitle,
              style: AppTheme.pixelHeading(fontSize: 14, color: AppTheme.accentGold)),
          content: SizedBox(
            width: 240,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(ctx).setDailyResetHint,
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
                Text(AppLocalizations.of(ctx).setDailyResetWarning,
                    style: TextStyle(fontSize: 11, color: Colors.redAccent)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(ctx).csCancel, style: const TextStyle(fontSize: 12, color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                game.setResetHour(selected);
                Navigator.pop(ctx);
              },
              child: Text(AppLocalizations.of(ctx).setConfirm, style: const TextStyle(fontSize: 12, color: AppTheme.accentGold)),
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
        title: Text(AppLocalizations.of(context).setLoadCloudTitle,
            style: AppTheme.pixelHeading(fontSize: 14, color: AppTheme.accentGold)),
        content: Text(
          AppLocalizations.of(context).setLoadCloudBody,
          style: TextStyle(fontSize: 15, color: AppTheme.textLight),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).csCancel, style: AppTheme.pixelHeading(fontSize: 14, color: AppTheme.textMuted))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await game.loadFromCloud();
            },
            child: Text(AppLocalizations.of(context).setLoad, style: AppTheme.pixelHeading(fontSize: 14, color: AppTheme.accentGold)),
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
        title: Text(AppLocalizations.of(context).setResetAllTitle,
            style: AppTheme.pixelHeading(fontSize: 14, color: const Color(0xFFcc4444))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).setResetAllBody,
              style: TextStyle(fontSize: 15, color: AppTheme.textLight),
            ),
            const SizedBox(height: 14),
            Text(AppLocalizations.of(context).setNewHeroName, style: const TextStyle(fontSize: 14, color: AppTheme.textMuted)),
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
            child: Text(AppLocalizations.of(context).csCancel, style: AppTheme.pixelHeading(fontSize: 14, color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim().isEmpty ? 'The Warden' : nameController.text.trim();
              nameController.dispose();
              Navigator.pop(context);
              Navigator.pop(context);
              game.loadSlot(0, newName: name);
            },
            child: Text(AppLocalizations.of(context).setReset, style: AppTheme.pixelHeading(fontSize: 14, color: const Color(0xFFcc4444))),
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
        borderRadius: BorderRadius.circular(8),
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

import 'dart:io' show Platform, File;
import 'package:flutter/services.dart' show rootBundle;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../models/hero_ability.dart';
import '../models/damage_type.dart';

enum SoundEffect {
  hit, playerHit, ability, abilityDamage, abilityBuff, abilityDebuff,
  coin, victory, defeat, levelUp, uiClick, uiConfirm, uiError,
  // Element-specific ability SFX
  sfxPhysical, sfxLightning, sfxCold, sfxPoison, sfxFire, sfxVoid,
  // Healing SFX
  sfxHealA, sfxHealB, sfxAura,
}

final bool _isWindows = Platform.isWindows;

// Copies an asset MP3 to the device temp dir and returns the file path.
// DeviceFileSource is far more reliable than AssetSource for large MP3s on Android.
Future<String> _cacheAsset(String assetPath) async {
  final dir  = await getTemporaryDirectory();
  final file = File('${dir.path}/${assetPath.replaceAll('/', '_')}');
  if (!file.existsSync()) {
    final data = await rootBundle.load('assets/$assetPath');
    await file.writeAsBytes(data.buffer.asUint8List());
  }
  return file.path;
}

class AudioService {
  // ── SFX ──────────────────────────────────────────────────────────────────────
  bool _sfxMuted = false;
  bool get muted => _sfxMuted;
  bool get sfxMuted => _sfxMuted;
  void toggleMute()    { _sfxMuted = !_sfxMuted; if (!_sfxMuted) _resetSfxPool(); }
  void toggleSfxMute() { _sfxMuted = !_sfxMuted; if (!_sfxMuted) _resetSfxPool(); }

  void _resetSfxPool() {
    for (final p in _sfxPool) { try { p.dispose(); } catch (_) {} }
    _sfxPool.clear();
    _poolIndex = 0;
  }

  final List<AudioPlayer> _sfxPool = [];
  static const int _poolSize = 4;
  int _poolIndex = 0;

  // SFX context: AudioFocus.none so SFX never steal focus from music player.
  static final _kSfxContext = AudioContext(
    android: AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.none,
    ),
  );

  AudioPlayer _nextSfxPlayer() {
    if (_sfxPool.isEmpty) {
      for (int i = 0; i < _poolSize; i++) {
        final p = AudioPlayer();
        if (!_isWindows) {
          p.setAudioContext(_kSfxContext).catchError((_) {});
        }
        _sfxPool.add(p);
      }
    }
    final player = _sfxPool[_poolIndex % _poolSize];
    _poolIndex++;
    return player;
  }

  Future<void> play(SoundEffect effect) async {
    if (_sfxMuted || _isWindows) return;
    try {
      final player = _nextSfxPlayer();
      await player.stop();
      await player.play(AssetSource(_path(effect)));
    } catch (_) {}
  }

  Future<void> playHit()       => play(SoundEffect.hit);
  Future<void> playPlayerHit() => play(SoundEffect.playerHit);
  Future<void> playAbility()   => play(SoundEffect.ability);
  Future<void> playCoin()      => play(SoundEffect.coin);
  Future<void> playVictory()   => play(SoundEffect.victory);
  Future<void> playDefeat()    => play(SoundEffect.defeat);
  Future<void> playLevelUp()   => play(SoundEffect.levelUp);
  Future<void> playUiClick()   => play(SoundEffect.uiClick);
  Future<void> playUiConfirm() => play(SoundEffect.uiConfirm);
  Future<void> playUiError()   => play(SoundEffect.uiError);

  Future<void> playAbilityByCategory(AbilityCategory category) async {
    if (_sfxMuted || _isWindows) return;
    final effect = switch (category) {
      AbilityCategory.damage   => SoundEffect.abilityDamage,
      AbilityCategory.buff     => SoundEffect.abilityBuff,
      AbilityCategory.debuff   => SoundEffect.abilityDebuff,
      AbilityCategory.ultimate => SoundEffect.abilityDamage,
    };
    try {
      final player = _nextSfxPlayer();
      await player.stop();
      await player.play(AssetSource(_path(effect)));
    } catch (_) {
      await play(SoundEffect.ability);
    }
  }

  String _path(SoundEffect e) {
    return switch (e) {
      SoundEffect.hit           => 'audio/hit.wav',
      SoundEffect.playerHit     => 'audio/player_hit.wav',
      SoundEffect.ability       => 'audio/ability.wav',
      SoundEffect.abilityDamage => 'audio/ability.wav',
      SoundEffect.abilityBuff   => 'audio/ability.wav',
      SoundEffect.abilityDebuff => 'audio/ability.wav',
      SoundEffect.coin          => 'audio/coin.wav',
      SoundEffect.victory       => 'audio/victory.wav',
      SoundEffect.defeat        => 'audio/defeat.wav',
      SoundEffect.levelUp       => 'audio/levelup.wav',
      SoundEffect.uiClick       => 'audio/ui_click.wav',
      SoundEffect.uiConfirm     => 'audio/ui_confirm.wav',
      SoundEffect.uiError       => 'audio/ui_error.wav',
      SoundEffect.sfxPhysical   => 'audio/sfx_sword.mp3',
      SoundEffect.sfxLightning  => 'audio/sfx_lightning.mp3',
      SoundEffect.sfxCold       => 'audio/sfx_cold.mp3',
      SoundEffect.sfxPoison     => 'audio/sfx_poison.mp3',
      SoundEffect.sfxFire       => 'audio/sfx_fire.mp3',
      SoundEffect.sfxVoid       => 'audio/sfx_void.mp3',
      SoundEffect.sfxHealA      => 'audio/sfx_heal_a.mp3',
      SoundEffect.sfxHealB      => 'audio/sfx_heal_b.mp3',
      SoundEffect.sfxAura       => 'audio/sfx_aura_heal.mp3',
    };
  }

  // ── MP3 SFX cache (DeviceFileSource is required for MP3s on Android) ─────────
  final Map<SoundEffect, String> _sfxCachePaths = {};

  Future<void> _playMp3Sfx(SoundEffect sfx) async {
    if (_sfxMuted || _isWindows) return;
    try {
      final player = _nextSfxPlayer();
      await player.stop();
      if (Platform.isAndroid) {
        final cached = _sfxCachePaths[sfx] ??= await _cacheAsset(_path(sfx));
        await player.play(DeviceFileSource(cached));
      } else {
        await player.play(AssetSource(_path(sfx)));
      }
    } catch (_) {}
  }

  // Play a hit sound matched to the hero's active damage type.
  Future<void> playHitWithType(DamageType type) async {
    if (_sfxMuted || _isWindows) return;
    if (type == DamageType.physical) {
      await play(SoundEffect.hit);
    } else {
      await _playMp3Sfx(switch (type) {
        DamageType.fire      => SoundEffect.sfxFire,
        DamageType.cold      => SoundEffect.sfxCold,
        DamageType.lightning => SoundEffect.sfxLightning,
        DamageType.poison    => SoundEffect.sfxPoison,
        DamageType.void_     => SoundEffect.sfxVoid,
        DamageType.physical  => SoundEffect.sfxPhysical,
      });
    }
  }

  // Plays the correct SFX for an ability based on its effect and the hero's active damage type.
  int _healToggle = 0;
  Future<void> playAbilityFull(AbilityEffect effect, DamageType damageType) async {
    if (_sfxMuted || _isWindows) return;
    final SoundEffect sfx;
    if (effect == AbilityEffect.aura) {
      sfx = SoundEffect.sfxAura;
    } else if (effect == AbilityEffect.heal) {
      sfx = (_healToggle++ % 2 == 0) ? SoundEffect.sfxHealA : SoundEffect.sfxHealB;
    } else {
      sfx = switch (damageType) {
        DamageType.physical  => SoundEffect.sfxPhysical,
        DamageType.lightning => SoundEffect.sfxLightning,
        DamageType.cold      => SoundEffect.sfxCold,
        DamageType.poison    => SoundEffect.sfxPoison,
        DamageType.fire      => SoundEffect.sfxFire,
        DamageType.void_     => SoundEffect.sfxVoid,
      };
    }
    await _playMp3Sfx(sfx);
  }

  // ── Music context ─────────────────────────────────────────────────────────────
  // AudioFocus.gain was causing MEDIA_ERROR_UNKNOWN {what:-38} on Samsung Galaxy
  // devices. Using gainTransientMayDuck avoids the exclusive-focus conflict.
  static final _kMusicContext = AudioContext(
    android: AudioContextAndroid(
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.media,
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
    ),
  );

  // ── Exploration music ─────────────────────────────────────────────────────────
  final AudioPlayer _musicPlayer = AudioPlayer();
  bool _musicMuted = false;
  double _musicVolume = 0.35;
  bool _musicStarted = false;
  String? _exploreCachePath;

  bool   get musicMuted  => _musicMuted;
  double get musicVolume => _musicVolume;

  Future<void> startMusic() async {
    if (_musicStarted || _isWindows) return;
    _musicStarted = true;
    try {
      _exploreCachePath ??= await _cacheAsset('audio/explore_music.mp3');
      await _musicPlayer.setAudioContext(_kMusicContext);
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(_musicMuted ? 0.0 : _musicVolume);
      await _musicPlayer.play(DeviceFileSource(_exploreCachePath!));
    } catch (e) {
      // ignore: avoid_print
      print('[AUDIO] explore music error: $e');
      _musicStarted = false;
    }
  }

  void toggleMusicMute() {
    _musicMuted = !_musicMuted;
    try {
      _musicPlayer.setVolume(_musicMuted ? 0.0 : _musicVolume);
      _battlePlayer.setVolume(_musicMuted ? 0.0 : _musicVolume);
    } catch (_) {}
  }

  void setMusicVolume(double v) {
    _musicVolume = v.clamp(0.0, 1.0);
    if (!_musicMuted) {
      try {
        _musicPlayer.setVolume(_musicVolume);
        _battlePlayer.setVolume(_musicVolume);
      } catch (_) {}
    }
  }

  void pauseMusic() {
    try {
      _musicPlayer.pause();
      _battlePlayer.pause();
    } catch (_) {}
  }

  Future<void> resumeMusic() async {
    if (_musicMuted) return;
    try {
      if (_inBattle && _battleMusicStarted) {
        final bs = _battlePlayer.state;
        if (bs == PlayerState.paused) {
          await _battlePlayer.resume();
        } else if (bs == PlayerState.stopped || bs == PlayerState.completed) {
          // Audio focus was lost; restart battle music from cached file
          _battleCachePath ??= await _cacheAsset('audio/battle_music.mp3');
          await _battlePlayer.setAudioContext(_kMusicContext);
          await _battlePlayer.setReleaseMode(ReleaseMode.loop);
          await _battlePlayer.setVolume(_musicVolume);
          await _battlePlayer.play(DeviceFileSource(_battleCachePath!));
        }
      } else if (_musicStarted) {
        final ms = _musicPlayer.state;
        if (ms == PlayerState.paused) {
          await _musicPlayer.resume();
        } else if (ms == PlayerState.stopped || ms == PlayerState.completed) {
          // Audio focus was lost; restart explore music from cached file
          _musicStarted = false;
          await startMusic();
        }
      }
    } catch (_) {}
  }

  // ── Battle music ──────────────────────────────────────────────────────────────
  final AudioPlayer _battlePlayer = AudioPlayer();
  bool _battleMusicStarted = false;
  bool _inBattle = false;
  String? _battleCachePath;

  Future<void> startBattleMusic() async {
    if (_inBattle || _isWindows) return;
    _inBattle = true;
    try {
      _musicPlayer.pause();
    } catch (_) {}

    try {
      _battleCachePath ??= await _cacheAsset('audio/battle_music.mp3');
      // Always stop so playback restarts from the beginning of every battle
      try { await _battlePlayer.stop(); } catch (_) {}
      await _battlePlayer.setAudioContext(_kMusicContext);
      await _battlePlayer.setReleaseMode(ReleaseMode.loop);
      await _battlePlayer.setVolume(_musicMuted ? 0.0 : _musicVolume);
      await _battlePlayer.play(DeviceFileSource(_battleCachePath!));
      _battleMusicStarted = true;
    } catch (e) {
      // ignore: avoid_print
      print('[AUDIO] battle music error: $e');
      _battleMusicStarted = false;
      try { if (!_musicMuted) await _musicPlayer.resume(); } catch (_) {}
    }
  }

  Future<void> endBattleMusic() async {
    if (!_inBattle) return;
    _inBattle = false;
    try {
      await _battlePlayer.pause();
      if (!_musicMuted) {
        final state = _musicPlayer.state;
        if (state == PlayerState.paused) {
          await _musicPlayer.setVolume(_musicVolume);
          await _musicPlayer.resume();
        } else if (state == PlayerState.stopped || state == PlayerState.completed) {
          _exploreCachePath ??= await _cacheAsset('audio/explore_music.mp3');
          await _musicPlayer.setAudioContext(_kMusicContext);
          await _musicPlayer.setVolume(_musicVolume);
          await _musicPlayer.play(DeviceFileSource(_exploreCachePath!));
        }
      }
    } catch (_) {}
  }

  void dispose() {
    try {
      for (final p in _sfxPool) { p.dispose(); }
      _musicPlayer.dispose();
      _battlePlayer.dispose();
    } catch (_) {}
  }
}

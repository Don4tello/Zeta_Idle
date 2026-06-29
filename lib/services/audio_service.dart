import 'dart:io' show Platform;
import 'package:audioplayers/audioplayers.dart';
import '../models/hero_ability.dart';

enum SoundEffect { hit, playerHit, ability, abilityDamage, abilityBuff, abilityDebuff, coin, victory, defeat, levelUp }

final bool _isWindows = Platform.isWindows;

class AudioService {
  // ── SFX ──────────────────────────────────────────────────────────────────────
  bool _sfxMuted = false;
  bool get muted => _sfxMuted;
  bool get sfxMuted => _sfxMuted;
  void toggleMute()    => _sfxMuted = !_sfxMuted;
  void toggleSfxMute() => _sfxMuted = !_sfxMuted;

  // Reusable SFX player pool to avoid threading crashes on Windows
  final List<AudioPlayer> _sfxPool = [];
  static const int _poolSize = 4;
  int _poolIndex = 0;

  AudioPlayer _nextSfxPlayer() {
    if (_sfxPool.isEmpty) {
      for (int i = 0; i < _poolSize; i++) {
        _sfxPool.add(AudioPlayer());
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
      SoundEffect.abilityDamage => 'audio/ability_damage.wav',
      SoundEffect.abilityBuff   => 'audio/ability_buff.wav',
      SoundEffect.abilityDebuff => 'audio/ability_debuff.wav',
      SoundEffect.coin          => 'audio/coin.wav',
      SoundEffect.victory       => 'audio/victory.wav',
      SoundEffect.defeat        => 'audio/defeat.wav',
      SoundEffect.levelUp       => 'audio/levelup.wav',
    };
  }

  // ── Tavern music ──────────────────────────────────────────────────────────────
  final AudioPlayer _musicPlayer = AudioPlayer();
  bool _musicMuted = false;
  double _musicVolume = 0.35;
  bool _musicStarted = false;

  bool   get musicMuted  => _musicMuted;
  double get musicVolume => _musicVolume;

  Future<void> startMusic() async {
    if (_musicStarted || _isWindows) return;
    _musicStarted = true;
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(_musicMuted ? 0.0 : _musicVolume);
      await _musicPlayer.play(AssetSource('audio/bg_music.mp3'));
    } catch (_) {
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

  void resumeMusic() {
    if (_musicMuted) return;
    try {
      if (_inBattle && _battleMusicStarted) {
        _battlePlayer.resume();
      } else if (_musicStarted) {
        _musicPlayer.resume();
      }
    } catch (_) {}
  }

  // ── Battle music ──────────────────────────────────────────────────────────────
  final AudioPlayer _battlePlayer = AudioPlayer();
  bool _battleMusicStarted = false;
  bool _inBattle = false;

  Future<void> startBattleMusic() async {
    if (_inBattle || _isWindows) return;
    _inBattle = true;
    try {
      _musicPlayer.setVolume((_musicMuted ? 0.0 : _musicVolume) * 0.15);
    } catch (_) {}

    if (_battleMusicStarted) {
      try {
        if (!_musicMuted) await _battlePlayer.setVolume(_musicVolume);
        await _battlePlayer.resume();
      } catch (_) {}
      return;
    }
    _battleMusicStarted = true;
    try {
      await _battlePlayer.setReleaseMode(ReleaseMode.loop);
      await _battlePlayer.setVolume(_musicMuted ? 0.0 : _musicVolume);
      await _battlePlayer.play(AssetSource('audio/battle_music.mp3'));
    } catch (_) {
      _battleMusicStarted = false;
      try { _musicPlayer.setVolume(_musicMuted ? 0.0 : _musicVolume); } catch (_) {}
    }
  }

  Future<void> endBattleMusic() async {
    if (!_inBattle) return;
    _inBattle = false;
    try {
      await _battlePlayer.pause();
      _musicPlayer.setVolume(_musicMuted ? 0.0 : _musicVolume);
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

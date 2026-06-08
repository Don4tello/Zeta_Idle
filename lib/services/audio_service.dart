import 'package:audioplayers/audioplayers.dart';

enum SoundEffect { hit, playerHit, ability, coin, victory, defeat, levelUp }

class AudioService {
  bool _muted = false;
  bool get muted => _muted;
  void toggleMute() => _muted = !_muted;

  Future<void> play(SoundEffect effect) async {
    if (_muted) return;
    try {
      final player = AudioPlayer();
      await player.play(AssetSource(_path(effect)));
      player.onPlayerComplete.listen((_) => player.dispose());
    } catch (_) {}
  }

  Future<void> playHit()       => play(SoundEffect.hit);
  Future<void> playPlayerHit() => play(SoundEffect.playerHit);
  Future<void> playAbility()   => play(SoundEffect.ability);
  Future<void> playCoin()      => play(SoundEffect.coin);
  Future<void> playVictory()   => play(SoundEffect.victory);
  Future<void> playDefeat()    => play(SoundEffect.defeat);
  Future<void> playLevelUp()   => play(SoundEffect.levelUp);

  String _path(SoundEffect e) {
    switch (e) {
      case SoundEffect.hit:        return 'audio/hit.wav';
      case SoundEffect.playerHit:  return 'audio/player_hit.wav';
      case SoundEffect.ability:    return 'audio/ability.wav';
      case SoundEffect.coin:       return 'audio/coin.wav';
      case SoundEffect.victory:    return 'audio/victory.wav';
      case SoundEffect.defeat:     return 'audio/defeat.wav';
      case SoundEffect.levelUp:    return 'audio/levelup.wav';
    }
  }
}

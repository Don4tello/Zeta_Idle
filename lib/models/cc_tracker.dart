/// Shared diminishing-returns tracker for hard crowd control (stun / freeze /
/// disarm / silence) used by the alternate game modes (Boss Rush, Dungeon,
/// Gauntlet, Guild). Mirrors the campaign's DR (game_state `_hardCcDuration`):
/// full effect on the 1st application, half on the 2nd, immune on the 3rd,
/// resetting after 5 CC-free rounds. Every mode routes its hard CC through one
/// instance so nothing can be perma-stunned/-silenced/-disarmed.
class CcTracker {
  int _count = 0;        // applications in the current window
  int _roundsSince = 0;  // rounds since the last landed CC
  static const _drMult = [1.0, 0.5, 0.0];

  /// Call once per combat round to advance the reset timer.
  void tickRound() {
    _roundsSince++;
    if (_roundsSince >= 5 && _count > 0) {
      _count = 0;
      _roundsSince = 0;
    }
  }

  /// DR-adjusted duration for a CC of [baseDur] rounds (0 = resisted).
  int apply(int baseDur) {
    if (_roundsSince >= 5) {
      _count = 0;
      _roundsSince = 0;
    }
    final dur = (baseDur * _drMult[_count.clamp(0, _drMult.length - 1)]).floor();
    if (dur > 0) {
      _count++;
      _roundsSince = 0;
    }
    return dur;
  }

  /// Boolean (single-round) CC used by the alt modes: lands for the first two
  /// applications in a window, then is DR-immune until [tickRound] resets it
  /// after 5 CC-free rounds. Returns true if the CC lands.
  bool applyBool() {
    if (_roundsSince >= 5) {
      _count = 0;
      _roundsSince = 0;
    }
    if (_count >= 2) return false; // DR immune
    _count++;
    _roundsSince = 0;
    return true;
  }

  void reset() {
    _count = 0;
    _roundsSince = 0;
  }
}

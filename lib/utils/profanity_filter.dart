/// Lightweight profanity check for player-chosen names.
///
/// Names now appear on shared leaderboards and in PvP, so we screen them at
/// character creation. This is intentionally pragmatic, not exhaustive — it
/// catches the obvious cases (incl. common leetspeak/space evasions) while
/// trying to avoid false positives on innocent words (the "Scunthorpe problem")
/// by matching most terms on word boundaries. Server-side moderation could
/// harden this later; for a closed test this keeps the boards family-friendly.
class ProfanityFilter {
  ProfanityFilter._();

  // Common profanity + slurs. Kept lowercase; matched on word boundaries below.
  static const Set<String> _banned = {
    'fuck', 'shit', 'bitch', 'cunt', 'dick', 'cock', 'pussy', 'asshole',
    'bastard', 'slut', 'whore', 'nigger', 'nigga', 'faggot', 'fag', 'retard',
    'spastic', 'wanker', 'twat', 'bollocks', 'nazi', 'rape', 'rapist',
    'pedo', 'pedophile', 'molest', 'kys', 'jizz', 'cum', 'boner', 'dildo',
    'coon', 'chink', 'spic', 'kike', 'tranny', 'dyke',
  };

  // Severe terms blocked even when embedded inside another token (no innocent
  // word contains these as a substring), so "xXn1gg3rXx" can't slip through.
  static const Set<String> _severeSubstrings = {
    'nigger', 'nigga', 'faggot', 'nazi', 'rapist', 'pedophile', 'kike',
    'chink', 'tranny',
  };

  /// Map common leetspeak/symbol substitutions back to letters so evasions
  /// like "sh1t" / "f_u_c_k" / "a$$" are still caught.
  static String _normalize(String input) {
    final lower = input.toLowerCase();
    final buf = StringBuffer();
    for (final ch in lower.split('')) {
      buf.write(switch (ch) {
        '0' => 'o',
        '1' || '!' || '|' => 'i',
        '3' => 'e',
        '4' || '@' => 'a',
        '5' || r'$' => 's',
        '7' => 't',
        '8' => 'b',
        _ => ch,
      });
    }
    return buf.toString();
  }

  /// True if [name] contains banned language.
  static bool isProfane(String name) {
    if (name.trim().isEmpty) return false;
    final normalized = _normalize(name);
    // Collapse everything to bare letters to defeat spacing/punctuation evasion
    // (e.g. "f u c k", "s.h.i.t") for the severe-substring pass.
    final collapsed = normalized.replaceAll(RegExp(r'[^a-z]'), '');
    for (final w in _severeSubstrings) {
      if (collapsed.contains(w)) return true;
    }
    // Word-boundary pass on the normalized (spacing-preserved) form so innocent
    // words that merely contain a short banned token aren't flagged.
    final tokens = normalized.split(RegExp(r'[^a-z]+'));
    for (final t in tokens) {
      if (t.isNotEmpty && _banned.contains(t)) return true;
    }
    return false;
  }
}

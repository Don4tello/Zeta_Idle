// l10n_audit — localization progress + ARB sync checker for Zeta Idle.
//
// Run from repo root:
//   dart tool/l10n_audit.dart            # full report
//   dart tool/l10n_audit.dart --sync     # only the de/en key diff (CI-friendly)
//   dart tool/l10n_audit.dart --file lib/screens/battle_screen.dart
//
// Part 1 (sync): compares app_de.arb against the app_en.arb template and lists
//   any English keys with no German translation (and any stale German-only keys).
//   Exits non-zero if German is behind — safe to wire into a pre-commit/CI hook.
// Part 2 (audit): scans lib/**.dart for user-facing string literals that are
//   still hardcoded (not yet routed through AppLocalizations), so we can track
//   how much of the ~1,900-string migration is left and target the biggest files.
//
// This is a heuristic linter, not a parser: it flags literals passed to the
// common UI sinks below. A handful of false positives (debug text, keys) is
// expected — the per-file counts are what matter for prioritizing work.

import 'dart:convert';
import 'dart:io';

const arbDir = 'lib/l10n';
const templateArb = '$arbDir/app_en.arb';

// UI sinks whose string arguments are shown to players.
final sinkPattern = RegExp(
  r'''(?:Text|TextSpan|Tooltip|SelectableText)\(\s*(['"])''',
);
// Named args that carry visible copy.
final namedArgPattern = RegExp(
  r'''\b(?:hintText|labelText|helperText|title|subtitle|tooltip|semanticLabel)\s*:\s*(['"])''',
);

void main(List<String> args) {
  final syncOnly = args.contains('--sync');
  final fileArgIdx = args.indexOf('--file');
  final onlyFile = fileArgIdx >= 0 && fileArgIdx + 1 < args.length
      ? args[fileArgIdx + 1]
      : null;

  final behind = _syncReport();

  if (syncOnly) {
    exit(behind ? 1 : 0);
  }

  _auditReport(onlyFile);

  if (behind) {
    stdout.writeln('\n⚠  German is missing keys — see the sync section above.');
    exit(1);
  }
}

/// Returns true if German is missing one or more English keys.
bool _syncReport() {
  final en = _readArbKeys(templateArb);
  final deFile = File('$arbDir/app_de.arb');
  if (!deFile.existsSync()) {
    stdout.writeln('✗ $arbDir/app_de.arb not found.');
    return true;
  }
  final de = _readArbKeys('$arbDir/app_de.arb');

  final missing = en.difference(de).toList()..sort();
  final stale = de.difference(en).toList()..sort();

  stdout.writeln('=== ARB SYNC (de vs en) ===');
  stdout.writeln('en keys: ${en.length}   de keys: ${de.length}');
  if (missing.isEmpty && stale.isEmpty) {
    stdout.writeln('✓ German is fully in sync.\n');
    return false;
  }
  if (missing.isNotEmpty) {
    stdout.writeln('\n✗ ${missing.length} English key(s) missing German:');
    for (final k in missing) {
      stdout.writeln('    $k');
    }
  }
  if (stale.isNotEmpty) {
    stdout.writeln('\n! ${stale.length} German-only key(s) not in template (stale?):');
    for (final k in stale) {
      stdout.writeln('    $k');
    }
  }
  stdout.writeln('');
  return missing.isNotEmpty;
}

/// Keys in an ARB file, ignoring @@locale and @-metadata entries.
Set<String> _readArbKeys(String path) {
  final raw = File(path).readAsStringSync();
  final map = jsonDecode(raw) as Map<String, dynamic>;
  return map.keys
      .where((k) => !k.startsWith('@'))
      .toSet();
}

void _auditReport(String? onlyFile) {
  final files = <File>[];
  if (onlyFile != null) {
    files.add(File(onlyFile));
  } else {
    final dir = Directory('lib');
    for (final e in dir.listSync(recursive: true)) {
      if (e is File &&
          e.path.endsWith('.dart') &&
          !e.path.contains('${Platform.pathSeparator}l10n${Platform.pathSeparator}')) {
        files.add(e);
      }
    }
  }

  final counts = <String, int>{};
  var total = 0;
  for (final f in files) {
    final src = f.readAsStringSync();
    var n = 0;
    for (final m in sinkPattern.allMatches(src)) {
      if (_isLocalizable(src, m)) n++;
    }
    for (final m in namedArgPattern.allMatches(src)) {
      if (_isLocalizable(src, m)) n++;
    }
    if (n > 0) {
      counts[_rel(f.path)] = n;
      total += n;
    }
  }

  stdout.writeln('=== HARDCODED UI STRINGS (not via AppLocalizations) ===');
  stdout.writeln('$total literal(s) across ${counts.length} file(s)\n');

  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  for (final e in sorted) {
    stdout.writeln('  ${e.value.toString().padLeft(4)}  ${e.key}');
  }
}

/// A literal is worth flagging unless it is empty or clearly non-copy
/// (single char, interpolation-only handled loosely).
bool _isLocalizable(String src, RegExpMatch m) {
  final quote = m.group(1)!;
  final start = m.end; // position just after opening quote
  final close = src.indexOf(quote, start);
  if (close < 0) return false;
  final literal = src.substring(start, close);
  if (literal.trim().isEmpty) return false;
  if (literal.length <= 1) return false;
  // Skip pure interpolations like '$x' with no surrounding letters.
  final hasLetters = RegExp(r'[A-Za-z]{2,}').hasMatch(literal);
  if (!hasLetters) return false;
  return true;
}

String _rel(String p) => p.replaceAll(Platform.pathSeparator, '/');

import 'dart:io';

/// Lightweight event log for balance tuning and debugging.
/// Writes one line per event to ZetaIdle_debug.log in the system temp dir.
/// Call DebugLogger.log(category, message) from anywhere; fire-and-forget.
class DebugLogger {
  DebugLogger._();

  static File? _file;
  static bool _enabled = true;

  /// Optional forwarder (wired in main.dart when Firebase is ready) so every
  /// logged event becomes a Crashlytics breadcrumb and error-like entries are
  /// recorded as non-fatals. Kept as a callback so this logger stays platform-
  /// agnostic (no Firebase import — safe on Windows/desktop).
  static void Function(String category, String message)? sink;

  static Future<void> init() async {
    if (!_enabled) return;
    try {
      final dir = Directory.systemTemp;
      _file = File('${dir.path}/ZetaIdle_debug.log');
      if (await _file!.length().catchError((_) => 0) > 2 * 1024 * 1024) {
        // Trim file if it grows past 2 MB: keep the last 500 lines
        final lines = await _file!.readAsLines();
        final trimmed = lines.length > 500 ? lines.sublist(lines.length - 500) : lines;
        await _file!.writeAsString(trimmed.join('\n') + '\n');
      }
    } catch (_) {
      _file = null;
    }
  }

  static void log(String category, String message) {
    // Forward to Crashlytics (breadcrumb + non-fatal) even if file logging is
    // disabled/unavailable — this is the crash-visibility path.
    try { sink?.call(category, message); } catch (_) {}
    if (!_enabled || _file == null) return;
    final ts = DateTime.now().toIso8601String();
    _file!.writeAsString('[$ts] [$category] $message\n',
        mode: FileMode.append, flush: false);
  }

  static void disable() => _enabled = false;
  static void enable()  => _enabled = true;
}

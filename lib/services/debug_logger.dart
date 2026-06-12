import 'dart:io';

/// Lightweight event log for balance tuning and debugging.
/// Writes one line per event to ZetaIdle_debug.log in the system temp dir.
/// Call DebugLogger.log(category, message) from anywhere; fire-and-forget.
class DebugLogger {
  DebugLogger._();

  static File? _file;
  static bool _enabled = true;

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
    if (!_enabled || _file == null) return;
    final ts = DateTime.now().toIso8601String();
    _file!.writeAsString('[$ts] [$category] $message\n',
        mode: FileMode.append, flush: false);
  }

  static void disable() => _enabled = false;
  static void enable()  => _enabled = true;
}

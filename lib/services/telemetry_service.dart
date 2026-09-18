import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'remote_config_service.dart';

/// Writes fight balance telemetry (the same JSON that `DebugLogger.balance`
/// emits) to a Firestore `telemetry` collection, so runs can be queried in the
/// Firebase console WITHOUT adb / logcat / a plugged-in device.
///
/// Two independent ways to turn it on, BOTH default OFF so a normal production
/// build never writes:
///   1. Compile flag — `flutter build ... --dart-define=ZETA_TELEMETRY=1`
///      (forces it on for local dev builds).
///   2. Remote Config — set `telemetry_enabled = true` in the Firebase console.
///      One build (e.g. the closed-test .aab) can be flipped on live for testers
///      and back off before/for production, with `telemetry_sample_pct` to dial
///      down volume. Toggles land within Remote Config's fetch window (~1h).
///
/// Then read/filter the `telemetry` collection in the Firebase console.
class TelemetryService {
  TelemetryService._();

  /// Dev compile flag — forces telemetry on regardless of Remote Config.
  static const bool _forceOn =
      bool.fromEnvironment('ZETA_TELEMETRY', defaultValue: false);

  static final Random _rng = Random();

  /// Groups every fight from one app run together (set once at startup).
  static String? sessionId;

  /// Record one fight — the compact JSON line `DebugLogger.balance` emits.
  /// No-op unless enabled by the compile flag or Remote Config (both OFF by
  /// default). Fire-and-forget; never allowed to affect gameplay.
  static void recordFight(String jsonLine) {
    final on = _forceOn || RemoteConfigService.instance.telemetryEnabled;
    if (!on) return;
    // Sampling (Remote-Config path only) so a wider rollout can't write-storm.
    if (!_forceOn) {
      final pct = RemoteConfigService.instance.telemetrySamplePct;
      if (pct < 100 && _rng.nextDouble() * 100 >= pct) return;
    }
    try {
      final data = <String, dynamic>{
        ...(jsonDecode(jsonLine) as Map<String, dynamic>),
        'ts': FieldValue.serverTimestamp(),
        if (sessionId != null) 'session': sessionId,
      };
      FirebaseFirestore.instance
          .collection('telemetry')
          .add(data)
          .then((_) {}, onError: (_) {});
    } catch (_) {/* telemetry must never affect gameplay */}
  }
}

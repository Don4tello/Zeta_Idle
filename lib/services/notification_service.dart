import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local scheduled "come back" reminders for retention. No backend needed —
/// when the app is backgrounded we schedule a few reminders; when it returns to
/// the foreground we cancel them (the player is already here).
///
/// Scheduling uses UTC absolute instants (relative to "now + duration"), so we
/// don't need the device's timezone name — the notification fires the right
/// number of hours later regardless of locale.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const String _channelId   = 'zeta_reminders';
  static const String _channelName = 'Reminders';
  static const String _channelDesc = 'Idle progress & daily reset reminders';

  bool get _supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> initialize() async {
    if (_ready || !_supported) return;
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
    );
    _ready = true;
  }

  /// Ask for the OS notification permission (Android 13+ / iOS). Returns true
  /// if granted. Safe to call repeatedly.
  Future<bool> requestPermission() async {
    if (!_supported) return false;
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
        false;
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId, _channelName,
          channelDescription: _channelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      );

  Future<void> _scheduleIn(int id, String title, String body, Duration after) async {
    final when = tz.TZDateTime.now(tz.UTC).add(after);
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: when,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Cancel any pending reminders, then schedule a fresh retention ladder.
  /// Call when the app is backgrounded.
  Future<void> scheduleRetentionReminders() async {
    if (!_ready) return;
    await _plugin.cancelAll();
    await _scheduleIn(1, 'Your realm awaits',
        'Idle gold and loot are piling up in Zeta Idle.',
        const Duration(hours: 12));
    await _scheduleIn(2, 'Daily challenges reset',
        'Fresh daily challenges and rewards are ready to claim.',
        const Duration(hours: 24));
    await _scheduleIn(3, 'The Warden grows restless',
        'Return to continue your campaign and grow stronger.',
        const Duration(days: 3));
  }

  /// Cancel all pending reminders. Call when the app returns to foreground.
  Future<void> cancelAll() async {
    if (!_ready) return;
    await _plugin.cancelAll();
  }
}

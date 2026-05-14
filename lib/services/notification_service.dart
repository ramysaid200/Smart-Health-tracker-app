import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Local notification service for daily reminders and medication alerts
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Notification IDs
  static const int morningReminderId = 1;
  static const int eveningReminderId = 2;
  static const int goalAchievedId = 100;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Navigation handled externally via app router
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    bool? androidGranted = await android?.requestNotificationsPermission();
    bool? iosGranted = await ios?.requestPermissions(alert: true, badge: true, sound: true);

    return (androidGranted ?? true) && (iosGranted ?? true);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Schedule Notifications
  // ──────────────────────────────────────────────────────────────────────────

  /// Schedule a daily repeating reminder at a specific time
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String channelId = 'daily_reminders',
    String channelName = 'Daily Reminders',
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfTime(time),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule morning reminder (8:00 AM daily)
  Future<void> scheduleMorningReminder() => scheduleDailyReminder(
        id: morningReminderId,
        title: '🌅 Good morning!',
        body: 'Log your weight and plan your meals for today.',
        time: const TimeOfDay(hour: 8, minute: 0),
      );

  /// Schedule evening reminder (8:00 PM daily)
  Future<void> scheduleEveningReminder() => scheduleDailyReminder(
        id: eveningReminderId,
        title: '🌙 Evening check-in',
        body: "Don't forget to log your sleep schedule.",
        time: const TimeOfDay(hour: 20, minute: 0),
      );

  /// Schedule a medication reminder
  Future<void> scheduleMedicationReminder({
    required int id,
    required String medicationName,
    required String dosage,
    required TimeOfDay time,
  }) =>
      scheduleDailyReminder(
        id: id,
        title: '💊 Time for $medicationName',
        body: '$dosage • Tap to mark as taken',
        time: time,
        channelId: 'medication_reminders',
        channelName: 'Medication Reminders',
      );

  /// Show immediate notification for goal achievement
  Future<void> showGoalAchievedNotification() async {
    await _plugin.show(
      id: goalAchievedId,
      title: '🎉 Daily goal achieved!',
      body: 'You crushed your daily goals! Keep it up!',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'goals',
          'Goal Achievements',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Cancel
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> cancelNotification(int id) => _plugin.cancel(id: id);
  Future<void> cancelAllNotifications() => _plugin.cancelAll();

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

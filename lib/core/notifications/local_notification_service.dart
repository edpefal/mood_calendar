import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

typedef NotificationTapCallback = Future<void> Function();

class LocalNotificationService {
  LocalNotificationService({required NotificationTapCallback onReminderTap})
      : _onReminderTap = onReminderTap;

  static const _dailyReminderId = 1001;
  static const _dailyReminderPayload = 'daily_mood_reminder';
  static const _dailyReminderChannelId = 'daily_mood_channel';
  static const _dailyReminderChannelName = 'Daily Mood Reminder';
  static const _dailyReminderChannelDescription =
      'Daily reminder to log how you feel at 6:00 PM';
  static const AndroidNotificationChannel _dailyReminderChannel =
      AndroidNotificationChannel(
    _dailyReminderChannelId,
    _dailyReminderChannelName,
    description: _dailyReminderChannelDescription,
    importance: Importance.high,
  );
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final NotificationTapCallback _onReminderTap;

  Future<void> initialize() async {
    await _configureTimeZones();
    await _requestPermissions();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final darwinSettings = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async =>
          _onReminderTap(),
    );

    final settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) async {
        if (details.payload == _dailyReminderPayload) {
          await _onReminderTap();
        }
      },
    );
    await _ensureAndroidChannel();

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final payload = launchDetails?.notificationResponse?.payload;
    if (payload == _dailyReminderPayload) {
      await _onReminderTap();
    }
  }

  Future<void> scheduleDailyReminder() async {
    await cancelDailyReminder();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, _reminderHour);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _dailyReminderChannelId,
      _dailyReminderChannelName,
      channelDescription: _dailyReminderChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );

    await _plugin.zonedSchedule(
      _dailyReminderId,
      'How are you feeling today?',
      'Tap to record your mood for today.',
      scheduled,
      const NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: _dailyReminderPayload,
    );
  }

  Future<void> cancelDailyReminder() => _plugin.cancel(_dailyReminderId);

  Future<void> _configureTimeZones() async {
    if (_timeZoneInitialized) {
      return;
    }
    tz.initializeTimeZones();
    final timeZoneName = await _tryGetLocalTimeZone();
    final resolvedName = timeZoneName ?? _fallbackTimeZone;
    try {
      tz.setLocalLocation(tz.getLocation(resolvedName));
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to apply timezone $resolvedName: $error');
      }
      tz.setLocalLocation(tz.getLocation(_fallbackTimeZone));
    }
    _timeZoneInitialized = true;
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: false, sound: true);
    }

    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();
      if (granted != null && !granted) {
        if (kDebugMode) {
          debugPrint('Notification permission not granted on Android.');
        }
      }
    }
  }

  Future<String?> _tryGetLocalTimeZone() async {
    try {
      return await FlutterNativeTimezone.getLocalTimezone();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to resolve local timezone: $error');
      }
      return null;
    }
  }

  static const _reminderHour = 18;
  static const _fallbackTimeZone = 'UTC';
  static bool _timeZoneInitialized = false;

  Future<void> _ensureAndroidChannel() async {
    if (!Platform.isAndroid) {
      return;
    }
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_dailyReminderChannel);
  }
}

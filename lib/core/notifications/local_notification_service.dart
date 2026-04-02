import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../localization/app_strings.dart';
import '../settings/domain/repositories/app_settings_repository.dart';
import '../telemetry/app_telemetry.dart';
import '../telemetry/app_telemetry_events.dart';

typedef NotificationTapCallback = Future<void> Function();

class LocalNotificationService {
  LocalNotificationService({
    required NotificationTapCallback onReminderTap,
    required AppSettingsRepository appSettingsRepository,
    required AppTelemetry telemetry,
  })  : _onReminderTap = onReminderTap,
        _appSettingsRepository = appSettingsRepository,
        _telemetry = telemetry;

  static const _dailyReminderId = 1001;
  static const _dailyReminderPayload = 'daily_mood_reminder';
  static const _dailyReminderChannelId = 'daily_mood_channel';
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final NotificationTapCallback _onReminderTap;
  final AppSettingsRepository _appSettingsRepository;
  final AppTelemetry _telemetry;

  Future<bool> initialize() async {
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
          _telemetry.trackEvent(
            AppTelemetryEvents.openedFromReminder,
            properties: {'source': 'notification_tap'},
          );
          await _onReminderTap();
        }
      },
    );
    await _ensureAndroidChannel();

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final payload = launchDetails?.notificationResponse?.payload;
    if (payload == _dailyReminderPayload) {
      _telemetry.trackEvent(
        AppTelemetryEvents.openedFromReminder,
        properties: {'source': 'app_launch'},
      );
    }
    return payload == _dailyReminderPayload;
  }

  Future<void> scheduleDailyReminder() async {
    await cancelDailyReminder();
    final settings = await _appSettingsRepository.getSettings();
    if (!settings.dailyReminderEnabled) {
      _telemetry.trackEvent(
        AppTelemetryEvents.reminderCancelled,
        properties: {'reason': 'disabled_in_settings'},
      );
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      settings.dailyReminderHour,
      settings.dailyReminderMinute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _dailyReminderChannelId,
      'Recordatorio diario de animo',
      channelDescription: 'Recordatorio diario para registrar como te sientes',
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
      AppStrings.spanish.reminderNotificationTitle,
      AppStrings.spanish.reminderNotificationBody,
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
    _telemetry.trackEvent(
      AppTelemetryEvents.reminderScheduled,
      properties: {
        'hour': settings.dailyReminderHour,
        'minute': settings.dailyReminderMinute,
      },
    );
  }

  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(_dailyReminderId);
    _telemetry.trackEvent(
      AppTelemetryEvents.reminderCancelled,
      properties: {'reason': 'rescheduled_or_manual'},
    );
  }

  Future<void> _configureTimeZones() async {
    if (_timeZoneInitialized) {
      return;
    }
    tz.initializeTimeZones();
    final timeZoneName = await _tryGetLocalTimeZone();
    final resolvedName = timeZoneName ?? _fallbackTimeZone;
    try {
      tz.setLocalLocation(tz.getLocation(resolvedName));
    } catch (error, stackTrace) {
      _telemetry.recordError(
        'apply_timezone_failed',
        reason: 'invalid_timezone_name',
        context: {'timezone': resolvedName},
        error: error,
        stackTrace: stackTrace,
      );
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
        _telemetry.recordError(
          'notification_permission_denied',
          reason: 'android_runtime_permission',
        );
        if (kDebugMode) {
          debugPrint('Notification permission not granted on Android.');
        }
      }
    }
  }

  Future<String?> _tryGetLocalTimeZone() async {
    try {
      return await FlutterNativeTimezone.getLocalTimezone();
    } catch (error, stackTrace) {
      _telemetry.recordError(
        'resolve_timezone_failed',
        reason: 'native_timezone_lookup',
        error: error,
        stackTrace: stackTrace,
      );
      if (kDebugMode) {
        debugPrint('Failed to resolve local timezone: $error');
      }
      return null;
    }
  }

  static const _fallbackTimeZone = 'UTC';
  static bool _timeZoneInitialized = false;

  Future<void> _ensureAndroidChannel() async {
    if (!Platform.isAndroid) {
      return;
    }
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        _dailyReminderChannelId,
        AppStrings.spanish.notificationChannelName,
        description: AppStrings.spanish.notificationChannelDescription,
        importance: Importance.high,
      ),
    );
  }
}

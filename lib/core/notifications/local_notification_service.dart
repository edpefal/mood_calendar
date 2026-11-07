import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
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
    Locale Function()? localeResolver,
  })  : _onReminderTap = onReminderTap,
        _appSettingsRepository = appSettingsRepository,
        _telemetry = telemetry,
        _localeResolver =
            localeResolver ?? (() => PlatformDispatcher.instance.locale);

  static const _dailyReminderId = 1001;
  static const _dailyReminderPayload = 'daily_mood_reminder';
  static const _dailyReminderChannelId = 'daily_mood_channel';
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final NotificationTapCallback _onReminderTap;
  final AppSettingsRepository _appSettingsRepository;
  final AppTelemetry _telemetry;
  final Locale Function() _localeResolver;

  /// Strings in the device language, resolved on each use: this service has
  /// no BuildContext and the locale may change between launches.
  @visibleForTesting
  AppStrings get strings => AppStrings.forLocale(_localeResolver());

  /// [requestPermission] is false on a brand-new install: the onboarding asks
  /// for the notification permission itself (step 3), in context, instead of
  /// the OS dialog appearing at launch.
  Future<bool> initialize({bool requestPermission = true}) async {
    await _configureTimeZones();
    if (requestPermission) {
      await this.requestPermission();
    }

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

    final strings = this.strings;
    final androidDetails = AndroidNotificationDetails(
      _dailyReminderChannelId,
      strings.notificationChannelName,
      channelDescription: strings.notificationChannelDescription,
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
      strings.reminderNotificationTitle,
      strings.reminderNotificationBody,
      scheduled,
      NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      ),
      // Inexact on purpose: the daily reminder does not need to fire on the
      // minute, and exact alarms need SCHEDULE_EXACT_ALARM (Android 12+),
      // which the app does not declare; asking for it throws
      // `exact_alarms_not_permitted` and the reminder is never scheduled.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
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

  /// Asks the OS for permission to show notifications and reports whether it
  /// ended up granted. Safe to call again: once the user has decided, the OS
  /// shows no dialog and just returns the current answer.
  Future<bool> requestPermission() async {
    var granted = true;
    if (Platform.isIOS || Platform.isMacOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: false, sound: true);
      granted = result == true;
    }

    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final result = await androidPlugin?.requestNotificationsPermission();
      granted = result == true;
      if (result != null && !result) {
        _telemetry.recordError(
          'notification_permission_denied',
          reason: 'android_runtime_permission',
        );
        if (kDebugMode) {
          debugPrint('Notification permission not granted on Android.');
        }
      }
    }
    return granted;
  }

  Future<String?> _tryGetLocalTimeZone() async {
    try {
      return (await FlutterTimezone.getLocalTimezone()).identifier;
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
    final strings = this.strings;
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        _dailyReminderChannelId,
        strings.notificationChannelName,
        description: strings.notificationChannelDescription,
        importance: Importance.high,
      ),
    );
  }
}

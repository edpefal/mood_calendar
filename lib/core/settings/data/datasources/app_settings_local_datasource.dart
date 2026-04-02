import 'package:hive/hive.dart';

import '../../domain/entities/app_settings.dart';

class AppSettingsLocalDataSource {
  AppSettingsLocalDataSource(this._settingsBox);

  static const String boxName = 'app_settings';
  static const String _dailyReminderEnabledKey = 'daily_reminder_enabled';
  static const String _dailyReminderHourKey = 'daily_reminder_hour';
  static const String _dailyReminderMinuteKey = 'daily_reminder_minute';

  final Box<dynamic> _settingsBox;

  Future<AppSettings> getSettings() async {
    final dailyReminderEnabled = _settingsBox.get(
      _dailyReminderEnabledKey,
      defaultValue: AppSettings.defaults.dailyReminderEnabled,
    ) as bool;
    final dailyReminderHour = _settingsBox.get(
      _dailyReminderHourKey,
      defaultValue: AppSettings.defaults.dailyReminderHour,
    ) as int;
    final dailyReminderMinute = _settingsBox.get(
      _dailyReminderMinuteKey,
      defaultValue: AppSettings.defaults.dailyReminderMinute,
    ) as int;

    return AppSettings(
      dailyReminderEnabled: dailyReminderEnabled,
      dailyReminderHour: dailyReminderHour,
      dailyReminderMinute: dailyReminderMinute,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put(
      _dailyReminderEnabledKey,
      settings.dailyReminderEnabled,
    );
    await _settingsBox.put(
      _dailyReminderHourKey,
      settings.dailyReminderHour,
    );
    await _settingsBox.put(
      _dailyReminderMinuteKey,
      settings.dailyReminderMinute,
    );
  }
}

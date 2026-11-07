import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mood_calendar/core/settings/data/datasources/app_settings_local_datasource.dart';
import 'package:mood_calendar/core/settings/domain/entities/app_settings.dart';
import 'package:mood_calendar/core/settings/domain/entities/app_theme_preference.dart';

void main() {
  late Directory tempDir;
  late Box<dynamic> settingsBox;
  late AppSettingsLocalDataSource dataSource;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('app_settings_test_');
    Hive.init(tempDir.path);
    settingsBox = await Hive.openBox<dynamic>(
      AppSettingsLocalDataSource.boxName,
    );
    dataSource = AppSettingsLocalDataSource(settingsBox);
  });

  tearDown(() async {
    await settingsBox.close();
    await tempDir.delete(recursive: true);
  });

  test('returns default settings when the box is empty', () async {
    final settings = await dataSource.getSettings();

    expect(settings.dailyReminderEnabled, isTrue);
    expect(settings.dailyReminderHour, 18);
    expect(settings.dailyReminderMinute, 0);
    expect(settings.usageAnalyticsEnabled, isTrue);
    expect(settings.themePreference, AppThemePreference.system);
    expect(settings.noteLockEnabled, isFalse);
  });

  test('persists and reloads typed settings values', () async {
    const updatedSettings = AppSettings(
      dailyReminderEnabled: false,
      dailyReminderHour: 9,
      dailyReminderMinute: 30,
    );

    await dataSource.saveSettings(updatedSettings);
    final reloadedSettings = await dataSource.getSettings();

    expect(reloadedSettings.dailyReminderEnabled, isFalse);
    expect(reloadedSettings.dailyReminderHour, 9);
    expect(reloadedSettings.dailyReminderMinute, 30);
  });

  test('persists the usage analytics preference across reopens', () async {
    await dataSource.saveSettings(
      AppSettings.defaults.copyWith(usageAnalyticsEnabled: false),
    );
    await settingsBox.close();
    settingsBox = await Hive.openBox<dynamic>(
      AppSettingsLocalDataSource.boxName,
    );

    final reloaded =
        await AppSettingsLocalDataSource(settingsBox).getSettings();

    expect(reloaded.usageAnalyticsEnabled, isFalse);
  });

  group('theme preference', () {
    test('persists and reloads the chosen theme', () async {
      await dataSource.saveSettings(
        AppSettings.defaults.copyWith(themePreference: AppThemePreference.dark),
      );

      expect(
        (await dataSource.getSettings()).themePreference,
        AppThemePreference.dark,
      );
    });

    test('keeps the other settings when only the theme changes', () async {
      await dataSource.saveSettings(
        AppSettings.defaults.copyWith(dailyReminderHour: 7),
      );
      final saved = await dataSource.getSettings();
      await dataSource.saveSettings(
        saved.copyWith(themePreference: AppThemePreference.light),
      );

      final reloaded = await dataSource.getSettings();
      expect(reloaded.dailyReminderHour, 7);
      expect(reloaded.themePreference, AppThemePreference.light);
    });

    test('falls back to system when the stored value is unknown', () async {
      await settingsBox.put('theme_preference', 'sepia');

      expect(
        (await dataSource.getSettings()).themePreference,
        AppThemePreference.system,
      );
    });
  });

  group('note lock', () {
    test('is off for a box saved before the key existed', () async {
      await settingsBox.put('daily_reminder_hour', 7);

      expect((await dataSource.getSettings()).noteLockEnabled, isFalse);
    });

    test('persists across reopens and keeps the other settings', () async {
      await dataSource.saveSettings(
        AppSettings.defaults.copyWith(dailyReminderHour: 7),
      );
      final saved = await dataSource.getSettings();
      await dataSource.saveSettings(saved.copyWith(noteLockEnabled: true));
      await settingsBox.close();
      settingsBox = await Hive.openBox<dynamic>(
        AppSettingsLocalDataSource.boxName,
      );

      final reloaded =
          await AppSettingsLocalDataSource(settingsBox).getSettings();

      expect(reloaded.noteLockEnabled, isTrue);
      expect(reloaded.dailyReminderHour, 7);
    });
  });
}

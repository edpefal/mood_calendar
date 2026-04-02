import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mood_calendar/core/settings/data/datasources/app_settings_local_datasource.dart';
import 'package:mood_calendar/core/settings/domain/entities/app_settings.dart';

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
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mood_calendar/core/settings/data/datasources/app_settings_local_datasource.dart';
import 'package:mood_calendar/core/settings/data/datasources/rating_prompt_local_datasource.dart';
import 'package:mood_calendar/core/settings/domain/entities/app_settings.dart';

void main() {
  late Directory tempDir;
  late Box<dynamic> settingsBox;
  late RatingPromptLocalDataSource dataSource;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('rating_prompt_test_');
    Hive.init(tempDir.path);
    settingsBox = await Hive.openBox<dynamic>(
      AppSettingsLocalDataSource.boxName,
    );
    dataSource = RatingPromptLocalDataSource(settingsBox);
  });

  tearDown(() async {
    await settingsBox.close();
    await tempDir.delete(recursive: true);
  });

  test('returns no attempts when the box is empty', () {
    final state = dataSource.getState();

    expect(state.attempts, 0);
    expect(state.lastAttemptAt, isNull);
  });

  test('records attempts and the time of the latest one', () async {
    final first = DateTime(2026, 10, 5, 12);
    final second = DateTime(2026, 11, 8, 9, 30);

    await dataSource.recordAttempt(first);
    expect(dataSource.getState().attempts, 1);
    expect(dataSource.getState().lastAttemptAt, first);

    await dataSource.recordAttempt(second);
    expect(dataSource.getState().attempts, 2);
    expect(dataSource.getState().lastAttemptAt, second);
  });

  test('keeps the state across a new data source over the same box', () async {
    final at = DateTime(2026, 10, 5, 12);
    await dataSource.recordAttempt(at);

    final reopened = RatingPromptLocalDataSource(settingsBox);

    expect(reopened.getState().attempts, 1);
    expect(reopened.getState().lastAttemptAt, at);
  });

  test('does not interfere with the reminder settings stored in the box',
      () async {
    final settingsDataSource = AppSettingsLocalDataSource(settingsBox);
    const reminder = AppSettings(
      dailyReminderEnabled: false,
      dailyReminderHour: 9,
      dailyReminderMinute: 30,
    );
    await settingsDataSource.saveSettings(reminder);

    await dataSource.recordAttempt(DateTime(2026, 10, 5, 12));
    await settingsDataSource.saveSettings(reminder);

    final reloaded = await settingsDataSource.getSettings();
    expect(reloaded.dailyReminderEnabled, isFalse);
    expect(reloaded.dailyReminderHour, 9);
    expect(reloaded.dailyReminderMinute, 30);
    expect(dataSource.getState().attempts, 1);
  });
}

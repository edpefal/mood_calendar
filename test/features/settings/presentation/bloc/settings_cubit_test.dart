import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/logging/app_logger.dart';
import 'package:mood_calendar/core/settings/domain/entities/app_settings.dart';
import 'package:mood_calendar/core/settings/domain/repositories/app_settings_repository.dart';
import 'package:mood_calendar/features/settings/presentation/bloc/settings_cubit.dart';

void main() {
  late _FakeSettingsRepository repository;
  late List<String> calls;
  late bool failScheduling;

  SettingsCubit buildCubit() => SettingsCubit(
        settingsRepository: repository,
        scheduleReminder: () async {
          calls.add('schedule');
          if (failScheduling) throw StateError('schedule failed');
        },
        cancelReminder: () async => calls.add('cancel'),
        loadAppVersion: () async => '1.8.3 (28)',
        logger: _SilentLogger(),
      );

  setUp(() {
    repository = _FakeSettingsRepository(
      const AppSettings(
        dailyReminderEnabled: true,
        dailyReminderHour: 18,
        dailyReminderMinute: 0,
      ),
    );
    calls = [];
    failScheduling = false;
  });

  test('load exposes the saved settings and the app version', () async {
    final cubit = buildCubit();
    await cubit.load();

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.remindersEnabled, isTrue);
    expect(cubit.state.reminderTime, const TimeOfDay(hour: 18, minute: 0));
    expect(cubit.state.appVersion, '1.8.3 (28)');
  });

  test('turning reminders off saves and cancels the notification', () async {
    final cubit = buildCubit();
    await cubit.load();

    await cubit.setRemindersEnabled(false);

    expect(cubit.state.remindersEnabled, isFalse);
    expect(repository.saved.dailyReminderEnabled, isFalse);
    expect(calls, ['cancel']);
  });

  test('turning reminders on saves and schedules the notification', () async {
    repository.saved = repository.saved.copyWith(dailyReminderEnabled: false);
    final cubit = buildCubit();
    await cubit.load();

    await cubit.setRemindersEnabled(true);

    expect(repository.saved.dailyReminderEnabled, isTrue);
    expect(calls, ['schedule']);
  });

  test('changing the time saves it and reschedules', () async {
    final cubit = buildCubit();
    await cubit.load();

    await cubit.setReminderTime(const TimeOfDay(hour: 7, minute: 30));

    expect(cubit.state.reminderTime, const TimeOfDay(hour: 7, minute: 30));
    expect(repository.saved.dailyReminderHour, 7);
    expect(repository.saved.dailyReminderMinute, 30);
    expect(calls, ['schedule']);
  });

  test('rapid changes run in order and keep every change', () async {
    final cubit = buildCubit();
    await cubit.load();

    final first = cubit.setRemindersEnabled(false);
    final second = cubit.setRemindersEnabled(true);
    final third = cubit.setReminderTime(const TimeOfDay(hour: 9, minute: 15));
    await Future.wait([first, second, third]);

    expect(calls, ['cancel', 'schedule', 'schedule']);
    expect(repository.saved.dailyReminderEnabled, isTrue);
    expect(repository.saved.dailyReminderHour, 9);
    expect(repository.saved.dailyReminderMinute, 15);
    expect(cubit.state.remindersEnabled, isTrue);
    expect(cubit.state.reminderTime, const TimeOfDay(hour: 9, minute: 15));
  });

  test('a failed save reverts to the last saved value and reports it',
      () async {
    final cubit = buildCubit();
    await cubit.load();
    repository.failSaves = true;

    await cubit.setRemindersEnabled(false);

    expect(cubit.state.remindersEnabled, isTrue);
    expect(cubit.state.saveFailureCount, 1);
    expect(repository.saved.dailyReminderEnabled, isTrue);
    expect(calls, isEmpty);
  });

  test('a failed scheduling rolls back the saved value', () async {
    final cubit = buildCubit();
    await cubit.load();
    failScheduling = true;

    await cubit.setReminderTime(const TimeOfDay(hour: 7, minute: 30));

    expect(cubit.state.reminderTime, const TimeOfDay(hour: 18, minute: 0));
    expect(repository.saved.dailyReminderHour, 18);
    expect(cubit.state.saveFailureCount, 1);
  });

  test('a failure does not block later changes', () async {
    final cubit = buildCubit();
    await cubit.load();
    repository.failSaves = true;
    await cubit.setRemindersEnabled(false);
    repository.failSaves = false;

    await cubit.setRemindersEnabled(false);

    expect(cubit.state.remindersEnabled, isFalse);
    expect(repository.saved.dailyReminderEnabled, isFalse);
  });
}

class _FakeSettingsRepository implements AppSettingsRepository {
  _FakeSettingsRepository(this.saved);

  AppSettings saved;
  bool failSaves = false;

  @override
  Future<AppSettings> getSettings() async => saved;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    if (failSaves) throw StateError('save failed');
    saved = settings;
  }
}

class _SilentLogger implements AppLogger {
  @override
  void debug(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {}

  @override
  void error(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {}
}

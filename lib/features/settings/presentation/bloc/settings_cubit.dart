import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/settings/domain/entities/app_settings.dart';
import '../../../../core/settings/domain/repositories/app_settings_repository.dart';
import 'settings_state.dart';

/// Returns the app version already formatted for display, e.g. `1.8.3 (28)`.
typedef AppVersionLoader = Future<String> Function();

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required AppSettingsRepository settingsRepository,
    required Future<void> Function() scheduleReminder,
    required Future<void> Function() cancelReminder,
    required AppVersionLoader loadAppVersion,
    required AppLogger logger,
  })  : _settingsRepository = settingsRepository,
        _scheduleReminder = scheduleReminder,
        _cancelReminder = cancelReminder,
        _loadAppVersion = loadAppVersion,
        _logger = logger,
        super(const SettingsState());

  final AppSettingsRepository _settingsRepository;
  final Future<void> Function() _scheduleReminder;
  final Future<void> Function() _cancelReminder;
  final AppVersionLoader _loadAppVersion;
  final AppLogger _logger;

  /// Last settings known to be saved; changes that fail revert to this.
  AppSettings _persisted = AppSettings.defaults;

  /// Saves run one after another so quick consecutive changes never
  /// interleave their writes and (re)scheduling.
  Future<void> _queue = Future.value();

  Future<void> load() async {
    _persisted = await _settingsRepository.getSettings();
    if (isClosed) return;
    emit(_stateFrom(_persisted).copyWith(isLoading: false));

    // Secondary info: it must never keep the settings from showing.
    try {
      final version = await _loadAppVersion();
      if (isClosed) return;
      emit(state.copyWith(appVersion: version));
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to read the app version',
        tag: 'Settings',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> setRemindersEnabled(bool enabled) {
    emit(state.copyWith(remindersEnabled: enabled));
    return _enqueue(
        (current) => current.copyWith(dailyReminderEnabled: enabled));
  }

  Future<void> setReminderTime(TimeOfDay time) {
    emit(state.copyWith(reminderTime: time));
    return _enqueue(
      (current) => current.copyWith(
        dailyReminderHour: time.hour,
        dailyReminderMinute: time.minute,
      ),
    );
  }

  Future<void> _enqueue(AppSettings Function(AppSettings) change) {
    final run = _queue.then((_) => _apply(change));
    _queue = run;
    return run;
  }

  Future<void> _apply(AppSettings Function(AppSettings) change) async {
    // Applied to the latest saved values, not to those at the time of the
    // tap, so a queued change never undoes an earlier one.
    final previous = _persisted;
    final next = change(previous);
    try {
      await _settingsRepository.saveSettings(next);
      _persisted = next;
      if (next.dailyReminderEnabled) {
        await _scheduleReminder();
      } else {
        await _cancelReminder();
      }
      if (isClosed) return;
      emit(_stateFrom(next).copyWith(
        isLoading: false,
        appVersion: state.appVersion,
        saveFailureCount: state.saveFailureCount,
      ));
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to save reminder settings',
        tag: 'Settings',
        error: error,
        stackTrace: stackTrace,
      );
      await _restore(previous);
      if (isClosed) return;
      emit(_stateFrom(previous).copyWith(
        isLoading: false,
        appVersion: state.appVersion,
        saveFailureCount: state.saveFailureCount + 1,
      ));
    }
  }

  Future<void> _restore(AppSettings previous) async {
    try {
      await _settingsRepository.saveSettings(previous);
      _persisted = previous;
    } catch (_) {
      // Best effort: the original failure is already reported.
    }
  }

  SettingsState _stateFrom(AppSettings settings) {
    return state.copyWith(
      remindersEnabled: settings.dailyReminderEnabled,
      reminderTime: TimeOfDay(
        hour: settings.dailyReminderHour,
        minute: settings.dailyReminderMinute,
      ),
    );
  }
}

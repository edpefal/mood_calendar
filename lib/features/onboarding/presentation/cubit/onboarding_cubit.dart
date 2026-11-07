import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/telemetry/app_telemetry.dart';
import '../../../../core/telemetry/app_telemetry_events.dart';
import '../../../mood/domain/entities/mood_entry.dart';
import 'onboarding_state.dart';

/// Drives the four first-run steps (see the `onboarding` spec). Every effect
/// (saving settings, the OS permission, saving the first mood) is injected so
/// the flow can be tested without plugins.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    required Future<void> Function(int hour, int minute) saveReminderTime,
    required Future<bool> Function() requestNotificationPermission,
    required Future<void> Function(bool enabled) setReminderEnabled,
    required Future<bool> Function(MoodEntry entry) saveFirstEntry,
    required Future<void> Function() markCompleted,
    required AppTelemetry telemetry,
    DateTime Function()? now,
  })  : _saveReminderTime = saveReminderTime,
        _requestNotificationPermission = requestNotificationPermission,
        _setReminderEnabled = setReminderEnabled,
        _saveFirstEntry = saveFirstEntry,
        _markCompleted = markCompleted,
        _telemetry = telemetry,
        _now = now ?? DateTime.now,
        super(const OnboardingState());

  static const int stepCount = 4;

  final Future<void> Function(int hour, int minute) _saveReminderTime;
  final Future<bool> Function() _requestNotificationPermission;
  final Future<void> Function(bool enabled) _setReminderEnabled;
  final Future<bool> Function(MoodEntry entry) _saveFirstEntry;
  final Future<void> Function() _markCompleted;
  final AppTelemetry _telemetry;
  final DateTime Function() _now;

  void getStarted() => emit(state.copyWith(step: 2));

  /// Android back gesture: one step back; false when there is none.
  bool back() {
    if (state.step <= 1 || state.saved) return false;
    emit(state.copyWith(step: state.step - 1));
    return true;
  }

  void selectSuggestion(ReminderSuggestion suggestion) {
    emit(state.copyWith(
      suggestion: suggestion,
      hour: suggestion.hour,
      minute: suggestion.minute,
    ));
  }

  /// The wheel was moved by hand: no suggestion matches anymore.
  void setTime(int hour, int minute) {
    if (hour == state.hour && minute == state.minute) return;
    emit(state.copyWith(suggestion: null, hour: hour, minute: minute));
  }

  Future<void> continueFromTime() async {
    await _guarded('save_reminder_time', () {
      return _saveReminderTime(state.hour, state.minute);
    });
    emit(state.copyWith(step: 3));
  }

  /// "Turn on reminder": asks the OS and enables the reminder only if granted.
  Future<void> turnOnReminder() async {
    var granted = false;
    await _guarded('request_notification_permission', () async {
      granted = await _requestNotificationPermission();
    });
    await _guarded('set_reminder', () => _setReminderEnabled(granted));
    emit(state.copyWith(step: 4));
  }

  /// "Not now": no OS dialog, reminder off.
  Future<void> notNow() async {
    await _guarded('set_reminder', () => _setReminderEnabled(false));
    emit(state.copyWith(step: 4));
  }

  /// The reminder is a convenience: if the system refuses to schedule it, the
  /// user must still get to log their first day (the failure is reported).
  Future<void> _guarded(String step, Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stackTrace) {
      _telemetry.recordError(
        'onboarding_reminder_failed',
        reason: step,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// "Skip" (steps 1 to 3). The first step leaves the onboarding; the others
  /// go straight to logging the first day. The reminder stays off either way:
  /// the permission was never asked.
  Future<void> skip() async {
    final step = state.step;
    _telemetry.trackEvent(
      AppTelemetryEvents.onboardingSkipped,
      properties: {'step': step},
    );
    await _guarded('set_reminder', () => _setReminderEnabled(false));
    if (step == 1) {
      await _markCompleted();
      emit(state.copyWith(outcome: OnboardingOutcome.skipped));
      return;
    }
    emit(state.copyWith(step: 4));
  }

  void selectMood(String moodId) => emit(state.copyWith(moodId: moodId));

  void setNote(String note) => emit(state.copyWith(note: note));

  /// "Save my first day": saves today's entry like the Log does.
  Future<void> saveFirstDay({
    required String assetPath,
    required int intensity,
  }) async {
    if (state.saving || state.saved) return;
    emit(state.copyWith(saving: true));
    final today = _now();
    final note = state.note.trim();
    final saved = await _saveFirstEntry(
      MoodEntry(
        date: DateTime(today.year, today.month, today.day),
        mood: assetPath,
        note: note.isEmpty ? null : state.note,
        intensity: intensity,
      ),
    );
    if (saved) {
      emit(state.copyWith(saving: false, saved: true));
    } else {
      emit(state.copyWith(
        saving: false,
        saveFailureCount: state.saveFailureCount + 1,
      ));
    }
  }

  /// "Continue" on the confirmation: the onboarding is done for good.
  Future<void> finish() async {
    await _markCompleted();
    _telemetry.trackEvent(AppTelemetryEvents.onboardingCompleted);
    emit(state.copyWith(outcome: OnboardingOutcome.completed));
  }
}

import 'package:equatable/equatable.dart';

/// Suggested check-in times of step 2.
enum ReminderSuggestion {
  morning(9, 0),
  afternoon(14, 0),
  night(20, 0);

  const ReminderSuggestion(this.hour, this.minute);
  final int hour;
  final int minute;
}

/// How the onboarding ended.
enum OnboardingOutcome {
  /// "Skip" on the first step.
  skipped,

  /// The first day was logged and the confirmation dismissed.
  completed,
}

class OnboardingState extends Equatable {
  const OnboardingState({
    this.step = 1,
    this.suggestion = ReminderSuggestion.night,
    this.hour = 20,
    this.minute = 0,
    this.moodId,
    this.note = '',
    this.saving = false,
    this.saved = false,
    this.saveFailureCount = 0,
    this.outcome,
  });

  /// 1 to 4: welcome, reminder time, notification permission, first log.
  final int step;

  /// The chosen suggestion; null once the wheel was moved by hand.
  final ReminderSuggestion? suggestion;
  final int hour;
  final int minute;

  /// Step 4: the mood picked (its id) and the optional note.
  final String? moodId;
  final String note;
  final bool saving;

  /// The first day was saved: the confirmation is on screen.
  final bool saved;
  final int saveFailureCount;
  final OnboardingOutcome? outcome;

  OnboardingState copyWith({
    int? step,
    Object? suggestion = _keep,
    int? hour,
    int? minute,
    String? moodId,
    String? note,
    bool? saving,
    bool? saved,
    int? saveFailureCount,
    OnboardingOutcome? outcome,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      suggestion: identical(suggestion, _keep)
          ? this.suggestion
          : suggestion as ReminderSuggestion?,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      moodId: moodId ?? this.moodId,
      note: note ?? this.note,
      saving: saving ?? this.saving,
      saved: saved ?? this.saved,
      saveFailureCount: saveFailureCount ?? this.saveFailureCount,
      outcome: outcome ?? this.outcome,
    );
  }

  static const Object _keep = Object();

  @override
  List<Object?> get props => [
        step,
        suggestion,
        hour,
        minute,
        moodId,
        note,
        saving,
        saved,
        saveFailureCount,
        outcome,
      ];
}

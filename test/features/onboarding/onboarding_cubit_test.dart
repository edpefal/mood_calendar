import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:mood_calendar/features/onboarding/presentation/cubit/onboarding_state.dart';

import '../../support/app_harness.dart';

void main() {
  late List<String> calls;
  late bool permissionGranted;
  late bool saveSucceeds;
  late MoodEntry? savedEntry;
  late RecordingTelemetry telemetry;
  late bool schedulingFails;

  OnboardingCubit build() => OnboardingCubit(
        saveReminderTime: (h, m) async => calls.add('time:$h:$m'),
        requestNotificationPermission: () async {
          calls.add('permission');
          return permissionGranted;
        },
        setReminderEnabled: (enabled) async {
          calls.add('enabled:$enabled');
          if (schedulingFails) {
            throw StateError('exact_alarms_not_permitted');
          }
        },
        saveFirstEntry: (entry) async {
          savedEntry = entry;
          return saveSucceeds;
        },
        markCompleted: () async => calls.add('completed'),
        telemetry: telemetry,
        now: () => DateTime(2026, 11, 5, 21, 30),
      );

  setUp(() {
    calls = [];
    permissionGranted = true;
    saveSucceeds = true;
    savedEntry = null;
    telemetry = RecordingTelemetry();
    schedulingFails = false;
  });

  test('starts on the welcome step with Night suggested', () {
    final state = build().state;

    expect(state.step, 1);
    expect(state.suggestion, ReminderSuggestion.night);
    expect((state.hour, state.minute), (20, 0));
  });

  group('reminder time', () {
    test('a suggestion moves the wheel to its time', () {
      final cubit = build()..selectSuggestion(ReminderSuggestion.morning);

      expect(cubit.state.suggestion, ReminderSuggestion.morning);
      expect((cubit.state.hour, cubit.state.minute), (9, 0));
    });

    test('moving the wheel clears the suggestion', () {
      final cubit = build()..setTime(21, 30);

      expect(cubit.state.suggestion, isNull);
      expect((cubit.state.hour, cubit.state.minute), (21, 30));
    });

    test('Continue saves the chosen time and goes to the permission step',
        () async {
      final cubit = build()..setTime(21, 30);

      await cubit.continueFromTime();

      expect(calls, ['time:21:30']);
      expect(cubit.state.step, 3);
    });
  });

  group('notification permission', () {
    test('granted: the reminder is turned on', () async {
      final cubit = build();

      await cubit.turnOnReminder();

      expect(calls, ['permission', 'enabled:true']);
      expect(cubit.state.step, 4);
    });

    test('denied: the reminder stays off and the flow goes on', () async {
      permissionGranted = false;
      final cubit = build();

      await cubit.turnOnReminder();

      expect(calls, ['permission', 'enabled:false']);
      expect(cubit.state.step, 4);
    });

    test('a failure scheduling the reminder never traps the user on the step',
        () async {
      schedulingFails = true;
      final cubit = build();

      await cubit.turnOnReminder();

      expect(cubit.state.step, 4);
    });

    test('"Not now" never asks the system', () async {
      final cubit = build();

      await cubit.notNow();

      expect(calls, ['enabled:false']);
      expect(cubit.state.step, 4);
    });
  });

  group('skip', () {
    test('on the welcome step leaves the onboarding for good', () async {
      final cubit = build();

      await cubit.skip();

      expect(cubit.state.outcome, OnboardingOutcome.skipped);
      expect(calls, ['enabled:false', 'completed']);
      expect(telemetry.events.single.name, 'onboarding_skipped');
      expect(telemetry.events.single.properties, {'step': 1});
    });

    test('on the time step jumps to the first log, reminder off', () async {
      final cubit = build()..getStarted();

      await cubit.skip();

      expect(cubit.state.step, 4);
      expect(cubit.state.outcome, isNull);
      expect(calls, ['enabled:false']);
      expect(telemetry.events.single.properties, {'step': 2});
    });

    test('on the permission step jumps to the first log without asking',
        () async {
      final cubit = build()..getStarted();
      await cubit.continueFromTime();
      calls.clear();

      await cubit.skip();

      expect(cubit.state.step, 4);
      expect(calls, ['enabled:false']);
      expect(telemetry.events.single.properties, {'step': 3});
    });
  });

  group('first log', () {
    test('saves today with the picked mood and the note', () async {
      final cubit = build()
        ..selectMood('calm')
        ..setNote('  a quiet day ');

      await cubit.saveFirstDay(assetPath: 'assets/icon/calm.svg', intensity: 2);

      expect(savedEntry?.date, DateTime(2026, 11, 5));
      expect(savedEntry?.mood, 'assets/icon/calm.svg');
      expect(savedEntry?.note, '  a quiet day ');
      expect(cubit.state.saved, isTrue);
    });

    test('an empty note is saved as no note', () async {
      final cubit = build()..selectMood('calm');

      await cubit.saveFirstDay(assetPath: 'assets/icon/calm.svg', intensity: 2);

      expect(savedEntry?.note, isNull);
    });

    test('a failed save stays on the step and reports it', () async {
      saveSucceeds = false;
      final cubit = build()..selectMood('calm');

      await cubit.saveFirstDay(assetPath: 'assets/icon/calm.svg', intensity: 2);

      expect(cubit.state.saved, isFalse);
      expect(cubit.state.saving, isFalse);
      expect(cubit.state.saveFailureCount, 1);
    });

    test('Continue marks the onboarding completed and reports it', () async {
      final cubit = build()..selectMood('calm');
      await cubit.saveFirstDay(assetPath: 'assets/icon/calm.svg', intensity: 2);

      await cubit.finish();

      expect(cubit.state.outcome, OnboardingOutcome.completed);
      expect(calls, ['completed']);
      expect(telemetry.events.single.name, 'onboarding_completed');
      expect(telemetry.events.single.properties, isEmpty);
    });
  });

  group('back', () {
    test('goes one step back, never from the first step or after saving',
        () async {
      final cubit = build();
      expect(cubit.back(), isFalse);

      cubit.getStarted();
      expect(cubit.back(), isTrue);
      expect(cubit.state.step, 1);

      await cubit.skip(); // exits from step 1; state.step stays 1
      cubit.getStarted();
      await cubit.skip();
      cubit.selectMood('calm');
      await cubit.saveFirstDay(assetPath: 'assets/icon/calm.svg', intensity: 2);
      expect(cubit.back(), isFalse);
    });
  });
}

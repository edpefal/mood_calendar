import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/localization/app_strings.dart';
import 'package:mood_calendar/core/widgets/gradient_pill_button.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:mood_calendar/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:mood_calendar/features/onboarding/presentation/screens/onboarding_flow.dart';

import '../../support/app_harness.dart';

void main() {
  final strings = AppStrings.forLocale(const Locale('en'));

  late List<String> calls;
  late bool permissionGranted;
  late MoodEntry? savedEntry;
  late List<OnboardingOutcome> finished;
  late RecordingTelemetry telemetry;

  OnboardingCubit buildCubit() => OnboardingCubit(
        saveReminderTime: (h, m) async => calls.add('time:$h:$m'),
        requestNotificationPermission: () async {
          calls.add('permission');
          return permissionGranted;
        },
        setReminderEnabled: (enabled) async => calls.add('enabled:$enabled'),
        saveFirstEntry: (entry) async {
          savedEntry = entry;
          return true;
        },
        markCompleted: () async => calls.add('completed'),
        telemetry: telemetry,
        now: () => DateTime(2026, 11, 5, 21),
      );

  setUp(() {
    calls = [];
    permissionGranted = true;
    savedEntry = null;
    finished = [];
    telemetry = RecordingTelemetry();
  });

  Future<void> pumpFlow(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    double? textScale,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    if (textScale != null) {
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    }
    await tester.pumpWidget(
      buildTestApp(
        locale: locale,
        home: OnboardingFlow(cubit: buildCubit(), onFinished: finished.add),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  bool saveEnabled(WidgetTester tester) => tester
      .widget<GradientPillButton>(find.byType(GradientPillButton))
      .enabled;

  group('step 1, welcome', () {
    testWidgets('shows the title, the preview and Get started', (tester) async {
      await pumpFlow(tester);

      expect(find.text(strings.onboardingWelcomeTitle), findsOneWidget);
      expect(find.text(strings.onboardingWelcomeBody), findsOneWidget);
      expect(find.text(strings.onboardingGetStarted), findsOneWidget);
      expect(find.text(strings.onboardingSkip), findsOneWidget);
      expect(
        find.bySemanticsLabel(strings.onboardingCalendarPreviewSemantics),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(strings.onboardingStepLabel(1)),
        findsOneWidget,
      );
    });

    testWidgets('Skip leaves the onboarding and marks it done', (tester) async {
      await pumpFlow(tester);

      await tapText(tester, strings.onboardingSkip);

      expect(finished, [OnboardingOutcome.skipped]);
      expect(calls, ['enabled:false', 'completed']);
    });

    testWidgets('speaks the device language', (tester) async {
      await pumpFlow(tester, locale: const Locale('es'));

      expect(find.text('Empezar'), findsOneWidget);
      expect(find.text('Omitir'), findsOneWidget);
      expect(find.bySemanticsLabel('Paso 1 de 4'), findsOneWidget);
    });
  });

  group('step 2, reminder time', () {
    Future<void> toTimeStep(WidgetTester tester) async {
      await pumpFlow(tester);
      await tapText(tester, strings.onboardingGetStarted);
    }

    testWidgets('Night is suggested and the wheel starts at 8:00 PM',
        (tester) async {
      await toTimeStep(tester);

      expect(find.text(strings.onboardingTimeTitle), findsOneWidget);
      expect(find.bySemanticsLabel(strings.onboardingStepLabel(2)),
          findsOneWidget);
      expect(
        find.bySemanticsLabel(
          strings.onboardingTimeSuggestionSemantics('Night', '8:00 PM'),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(strings.onboardingTimePickerSemantics('8:00 PM')),
        findsOneWidget,
      );
    });

    testWidgets('a suggestion moves the time and Continue saves it',
        (tester) async {
      await toTimeStep(tester);

      await tapText(tester, 'Morning');
      await tapText(tester, strings.continueLabel);

      expect(calls, ['time:9:0']);
      expect(find.text(strings.onboardingReminderTitle), findsOneWidget);
    });

    testWidgets('Skip jumps to the first log without touching the time',
        (tester) async {
      await toTimeStep(tester);

      await tapText(tester, strings.onboardingSkip);

      expect(find.text(strings.onboardingLogTitle), findsOneWidget);
      expect(calls, ['enabled:false']);
      expect(telemetry.events.single.properties, {'step': 2});
    });
  });

  group('step 3, permission', () {
    Future<void> toPermissionStep(WidgetTester tester) async {
      await pumpFlow(tester);
      await tapText(tester, strings.onboardingGetStarted);
      await tapText(tester, strings.continueLabel);
    }

    testWidgets('Turn on reminder asks the system and goes on', (tester) async {
      await toPermissionStep(tester);
      expect(calls, ['time:20:0']);

      await tapText(tester, strings.onboardingTurnOnReminder);

      expect(calls, ['time:20:0', 'permission', 'enabled:true']);
      expect(find.text(strings.onboardingLogTitle), findsOneWidget);
    });

    testWidgets('a denied permission still goes on, reminder off',
        (tester) async {
      permissionGranted = false;
      await toPermissionStep(tester);

      await tapText(tester, strings.onboardingTurnOnReminder);

      expect(calls.last, 'enabled:false');
      expect(find.text(strings.onboardingLogTitle), findsOneWidget);
    });

    testWidgets('Not now never asks the system', (tester) async {
      await toPermissionStep(tester);

      await tapText(tester, strings.onboardingNotNow);

      expect(calls, ['time:20:0', 'enabled:false']);
      expect(find.text(strings.onboardingLogTitle), findsOneWidget);
    });
  });

  group('step 4, first log', () {
    Future<void> toFirstLog(WidgetTester tester) async {
      await pumpFlow(tester);
      await tapText(tester, strings.onboardingGetStarted);
      await tapText(tester, strings.continueLabel);
      await tapText(tester, strings.onboardingNotNow);
    }

    testWidgets('offers only the base moods and nothing is selected',
        (tester) async {
      await toFirstLog(tester);

      expect(find.text('Happy'), findsOneWidget);
      expect(find.text('Sick'), findsOneWidget);
      // Premium moods are not offered, locked or otherwise.
      expect(find.text('Laughing'), findsNothing);
      expect(find.text('Brave'), findsNothing);
      expect(find.byIcon(Icons.lock_rounded), findsNothing);
      expect(saveEnabled(tester), isFalse);
    });

    testWidgets('has no Skip', (tester) async {
      await toFirstLog(tester);

      expect(find.text(strings.onboardingSkip), findsNothing);
      expect(find.bySemanticsLabel(strings.onboardingStepLabel(4)),
          findsOneWidget);
    });

    testWidgets('picking a mood enables Save, which logs today and confirms',
        (tester) async {
      await toFirstLog(tester);

      await tapText(tester, 'Calm');
      expect(saveEnabled(tester), isTrue);
      await tapText(tester, strings.onboardingSaveFirstDay);

      expect(savedEntry?.date, DateTime(2026, 11, 5));
      expect(savedEntry?.mood, 'assets/icon/calm.svg');
      expect(savedEntry?.note, isNull);
      expect(find.text(strings.onboardingDayOneTitle), findsOneWidget);
      expect(find.text('Today: Calm'), findsOneWidget);
      expect(finished, isEmpty);
    });

    testWidgets('the optional note is saved with the entry', (tester) async {
      await toFirstLog(tester);
      await tapText(tester, 'Calm');

      await tapText(tester, strings.notePromptEmpty);
      await tester.enterText(find.byType(TextField), 'a quiet start');
      await tester.tap(find.text(strings.noteSheetDoneButton));
      await tester.pumpAndSettle();
      await tapText(tester, strings.onboardingSaveFirstDay);

      expect(savedEntry?.note, 'a quiet start');
    });

    testWidgets('Continue after the confirmation finishes the onboarding',
        (tester) async {
      await toFirstLog(tester);
      await tapText(tester, 'Calm');
      await tapText(tester, strings.onboardingSaveFirstDay);

      await tapText(tester, strings.continueLabel);

      expect(finished, [OnboardingOutcome.completed]);
      expect(calls.last, 'completed');
      expect(telemetry.events.last.name, 'onboarding_completed');
    });
  });

  testWidgets('large system text keeps the main button reachable',
      (tester) async {
    await pumpFlow(tester, textScale: 2);

    final button = find.text(strings.onboardingGetStarted);
    expect(button, findsOneWidget);
    final rect = tester.getRect(button);
    expect(rect.bottom, lessThanOrEqualTo(844));
    expect(rect.top, greaterThanOrEqualTo(0));
  });
}

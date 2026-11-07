import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/navigation/app_root.dart';
import 'package:mood_calendar/features/onboarding/domain/onboarding_gate.dart';
import 'package:mood_calendar/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:mood_calendar/features/purchases/domain/entities/subscription_plan.dart';
import 'package:mood_calendar/features/purchases/domain/entities/subscription_status.dart';

import '../../support/app_harness.dart';
import '../../support/fake_mood_entitlements_repository.dart';

void main() {
  late ValueChanged<OnboardingOutcome> finishOnboarding;

  Widget root({required bool showOnboarding}) => AppRoot(
        gate: OnboardingGate(
          isCompleted: () => !showOnboarding,
          hasEntries: () => false,
        ),
        shell: const Scaffold(body: Text('the shell')),
        onboardingBuilder: (onFinished) {
          finishOnboarding = onFinished;
          return const Scaffold(body: Text('the onboarding'));
        },
      );

  Future<void> pump(
    WidgetTester tester, {
    required bool showOnboarding,
    FakeMoodEntitlementsRepository? entitlements,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      buildTestApp(
        entitlements: entitlements,
        home: root(showOnboarding: showOnboarding),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('opens on the onboarding on a brand-new install', (tester) async {
    await pump(tester, showOnboarding: true);

    expect(find.text('the onboarding'), findsOneWidget);
    expect(find.text('the shell'), findsNothing);
  });

  testWidgets('opens on the shell otherwise, with no subscription sheet',
      (tester) async {
    await pump(tester, showOnboarding: false);

    expect(find.text('the shell'), findsOneWidget);
    expect(find.text('Understand how you feel'), findsNothing);
  });

  testWidgets('finishing the first day shows the shell and offers Premium once',
      (tester) async {
    await pump(tester, showOnboarding: true);

    finishOnboarding(OnboardingOutcome.completed);
    await tester.pumpAndSettle();

    expect(find.text('the onboarding'), findsNothing);
    expect(find.text('Understand how you feel'), findsOneWidget);

    // Dismissed: it stays closed.
    Navigator.of(tester.element(find.text('the shell')), rootNavigator: true)
        .pop();
    await tester.pumpAndSettle();
    expect(find.text('Understand how you feel'), findsNothing);
    expect(find.text('the shell'), findsOneWidget);

    finishOnboarding(OnboardingOutcome.completed);
    await tester.pumpAndSettle();
    expect(find.text('Understand how you feel'), findsNothing);
  });

  testWidgets('the sheet is tracked with the onboarding source',
      (tester) async {
    final telemetry = RecordingTelemetry();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      buildTestApp(telemetry: telemetry, home: root(showOnboarding: true)),
    );
    await tester.pumpAndSettle();

    finishOnboarding(OnboardingOutcome.completed);
    await tester.pumpAndSettle();

    final opened = telemetry.events.where((e) => e.name == 'store_opened');
    expect(opened.single.properties, {'source': 'onboarding'});
  });

  testWidgets('a subscriber never sees the sheet', (tester) async {
    await pump(
      tester,
      showOnboarding: true,
      entitlements: FakeMoodEntitlementsRepository(
        subscription: const SubscriptionStatus(
          isActive: true,
          plan: SubscriptionPlanType.annual,
        ),
      ),
    );

    finishOnboarding(OnboardingOutcome.completed);
    await tester.pumpAndSettle();

    expect(find.text('the shell'), findsOneWidget);
    expect(find.text('Understand how you feel'), findsNothing);
  });

  testWidgets('skipping the first step shows the shell without the sheet',
      (tester) async {
    await pump(tester, showOnboarding: true);

    finishOnboarding(OnboardingOutcome.skipped);
    await tester.pumpAndSettle();

    expect(find.text('the shell'), findsOneWidget);
    expect(find.text('Understand how you feel'), findsNothing);
  });
}

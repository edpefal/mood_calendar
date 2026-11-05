import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/localization/app_strings.dart';
import 'package:mood_calendar/features/mood/domain/services/mood_definition_resolver.dart';
import 'package:mood_calendar/features/purchases/domain/entities/purchase_failure.dart';
import 'package:mood_calendar/features/purchases/domain/entities/subscription_plan.dart';
import 'package:mood_calendar/features/purchases/domain/entities/subscription_status.dart';
import 'package:mood_calendar/features/purchases/presentation/bloc/purchases_cubit.dart';
import 'package:mood_calendar/features/purchases/presentation/widgets/premium_sheet.dart';

import '../../../../support/app_harness.dart';
import '../../../../support/fake_mood_entitlements_repository.dart';

void main() {
  final strings = AppStrings.forLocale(const Locale('en'));
  final opened = <Uri>[];

  setUp(opened.clear);

  Future<void> pumpHost(
    WidgetTester tester,
    FakeMoodEntitlementsRepository repository, {
    Locale locale = const Locale('en'),
    String? mood,
    PremiumSource source = PremiumSource.lockedMood,
    RecordingTelemetry? telemetry,
    Size size = const Size(390, 2400),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Future<bool> openUrl(Uri url) async {
      opened.add(url);
      return true;
    }

    await tester.pumpWidget(
      buildTestApp(
        entitlements: repository,
        locale: locale,
        telemetry: telemetry ?? RecordingTelemetry(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showPremiumSheet(
                  context,
                  source: source,
                  mood: mood == null ? null : MoodDefinitionResolver.byId(mood),
                  openUrl: openUrl,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('content', () {
    testWidgets('shows the title, three benefits and no other promises',
        (tester) async {
      await pumpHost(tester, FakeMoodEntitlementsRepository());
      await openSheet(tester);

      expect(find.text(strings.paywallTitle), findsOneWidget);
      expect(find.text(strings.paywallBenefitInsights), findsOneWidget);
      expect(find.text(strings.paywallBenefitNotes), findsOneWidget);
      expect(
        find.text(
          strings.paywallBenefitMoods('Laughing', 'Confident', 'Brave'),
        ),
        findsOneWidget,
      );
      for (final banned in ['cloud', 'widget', 'theme', 'backup']) {
        expect(find.textContaining(banned, findRichText: true), findsNothing,
            reason: banned);
      }
    });

    testWidgets('shows the tapped mood as context', (tester) async {
      await pumpHost(tester, FakeMoodEntitlementsRepository(), mood: 'brave');
      await openSheet(tester);

      expect(find.text('Brave'), findsOneWidget);
    });

    testWidgets('from Settings there is no mood capsule', (tester) async {
      await pumpHost(
        tester,
        FakeMoodEntitlementsRepository(),
        source: PremiumSource.settings,
      );
      await openSheet(tester);

      expect(find.text('Brave'), findsNothing);
      expect(find.text(strings.paywallTitle), findsOneWidget);
    });

    testWidgets('the mood capsule follows the device language', (tester) async {
      await pumpHost(
        tester,
        FakeMoodEntitlementsRepository(),
        locale: const Locale('de'),
        mood: 'brave',
      );
      await openSheet(tester);

      expect(find.text('Mutig'), findsOneWidget);
    });

    testWidgets('the close button closes the sheet', (tester) async {
      await pumpHost(tester, FakeMoodEntitlementsRepository());
      await openSheet(tester);

      await tester.tap(find.byTooltip(strings.closeLabel));
      await tester.pumpAndSettle();

      expect(find.text(strings.paywallTitle), findsNothing);
    });

    testWidgets('a subscriber can never open it', (tester) async {
      await pumpHost(
        tester,
        FakeMoodEntitlementsRepository(
          subscription: const SubscriptionStatus(
            isActive: true,
            plan: SubscriptionPlanType.monthly,
          ),
        ),
      );
      // Let the subscription status reach the cubit before asking for the sheet.
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();

      await openSheet(tester);

      expect(find.text(strings.paywallTitle), findsNothing);
    });
  });

  group('loading plans', () {
    testWidgets('shows a retry button next to the load error', (tester) async {
      await pumpHost(
        tester,
        FakeMoodEntitlementsRepository(failCatalogLoads: 2),
      );
      await openSheet(tester);

      expect(find.text(strings.storeLoadError), findsOneWidget);
      expect(find.text(strings.storeRetry), findsOneWidget);
    });

    testWidgets('opening the sheet with an error retries once', (tester) async {
      final repository = FakeMoodEntitlementsRepository(failCatalogLoads: 1);
      await pumpHost(tester, repository);

      // The cubit starts with the sheet: its own load fails, the sheet's
      // retry on opening is the second request and recovers.
      await openSheet(tester);

      expect(repository.catalogLoadCount, 2);
      expect(find.text(strings.storeLoadError), findsNothing);
      expect(find.text(strings.annualPlanLabel), findsOneWidget);
    });

    testWidgets('a failed retry shows the error and the button again',
        (tester) async {
      final repository = FakeMoodEntitlementsRepository(failCatalogLoads: 3);
      await pumpHost(tester, repository);
      await openSheet(tester);
      expect(find.text(strings.storeLoadError), findsOneWidget);

      await tester.tap(find.text(strings.storeRetry));
      await tester.pumpAndSettle();

      expect(find.text(strings.storeLoadError), findsOneWidget);
      expect(find.text(strings.storeRetry), findsOneWidget);
    });

    testWidgets('a manual retry recovers the plans', (tester) async {
      final repository = FakeMoodEntitlementsRepository(failCatalogLoads: 2);
      await pumpHost(tester, repository);
      await openSheet(tester);

      await tester.tap(find.text(strings.storeRetry));
      await tester.pumpAndSettle();

      expect(find.text(strings.storeLoadError), findsNothing);
      expect(find.text(strings.annualPlanLabel), findsOneWidget);
    });

    testWidgets('shows a loading state while retrying', (tester) async {
      final repository = FakeMoodEntitlementsRepository(failCatalogLoads: 2);
      await pumpHost(tester, repository);
      await openSheet(tester);

      final gate = Completer<void>();
      repository.holdCatalogLoads = gate.future;
      await tester.tap(find.text(strings.storeRetry));
      await tester.pump();

      expect(find.text(strings.storeLoading), findsOneWidget);
      expect(find.text(strings.storeRetry), findsNothing);

      gate.complete();
      await tester.pumpAndSettle();
      expect(find.text(strings.annualPlanLabel), findsOneWidget);
    });

    testWidgets('loaded plans are kept when the sheet opens again',
        (tester) async {
      final repository = FakeMoodEntitlementsRepository();
      await pumpHost(tester, repository);
      await openSheet(tester);
      await tester.tap(find.byTooltip(strings.closeLabel));
      await tester.pumpAndSettle();

      await openSheet(tester);

      expect(repository.catalogLoadCount, 1);
    });
  });

  group('plans', () {
    testWidgets('shows the three plans with the store price', (tester) async {
      await pumpHost(tester, FakeMoodEntitlementsRepository());
      await openSheet(tester);

      expect(find.text(strings.annualPlanLabel), findsOneWidget);
      expect(find.text(strings.monthlyPlanLabel), findsOneWidget);
      expect(find.text(strings.weeklyPlanLabel), findsOneWidget);
      expect(find.text(r'$14.99 / year'), findsOneWidget);
      expect(find.text(r'$2.99 / month'), findsOneWidget);
      expect(find.text(r'$0.99 / week'), findsOneWidget);
    });

    testWidgets('the annual plan starts selected and marked best value',
        (tester) async {
      await pumpHost(tester, FakeMoodEntitlementsRepository());
      await openSheet(tester);

      expect(
        find.textContaining(strings.bestValueLabel),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
      expect(
        find.descendant(
          of: find
              .ancestor(
                of: find.text(strings.annualPlanLabel),
                matching: find.byType(Row),
              )
              .first,
          matching: find.byIcon(Icons.radio_button_checked),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the saving is recalculated from the store prices',
        (tester) async {
      await pumpHost(
        tester,
        FakeMoodEntitlementsRepository(plans: const [
          SubscriptionPlan(
            type: SubscriptionPlanType.annual,
            productId: 'premium_annual',
            displayPrice: '€20.00',
            price: 20,
            currencyCode: 'EUR',
          ),
          SubscriptionPlan(
            type: SubscriptionPlanType.monthly,
            productId: 'premium_monthly',
            displayPrice: '€4.00',
            price: 4,
            currencyCode: 'EUR',
          ),
        ]),
      );
      await openSheet(tester);

      expect(
        find.text(
          '${strings.bestValueLabel} · ${strings.savePercentLabel(58)}',
        ),
        findsOneWidget,
      );
      expect(find.text('€20.00 / year'), findsOneWidget);
    });

    testWidgets('tapping another plan selects it', (tester) async {
      await pumpHost(tester, FakeMoodEntitlementsRepository());
      await openSheet(tester);

      await tester.tap(find.text(strings.monthlyPlanLabel));
      await tester.pumpAndSettle();

      expect(find.text(strings.subscribeButtonLabel(r'$2.99')), findsOneWidget);
    });

    testWidgets('the price per cycle is the largest text of a card',
        (tester) async {
      await pumpHost(tester, FakeMoodEntitlementsRepository());
      await openSheet(tester);

      final price = tester.widget<Text>(find.text(r'$14.99 / year'));
      final label = tester.widget<Text>(find.text(strings.annualPlanLabel));
      expect(price.style!.fontSize!, greaterThan(label.style!.fontSize!));
    });
  });

  group('free trial', () {
    testWidgets('only the annual plan offers it, with the timeline',
        (tester) async {
      await pumpHost(tester, FakeMoodEntitlementsRepository());
      await openSheet(tester);

      expect(find.text(strings.startTrialButtonLabel), findsOneWidget);
      expect(find.text(strings.trialFreeLabel), findsOneWidget);
      expect(find.text(strings.trialTimelineToday), findsOneWidget);
      final firstCharge = DateTime.now().add(const Duration(days: 3));
      expect(
        find.text(
          strings.trialTimelineCharge(
            strings.formatFullDate(firstCharge),
            r'$14.99',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('Free for 3 days'),
        findsOneWidget,
      );
    });

    testWidgets('the monthly plan never mentions a trial', (tester) async {
      await pumpHost(tester, FakeMoodEntitlementsRepository());
      await openSheet(tester);

      await tester.tap(find.text(strings.monthlyPlanLabel));
      await tester.pumpAndSettle();

      expect(find.text(strings.startTrialButtonLabel), findsNothing);
      expect(find.text(strings.trialFreeLabel), findsNothing);
      expect(find.text(strings.trialTimelineToday), findsNothing);
      expect(find.textContaining('Free for 3 days'), findsNothing);
      expect(find.text(strings.subscribeButtonLabel(r'$2.99')), findsOneWidget);
    });

    testWidgets('the weekly plan never mentions a trial', (tester) async {
      await pumpHost(tester, FakeMoodEntitlementsRepository());
      await openSheet(tester);

      await tester.tap(find.text(strings.weeklyPlanLabel));
      await tester.pumpAndSettle();

      expect(find.text(strings.startTrialButtonLabel), findsNothing);
      expect(find.text(strings.subscribeButtonLabel(r'$0.99')), findsOneWidget);
    });

    testWidgets('a user who already used the trial never sees it',
        (tester) async {
      await pumpHost(
        tester,
        FakeMoodEntitlementsRepository(
          plans: [
            for (final plan in defaultTestPlans)
              SubscriptionPlan(
                type: plan.type,
                productId: plan.productId,
                displayPrice: plan.displayPrice,
                price: plan.price,
                currencyCode: plan.currencyCode,
              ),
          ],
        ),
      );
      await openSheet(tester);

      expect(find.text(strings.startTrialButtonLabel), findsNothing);
      expect(find.text(strings.trialTimelineToday), findsNothing);
      expect(
          find.text(strings.subscribeButtonLabel(r'$14.99')), findsOneWidget);
      expect(find.textContaining('3 days', findRichText: true), findsNothing);
    });

    testWidgets('promises no reminder before the trial ends', (tester) async {
      await pumpHost(tester, FakeMoodEntitlementsRepository());
      await openSheet(tester);

      for (final word in ['remind', 'notif', 'before your trial']) {
        expect(find.textContaining(word, findRichText: true), findsNothing,
            reason: word);
      }
    });
  });

  group('legal', () {
    testWidgets('states price, auto-renewal and where to cancel',
        (tester) async {
      await pumpHost(tester, FakeMoodEntitlementsRepository());
      await openSheet(tester);
      await tester.tap(find.text(strings.monthlyPlanLabel));
      await tester.pumpAndSettle();

      expect(
        find.textContaining(r'$2.99 per month. Renews automatically'),
        findsOneWidget,
      );
      expect(find.textContaining('subscription settings'), findsOneWidget);
    });

    testWidgets('opens the terms and the privacy policy', (tester) async {
      await pumpHost(tester, FakeMoodEntitlementsRepository());
      await openSheet(tester);

      await tester.tap(find.text(strings.termsLinkLabel));
      await tester.tap(find.text(strings.privacyLinkLabel));

      expect(opened, [
        Uri.parse('https://moodcalendar.app/terms/'),
        Uri.parse('https://moodcalendar.app/privacy/'),
      ]);
    });

    testWidgets('Spanish uses the Spanish pages', (tester) async {
      await pumpHost(
        tester,
        FakeMoodEntitlementsRepository(),
        locale: const Locale('es'),
      );
      await openSheet(tester);
      final es = AppStrings.forLocale(const Locale('es'));

      await tester.tap(find.text(es.termsLinkLabel));
      await tester.tap(find.text(es.privacyLinkLabel));

      expect(opened, [
        Uri.parse('https://moodcalendar.app/es/terms/'),
        Uri.parse('https://moodcalendar.app/es/privacy/'),
      ]);
    });
  });

  group('purchasing', () {
    testWidgets('subscribing unlocks premium and closes the sheet',
        (tester) async {
      final repository = FakeMoodEntitlementsRepository();
      await pumpHost(tester, repository);
      await openSheet(tester);

      await tester.tap(find.text(strings.startTrialButtonLabel));
      await tester.pumpAndSettle();

      expect(repository.purchasedPlans, [SubscriptionPlanType.annual]);
      expect(repository.isUnlocked('brave'), isTrue);
      expect(find.text(strings.paywallTitle), findsNothing);
      expect(find.text(strings.purchaseSuccessMessage), findsOneWidget);
    });

    testWidgets('the chosen plan is the one that is bought', (tester) async {
      final repository = FakeMoodEntitlementsRepository();
      await pumpHost(tester, repository);
      await openSheet(tester);

      await tester.tap(find.text(strings.weeklyPlanLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.subscribeButtonLabel(r'$0.99')));
      await tester.pumpAndSettle();

      expect(repository.purchasedPlans, [SubscriptionPlanType.weekly]);
    });

    testWidgets('a cancelled purchase keeps the sheet and the plans',
        (tester) async {
      final repository = FakeMoodEntitlementsRepository(
        failPurchaseWith: PurchaseFailureReason.cancelled,
      );
      await pumpHost(tester, repository);
      await openSheet(tester);

      await tester.tap(find.text(strings.startTrialButtonLabel));
      await tester.pumpAndSettle();

      expect(find.text(strings.purchaseCancelledMessage), findsOneWidget);
      expect(find.text(strings.paywallTitle), findsOneWidget);
      expect(repository.isUnlocked('brave'), isFalse);
      // It can be tried again.
      expect(find.text(strings.startTrialButtonLabel), findsOneWidget);
    });

    testWidgets('a network error is explained', (tester) async {
      final repository = FakeMoodEntitlementsRepository(
        failPurchaseWith: PurchaseFailureReason.network,
      );
      await pumpHost(tester, repository);
      await openSheet(tester);

      await tester.tap(find.text(strings.startTrialButtonLabel));
      await tester.pumpAndSettle();

      expect(find.text(strings.purchaseNetworkErrorMessage), findsOneWidget);
      expect(repository.isUnlocked('brave'), isFalse);
    });

    testWidgets('restoring from the sheet runs the restore', (tester) async {
      final repository = FakeMoodEntitlementsRepository(
        restorableMoodIds: {'brave'},
      );
      await pumpHost(tester, repository);
      await openSheet(tester);

      await tester.tap(find.text(strings.restorePurchasesButtonLabel));
      await tester.pumpAndSettle();

      expect(repository.restoreCount, 1);
      expect(find.text(strings.restoreSuccessMessage), findsOneWidget);
      expect(repository.isUnlocked('brave'), isTrue);
    });
  });

  group('analytics', () {
    testWidgets('opening from a locked mood reports locked_mood',
        (tester) async {
      final telemetry = RecordingTelemetry();
      await pumpHost(
        tester,
        FakeMoodEntitlementsRepository(),
        mood: 'brave',
        telemetry: telemetry,
      );
      await openSheet(tester);

      final opened = telemetry.events.where((e) => e.name == 'store_opened');
      expect(opened.single.properties, {'source': 'locked_mood'});
    });

    testWidgets('opening from Settings reports settings', (tester) async {
      final telemetry = RecordingTelemetry();
      await pumpHost(
        tester,
        FakeMoodEntitlementsRepository(),
        source: PremiumSource.settings,
        telemetry: telemetry,
      );
      await openSheet(tester);

      final opened = telemetry.events.where((e) => e.name == 'store_opened');
      expect(opened.single.properties, {'source': 'settings'});
    });

    testWidgets('no event carries a mood id', (tester) async {
      final telemetry = RecordingTelemetry();
      await pumpHost(
        tester,
        FakeMoodEntitlementsRepository(),
        mood: 'brave',
        telemetry: telemetry,
      );
      await openSheet(tester);
      await tester.tap(find.text(strings.startTrialButtonLabel));
      await tester.pumpAndSettle();

      for (final event in telemetry.events) {
        expect(event.properties.values.join(), isNot(contains('brave')),
            reason: event.name);
      }
    });
  });

  group('accessibility', () {
    for (final locale in AppStrings.supportedLocales) {
      testWidgets(
        'fits at 200% text in ${locale.languageCode} on a 390 pt screen',
        (tester) async {
          tester.platformDispatcher.textScaleFactorTestValue = 2;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await pumpHost(
            tester,
            FakeMoodEntitlementsRepository(),
            locale: locale,
            mood: 'brave',
            size: const Size(390, 844),
          );
          await openSheet(tester);

          expect(tester.takeException(), isNull);
          final es = AppStrings.forLocale(locale);
          expect(find.text(es.paywallTitle), findsOneWidget);
        },
      );
    }

    testWidgets('the plan cards are labelled buttons', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpHost(tester, FakeMoodEntitlementsRepository());
      await openSheet(tester);

      expect(
        find.bySemanticsLabel(
          strings.planCardSemanticLabel(
            strings.annualPlanLabel,
            r'$14.99 / year',
          ),
        ),
        findsOneWidget,
      );
      expect(find.byTooltip(strings.closeLabel), findsOneWidget);
      handle.dispose();
    });
  });
}

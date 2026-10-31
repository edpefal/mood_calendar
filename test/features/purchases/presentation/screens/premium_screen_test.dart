import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/localization/app_strings.dart';
import 'package:mood_calendar/features/purchases/domain/entities/purchase_failure.dart';
import 'package:mood_calendar/features/purchases/domain/entities/subscription_plan.dart';
import 'package:mood_calendar/features/purchases/presentation/bloc/purchases_cubit.dart';
import 'package:mood_calendar/features/purchases/presentation/screens/premium_screen.dart';
import 'package:mood_calendar/features/purchases/presentation/widgets/premium_plans_view.dart';

import '../../../../support/fake_mood_entitlements_repository.dart';

void main() {
  final strings = AppStrings.forLocale(const Locale('en'));
  final opened = <Uri>[];

  setUp(opened.clear);

  Widget buildApp(
    FakeMoodEntitlementsRepository repository, {
    ValueNotifier<bool>? isActive,
    Key? screenKey,
    Locale locale = const Locale('en'),
  }) {
    Future<bool> openUrl(Uri url) async {
      opened.add(url);
      return true;
    }

    return BlocProvider(
      create: (_) => PurchasesCubit(repository),
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppStrings.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: isActive == null
            ? PremiumScreen(key: screenKey, isActive: false, openUrl: openUrl)
            : ValueListenableBuilder<bool>(
                valueListenable: isActive,
                builder: (_, active, __) => PremiumScreen(
                  key: screenKey,
                  isActive: active,
                  openUrl: openUrl,
                ),
              ),
      ),
    );
  }

  /// La pantalla es una lista larga: con una ventana alta se construye entera.
  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Finder retryButton() => find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.button == true &&
            widget.properties.label == strings.storeRetry,
      );

  group('loading plans', () {
    testWidgets('shows a retry button next to the load error', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(
        buildApp(FakeMoodEntitlementsRepository(failCatalogLoads: 1)),
      );
      await tester.pumpAndSettle();

      expect(find.text(strings.storeLoadError), findsOneWidget);
      expect(find.text(strings.storeRetry), findsOneWidget);
      expect(retryButton(), findsOneWidget);
    });

    testWidgets('retrying recovers the plans', (tester) async {
      useTallScreen(tester);
      final repository = FakeMoodEntitlementsRepository(failCatalogLoads: 1);
      await tester.pumpWidget(buildApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text(strings.storeRetry));
      await tester.pumpAndSettle();

      expect(find.text(strings.storeLoadError), findsNothing);
      expect(find.text(strings.storeRetry), findsNothing);
      expect(find.text(strings.annualPlanLabel), findsOneWidget);
      expect(repository.catalogLoadCount, 2);
    });

    testWidgets('shows the loading state while retrying', (tester) async {
      useTallScreen(tester);
      final repository = FakeMoodEntitlementsRepository(failCatalogLoads: 1);
      await tester.pumpWidget(buildApp(repository));
      await tester.pumpAndSettle();
      expect(find.text(strings.storeLoadError), findsOneWidget);

      final gate = Completer<void>();
      repository.holdCatalogLoads = gate.future;
      await tester.tap(find.text(strings.storeRetry));
      await tester.pump();

      expect(find.text(strings.storeLoading), findsOneWidget);
      expect(find.text(strings.storeRetry), findsNothing);

      gate.complete();
      await tester.pumpAndSettle();
      expect(find.text(strings.storeLoading), findsNothing);
      expect(find.text(strings.annualPlanLabel), findsOneWidget);
    });

    testWidgets('a retry that fails again shows the error and the button',
        (tester) async {
      useTallScreen(tester);
      final repository = FakeMoodEntitlementsRepository(failCatalogLoads: 2);
      await tester.pumpWidget(buildApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text(strings.storeRetry));
      await tester.pumpAndSettle();

      expect(find.text(strings.storeLoadError), findsOneWidget);
      expect(find.text(strings.storeRetry), findsOneWidget);
      expect(repository.catalogLoadCount, 2);
    });

    testWidgets('becoming active with an error retries once', (tester) async {
      useTallScreen(tester);
      final repository = FakeMoodEntitlementsRepository(failCatalogLoads: 1);
      final isActive = ValueNotifier(false);
      await tester.pumpWidget(buildApp(repository, isActive: isActive));
      await tester.pumpAndSettle();
      expect(find.text(strings.storeLoadError), findsOneWidget);
      expect(repository.catalogLoadCount, 1);

      isActive.value = true;
      await tester.pumpAndSettle();

      expect(find.text(strings.annualPlanLabel), findsOneWidget);
      expect(repository.catalogLoadCount, 2);
    });

    testWidgets('opened for the first time after a failed load retries',
        (tester) async {
      useTallScreen(tester);
      final repository = FakeMoodEntitlementsRepository(failCatalogLoads: 1);
      // El cubit pide los planes al arrancar la app y falla; la pantalla se
      // construye después, cuando el usuario abre la pestaña.
      await tester.pumpWidget(
        buildApp(repository, screenKey: const ValueKey('hidden')),
      );
      await tester.pumpAndSettle();
      expect(repository.catalogLoadCount, 1);

      await tester.pumpWidget(
        buildApp(
          repository,
          isActive: ValueNotifier(true),
          screenKey: const ValueKey('opened'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(strings.annualPlanLabel), findsOneWidget);
      expect(repository.catalogLoadCount, 2);
    });

    testWidgets('does not reload again once the plans are loaded',
        (tester) async {
      useTallScreen(tester);
      final repository = FakeMoodEntitlementsRepository();
      final isActive = ValueNotifier(false);
      await tester.pumpWidget(buildApp(repository, isActive: isActive));
      await tester.pumpAndSettle();
      expect(repository.catalogLoadCount, 1);

      isActive.value = true;
      await tester.pumpAndSettle();
      isActive.value = false;
      await tester.pumpAndSettle();
      isActive.value = true;
      await tester.pumpAndSettle();

      expect(repository.catalogLoadCount, 1);
      expect(find.text(strings.annualPlanLabel), findsOneWidget);
    });
  });

  group('plans', () {
    testWidgets('shows the three plans with the store price', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(buildApp(FakeMoodEntitlementsRepository()));
      await tester.pumpAndSettle();

      expect(find.text(strings.weeklyPlanLabel), findsOneWidget);
      expect(find.text(strings.monthlyPlanLabel), findsOneWidget);
      expect(find.text(strings.annualPlanLabel), findsOneWidget);
      expect(find.text(r'$14.99 / year'), findsOneWidget);
      expect(find.text(r'$2.99 / month'), findsOneWidget);
      expect(find.text(r'$0.99 / week'), findsOneWidget);
    });

    testWidgets(
        'the annual plan is selected and labelled best value with the saving',
        (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(buildApp(FakeMoodEntitlementsRepository()));
      await tester.pumpAndSettle();

      expect(
        find.text(
            '${strings.bestValueLabel} · ${strings.savePercentLabel(58)}'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    });

    testWidgets('the saving is recalculated from the store prices',
        (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(buildApp(
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
      ));
      await tester.pumpAndSettle();

      expect(
        find.text(
            '${strings.bestValueLabel} · ${strings.savePercentLabel(58)}'),
        findsOneWidget,
      );
      expect(find.text('€20.00 / year'), findsOneWidget);
    });

    testWidgets('tapping another plan selects it and updates the legal text',
        (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(buildApp(FakeMoodEntitlementsRepository()));
      await tester.pumpAndSettle();
      expect(find.textContaining(r'then $14.99 per year'), findsOneWidget);

      await tester.tap(find.text(strings.monthlyPlanLabel));
      await tester.pumpAndSettle();

      expect(find.textContaining(r'then $2.99 per month'), findsOneWidget);
      expect(find.textContaining('per year'), findsNothing);
    });

    testWidgets('shows the premium moods with their localized names',
        (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(buildApp(
        FakeMoodEntitlementsRepository(),
        locale: const Locale('de'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Mutig'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('marks a mood unlocked by an earlier purchase', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(buildApp(
        FakeMoodEntitlementsRepository(unlockedMoodIds: {'brave'}),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });

  group('free trial', () {
    testWidgets('an eligible user sees the trial button and the trial terms',
        (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(buildApp(FakeMoodEntitlementsRepository()));
      await tester.pumpAndSettle();

      expect(find.text(strings.startTrialButtonLabel), findsOneWidget);
      expect(find.textContaining('Free for 3 days, then'), findsOneWidget);
    });

    testWidgets('a user who already used the trial never sees it mentioned',
        (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(buildApp(
        FakeMoodEntitlementsRepository(plans: [
          for (final plan in defaultTestPlans)
            SubscriptionPlan(
              type: plan.type,
              productId: plan.productId,
              displayPrice: plan.displayPrice,
              price: plan.price,
              currencyCode: plan.currencyCode,
            ),
        ]),
      ));
      await tester.pumpAndSettle();

      expect(find.text(strings.startTrialButtonLabel), findsNothing);
      expect(
          find.text(strings.subscribeButtonLabel(r'$14.99')), findsOneWidget);
      expect(find.textContaining('Free for'), findsNothing);
      expect(find.textContaining('free'), findsNothing);
    });
  });

  group('legal information', () {
    testWidgets('states price, auto-renewal and where to cancel',
        (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(buildApp(FakeMoodEntitlementsRepository()));
      await tester.pumpAndSettle();

      final legal = find.textContaining('Renews automatically');
      expect(legal, findsOneWidget);
      expect(
        tester.widget<Text>(legal).data,
        allOf(contains(r'$14.99 per year'), contains('subscription settings')),
      );
    });

    testWidgets(
        'the terms and privacy links open the site in the device language',
        (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(buildApp(FakeMoodEntitlementsRepository()));
      await tester.pumpAndSettle();

      await tester.tap(find.text(strings.termsLinkLabel));
      await tester.tap(find.text(strings.privacyLinkLabel));

      expect(opened, [
        Uri.parse('https://moodcalendar.app/terms/'),
        Uri.parse('https://moodcalendar.app/privacy/'),
      ]);
    });

    testWidgets('Spanish uses the Spanish pages', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(buildApp(
        FakeMoodEntitlementsRepository(),
        locale: const Locale('es'),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Términos de uso'));

      expect(opened.single, Uri.parse('https://moodcalendar.app/es/terms/'));
    });
  });

  group('purchasing', () {
    testWidgets('subscribing unlocks premium and shows the subscribed state',
        (tester) async {
      useTallScreen(tester);
      final repository = FakeMoodEntitlementsRepository();
      await tester.pumpWidget(buildApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text(strings.startTrialButtonLabel));
      await tester.pumpAndSettle();

      expect(repository.purchasedPlans, [SubscriptionPlanType.annual]);
      expect(find.text(strings.premiumActiveTitle), findsOneWidget);
      expect(find.text(strings.premiumPlanLine(strings.annualPlanLabel)),
          findsOneWidget);
      expect(find.text(strings.premiumRenewsOn('January 15, 2030')),
          findsOneWidget);
      expect(find.text(strings.manageSubscriptionButtonLabel), findsOneWidget);
      // Los planes se esconden y "Restaurar" sigue disponible.
      expect(find.text(strings.monthlyPlanLabel), findsNothing);
      expect(find.text(strings.restorePurchasesButtonLabel), findsOneWidget);
      expect(find.text(strings.purchaseSuccessMessage), findsOneWidget);
    });

    testWidgets('"Manage subscription" opens the system subscriptions page',
        (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(buildApp(FakeMoodEntitlementsRepository()));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.startTrialButtonLabel));
      await tester.pumpAndSettle();

      await tester.tap(find.text(strings.manageSubscriptionButtonLabel));

      expect(opened.single, Uri.parse('https://example.com/manage'));
    });

    testWidgets('the chosen plan is the one that is bought', (tester) async {
      useTallScreen(tester);
      final repository = FakeMoodEntitlementsRepository();
      await tester.pumpWidget(buildApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text(strings.weeklyPlanLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.startTrialButtonLabel));
      await tester.pumpAndSettle();

      expect(repository.purchasedPlans, [SubscriptionPlanType.weekly]);
    });

    testWidgets('a cancelled purchase shows a message and keeps the plans',
        (tester) async {
      useTallScreen(tester);
      final repository = FakeMoodEntitlementsRepository(
        failPurchaseWith: PurchaseFailureReason.cancelled,
      );
      await tester.pumpWidget(buildApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text(strings.startTrialButtonLabel));
      await tester.pumpAndSettle();

      expect(find.text(strings.purchaseCancelledMessage), findsOneWidget);
      expect(find.text(strings.monthlyPlanLabel), findsOneWidget);
      expect(find.text(strings.premiumActiveTitle), findsNothing);
    });

    testWidgets('a network error is explained', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(buildApp(
        FakeMoodEntitlementsRepository(
          failPurchaseWith: PurchaseFailureReason.network,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text(strings.startTrialButtonLabel));
      await tester.pumpAndSettle();

      expect(find.text(strings.purchaseNetworkErrorMessage), findsOneWidget);
    });

    testWidgets('restoring shows the restored message', (tester) async {
      useTallScreen(tester);
      final repository = FakeMoodEntitlementsRepository(
        restorableMoodIds: {'brave'},
      );
      await tester.pumpWidget(buildApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text(strings.restorePurchasesButtonLabel));
      await tester.pumpAndSettle();

      expect(repository.restoreCount, 1);
      expect(find.text(strings.restoreSuccessMessage), findsOneWidget);
    });

    testWidgets('after the subscription ends the plans come back',
        (tester) async {
      useTallScreen(tester);
      final repository = FakeMoodEntitlementsRepository();
      await tester.pumpWidget(buildApp(repository));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.startTrialButtonLabel));
      await tester.pumpAndSettle();
      expect(find.text(strings.monthlyPlanLabel), findsNothing);

      repository.expireSubscription();
      await tester.pumpAndSettle();

      expect(find.text(strings.monthlyPlanLabel), findsOneWidget);
      expect(find.text(strings.premiumActiveTitle), findsNothing);
    });
  });

  group('mood row hints that it scrolls', () {
    void useIphoneWidth(WidgetTester tester) {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }

    testWidgets('the next mood peeks in, cut by the edge of the row',
        (tester) async {
      useIphoneWidth(tester);
      await tester.pumpWidget(buildApp(FakeMoodEntitlementsRepository()));
      await tester.pumpAndSettle();

      final row = tester.getRect(find.byKey(const Key('premium-moods-row')));
      final first = tester.getRect(find.byKey(const Key('premium-mood-0')));
      final third = tester.getRect(find.byKey(const Key('premium-mood-2')));
      final fourth = tester.getRect(find.byKey(const Key('premium-mood-3')));

      expect(first.left, greaterThanOrEqualTo(row.left));
      expect(third.right, lessThanOrEqualTo(row.right));
      // El cuarto empieza dentro de la fila pero no cabe entero.
      expect(fourth.left, lessThan(row.right));
      expect(fourth.right, greaterThan(row.right));
      // Y no es una migaja: se ve una parte apreciable.
      expect(row.right - fourth.left, greaterThan(30));
    });

    testWidgets('every premium mood can be reached by swiping', (tester) async {
      useIphoneWidth(tester);
      await tester.pumpWidget(buildApp(FakeMoodEntitlementsRepository()));
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.byKey(const Key('premium-mood-13')),
        find.byKey(const Key('premium-moods-row')),
        const Offset(-150, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text(strings.moodName('stressed')), findsOneWidget);
      final row = tester.getRect(find.byKey(const Key('premium-moods-row')));
      final last = tester.getRect(find.byKey(const Key('premium-mood-13')));
      expect(last.right, lessThanOrEqualTo(row.right + 0.5));
    });

    test('the edge with more moods fades and the edge at the end does not', () {
      expect(
        premiumShowcaseFade(canScrollLeft: false, canScrollRight: true),
        [Colors.black, Colors.black, Colors.black, Colors.transparent],
      );
      expect(
        premiumShowcaseFade(canScrollLeft: true, canScrollRight: true),
        [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
      );
      expect(
        premiumShowcaseFade(canScrollLeft: true, canScrollRight: false),
        [Colors.transparent, Colors.black, Colors.black, Colors.black],
      );
    });

    testWidgets('at 200% text the cells grow so names stay readable',
        (tester) async {
      useIphoneWidth(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await tester.pumpWidget(buildApp(FakeMoodEntitlementsRepository()));
      await tester.pumpAndSettle();

      final first = tester.getRect(find.byKey(const Key('premium-mood-0')));

      expect(first.width, greaterThanOrEqualTo(88 * 2));
      expect(tester.takeException(), isNull);
    });
  });

  group('accessibility', () {
    for (final locale in ['en', 'de', 'fr', 'it', 'es']) {
      testWidgets('fits at 200% text in $locale on a 390 pt wide screen',
          (tester) async {
        tester.view.physicalSize = const Size(390 * 3, 844 * 3);
        tester.view.devicePixelRatio = 3;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearAllTestValues);
        await tester.pumpWidget(
          buildApp(
            FakeMoodEntitlementsRepository(),
            locale: Locale(locale),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          MediaQuery.textScalerOf(tester.element(find.byType(PremiumScreen)))
              .scale(10),
          20,
        );
      });
    }
  });
}

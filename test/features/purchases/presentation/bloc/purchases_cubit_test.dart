import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry.dart';
import 'package:mood_calendar/features/purchases/domain/entities/purchase_failure.dart';
import 'package:mood_calendar/features/purchases/domain/entities/subscription_plan.dart';
import 'package:mood_calendar/features/purchases/presentation/bloc/purchases_cubit.dart';

import '../../../../support/fake_mood_entitlements_repository.dart';

typedef _Event = ({String name, Map<String, Object?> properties});

class _RecordingTelemetry implements AppTelemetry {
  final List<_Event> tracked = [];
  final List<
      ({
        String name,
        String? reason,
        Object? error,
        StackTrace? stackTrace,
      })> errors = [];

  List<String> get events => tracked.map((event) => event.name).toList();

  @override
  void trackEvent(
    String name, {
    Map<String, Object?> properties = const {},
  }) {
    tracked.add((name: name, properties: properties));
  }

  @override
  void recordError(
    String name, {
    String? reason,
    Map<String, Object?> context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    errors.add(
      (name: name, reason: reason, error: error, stackTrace: stackTrace),
    );
  }
}

void main() {
  test('a failed catalog load keeps the error and records it', () async {
    final telemetry = _RecordingTelemetry();
    final cubit = PurchasesCubit(
      FakeMoodEntitlementsRepository(failCatalogLoads: 1),
      telemetry: telemetry,
    );
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.catalogError, isA<StateError>());
    expect(cubit.state.isLoadingCatalog, isFalse);
    expect(telemetry.errors, hasLength(1));
    final recorded = telemetry.errors.single;
    expect(recorded.name, 'load_store_catalog_failed');
    expect(recorded.reason, 'get_offerings');
    expect(recorded.error, isA<StateError>());
    expect(recorded.stackTrace, isNotNull);
  });

  test('a retry after a failure clears the error and loads the plans',
      () async {
    final telemetry = _RecordingTelemetry();
    final cubit = PurchasesCubit(
      FakeMoodEntitlementsRepository(failCatalogLoads: 1),
      telemetry: telemetry,
    );
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.catalogError, isNotNull);

    await cubit.loadCatalog();

    expect(cubit.state.catalogError, isNull);
    expect(cubit.state.plans, defaultTestPlans);
    expect(telemetry.errors, hasLength(1));
  });

  test('works without telemetry', () async {
    final cubit = PurchasesCubit(
      FakeMoodEntitlementsRepository(failCatalogLoads: 1),
    );
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.catalogError, isNotNull);
  });

  group('plan selection', () {
    test('the annual plan is preselected', () async {
      final cubit = PurchasesCubit(FakeMoodEntitlementsRepository());
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);

      expect(
        cubit.state.effectiveSelectedPlan?.type,
        SubscriptionPlanType.annual,
      );
    });

    test('selecting another plan changes the plan that is purchased', () async {
      final repository = FakeMoodEntitlementsRepository();
      final cubit = PurchasesCubit(repository);
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);

      cubit.selectPlan(SubscriptionPlanType.monthly);
      await cubit.purchaseSelectedPlan();

      expect(repository.purchasedPlans, [SubscriptionPlanType.monthly]);
    });

    test('with no plans nothing is selected and nothing is purchased',
        () async {
      final repository = FakeMoodEntitlementsRepository(plans: const []);
      final cubit = PurchasesCubit(repository);
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);

      await cubit.purchaseSelectedPlan();

      expect(cubit.state.effectiveSelectedPlan, isNull);
      expect(repository.purchasedPlans, isEmpty);
    });
  });

  group('subscription state', () {
    test('a purchase unlocks every premium mood and marks the plan', () async {
      final repository = FakeMoodEntitlementsRepository();
      final cubit = PurchasesCubit(repository);
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.subscription.isActive, isFalse);
      expect(cubit.isMoodUnlocked('brave'), isFalse);

      await cubit.purchasePlan(SubscriptionPlanType.weekly);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.actionStatus, PurchaseActionStatus.success);
      expect(cubit.state.subscription.isActive, isTrue);
      expect(cubit.state.subscription.plan, SubscriptionPlanType.weekly);
      expect(cubit.isMoodUnlocked('brave'), isTrue);
      expect(cubit.isMoodUnlocked('stressed'), isTrue);
    });

    test('an expired subscription locks the moods again', () async {
      final repository = FakeMoodEntitlementsRepository();
      final cubit = PurchasesCubit(repository);
      addTearDown(cubit.close);
      await cubit.purchasePlan(SubscriptionPlanType.annual);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.isMoodUnlocked('brave'), isTrue);

      repository.expireSubscription();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.subscription.isActive, isFalse);
      expect(cubit.isMoodUnlocked('brave'), isFalse);
    });

    test('moods bought in an earlier version stay unlocked after expiry',
        () async {
      final repository = FakeMoodEntitlementsRepository();
      final cubit = PurchasesCubit(repository);
      addTearDown(cubit.close);
      await cubit.purchasePlan(SubscriptionPlanType.annual);
      await Future<void>.delayed(Duration.zero);

      repository.expireSubscription(remaining: {'brave'});
      await Future<void>.delayed(Duration.zero);

      expect(cubit.isMoodUnlocked('brave'), isTrue);
      expect(cubit.isMoodUnlocked('anxious'), isFalse);
    });

    test('restoring reports restored, not a purchase success', () async {
      final cubit = PurchasesCubit(
        FakeMoodEntitlementsRepository(restorableMoodIds: {'brave'}),
      );
      addTearDown(cubit.close);

      await cubit.restorePurchases();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.actionStatus, PurchaseActionStatus.restored);
      expect(cubit.isMoodUnlocked('brave'), isTrue);
    });
  });

  group('annual savings', () {
    SubscriptionPlan plan(SubscriptionPlanType type, double price) =>
        SubscriptionPlan(
          type: type,
          productId: type.name,
          displayPrice: '$price',
          price: price,
          currencyCode: 'USD',
        );

    test('is computed from the store prices', () {
      expect(annualSavingsPercent(defaultTestPlans), 58);
      expect(
        annualSavingsPercent([
          plan(SubscriptionPlanType.monthly, 5),
          plan(SubscriptionPlanType.annual, 30),
        ]),
        50,
      );
    });

    test('is null when a price is missing or the annual does not save', () {
      expect(
        annualSavingsPercent([plan(SubscriptionPlanType.annual, 14.99)]),
        isNull,
      );
      expect(
        annualSavingsPercent([
          plan(SubscriptionPlanType.monthly, 1),
          plan(SubscriptionPlanType.annual, 12),
        ]),
        isNull,
      );
    });
  });

  group('analytics events', () {
    test('a purchase reports started and completed with the plan only',
        () async {
      final telemetry = _RecordingTelemetry();
      final cubit = PurchasesCubit(
        FakeMoodEntitlementsRepository(),
        telemetry: telemetry,
      );
      addTearDown(cubit.close);

      await cubit.purchasePlan(SubscriptionPlanType.annual);

      expect(telemetry.events, ['purchase_started', 'purchase_completed']);
      for (final event in telemetry.tracked) {
        expect(event.properties, {'plan': 'annual'}, reason: event.name);
      }
    });

    test('a cancelled purchase reports cancelled, not failed', () async {
      final telemetry = _RecordingTelemetry();
      final cubit = PurchasesCubit(
        FakeMoodEntitlementsRepository(
          failPurchaseWith: PurchaseFailureReason.cancelled,
        ),
        telemetry: telemetry,
      );
      addTearDown(cubit.close);

      await cubit.purchasePlan(SubscriptionPlanType.weekly);

      expect(telemetry.events, ['purchase_started', 'purchase_cancelled']);
      expect(cubit.state.actionStatus, PurchaseActionStatus.cancelled);
    });

    test('other failures report failed', () async {
      final telemetry = _RecordingTelemetry();
      final cubit = PurchasesCubit(
        FakeMoodEntitlementsRepository(
          failPurchaseWith: PurchaseFailureReason.network,
        ),
        telemetry: telemetry,
      );
      addTearDown(cubit.close);

      await cubit.purchasePlan(SubscriptionPlanType.monthly);

      expect(telemetry.events, ['purchase_started', 'purchase_failed']);
      expect(cubit.state.actionStatus, PurchaseActionStatus.networkError);
    });

    test('restoring reports purchases_restored only', () async {
      final telemetry = _RecordingTelemetry();
      final cubit = PurchasesCubit(
        FakeMoodEntitlementsRepository(),
        telemetry: telemetry,
      );
      addTearDown(cubit.close);

      await cubit.restorePurchases();

      expect(telemetry.events, ['purchases_restored']);
      expect(telemetry.tracked.single.properties, isEmpty);
    });

    test('opening Premium reports store_opened with where it came from', () {
      final telemetry = _RecordingTelemetry();
      final cubit = PurchasesCubit(
        FakeMoodEntitlementsRepository(),
        telemetry: telemetry,
      );
      addTearDown(cubit.close);

      cubit.trackPremiumOpened(PremiumSource.tab);
      cubit.trackPremiumOpened(PremiumSource.lockedMood);

      expect(telemetry.events, ['store_opened', 'store_opened']);
      expect(telemetry.tracked[0].properties, {'source': 'tab'});
      expect(telemetry.tracked[1].properties, {'source': 'locked_mood'});
    });
  });
}

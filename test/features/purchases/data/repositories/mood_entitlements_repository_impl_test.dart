import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_definition.dart';
import 'package:mood_calendar/features/purchases/data/datasources/revenue_cat_datasource.dart';
import 'package:mood_calendar/features/purchases/data/repositories/mood_entitlements_repository_impl.dart';
import 'package:mood_calendar/features/purchases/domain/entities/purchase_failure.dart';
import 'package:mood_calendar/features/purchases/domain/entities/subscription_plan.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class _FakeDatasource extends RevenueCatDatasource {
  _FakeDatasource(this.offerings, {this.eligible = const {}});

  final Offerings offerings;
  final Map<String, bool> eligible;
  bool failEligibility = false;
  final updates = StreamController<CustomerInfo>.broadcast();
  final List<Package> purchased = [];
  CustomerInfo? purchaseResult;
  Object? purchaseError;
  CustomerInfo? restoreResult;

  @override
  Stream<CustomerInfo> get customerInfoUpdates => updates.stream;

  @override
  void startListening() {}

  @override
  Future<Offerings> getOfferings() async => offerings;

  @override
  Future<Map<String, bool>> trialEligibility(List<Package> packages) async {
    if (failEligibility) {
      throw StateError('eligibility unavailable');
    }
    return eligible;
  }

  @override
  Future<CustomerInfo> purchasePackage(Package package) async {
    final error = purchaseError;
    if (error != null) {
      throw error;
    }
    purchased.add(package);
    return purchaseResult!;
  }

  @override
  Future<CustomerInfo> restorePurchases() async => restoreResult!;

  @override
  Future<void> dispose() => updates.close();
}

Package _package(
  String identifier,
  PackageType type,
  String productId,
  String priceString,
  double price,
) =>
    Package(
      identifier,
      type,
      StoreProduct(productId, '', productId, price, priceString, 'USD'),
      const PresentedOfferingContext('default', null, null),
    );

/// La oferta `default` real: paquetes heredados de compras sueltas y los tres
/// planes de la suscripción.
Offerings _offerings({bool withPlans = true}) {
  final packages = [
    _package(r'$rc_custom_mood_brave', PackageType.custom, 'mood_brave_unlock',
        r'$0.99', 0.99),
    _package(r'$rc_custom_pack_afecto', PackageType.custom,
        'pack_afecto_unlock', r'$1.99', 1.99),
    if (withPlans) ...[
      _package(
          r'$rc_weekly', PackageType.weekly, 'premium_weekly', r'$0.99', 0.99),
      _package(r'$rc_monthly', PackageType.monthly, 'premium_monthly', r'$2.99',
          2.99),
      _package(r'$rc_annual', PackageType.annual, 'premium_annual', r'$14.99',
          14.99),
    ],
  ];
  final offering = Offering('default', '', const {}, packages);
  return Offerings({'default': offering}, current: offering);
}

EntitlementInfo _entitlement(
  String identifier, {
  String productId = 'premium_annual',
  String? planId,
  PeriodType periodType = PeriodType.normal,
  bool willRenew = true,
  String? expiration = '2030-01-15T10:00:00Z',
}) =>
    EntitlementInfo(
      identifier,
      true,
      willRenew,
      '2026-10-31T10:00:00Z',
      '2026-10-31T10:00:00Z',
      productId,
      false,
      periodType: periodType,
      expirationDate: expiration,
      productPlanIdentifier: planId,
    );

CustomerInfo _customer(
  List<EntitlementInfo> active, {
  String? managementUrl = 'https://apps.apple.com/account/subscriptions',
}) =>
    CustomerInfo(
      EntitlementInfos({for (final e in active) e.identifier: e},
          {for (final e in active) e.identifier: e}),
      const {},
      const [],
      const [],
      const [],
      '2026-10-31T10:00:00Z',
      'user',
      const {},
      '2026-10-31T10:00:00Z',
      managementURL: managementUrl,
    );

final _allPremiumIds = premiumMoodDefinitions.map((mood) => mood.id).toSet();

void main() {
  late _FakeDatasource datasource;
  late MoodEntitlementsRepositoryImpl repository;

  setUp(() {
    datasource = _FakeDatasource(
      _offerings(),
      eligible: const {'premium_annual': true, 'premium_monthly': true},
    );
    repository = MoodEntitlementsRepositoryImpl(datasource);
  });

  tearDown(() => repository.dispose());

  Future<void> deliver(CustomerInfo info) async {
    datasource.updates.add(info);
    await Future<void>.delayed(Duration.zero);
  }

  group('plans', () {
    test('lists annual, monthly and weekly with the store prices', () async {
      final plans = await repository.availablePlans();

      expect(plans.map((plan) => plan.type), [
        SubscriptionPlanType.annual,
        SubscriptionPlanType.monthly,
        SubscriptionPlanType.weekly,
      ]);
      expect(plans.map((plan) => plan.productId),
          ['premium_annual', 'premium_monthly', 'premium_weekly']);
      expect(plans.map((plan) => plan.displayPrice),
          [r'$14.99', r'$2.99', r'$0.99']);
      expect(plans.first.price, 14.99);
      expect(plans.first.currencyCode, 'USD');
    });

    test('ignores the legacy per-mood and per-pack packages', () async {
      final plans = await repository.availablePlans();

      expect(plans, hasLength(3));
      expect(plans.any((plan) => plan.productId.contains('unlock')), isFalse);
    });

    test('marks the trial only for the plans the store says are eligible',
        () async {
      final plans = await repository.availablePlans();

      final trial = {for (final plan in plans) plan.type: plan.isTrialEligible};
      expect(trial, {
        SubscriptionPlanType.annual: true,
        SubscriptionPlanType.monthly: true,
        SubscriptionPlanType.weekly: false,
      });
    });

    test('when the eligibility check fails no plan promises a trial', () async {
      datasource.failEligibility = true;

      final plans = await repository.availablePlans();

      expect(plans, hasLength(3));
      expect(plans.every((plan) => !plan.isTrialEligible), isTrue);
    });

    test('an offering without the plans lists none', () async {
      final repo = MoodEntitlementsRepositoryImpl(
        _FakeDatasource(_offerings(withPlans: false)),
      );
      addTearDown(repo.dispose);

      expect(await repo.availablePlans(), isEmpty);
    });

    test('without a current offering there are no plans', () async {
      final repo = MoodEntitlementsRepositoryImpl(
        _FakeDatasource(const Offerings({})),
      );
      addTearDown(repo.dispose);

      expect(await repo.availablePlans(), isEmpty);
    });
  });

  group('unlocked moods', () {
    test('start with only the base moods unlocked', () {
      expect(repository.isUnlocked('happy'), isTrue);
      expect(repository.isUnlocked('brave'), isFalse);
    });

    test('an active premium entitlement unlocks every premium mood', () async {
      await deliver(_customer([_entitlement('premium')]));

      for (final id in _allPremiumIds) {
        expect(repository.isUnlocked(id), isTrue, reason: id);
      }
      expect(await repository.unlockedPremiumMoodIds().first, _allPremiumIds);
    });

    test('legacy per-mood entitlements unlock only those moods', () async {
      await deliver(_customer([
        _entitlement('mood_brave', productId: 'pack_confianza_unlock'),
        _entitlement('mood_confident', productId: 'pack_confianza_unlock'),
      ]));

      expect(repository.isUnlocked('brave'), isTrue);
      expect(repository.isUnlocked('confident'), isTrue);
      expect(repository.isUnlocked('anxious'), isFalse);
      expect(await repository.unlockedPremiumMoodIds().first,
          {'brave', 'confident'});
    });

    test(
        'a subscription adds to the legacy purchases and, when it ends, the legacy ones stay',
        () async {
      await deliver(_customer([
        _entitlement('premium'),
        _entitlement('mood_brave', productId: 'mood_brave_unlock'),
      ]));
      expect(repository.isUnlocked('anxious'), isTrue);

      await deliver(
        _customer([_entitlement('mood_brave', productId: 'mood_brave_unlock')]),
      );

      expect(repository.isUnlocked('brave'), isTrue);
      expect(repository.isUnlocked('anxious'), isFalse);
    });

    test('an unknown mood id is not blocked', () {
      expect(repository.isUnlocked('not_a_mood'), isTrue);
    });
  });

  group('subscription status', () {
    test('starts inactive and replays the latest state to new listeners',
        () async {
      expect((await repository.subscriptionStatus().first).isActive, isFalse);

      await deliver(_customer([_entitlement('premium')]));

      expect((await repository.subscriptionStatus().first).isActive, isTrue);
    });

    test('reads the plan from the iOS product identifier', () async {
      await deliver(
        _customer([_entitlement('premium', productId: 'premium_weekly')]),
      );

      final status = await repository.subscriptionStatus().first;
      expect(status.plan, SubscriptionPlanType.weekly);
      expect(status.expiresAt, DateTime.utc(2030, 1, 15, 10).toLocal());
      expect(
          status.managementUrl, 'https://apps.apple.com/account/subscriptions');
    });

    test('reads the plan from the Android base plan id', () async {
      await deliver(_customer([
        _entitlement('premium', productId: 'premium', planId: 'monthly'),
      ]));

      expect((await repository.subscriptionStatus().first).plan,
          SubscriptionPlanType.monthly);
    });

    test('flags the free trial and a subscription that will not renew',
        () async {
      await deliver(_customer([
        _entitlement('premium', periodType: PeriodType.trial, willRenew: false),
      ]));

      final status = await repository.subscriptionStatus().first;
      expect(status.isInTrial, isTrue);
      expect(status.willRenew, isFalse);
    });

    test('legacy purchases alone are not a subscription', () async {
      await deliver(_customer([_entitlement('mood_brave')]));

      expect((await repository.subscriptionStatus().first).isActive, isFalse);
    });

    test('falls back to the store page when RevenueCat gives no URL', () async {
      await deliver(_customer([_entitlement('premium')], managementUrl: null));

      expect((await repository.subscriptionStatus().first).managementUrl,
          isNotNull);
    });
  });

  group('purchasing', () {
    test('buys the package of the chosen plan and applies the result',
        () async {
      datasource.purchaseResult = _customer([_entitlement('premium')]);

      await repository.purchasePlan(SubscriptionPlanType.monthly);

      expect(datasource.purchased.single.storeProduct.identifier,
          'premium_monthly');
      expect(repository.isUnlocked('brave'), isTrue);
    });

    test('a missing package reports the product as unavailable', () async {
      final repo = MoodEntitlementsRepositoryImpl(
        _FakeDatasource(_offerings(withPlans: false)),
      );
      addTearDown(repo.dispose);

      expect(
        () => repo.purchasePlan(SubscriptionPlanType.annual),
        throwsA(isA<PurchaseException>().having(
          (e) => e.reason,
          'reason',
          PurchaseFailureReason.productUnavailable,
        )),
      );
    });

    test('a cancelled purchase is reported as cancelled and unlocks nothing',
        () async {
      datasource.purchaseError = PlatformException(
        code: PurchasesErrorCode.purchaseCancelledError.index.toString(),
      );

      expect(
        () => repository.purchasePlan(SubscriptionPlanType.annual),
        throwsA(isA<PurchaseException>().having(
          (e) => e.reason,
          'reason',
          PurchaseFailureReason.cancelled,
        )),
      );
      expect(repository.isUnlocked('brave'), isFalse);
    });

    test('a network error is reported as such', () async {
      datasource.purchaseError = PlatformException(
        code: PurchasesErrorCode.networkError.index.toString(),
      );

      expect(
        () => repository.purchasePlan(SubscriptionPlanType.weekly),
        throwsA(isA<PurchaseException>().having(
          (e) => e.reason,
          'reason',
          PurchaseFailureReason.network,
        )),
      );
    });

    test('restoring recovers the subscription and the legacy purchases',
        () async {
      datasource.restoreResult = _customer([
        _entitlement('mood_brave', productId: 'mood_brave_unlock'),
      ]);

      await repository.restorePurchases();

      expect(repository.isUnlocked('brave'), isTrue);
      expect(repository.isUnlocked('anxious'), isFalse);
    });
  });
}

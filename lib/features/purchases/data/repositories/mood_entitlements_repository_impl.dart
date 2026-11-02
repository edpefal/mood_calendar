import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../mood/domain/entities/mood_definition.dart';
import '../../domain/entities/purchase_failure.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/repositories/mood_entitlements_repository.dart';
import '../datasources/revenue_cat_datasource.dart';

/// Entitlement de la suscripción Premium: lo activa cualquiera de sus planes y
/// desbloquea todos los moods premium, también los que se añadan después.
const _premiumEntitlement = 'premium';

/// Entitlements de compras sueltas hechas en versiones anteriores (1.8.x y
/// 1.9.0): `mood_<moodId>`, p. ej. `mood_confident`. Un Pack otorgaba varios.
/// Se siguen reconociendo para no quitar lo que el usuario ya pagó. Los
/// identificadores de RevenueCat nunca salen de este repositorio: el resto de
/// la app solo conoce ids de moods.
const _legacyEntitlementPrefix = 'mood_';

/// Orden en que se ofrecen los planes: el anual primero.
const _planOrder = [
  (PackageType.annual, SubscriptionPlanType.annual),
  (PackageType.monthly, SubscriptionPlanType.monthly),
  (PackageType.weekly, SubscriptionPlanType.weekly),
];

const _iosSubscriptionsUrl = 'https://apps.apple.com/account/subscriptions';
const _androidSubscriptionsUrl =
    'https://play.google.com/store/account/subscriptions';

class MoodEntitlementsRepositoryImpl implements MoodEntitlementsRepository {
  final RevenueCatDatasource datasource;

  Set<String> _unlockedMoodIds = {};
  SubscriptionStatus _subscriptionStatus = SubscriptionStatus.inactive;
  final _unlockedController = StreamController<Set<String>>.broadcast();
  final _statusController = StreamController<SubscriptionStatus>.broadcast();
  StreamSubscription<CustomerInfo>? _customerInfoSubscription;

  MoodEntitlementsRepositoryImpl(this.datasource) {
    // Subscribe BEFORE starting the native listener: RevenueCat calls the
    // listener synchronously and immediately if it already has cached
    // CustomerInfo (common on cold start once `configure()` finished its
    // own internal fetch). That first, most important event would be lost
    // on this broadcast stream if nothing were listening yet.
    _customerInfoSubscription =
        datasource.customerInfoUpdates.listen(_applyCustomerInfo);
    datasource.startListening();
  }

  /// Updates local state from a [CustomerInfo] snapshot and notifies the
  /// listeners. Called both by the passive `addCustomerInfoUpdateListener`
  /// callback and directly with the [CustomerInfo] returned by a purchase or
  /// restore call — don't rely solely on the listener firing again after
  /// those calls, since that introduced a bug where a successful restore left
  /// the UI showing stale (locked) state until the next full app relaunch.
  void _applyCustomerInfo(CustomerInfo info) {
    final active = info.entitlements.active;
    final premium = active[_premiumEntitlement];

    _unlockedMoodIds = premium != null
        ? premiumMoodDefinitions.map((mood) => mood.id).toSet()
        : active.keys
            .where(
                (identifier) => identifier.startsWith(_legacyEntitlementPrefix))
            .map((identifier) =>
                identifier.substring(_legacyEntitlementPrefix.length))
            .toSet();
    _subscriptionStatus = premium == null
        ? SubscriptionStatus.inactive
        : SubscriptionStatus(
            isActive: true,
            plan: _planOf(premium),
            expiresAt: premium.expirationDate == null
                ? null
                : DateTime.tryParse(premium.expirationDate!)?.toLocal(),
            isInTrial: premium.periodType == PeriodType.trial,
            willRenew: premium.willRenew,
            managementUrl: info.managementURL ?? _fallbackManagementUrl(),
          );

    if (!_unlockedController.isClosed) {
      _unlockedController.add(_unlockedMoodIds);
    }
    if (!_statusController.isClosed) {
      _statusController.add(_subscriptionStatus);
    }
  }

  /// iOS identifica el plan por el producto (`premium_weekly`); Android, por
  /// el plan base de la suscripción `premium` (`weekly`).
  SubscriptionPlanType? _planOf(EntitlementInfo entitlement) {
    final hint = '${entitlement.productIdentifier} '
            '${entitlement.productPlanIdentifier ?? ''}'
        .toLowerCase();
    if (hint.contains('annual')) {
      return SubscriptionPlanType.annual;
    }
    if (hint.contains('monthly')) {
      return SubscriptionPlanType.monthly;
    }
    if (hint.contains('weekly')) {
      return SubscriptionPlanType.weekly;
    }
    return null;
  }

  String _fallbackManagementUrl() =>
      defaultTargetPlatform == TargetPlatform.android
          ? _androidSubscriptionsUrl
          : _iosSubscriptionsUrl;

  Future<void> dispose() async {
    await _customerInfoSubscription?.cancel();
    await datasource.dispose();
    await _unlockedController.close();
    await _statusController.close();
  }

  @override
  bool isUnlocked(String moodId) {
    final definition = allMoodDefinitions.where((mood) => mood.id == moodId);
    if (definition.isEmpty || definition.first.tier == MoodTier.base) {
      return true;
    }
    return _unlockedMoodIds.contains(moodId);
  }

  @override
  Stream<Set<String>> unlockedPremiumMoodIds() async* {
    // Replay the current known state to every new subscriber before
    // continuing with live updates. `PurchasesCubit` subscribes later than
    // this repository is constructed (it's built during the widget tree,
    // after `main()` already ran), so without this replay it would miss
    // any CustomerInfo update that already arrived by then — the same
    // broadcast-stream-has-no-late-subscriber-replay issue fixed above for
    // the datasource-to-repository hop, one level up.
    yield _unlockedMoodIds;
    yield* _unlockedController.stream;
  }

  @override
  Stream<SubscriptionStatus> subscriptionStatus() async* {
    yield _subscriptionStatus;
    yield* _statusController.stream;
  }

  @override
  Future<List<SubscriptionPlan>> availablePlans() async {
    final offerings = await datasource.getOfferings();
    final current = offerings.current;
    if (current == null) {
      return [];
    }
    final packages = [
      for (final (packageType, _) in _planOrder)
        ...current.availablePackages
            .where((package) => package.packageType == packageType)
            .take(1),
    ];

    // Cualquier fallo o duda al comprobar la prueba equivale a "no elegible":
    // es preferible no prometer una prueba que no se va a dar.
    var eligibility = const <String, bool>{};
    try {
      eligibility = await datasource.trialEligibility(packages);
    } catch (_) {}

    return [
      for (final package in packages)
        SubscriptionPlan(
          type: _planOrder
              .firstWhere((entry) => entry.$1 == package.packageType)
              .$2,
          productId: package.storeProduct.identifier,
          displayPrice: package.storeProduct.priceString,
          price: package.storeProduct.price,
          currencyCode: package.storeProduct.currencyCode,
          isTrialEligible:
              eligibility[package.storeProduct.identifier] ?? false,
        ),
    ];
  }

  @override
  Future<void> purchasePlan(SubscriptionPlanType plan) async {
    final packageType = _planOrder.firstWhere((entry) => entry.$2 == plan).$1;
    final offerings = await datasource.getOfferings();
    final package = offerings.current?.availablePackages
        .where((package) => package.packageType == packageType)
        .firstOrNull;
    if (package == null) {
      throw const PurchaseException(PurchaseFailureReason.productUnavailable);
    }

    try {
      final customerInfo = await datasource.purchasePackage(package);
      _applyCustomerInfo(customerInfo);
    } on PlatformException catch (e) {
      throw _mapPlatformException(e);
    }
  }

  @override
  Future<void> restorePurchases() async {
    try {
      final customerInfo = await datasource.restorePurchases();
      _applyCustomerInfo(customerInfo);
    } on PlatformException catch (e) {
      throw _mapPlatformException(e);
    }
  }

  PurchaseException _mapPlatformException(PlatformException e) {
    final errorCode = PurchasesErrorHelper.getErrorCode(e);
    switch (errorCode) {
      case PurchasesErrorCode.purchaseCancelledError:
        return const PurchaseException(PurchaseFailureReason.cancelled);
      case PurchasesErrorCode.networkError:
        return const PurchaseException(PurchaseFailureReason.network);
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
      case PurchasesErrorCode.productAlreadyPurchasedError:
        return const PurchaseException(
          PurchaseFailureReason.productUnavailable,
        );
      default:
        return const PurchaseException(PurchaseFailureReason.unknown);
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../mood/domain/entities/mood_definition.dart';
import '../../domain/entities/mood_offer.dart';
import '../../domain/entities/mood_pack.dart';
import '../../domain/entities/purchase_failure.dart';
import '../../domain/repositories/mood_entitlements_repository.dart';
import '../datasources/revenue_cat_datasource.dart';

/// Package `lookup_key` convention agreed with the RevenueCat dashboard
/// config (see `setup-revenuecat-store-config`): `$rc_custom_mood_<moodId>`
/// for an individual mood, `$rc_custom_pack_<packId>` for a pack.
const _moodPackagePrefix = r'$rc_custom_mood_';
const _packPackagePrefix = r'$rc_custom_pack_';

/// Entitlement `lookup_key` convention (see `setup-revenuecat-store-config`
/// section 3.1): each entitlement is `mood_<moodId>`, e.g. `mood_confident`
/// for the mood `confident`. Entitlement identifiers are RevenueCat-specific
/// and must never leak past this repository — the rest of the app only ever
/// deals in plain `moodId`s.
const _entitlementPrefix = 'mood_';

class MoodEntitlementsRepositoryImpl implements MoodEntitlementsRepository {
  final RevenueCatDatasource datasource;

  Set<String> _unlockedMoodIds = {};
  final _unlockedController = StreamController<Set<String>>.broadcast();
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

  /// Updates local state from a [CustomerInfo] snapshot and notifies
  /// [unlockedPremiumMoodIds] listeners. Called both by the passive
  /// `addCustomerInfoUpdateListener` callback and directly with the
  /// [CustomerInfo] returned by a purchase/restore call — don't rely solely
  /// on the listener firing again after those calls, since that introduced
  /// a bug where a successful restore left the UI showing stale (locked)
  /// state until the next full app relaunch.
  void _applyCustomerInfo(CustomerInfo info) {
    _unlockedMoodIds = info.entitlements.active.keys
        .where((identifier) => identifier.startsWith(_entitlementPrefix))
        .map((identifier) => identifier.substring(_entitlementPrefix.length))
        .toSet();
    if (!_unlockedController.isClosed) {
      _unlockedController.add(_unlockedMoodIds);
    }
  }

  Future<void> dispose() async {
    await _customerInfoSubscription?.cancel();
    await datasource.dispose();
    await _unlockedController.close();
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
  Future<List<MoodOffer>> availableMoodOffers() async {
    final offerings = await datasource.getOfferings();
    final current = offerings.current;
    if (current == null) {
      return [];
    }
    return current.availablePackages
        .where((package) => package.identifier.startsWith(_moodPackagePrefix))
        .map(
          (package) => MoodOffer(
            moodId: package.identifier.substring(_moodPackagePrefix.length),
            displayPrice: package.storeProduct.priceString,
            productId: package.storeProduct.identifier,
          ),
        )
        .toList();
  }

  @override
  Future<List<MoodPack>> availablePacks() async {
    final offerings = await datasource.getOfferings();
    final current = offerings.current;
    if (current == null) {
      return [];
    }
    return current.availablePackages
        .where((package) => package.identifier.startsWith(_packPackagePrefix))
        .map((package) {
      final packId = package.identifier.substring(_packPackagePrefix.length);
      final moodIds = _moodIdsForPack(current, packId);
      return MoodPack(
        id: packId,
        label: package.storeProduct.title,
        moodIds: moodIds,
        displayPrice: package.storeProduct.priceString,
        productId: package.storeProduct.identifier,
      );
    }).toList();
  }

  List<String> _moodIdsForPack(Offering offering, String packId) {
    // Metadata key as configured on the Offering in the RevenueCat
    // dashboard (see `setup-revenuecat-store-config` 3.4): `pack_<packId>_moodIds`,
    // e.g. `pack_confianza_moodIds` for the pack `confianza`.
    final raw = offering.metadata['pack_${packId}_moodIds'];
    if (raw is! List) {
      return const [];
    }
    return raw.whereType<String>().toList();
  }

  @override
  Future<void> purchaseMood(String moodId) =>
      _purchaseByPackageIdentifier('$_moodPackagePrefix$moodId');

  @override
  Future<void> purchasePack(String packId) =>
      _purchaseByPackageIdentifier('$_packPackagePrefix$packId');

  Future<void> _purchaseByPackageIdentifier(String packageIdentifier) async {
    final offerings = await datasource.getOfferings();
    final current = offerings.current;
    final package = current?.availablePackages.where(
      (package) => package.identifier == packageIdentifier,
    ).firstOrNull;
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

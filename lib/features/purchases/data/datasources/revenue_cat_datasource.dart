import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatDatasource {
  final _customerInfoController = StreamController<CustomerInfo>.broadcast();
  void Function(CustomerInfo)? _listener;

  static Future<void> configure(String apiKey) {
    return Purchases.configure(PurchasesConfiguration(apiKey));
  }

  Stream<CustomerInfo> get customerInfoUpdates =>
      _customerInfoController.stream;

  void startListening() {
    _listener = (customerInfo) {
      if (!_customerInfoController.isClosed) {
        _customerInfoController.add(customerInfo);
      }
    };
    Purchases.addCustomerInfoUpdateListener(_listener!);
  }

  void stopListening() {
    final listener = _listener;
    if (listener != null) {
      Purchases.removeCustomerInfoUpdateListener(listener);
      _listener = null;
    }
  }

  Future<void> dispose() async {
    stopListening();
    await _customerInfoController.close();
  }

  Future<CustomerInfo> getCustomerInfo() => Purchases.getCustomerInfo();

  Future<Offerings> getOfferings() => Purchases.getOfferings();

  Future<CustomerInfo> purchasePackage(Package package) async {
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return result.customerInfo;
  }

  Future<CustomerInfo> restorePurchases() => Purchases.restorePurchases();

  /// Qué paquetes ofrecen hoy una prueba gratis a este usuario, por id de
  /// producto. En iOS la elegibilidad la confirma Apple (una sola vez por
  /// Apple ID y grupo de suscripción); en Android, Google Play solo incluye la
  /// oferta de prueba en el producto si el usuario puede usarla.
  Future<Map<String, bool>> trialEligibility(List<Package> packages) async {
    final productIds =
        packages.map((package) => package.storeProduct.identifier).toList();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final eligibility =
          await Purchases.checkTrialOrIntroductoryPriceEligibility(productIds);
      return {
        for (final id in productIds)
          id: eligibility[id]?.status ==
              IntroEligibilityStatus.introEligibilityStatusEligible,
      };
    }
    return {
      for (final package in packages)
        package.storeProduct.identifier:
            package.storeProduct.defaultOption?.freePhase != null,
    };
  }
}

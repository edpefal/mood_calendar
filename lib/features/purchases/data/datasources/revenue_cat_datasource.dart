import 'dart:async';

import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatDatasource {
  final _customerInfoController = StreamController<CustomerInfo>.broadcast();
  void Function(CustomerInfo)? _listener;

  static Future<void> configure(String apiKey) {
    return Purchases.configure(PurchasesConfiguration(apiKey));
  }

  Stream<CustomerInfo> get customerInfoUpdates => _customerInfoController.stream;

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
}

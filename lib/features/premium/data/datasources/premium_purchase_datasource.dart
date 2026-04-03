import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../mood/domain/entities/mood_definition.dart';
import '../../domain/entities/mood_store_product.dart';

abstract class PremiumPurchaseDataSource {
  Stream<List<PurchaseDetails>> get purchaseUpdates;
  Future<bool> isAvailable();
  Future<List<MoodStoreProduct>> queryMoodProducts();
  Future<void> buyMood(String productId);
  Future<void> restorePurchases();
  Future<void> completePurchase(PurchaseDetails purchase);
}

class StorePremiumPurchaseDataSource implements PremiumPurchaseDataSource {
  StorePremiumPurchaseDataSource(this._inAppPurchase);

  final InAppPurchase _inAppPurchase;

  @override
  Stream<List<PurchaseDetails>> get purchaseUpdates =>
      _inAppPurchase.purchaseStream;

  @override
  Future<bool> isAvailable() => _inAppPurchase.isAvailable();

  @override
  Future<List<MoodStoreProduct>> queryMoodProducts() async {
    final productIds = premiumMoodDefinitions
        .map((mood) => mood.productId)
        .whereType<String>()
        .toSet();
    final response = await _inAppPurchase.queryProductDetails(productIds);

    return premiumMoodDefinitions.map((mood) {
      final details = response.productDetails
          .where((product) => product.id == mood.productId)
          .cast<ProductDetails?>()
          .firstWhere((product) => product != null, orElse: () => null);

      return MoodStoreProduct(
        moodId: mood.id,
        productId: mood.productId ?? '',
        title: details?.title ?? mood.label,
        description:
            details?.description ?? 'Unlock ${mood.label} as a permanent mood.',
        price: details?.price ?? '\$0.99',
        isAvailable: details != null,
      );
    }).toList();
  }

  @override
  Future<void> buyMood(String productId) async {
    final response = await _inAppPurchase.queryProductDetails({productId});
    if (response.productDetails.isEmpty) {
      throw StateError('Product $productId is not available in the store.');
    }

    final purchaseParam =
        PurchaseParam(productDetails: response.productDetails.first);
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Future<void> restorePurchases() => _inAppPurchase.restorePurchases();

  @override
  Future<void> completePurchase(PurchaseDetails purchase) {
    return _inAppPurchase.completePurchase(purchase);
  }
}

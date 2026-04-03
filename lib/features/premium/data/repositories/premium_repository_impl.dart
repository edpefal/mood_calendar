import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../mood/domain/entities/mood_definition.dart';
import '../../domain/entities/premium_snapshot.dart';
import '../../domain/repositories/premium_repository.dart';
import '../datasources/premium_local_datasource.dart';
import '../datasources/premium_purchase_datasource.dart';

class PremiumRepositoryImpl implements PremiumRepository {
  PremiumRepositoryImpl({
    required PremiumLocalDataSource localDataSource,
    required PremiumPurchaseDataSource purchaseDataSource,
  })  : _localDataSource = localDataSource,
        _purchaseDataSource = purchaseDataSource;

  final PremiumLocalDataSource _localDataSource;
  final PremiumPurchaseDataSource _purchaseDataSource;
  final _controller = StreamController<PremiumSnapshot>.broadcast();

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  PremiumSnapshot _snapshot = const PremiumSnapshot(isLoading: true);
  bool _initialized = false;

  @override
  PremiumSnapshot get currentSnapshot => _snapshot;

  @override
  Stream<PremiumSnapshot> watchSnapshot() => _controller.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    try {
      final ownedMoodIds = await _localDataSource.getOwnedMoodIds();
      _emit(_snapshot.copyWith(
        ownedMoodIds: ownedMoodIds,
        isLoading: true,
        clearError: true,
      ));

      _purchaseSubscription =
          _purchaseDataSource.purchaseUpdates.listen(_handlePurchases);

      final isStoreAvailable = await _purchaseDataSource.isAvailable();
      _emit(_snapshot.copyWith(isStoreAvailable: isStoreAvailable));

      if (!isStoreAvailable) {
        _emit(
          _snapshot.copyWith(
            isLoading: false,
            errorMessage: 'Store is unavailable right now.',
          ),
        );
        return;
      }

      final products = await _purchaseDataSource.queryMoodProducts();
      _emit(
        _snapshot.copyWith(
          productsByMoodId: {
            for (final product in products) product.moodId: product,
          },
          isLoading: false,
          clearError: true,
        ),
      );
    } catch (error) {
      _emit(
        _snapshot.copyWith(
          isLoading: false,
          errorMessage: 'Could not initialize store access: $error',
        ),
      );
    }
  }

  @override
  Future<void> buyMood(String moodId) async {
    final definition = premiumMoodDefinitions.firstWhere(
      (mood) => mood.id == moodId,
      orElse: () => throw StateError('Unknown premium mood: $moodId'),
    );
    final productId = definition.productId;
    if (productId == null) {
      throw StateError('Mood $moodId is not linked to a store product.');
    }

    _emit(_snapshot.copyWith(isLoading: true, clearError: true));
    try {
      await _purchaseDataSource.buyMood(productId);
      _emit(_snapshot.copyWith(isLoading: false));
    } catch (error) {
      _emit(_snapshot.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      ));
      rethrow;
    }
  }

  @override
  Future<void> restorePurchases() async {
    _emit(_snapshot.copyWith(isLoading: true, clearError: true));
    try {
      await _purchaseDataSource.restorePurchases();
      _emit(_snapshot.copyWith(isLoading: false));
    } catch (error) {
      _emit(_snapshot.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      ));
      rethrow;
    }
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    var ownedMoodIds = {..._snapshot.ownedMoodIds};

    for (final purchase in purchases) {
      final isCompletedPurchase = purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored;

      if (isCompletedPurchase) {
        final mood = premiumMoodDefinitions.where(
          (definition) => definition.productId == purchase.productID,
        );
        if (mood.isNotEmpty) {
          ownedMoodIds.add(mood.first.id);
        }
        if (purchase.pendingCompletePurchase) {
          await _purchaseDataSource.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.error) {
        _emit(
          _snapshot.copyWith(
            isLoading: false,
            errorMessage: purchase.error?.message ?? 'Purchase failed.',
          ),
        );
      }
    }

    await _localDataSource.saveOwnedMoodIds(ownedMoodIds);
    _emit(
      _snapshot.copyWith(
        ownedMoodIds: ownedMoodIds,
        isLoading: false,
        clearError: true,
      ),
    );
  }

  void _emit(PremiumSnapshot snapshot) {
    _snapshot = snapshot;
    if (!_controller.isClosed) {
      _controller.add(snapshot);
    }
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    _controller.close();
  }
}

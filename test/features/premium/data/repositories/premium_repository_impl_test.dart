import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mood_calendar/features/premium/data/datasources/premium_local_datasource.dart';
import 'package:mood_calendar/features/premium/data/datasources/premium_purchase_datasource.dart';
import 'package:mood_calendar/features/premium/data/repositories/premium_repository_impl.dart';
import 'package:mood_calendar/features/premium/domain/entities/mood_store_product.dart';
import 'package:mood_calendar/features/premium/domain/entities/premium_snapshot.dart';

class _FakePurchaseDataSource implements PremiumPurchaseDataSource {
  final controller = StreamController<List<PurchaseDetails>>.broadcast();

  bool storeAvailable = true;
  List<MoodStoreProduct> products = const [
    MoodStoreProduct(
      moodId: 'shy',
      productId: 'mood_shy_unlock',
      title: 'Shy',
      description: 'Unlock Shy',
      price: '\$0.99',
      isAvailable: true,
    ),
  ];
  String? lastPurchasedProductId;
  bool restoreCalled = false;
  final completedPurchases = <String>[];

  @override
  Future<void> buyMood(String productId) async {
    lastPurchasedProductId = productId;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completedPurchases.add(purchase.productID);
  }

  @override
  Future<bool> isAvailable() async => storeAvailable;

  @override
  Stream<List<PurchaseDetails>> get purchaseUpdates => controller.stream;

  @override
  Future<List<MoodStoreProduct>> queryMoodProducts() async => products;

  @override
  Future<void> restorePurchases() async {
    restoreCalled = true;
  }

  void dispose() {
    controller.close();
  }
}

PurchaseDetails _purchase({
  required String productId,
  required PurchaseStatus status,
  bool pendingCompletePurchase = false,
}) {
  final purchase = PurchaseDetails(
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: 'local',
      serverVerificationData: 'server',
      source: 'test',
    ),
    transactionDate: DateTime.now().millisecondsSinceEpoch.toString(),
    status: status,
  );
  purchase.pendingCompletePurchase = pendingCompletePurchase;
  return purchase;
}

void main() {
  late Directory tempDir;
  late Box<dynamic> box;
  late _FakePurchaseDataSource purchaseDataSource;
  late PremiumRepositoryImpl repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('premium_repository_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<dynamic>('premium_entitlements_test');
    purchaseDataSource = _FakePurchaseDataSource();
    repository = PremiumRepositoryImpl(
      localDataSource: PremiumLocalDataSource(box),
      purchaseDataSource: purchaseDataSource,
    );
    await repository.initialize();
  });

  tearDown(() async {
    repository.dispose();
    purchaseDataSource.dispose();
    await box.close();
    await Hive.deleteBoxFromDisk('premium_entitlements_test');
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('restored purchase unlocks mood and completes transaction', () async {
    purchaseDataSource.controller.add([
      _purchase(
        productId: 'mood_shy_unlock',
        status: PurchaseStatus.restored,
        pendingCompletePurchase: true,
      ),
    ]);

    await expectLater(
      repository.watchSnapshot(),
      emitsThrough(
        isA<PremiumSnapshot>().having(
          (snapshot) => snapshot.ownedMoodIds,
          'ownedMoodIds',
          contains('shy'),
        ),
      ),
    );

    expect(repository.currentSnapshot.ownedMoodIds, contains('shy'));
    expect(purchaseDataSource.completedPurchases, contains('mood_shy_unlock'));
  });

  test('pending purchase does not unlock mood', () async {
    purchaseDataSource.controller.add([
      _purchase(
        productId: 'mood_shy_unlock',
        status: PurchaseStatus.pending,
        pendingCompletePurchase: true,
      ),
    ]);

    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(repository.currentSnapshot.ownedMoodIds, isNot(contains('shy')));
    expect(purchaseDataSource.completedPurchases, isEmpty);
  });
}

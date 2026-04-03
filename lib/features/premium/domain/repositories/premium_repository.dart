import '../entities/premium_snapshot.dart';

abstract class PremiumRepository {
  PremiumSnapshot get currentSnapshot;
  Stream<PremiumSnapshot> watchSnapshot();
  Future<void> initialize();
  Future<void> buyMood(String moodId);
  Future<void> restorePurchases();
  void dispose();
}

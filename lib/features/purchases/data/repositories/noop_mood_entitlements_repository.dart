import '../../../mood/domain/entities/mood_definition.dart';
import '../../domain/entities/mood_offer.dart';
import '../../domain/entities/mood_pack.dart';
import '../../domain/entities/purchase_failure.dart';
import '../../domain/repositories/mood_entitlements_repository.dart';

/// Used when RevenueCat was not configured (e.g. missing
/// `REVENUECAT_IOS_API_KEY` `--dart-define`), so the app never touches the
/// native `purchases_flutter` SDK before `Purchases.configure()` — calling
/// any of its methods unconfigured crashes natively with an uncatchable
/// Swift `fatalError`. All premium moods stay locked and purchases fail
/// gracefully instead of taking down the app.
class NoopMoodEntitlementsRepository implements MoodEntitlementsRepository {
  const NoopMoodEntitlementsRepository();

  @override
  bool isUnlocked(String moodId) {
    final definition = allMoodDefinitions.where((mood) => mood.id == moodId);
    return definition.isNotEmpty && definition.first.tier == MoodTier.base;
  }

  @override
  Stream<Set<String>> unlockedPremiumMoodIds() => const Stream.empty();

  @override
  Future<List<MoodOffer>> availableMoodOffers() async => const [];

  @override
  Future<List<MoodPack>> availablePacks() async => const [];

  @override
  Future<void> purchaseMood(String moodId) =>
      throw const PurchaseException(PurchaseFailureReason.productUnavailable);

  @override
  Future<void> purchasePack(String packId) =>
      throw const PurchaseException(PurchaseFailureReason.productUnavailable);

  @override
  Future<void> restorePurchases() =>
      throw const PurchaseException(PurchaseFailureReason.productUnavailable);
}

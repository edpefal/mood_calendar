import '../../../mood/domain/entities/mood_definition.dart';
import '../../domain/entities/purchase_failure.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/subscription_status.dart';
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
  Stream<SubscriptionStatus> subscriptionStatus() => const Stream.empty();

  @override
  Future<List<SubscriptionPlan>> availablePlans() async => const [];

  @override
  Future<void> purchasePlan(SubscriptionPlanType plan) =>
      throw const PurchaseException(PurchaseFailureReason.productUnavailable);

  @override
  Future<void> restorePurchases() =>
      throw const PurchaseException(PurchaseFailureReason.productUnavailable);
}

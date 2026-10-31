import '../entities/subscription_plan.dart';
import '../entities/subscription_status.dart';

abstract class MoodEntitlementsRepository {
  bool isUnlocked(String moodId);

  /// Ids de los moods premium desbloqueados: todos con una suscripción activa,
  /// o solo los de compras sueltas hechas en versiones anteriores.
  Stream<Set<String>> unlockedPremiumMoodIds();

  Stream<SubscriptionStatus> subscriptionStatus();

  Future<List<SubscriptionPlan>> availablePlans();

  Future<void> purchasePlan(SubscriptionPlanType plan);

  Future<void> restorePurchases();
}

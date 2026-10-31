import 'dart:async';

import 'package:mood_calendar/features/mood/domain/entities/mood_definition.dart';
import 'package:mood_calendar/features/purchases/domain/entities/purchase_failure.dart';
import 'package:mood_calendar/features/purchases/domain/entities/subscription_plan.dart';
import 'package:mood_calendar/features/purchases/domain/entities/subscription_status.dart';
import 'package:mood_calendar/features/purchases/domain/repositories/mood_entitlements_repository.dart';

/// Planes que devuelve la tienda por defecto en los tests: anual, mensual y
/// semanal, con prueba gratis disponible.
const defaultTestPlans = [
  SubscriptionPlan(
    type: SubscriptionPlanType.annual,
    productId: 'premium_annual',
    displayPrice: r'$14.99',
    price: 14.99,
    currencyCode: 'USD',
    isTrialEligible: true,
  ),
  SubscriptionPlan(
    type: SubscriptionPlanType.monthly,
    productId: 'premium_monthly',
    displayPrice: r'$2.99',
    price: 2.99,
    currencyCode: 'USD',
    isTrialEligible: true,
  ),
  SubscriptionPlan(
    type: SubscriptionPlanType.weekly,
    productId: 'premium_weekly',
    displayPrice: r'$0.99',
    price: 0.99,
    currencyCode: 'USD',
    isTrialEligible: true,
  ),
];

class FakeMoodEntitlementsRepository implements MoodEntitlementsRepository {
  FakeMoodEntitlementsRepository({
    Set<String> unlockedMoodIds = const {},
    Set<String> restorableMoodIds = const {},
    this.plans = defaultTestPlans,
    int failCatalogLoads = 0,
    this.holdCatalogLoads,
    SubscriptionStatus subscription = SubscriptionStatus.inactive,
    this.failPurchaseWith,
  })  : _unlockedMoodIds = Set<String>.from(unlockedMoodIds),
        _restorableMoodIds = Set<String>.from(restorableMoodIds),
        _failCatalogLoads = failCatalogLoads,
        _subscription = subscription;

  /// Planes que devuelve `availablePlans` cuando la carga no falla.
  List<SubscriptionPlan> plans;

  /// Si no es nulo, las cargas del catálogo esperan a este future.
  Future<void>? holdCatalogLoads;

  /// Cuántas veces se pidió el catálogo (aciertos y fallos).
  int catalogLoadCount = 0;
  int _failCatalogLoads;

  /// Planes comprados con `purchasePlan`, en orden.
  final List<SubscriptionPlanType> purchasedPlans = [];

  /// Si no es nulo, `purchasePlan` falla con este motivo.
  PurchaseFailureReason? failPurchaseWith;

  /// Cuántas veces se ejecutó "Restaurar compras".
  int restoreCount = 0;

  final Set<String> _unlockedMoodIds;
  SubscriptionStatus _subscription;

  /// Moods que `restorePurchases` desbloquea, como una restauración real.
  final Set<String> _restorableMoodIds;
  final _controller = StreamController<Set<String>>.broadcast();
  final _statusController = StreamController<SubscriptionStatus>.broadcast();

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
    // Mirrors RevenueCat's addCustomerInfoUpdateListener, which invokes the
    // listener immediately with the latest known state on subscription.
    yield Set<String>.from(_unlockedMoodIds);
    yield* _controller.stream;
  }

  @override
  Stream<SubscriptionStatus> subscriptionStatus() async* {
    yield _subscription;
    yield* _statusController.stream;
  }

  @override
  Future<List<SubscriptionPlan>> availablePlans() async {
    catalogLoadCount++;
    await holdCatalogLoads;
    if (_failCatalogLoads > 0) {
      _failCatalogLoads--;
      throw StateError('catalog unavailable');
    }
    return plans;
  }

  @override
  Future<void> purchasePlan(SubscriptionPlanType plan) async {
    final failure = failPurchaseWith;
    if (failure != null) {
      throw PurchaseException(failure);
    }
    purchasedPlans.add(plan);
    _unlockedMoodIds.addAll(premiumMoodDefinitions.map((mood) => mood.id));
    _subscription = SubscriptionStatus(
      isActive: true,
      plan: plan,
      expiresAt: DateTime(2030, 1, 15),
      managementUrl: 'https://example.com/manage',
    );
    _controller.add(Set<String>.from(_unlockedMoodIds));
    _statusController.add(_subscription);
  }

  @override
  Future<void> restorePurchases() async {
    restoreCount++;
    _unlockedMoodIds.addAll(_restorableMoodIds);
    _controller.add(Set<String>.from(_unlockedMoodIds));
  }

  /// Simula que un mood queda desbloqueado fuera de esta pantalla (p. ej. una
  /// compra heredada restaurada).
  Future<void> unlockMood(String moodId) async {
    _unlockedMoodIds.add(moodId);
    _controller.add(Set<String>.from(_unlockedMoodIds));
  }

  /// Simula que la suscripción venció: los moods vuelven a estar bloqueados.
  void expireSubscription({Set<String> remaining = const {}}) {
    _unlockedMoodIds
      ..clear()
      ..addAll(remaining);
    _subscription = SubscriptionStatus.inactive;
    _controller.add(Set<String>.from(_unlockedMoodIds));
    _statusController.add(_subscription);
  }
}

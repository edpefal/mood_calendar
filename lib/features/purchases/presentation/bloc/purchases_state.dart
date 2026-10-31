part of 'purchases_cubit.dart';

enum PurchaseActionStatus {
  idle,
  inProgress,
  success,
  restored,
  cancelled,
  networkError,
  productUnavailable,
  unknownError,
}

class PurchasesState extends Equatable {
  final List<SubscriptionPlan> plans;

  /// Plan elegido por el usuario; mientras no elija, [effectiveSelectedPlan]
  /// propone el anual.
  final SubscriptionPlanType? selectedPlan;
  final SubscriptionStatus subscription;
  final Set<String> unlockedMoodIds;
  final bool isLoadingCatalog;
  final Object? catalogError;
  final PurchaseActionStatus actionStatus;

  const PurchasesState({
    this.plans = const [],
    this.selectedPlan,
    this.subscription = SubscriptionStatus.inactive,
    this.unlockedMoodIds = const {},
    this.isLoadingCatalog = false,
    this.catalogError,
    this.actionStatus = PurchaseActionStatus.idle,
  });

  bool isMoodUnlocked(String moodId) {
    final definition = allMoodDefinitions.where((mood) => mood.id == moodId);
    if (definition.isEmpty || definition.first.tier == MoodTier.base) {
      return true;
    }
    return unlockedMoodIds.contains(moodId);
  }

  /// Plan seleccionado, o el anual (y si no existe, el primero) por defecto.
  SubscriptionPlan? get effectiveSelectedPlan {
    if (plans.isEmpty) {
      return null;
    }
    for (final plan in plans) {
      if (plan.type == selectedPlan) {
        return plan;
      }
    }
    for (final plan in plans) {
      if (plan.type == SubscriptionPlanType.annual) {
        return plan;
      }
    }
    return plans.first;
  }

  PurchasesState copyWith({
    List<SubscriptionPlan>? plans,
    SubscriptionPlanType? selectedPlan,
    SubscriptionStatus? subscription,
    Set<String>? unlockedMoodIds,
    bool? isLoadingCatalog,
    Object? catalogError,
    PurchaseActionStatus? actionStatus,
  }) {
    return PurchasesState(
      plans: plans ?? this.plans,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      subscription: subscription ?? this.subscription,
      unlockedMoodIds: unlockedMoodIds ?? this.unlockedMoodIds,
      isLoadingCatalog: isLoadingCatalog ?? this.isLoadingCatalog,
      catalogError: catalogError,
      actionStatus: actionStatus ?? this.actionStatus,
    );
  }

  @override
  List<Object?> get props => [
        plans,
        selectedPlan,
        subscription,
        unlockedMoodIds,
        isLoadingCatalog,
        catalogError,
        actionStatus,
      ];
}

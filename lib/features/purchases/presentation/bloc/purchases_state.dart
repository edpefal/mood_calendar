part of 'purchases_cubit.dart';

enum PurchaseActionStatus {
  idle,
  inProgress,
  success,
  cancelled,
  networkError,
  productUnavailable,
  unknownError,
}

class PurchasesState extends Equatable {
  final List<MoodOffer> offers;
  final List<MoodPack> packs;
  final Set<String> unlockedMoodIds;
  final bool isLoadingCatalog;
  final Object? catalogError;
  final PurchaseActionStatus actionStatus;

  const PurchasesState({
    this.offers = const [],
    this.packs = const [],
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

  PurchasesState copyWith({
    List<MoodOffer>? offers,
    List<MoodPack>? packs,
    Set<String>? unlockedMoodIds,
    bool? isLoadingCatalog,
    Object? catalogError,
    PurchaseActionStatus? actionStatus,
  }) {
    return PurchasesState(
      offers: offers ?? this.offers,
      packs: packs ?? this.packs,
      unlockedMoodIds: unlockedMoodIds ?? this.unlockedMoodIds,
      isLoadingCatalog: isLoadingCatalog ?? this.isLoadingCatalog,
      catalogError: catalogError,
      actionStatus: actionStatus ?? this.actionStatus,
    );
  }

  @override
  List<Object?> get props => [
        offers,
        packs,
        unlockedMoodIds,
        isLoadingCatalog,
        catalogError,
        actionStatus,
      ];
}

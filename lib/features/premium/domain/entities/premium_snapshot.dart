import 'mood_store_product.dart';

class PremiumSnapshot {
  final Set<String> ownedMoodIds;
  final Map<String, MoodStoreProduct> productsByMoodId;
  final bool isStoreAvailable;
  final bool isLoading;
  final String? errorMessage;

  const PremiumSnapshot({
    this.ownedMoodIds = const {},
    this.productsByMoodId = const {},
    this.isStoreAvailable = false,
    this.isLoading = false,
    this.errorMessage,
  });

  bool isOwned(String moodId) => ownedMoodIds.contains(moodId);

  MoodStoreProduct? productForMood(String moodId) => productsByMoodId[moodId];

  PremiumSnapshot copyWith({
    Set<String>? ownedMoodIds,
    Map<String, MoodStoreProduct>? productsByMoodId,
    bool? isStoreAvailable,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PremiumSnapshot(
      ownedMoodIds: ownedMoodIds ?? this.ownedMoodIds,
      productsByMoodId: productsByMoodId ?? this.productsByMoodId,
      isStoreAvailable: isStoreAvailable ?? this.isStoreAvailable,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

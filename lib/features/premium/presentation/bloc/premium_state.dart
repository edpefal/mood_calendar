import '../../../mood/domain/entities/mood_definition.dart';
import '../../domain/entities/mood_store_product.dart';

class PremiumState {
  final Set<String> ownedMoodIds;
  final Map<String, MoodStoreProduct> productsByMoodId;
  final bool isStoreAvailable;
  final bool isLoading;
  final String? errorMessage;

  const PremiumState({
    this.ownedMoodIds = const {},
    this.productsByMoodId = const {},
    this.isStoreAvailable = false,
    this.isLoading = false,
    this.errorMessage,
  });

  bool isOwned(MoodDefinition mood) =>
      !mood.isPremium || ownedMoodIds.contains(mood.id);

  MoodStoreProduct? productForMood(String moodId) => productsByMoodId[moodId];

  PremiumState copyWith({
    Set<String>? ownedMoodIds,
    Map<String, MoodStoreProduct>? productsByMoodId,
    bool? isStoreAvailable,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PremiumState(
      ownedMoodIds: ownedMoodIds ?? this.ownedMoodIds,
      productsByMoodId: productsByMoodId ?? this.productsByMoodId,
      isStoreAvailable: isStoreAvailable ?? this.isStoreAvailable,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

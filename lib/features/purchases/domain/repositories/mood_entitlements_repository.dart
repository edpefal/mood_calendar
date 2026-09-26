import '../entities/mood_offer.dart';
import '../entities/mood_pack.dart';

abstract class MoodEntitlementsRepository {
  bool isUnlocked(String moodId);

  Stream<Set<String>> unlockedPremiumMoodIds();

  Future<List<MoodOffer>> availableMoodOffers();

  Future<List<MoodPack>> availablePacks();

  Future<void> purchaseMood(String moodId);

  Future<void> purchasePack(String packId);

  Future<void> restorePurchases();
}

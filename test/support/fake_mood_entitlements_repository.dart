import 'dart:async';

import 'package:mood_calendar/features/mood/domain/entities/mood_definition.dart';
import 'package:mood_calendar/features/purchases/domain/entities/mood_offer.dart';
import 'package:mood_calendar/features/purchases/domain/entities/mood_pack.dart';
import 'package:mood_calendar/features/purchases/domain/repositories/mood_entitlements_repository.dart';

class FakeMoodEntitlementsRepository implements MoodEntitlementsRepository {
  FakeMoodEntitlementsRepository({Set<String> unlockedMoodIds = const {}})
      : _unlockedMoodIds = Set<String>.from(unlockedMoodIds);

  final Set<String> _unlockedMoodIds;
  final _controller = StreamController<Set<String>>.broadcast();

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
  Future<List<MoodOffer>> availableMoodOffers() async => const [];

  @override
  Future<List<MoodPack>> availablePacks() async => const [];

  @override
  Future<void> purchaseMood(String moodId) async {
    _unlockedMoodIds.add(moodId);
    _controller.add(_unlockedMoodIds);
  }

  @override
  Future<void> purchasePack(String packId) async {}

  @override
  Future<void> restorePurchases() async {}
}

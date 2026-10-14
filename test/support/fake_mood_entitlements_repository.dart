import 'dart:async';

import 'package:mood_calendar/features/mood/domain/entities/mood_definition.dart';
import 'package:mood_calendar/features/purchases/domain/entities/mood_offer.dart';
import 'package:mood_calendar/features/purchases/domain/entities/mood_pack.dart';
import 'package:mood_calendar/features/purchases/domain/repositories/mood_entitlements_repository.dart';

class FakeMoodEntitlementsRepository implements MoodEntitlementsRepository {
  FakeMoodEntitlementsRepository({
    Set<String> unlockedMoodIds = const {},
    Set<String> restorableMoodIds = const {},
    this.offers = const [],
    int failCatalogLoads = 0,
    this.holdCatalogLoads,
  })  : _unlockedMoodIds = Set<String>.from(unlockedMoodIds),
        _restorableMoodIds = Set<String>.from(restorableMoodIds),
        _failCatalogLoads = failCatalogLoads;

  /// Ofertas que devuelve `availableMoodOffers` cuando la carga no falla.
  final List<MoodOffer> offers;

  /// Si no es nulo, las cargas del catálogo esperan a este future.
  Future<void>? holdCatalogLoads;

  /// Cuántas veces se pidió el catálogo (aciertos y fallos).
  int catalogLoadCount = 0;
  int _failCatalogLoads;

  final Set<String> _unlockedMoodIds;

  /// Moods que `restorePurchases` desbloquea, como una restauración real.
  final Set<String> _restorableMoodIds;
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
  Future<List<MoodOffer>> availableMoodOffers() async {
    catalogLoadCount++;
    await holdCatalogLoads;
    if (_failCatalogLoads > 0) {
      _failCatalogLoads--;
      throw StateError('catalog unavailable');
    }
    return offers;
  }

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
  Future<void> restorePurchases() async {
    _unlockedMoodIds.addAll(_restorableMoodIds);
    _controller.add(_unlockedMoodIds);
  }
}

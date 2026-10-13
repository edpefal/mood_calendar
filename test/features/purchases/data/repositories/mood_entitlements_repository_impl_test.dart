import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_definition.dart';
import 'package:mood_calendar/features/purchases/data/datasources/revenue_cat_datasource.dart';
import 'package:mood_calendar/features/purchases/data/repositories/mood_entitlements_repository_impl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

const _packs = {
  'confianza': ['brave', 'confident', 'romantic'],
  'afecto': ['affectionate', 'hugging', 'laughing'],
  'cuerpo': ['sleepy', 'sick', 'hurt'],
  'intenso': ['crying', 'scared', 'stressed'],
};

class _FakeDatasource extends RevenueCatDatasource {
  _FakeDatasource(this.offerings);

  final Offerings offerings;

  @override
  void startListening() {}

  @override
  Future<Offerings> getOfferings() async => offerings;
}

Package _package(String identifier, String productId, String price) => Package(
      identifier,
      PackageType.custom,
      StoreProduct(productId, '', productId, 0, price, 'USD'),
      const PresentedOfferingContext('default', null, null),
    );

Offerings _offerings({Map<String, Object>? metadata}) {
  final packages = [
    for (final mood in premiumMoodDefinitions)
      _package(
        '\$rc_custom_mood_${mood.id}',
        'mood_${mood.id}_unlock',
        r'$0.99',
      ),
    for (final pack in _packs.keys)
      _package(
        '\$rc_custom_pack_$pack',
        'pack_${pack}_unlock',
        r'$1.99',
      ),
  ];
  final offering = Offering(
    'default',
    '',
    metadata ??
        {
          for (final pack in _packs.entries)
            'pack_${pack.key}_moodIds': pack.value,
        },
    packages,
  );
  return Offerings({'default': offering}, current: offering);
}

void main() {
  late MoodEntitlementsRepositoryImpl repository;

  setUp(() {
    repository = MoodEntitlementsRepositoryImpl(_FakeDatasource(_offerings()));
  });

  tearDown(() => repository.dispose());

  test('lists one offer per premium mood, first-wave moods included', () async {
    final offers = await repository.availableMoodOffers();

    expect(
      offers.map((offer) => offer.moodId),
      premiumMoodDefinitions.map((mood) => mood.id),
    );
    final sleepy = offers.firstWhere((offer) => offer.moodId == 'sleepy');
    expect(sleepy.productId, 'mood_sleepy_unlock');
    expect(sleepy.displayPrice, r'$0.99');
  });

  test('lists the four packs with their frozen composition', () async {
    final packs = await repository.availablePacks();

    expect(packs.map((pack) => pack.id), _packs.keys);
    for (final pack in packs) {
      expect(pack.moodIds, _packs[pack.id], reason: pack.id);
      expect(pack.productId, 'pack_${pack.id}_unlock');
    }
  });

  test('every pack has three moods and shows the store price', () async {
    final packs = await repository.availablePacks();

    for (final pack in packs) {
      expect(pack.moodIds, hasLength(3), reason: pack.id);
      expect(pack.displayPrice, r'$1.99', reason: pack.id);
    }
  });

  test('every mood of every pack exists as a premium mood in the catalog', () {
    final premiumIds = premiumMoodDefinitions.map((mood) => mood.id).toSet();

    for (final entry in _packs.entries) {
      expect(premiumIds.containsAll(entry.value), isTrue, reason: entry.key);
    }
  });

  test('a pack without metadata is listed with no moods instead of failing',
      () async {
    final repo = MoodEntitlementsRepositoryImpl(
      _FakeDatasource(_offerings(metadata: {})),
    );
    addTearDown(repo.dispose);

    final packs = await repo.availablePacks();

    expect(packs, hasLength(_packs.length));
    expect(packs.every((pack) => pack.moodIds.isEmpty), isTrue);
  });
}

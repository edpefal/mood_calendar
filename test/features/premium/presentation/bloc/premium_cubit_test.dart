import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/premium/domain/entities/mood_store_product.dart';
import 'package:mood_calendar/features/premium/domain/entities/premium_snapshot.dart';
import 'package:mood_calendar/features/premium/domain/repositories/premium_repository.dart';
import 'package:mood_calendar/features/premium/presentation/bloc/premium_cubit.dart';

class _FakePremiumRepository implements PremiumRepository {
  final _controller = StreamController<PremiumSnapshot>.broadcast();
  PremiumSnapshot _snapshot;

  _FakePremiumRepository(this._snapshot);

  @override
  PremiumSnapshot get currentSnapshot => _snapshot;

  @override
  Future<void> buyMood(String moodId) async {
    _snapshot = _snapshot.copyWith(
      ownedMoodIds: {..._snapshot.ownedMoodIds, moodId},
      clearError: true,
    );
    _controller.add(_snapshot);
  }

  @override
  void dispose() {
    _controller.close();
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> restorePurchases() async {
    _controller.add(_snapshot);
  }

  @override
  Stream<PremiumSnapshot> watchSnapshot() => _controller.stream;
}

void main() {
  group('PremiumCubit', () {
    test('reflects repository snapshot updates', () async {
      final repository = _FakePremiumRepository(
        const PremiumSnapshot(
          ownedMoodIds: {'brave'},
          productsByMoodId: {
            'shy': MoodStoreProduct(
              moodId: 'shy',
              productId: 'mood_shy_unlock',
              title: 'Shy',
              description: 'Unlock Shy',
              price: '\$0.99',
              isAvailable: true,
            ),
          },
          isStoreAvailable: true,
        ),
      );
      final cubit = PremiumCubit(repository: repository);

      await repository.buyMood('shy');
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.ownedMoodIds, containsAll(<String>['brave', 'shy']));
      expect(cubit.state.productForMood('shy')?.price, '\$0.99');

      await cubit.close();
      repository.dispose();
    });
  });
}

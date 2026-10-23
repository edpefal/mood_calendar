import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry.dart';
import 'package:mood_calendar/features/purchases/domain/entities/mood_offer.dart';
import 'package:mood_calendar/features/purchases/domain/entities/purchase_failure.dart';
import 'package:mood_calendar/features/purchases/presentation/bloc/purchases_cubit.dart';

import '../../../../support/fake_mood_entitlements_repository.dart';

class _RecordingTelemetry implements AppTelemetry {
  final List<String> events = [];
  final List<
      ({
        String name,
        String? reason,
        Object? error,
        StackTrace? stackTrace,
      })> errors = [];

  @override
  void trackEvent(
    String name, {
    Map<String, Object?> properties = const {},
  }) {
    events.add(name);
  }

  @override
  void recordError(
    String name, {
    String? reason,
    Map<String, Object?> context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    errors.add(
      (name: name, reason: reason, error: error, stackTrace: stackTrace),
    );
  }
}

const _anxious = MoodOffer(
  moodId: 'anxious',
  displayPrice: r'$0.99',
  productId: 'mood_anxious_unlock',
);

void main() {
  test('a failed catalog load keeps the error and records it', () async {
    final telemetry = _RecordingTelemetry();
    final cubit = PurchasesCubit(
      FakeMoodEntitlementsRepository(failCatalogLoads: 1),
      telemetry: telemetry,
    );
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.catalogError, isA<StateError>());
    expect(cubit.state.isLoadingCatalog, isFalse);
    expect(telemetry.errors, hasLength(1));
    final recorded = telemetry.errors.single;
    expect(recorded.name, 'load_store_catalog_failed');
    expect(recorded.reason, 'get_offerings');
    expect(recorded.error, isA<StateError>());
    expect(recorded.stackTrace, isNotNull);
  });

  test('a retry after a failure clears the error and loads the offers',
      () async {
    final telemetry = _RecordingTelemetry();
    final cubit = PurchasesCubit(
      FakeMoodEntitlementsRepository(
        offers: const [_anxious],
        failCatalogLoads: 1,
      ),
      telemetry: telemetry,
    );
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.catalogError, isNotNull);

    await cubit.loadCatalog();

    expect(cubit.state.catalogError, isNull);
    expect(cubit.state.offers, const [_anxious]);
    expect(telemetry.errors, hasLength(1));
  });

  test('works without telemetry', () async {
    final cubit = PurchasesCubit(
      FakeMoodEntitlementsRepository(failCatalogLoads: 1),
    );
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.catalogError, isNotNull);
  });

  group('analytics events', () {
    test('a purchase reports started and completed without ids', () async {
      final telemetry = _RecordingTelemetry();
      final cubit = PurchasesCubit(
        FakeMoodEntitlementsRepository(),
        telemetry: telemetry,
      );
      addTearDown(cubit.close);

      await cubit.purchaseMood('anxious');

      expect(telemetry.events, ['purchase_started', 'purchase_completed']);
    });

    test('a cancelled purchase reports cancelled, not failed', () async {
      final telemetry = _RecordingTelemetry();
      final cubit = PurchasesCubit(
        _FailingPurchases(
          const PurchaseException(PurchaseFailureReason.cancelled),
        ),
        telemetry: telemetry,
      );
      addTearDown(cubit.close);

      await cubit.purchasePack('pack_afecto');

      expect(telemetry.events, ['purchase_started', 'purchase_cancelled']);
    });

    test('other failures report failed', () async {
      final telemetry = _RecordingTelemetry();
      final cubit = PurchasesCubit(
        _FailingPurchases(
          const PurchaseException(PurchaseFailureReason.network),
        ),
        telemetry: telemetry,
      );
      addTearDown(cubit.close);

      await cubit.purchaseMood('anxious');

      expect(telemetry.events, ['purchase_started', 'purchase_failed']);
    });

    test('restoring reports purchases_restored only', () async {
      final telemetry = _RecordingTelemetry();
      final cubit = PurchasesCubit(
        FakeMoodEntitlementsRepository(),
        telemetry: telemetry,
      );
      addTearDown(cubit.close);

      await cubit.restorePurchases();

      expect(telemetry.events, ['purchases_restored']);
    });

    test('opening the store reports store_opened', () {
      final telemetry = _RecordingTelemetry();
      final cubit = PurchasesCubit(
        FakeMoodEntitlementsRepository(),
        telemetry: telemetry,
      );
      addTearDown(cubit.close);

      cubit.trackStoreOpened();

      expect(telemetry.events, ['store_opened']);
    });
  });
}

class _FailingPurchases extends FakeMoodEntitlementsRepository {
  _FailingPurchases(this.failure);

  final PurchaseException failure;

  @override
  Future<void> purchaseMood(String moodId) async => throw failure;

  @override
  Future<void> purchasePack(String packId) async => throw failure;
}

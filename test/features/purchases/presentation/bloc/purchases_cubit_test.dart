import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry.dart';
import 'package:mood_calendar/features/purchases/domain/entities/mood_offer.dart';
import 'package:mood_calendar/features/purchases/presentation/bloc/purchases_cubit.dart';

import '../../../../support/fake_mood_entitlements_repository.dart';

class _RecordingTelemetry implements AppTelemetry {
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
  }) {}

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
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mood_calendar/core/rating/review_requester.dart';
import 'package:mood_calendar/core/settings/data/datasources/app_settings_local_datasource.dart';
import 'package:mood_calendar/core/settings/data/datasources/rating_prompt_local_datasource.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry_events.dart';
import 'package:mood_calendar/features/mood/data/services/rating_prompt_service.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/mood/domain/repositories/mood_repository.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_moods_usecase.dart';

void main() {
  final now = DateTime(2026, 10, 5, 12);

  late Directory tempDir;
  late Box<dynamic> settingsBox;
  late RatingPromptLocalDataSource stateDataSource;
  late _FakeMoodRepository repository;
  late _FakeReviewRequester requester;
  late _FakeAppTelemetry telemetry;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('rating_service_test_');
    Hive.init(tempDir.path);
    settingsBox = await Hive.openBox<dynamic>(
      AppSettingsLocalDataSource.boxName,
    );
    stateDataSource = RatingPromptLocalDataSource(settingsBox);
    repository = _FakeMoodRepository();
    requester = _FakeReviewRequester(stateDataSource);
    telemetry = _FakeAppTelemetry();
  });

  tearDown(() async {
    await settingsBox.close();
    await tempDir.delete(recursive: true);
  });

  RatingPromptService buildService({bool isIOS = true}) {
    return RatingPromptService(
      getMoods: GetMoodsUseCase(repository),
      stateDataSource: stateDataSource,
      reviewRequester: requester,
      telemetry: telemetry,
      clock: () => now,
      isIOS: isIOS,
    );
  }

  void givenEntryDays(int days) {
    repository.entries = [
      for (var i = 0; i < days; i++) _entry(DateTime(2026, 9, 1 + i)),
    ];
  }

  group('maybeRequestAfterSave', () {
    test('requests the rating on the 3rd entry day and records the attempt',
        () async {
      givenEntryDays(3);

      await buildService().maybeRequestAfterSave();

      expect(requester.requestCalls, 1);
      expect(stateDataSource.getState().attempts, 1);
      expect(stateDataSource.getState().lastAttemptAt, now);
      expect(telemetry.events, hasLength(1));
      expect(telemetry.events.single.name,
          AppTelemetryEvents.ratingPromptRequested);
      expect(telemetry.events.single.properties,
          {'attempt': 1, 'total_entry_days': 3});
    });

    test('does not request with fewer than 3 entry days', () async {
      givenEntryDays(2);

      await buildService().maybeRequestAfterSave();

      expect(requester.requestCalls, 0);
      expect(stateDataSource.getState().attempts, 0);
      expect(telemetry.events, isEmpty);
    });

    test('counts several entries on the same day as one entry day', () async {
      repository.entries = [
        _entry(DateTime(2026, 9, 1, 8)),
        _entry(DateTime(2026, 9, 1, 20)),
        _entry(DateTime(2026, 9, 2)),
      ];

      await buildService().maybeRequestAfterSave();

      expect(requester.requestCalls, 0);
    });

    test('records the attempt before asking the system to show the prompt',
        () async {
      givenEntryDays(3);

      await buildService().maybeRequestAfterSave();

      expect(requester.attemptsSeenDuringRequest, 1);
    });

    test('does not request again right after the first attempt', () async {
      givenEntryDays(3);
      final service = buildService();

      await service.maybeRequestAfterSave();
      await service.maybeRequestAfterSave();

      expect(requester.requestCalls, 1);
      expect(stateDataSource.getState().attempts, 1);
    });

    test('requests a second time after 7 entry days and 30 days', () async {
      await stateDataSource.recordAttempt(
        now.subtract(const Duration(days: 31)),
      );
      givenEntryDays(7);

      await buildService().maybeRequestAfterSave();

      expect(requester.requestCalls, 1);
      expect(stateDataSource.getState().attempts, 2);
      expect(telemetry.events.single.properties,
          {'attempt': 2, 'total_entry_days': 7});
    });

    test('never requests after 2 attempts', () async {
      await stateDataSource.recordAttempt(
        now.subtract(const Duration(days: 90)),
      );
      await stateDataSource.recordAttempt(
        now.subtract(const Duration(days: 60)),
      );
      givenEntryDays(50);

      await buildService().maybeRequestAfterSave();

      expect(requester.requestCalls, 0);
      expect(stateDataSource.getState().attempts, 2);
    });

    test('does nothing outside iOS', () async {
      givenEntryDays(10);

      await buildService(isIOS: false).maybeRequestAfterSave();

      expect(requester.requestCalls, 0);
      expect(stateDataSource.getState().attempts, 0);
      expect(telemetry.events, isEmpty);
    });

    test('keeps the attempt and reports the error when the request throws',
        () async {
      givenEntryDays(3);
      requester.requestError = StateError('boom');

      await buildService().maybeRequestAfterSave();

      expect(stateDataSource.getState().attempts, 1);
      expect(telemetry.errors.single, 'rating_prompt_request_failed');
    });
  });

  group('openStoreListing', () {
    test('opens the listing and tracks the manual event', () async {
      await buildService().openStoreListing();

      expect(requester.openListingCalls, 1);
      expect(telemetry.events.single.name,
          AppTelemetryEvents.ratingManualOpened);
    });

    test('does not change the automatic attempts state', () async {
      await stateDataSource.recordAttempt(
        now.subtract(const Duration(days: 10)),
      );

      await buildService().openStoreListing();

      expect(stateDataSource.getState().attempts, 1);
      expect(stateDataSource.getState().lastAttemptAt,
          now.subtract(const Duration(days: 10)));
    });

    test('reports the error instead of throwing when opening fails', () async {
      requester.openListingError = StateError('boom');

      await buildService().openStoreListing();

      expect(telemetry.errors.single, 'rating_store_listing_failed');
    });
  });
}

MoodEntry _entry(DateTime date) {
  return MoodEntry(date: date, mood: 'happy', intensity: 1);
}

class _FakeMoodRepository implements MoodRepository {
  List<MoodEntry> entries = [];

  @override
  Future<List<MoodEntry>> getMoods() async => entries;

  @override
  Future<void> saveMood(MoodEntry entry) async {}

  @override
  Future<List<MoodEntry>> getMoodsForMonth(DateTime month) async => entries;
}

class _FakeReviewRequester implements ReviewRequester {
  _FakeReviewRequester(this._stateDataSource);

  final RatingPromptLocalDataSource _stateDataSource;

  int requestCalls = 0;
  int openListingCalls = 0;
  int? attemptsSeenDuringRequest;
  Object? requestError;
  Object? openListingError;

  @override
  Future<void> requestReview() async {
    requestCalls++;
    attemptsSeenDuringRequest = _stateDataSource.getState().attempts;
    final error = requestError;
    if (error != null) throw error;
  }

  @override
  Future<void> openStoreListing() async {
    openListingCalls++;
    final error = openListingError;
    if (error != null) throw error;
  }
}

class _CapturedEvent {
  const _CapturedEvent(this.name, this.properties);

  final String name;
  final Map<String, Object?> properties;
}

class _FakeAppTelemetry implements AppTelemetry {
  final List<_CapturedEvent> events = [];
  final List<String> errors = [];

  @override
  void trackEvent(
    String name, {
    Map<String, Object?> properties = const {},
  }) {
    events.add(_CapturedEvent(name, properties));
  }

  @override
  void recordError(
    String name, {
    String? reason,
    Map<String, Object?> context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    errors.add(name);
  }
}

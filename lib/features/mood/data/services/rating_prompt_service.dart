import 'dart:io';

import '../../../../core/rating/review_requester.dart';
import '../../../../core/settings/data/datasources/rating_prompt_local_datasource.dart';
import '../../../../core/telemetry/app_telemetry.dart';
import '../../../../core/telemetry/app_telemetry_events.dart';
import '../../domain/services/rating_prompt_policy.dart';
import '../../domain/usecases/get_moods_usecase.dart';

class RatingPromptService {
  RatingPromptService({
    required GetMoodsUseCase getMoods,
    required RatingPromptLocalDataSource stateDataSource,
    required ReviewRequester reviewRequester,
    required AppTelemetry telemetry,
    DateTime Function()? clock,
    bool? isIOS,
  })  : _getMoods = getMoods,
        _stateDataSource = stateDataSource,
        _reviewRequester = reviewRequester,
        _telemetry = telemetry,
        _clock = clock ?? DateTime.now,
        _isIOS = isIOS ?? Platform.isIOS;

  final GetMoodsUseCase _getMoods;
  final RatingPromptLocalDataSource _stateDataSource;
  final ReviewRequester _reviewRequester;
  final AppTelemetry _telemetry;
  final DateTime Function() _clock;
  final bool _isIOS;

  Future<void> maybeRequestAfterSave() async {
    if (!_isIOS) return;

    final entries = await _getMoods();
    final totalEntryDays = entries
        .map((entry) => DateTime(
              entry.date.year,
              entry.date.month,
              entry.date.day,
            ))
        .toSet()
        .length;
    final state = _stateDataSource.getState();
    final now = _clock();

    final shouldRequest = RatingPromptPolicy.shouldRequest(
      totalEntryDays: totalEntryDays,
      attempts: state.attempts,
      lastAttemptAt: state.lastAttemptAt,
      now: now,
    );
    if (!shouldRequest) return;

    await _stateDataSource.recordAttempt(now);
    _telemetry.trackEvent(
      AppTelemetryEvents.ratingPromptRequested,
      properties: {
        'attempt': state.attempts + 1,
        'total_entry_days': totalEntryDays,
      },
    );
    try {
      await _reviewRequester.requestReview();
    } catch (error, stackTrace) {
      _telemetry.recordError(
        'rating_prompt_request_failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> openStoreListing() async {
    _telemetry.trackEvent(AppTelemetryEvents.ratingManualOpened);
    try {
      await _reviewRequester.openStoreListing();
    } catch (error, stackTrace) {
      _telemetry.recordError(
        'rating_store_listing_failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}

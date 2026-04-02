import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/logging/app_logger.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry_events.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/mood/domain/repositories/mood_repository.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_moods_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/save_mood_usecase.dart';
import 'package:mood_calendar/features/mood/presentation/bloc/mood_cubit.dart';

void main() {
  test('tracks mood_saved without exposing note contents', () async {
    final repository = _FakeMoodRepository();
    final telemetry = _FakeAppTelemetry();
    final cubit = MoodCubit(
      saveMood: SaveMoodUseCase(repository),
      getMoods: GetMoodsUseCase(repository),
      logger: const _TestAppLogger(),
      telemetry: telemetry,
    );

    await cubit.save(
      MoodEntry(
        date: DateTime(2026, 4, 1, 22, 10),
        mood: 'assets/icon/calm.svg',
        note: 'Sensitive note',
        intensity: 2,
      ),
    );

    expect(telemetry.events, hasLength(1));
    expect(telemetry.events.single.name, AppTelemetryEvents.moodSaved);
    expect(telemetry.events.single.properties['date'], '2026-04-01');
    expect(telemetry.events.single.properties['mood'], 'calm.svg');
    expect(telemetry.events.single.properties['has_note'], 'true');
    expect(
      telemetry.events.single.properties.containsKey('note'),
      isFalse,
    );

    await cubit.close();
  });

  test('records a traceable error when mood save fails', () async {
    final repository = _FakeMoodRepository(throwOnSave: true);
    final telemetry = _FakeAppTelemetry();
    final cubit = MoodCubit(
      saveMood: SaveMoodUseCase(repository),
      getMoods: GetMoodsUseCase(repository),
      logger: const _TestAppLogger(),
      telemetry: telemetry,
    );

    await cubit.save(
      MoodEntry(
        date: DateTime(2026, 4, 3),
        mood: 'assets/icon/angry.svg',
        intensity: 5,
      ),
    );

    expect(telemetry.errors, hasLength(1));
    expect(telemetry.errors.single.name, 'save_mood_failed');
    expect(telemetry.errors.single.reason, 'save_use_case');
    expect(telemetry.errors.single.context['date'], '2026-04-03');
    expect(telemetry.errors.single.context['mood'], 'angry.svg');
    expect(
      cubit.state.maybeWhen(
        error: (message) => message.contains('save failed'),
        orElse: () => false,
      ),
      isTrue,
    );

    await cubit.close();
  });
}

class _FakeMoodRepository implements MoodRepository {
  _FakeMoodRepository({this.throwOnSave = false});

  final bool throwOnSave;
  final List<MoodEntry> _entries = [];

  @override
  Future<List<MoodEntry>> getMoods() async => List<MoodEntry>.from(_entries);

  @override
  Future<List<MoodEntry>> getMoodsForMonth(DateTime month) async {
    return _entries.where((entry) {
      return entry.date.year == month.year && entry.date.month == month.month;
    }).toList();
  }

  @override
  Future<void> saveMood(MoodEntry entry) async {
    if (throwOnSave) {
      throw Exception('save failed');
    }
    _entries.add(entry);
  }
}

class _FakeAppTelemetry implements AppTelemetry {
  final List<_CapturedEvent> events = [];
  final List<_CapturedError> errors = [];

  @override
  void recordError(
    String name, {
    String? reason,
    Map<String, Object?> context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    errors.add(
      _CapturedError(name: name, reason: reason, context: Map.of(context)),
    );
  }

  @override
  void trackEvent(
    String name, {
    Map<String, Object?> properties = const {},
  }) {
    events.add(_CapturedEvent(name: name, properties: Map.of(properties)));
  }
}

class _CapturedEvent {
  const _CapturedEvent({required this.name, required this.properties});

  final String name;
  final Map<String, Object?> properties;
}

class _CapturedError {
  const _CapturedError({
    required this.name,
    required this.reason,
    required this.context,
  });

  final String name;
  final String? reason;
  final Map<String, Object?> context;
}

class _TestAppLogger implements AppLogger {
  const _TestAppLogger();

  @override
  void debug(
    String message, {
    String tag = '',
    Object? error,
    StackTrace? stackTrace,
  }) {}

  @override
  void error(
    String message, {
    String tag = '',
    Object? error,
    StackTrace? stackTrace,
  }) {}
}

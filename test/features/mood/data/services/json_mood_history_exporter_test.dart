import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/logging/app_logger.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry.dart';
import 'package:mood_calendar/features/mood/data/services/json_mood_history_exporter.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_history_export_result.dart';
import 'package:mood_calendar/features/mood/domain/repositories/mood_repository.dart';

void main() {
  late Directory tempDir;
  late _FakeAppTelemetry telemetry;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mood_export_test_');
    telemetry = _FakeAppTelemetry();
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  JsonMoodHistoryExporter buildExporter(
    List<MoodEntry> entries, {
    DateTime? now,
  }) {
    return JsonMoodHistoryExporter(
      repository: _FakeMoodRepository(entries),
      logger: const _TestAppLogger(),
      telemetry: telemetry,
      directoryProvider: () async => tempDir,
      now: () => now ?? DateTime(2026, 4, 3, 10, 11, 12),
    );
  }

  // intensity is required by the entity but must never reach the file.
  MoodEntry entry(DateTime date, String mood, {String? note}) =>
      MoodEntry(date: date, mood: mood, note: note, intensity: 1);

  Future<Map<String, dynamic>> readPayload(
    MoodHistoryExportResult result,
  ) async {
    return jsonDecode(await File(result.filePath).readAsString())
        as Map<String, dynamic>;
  }

  test('exports mood history as a versioned json file', () async {
    final result = await buildExporter([
      MoodEntry(
        date: DateTime(2026, 4, 2, 21, 30),
        mood: 'assets/icon/calm.svg',
        note: 'Quiet day',
        intensity: 2,
      ),
      MoodEntry(
        date: DateTime(2026, 4, 1, 8, 15),
        mood: 'assets/icon/happy.svg',
        intensity: 1,
      ),
    ]).exportHistory();
    final payload = await readPayload(result);
    final entries = payload['entries'] as List<dynamic>;

    expect(result.fileName, 'mood-history-20260403-101112.json');
    expect(result.entryCount, 2);
    expect(payload['formatVersion'], 1);
    expect(payload['entryCount'], 2);
    expect(
      payload['generatedAt'],
      DateTime(2026, 4, 3, 10, 11, 12).toUtc().toIso8601String(),
    );
    expect(entries, [
      {'date': '2026-04-01', 'mood': 'happy', 'note': null},
      {'date': '2026-04-02', 'mood': 'calm', 'note': 'Quiet day'},
    ]);
  });

  test('entries carry only date, stable mood id and note', () async {
    final result = await buildExporter([
      MoodEntry(
        date: DateTime(2026, 4, 2),
        mood: 'assets/icon/calm.svg',
        intensity: 2,
      ),
    ]).exportHistory();
    final raw = await File(result.filePath).readAsString();
    final entry = (await readPayload(result))['entries'][0] as Map;

    expect(entry.keys, unorderedEquals(['date', 'mood', 'note']));
    expect(raw, isNot(contains('intensity')));
    expect(raw, isNot(contains('assets/')));
  });

  test('sorts entries by date ascending whatever the stored order', () async {
    final result = await buildExporter([
      entry(DateTime(2026, 4, 3), 'assets/icon/sad.svg'),
      entry(DateTime(2026, 4, 1), 'assets/icon/happy.svg'),
      entry(DateTime(2026, 4, 2), 'assets/icon/calm.svg'),
    ]).exportHistory();
    final payload = await readPayload(result);
    final dates = (payload['entries'] as List)
        .map((entry) => (entry as Map)['date'])
        .toList();

    expect(dates, ['2026-04-01', '2026-04-02', '2026-04-03']);
    expect(payload['entryCount'], 3);
  });

  test('exports premium moods whether or not they are unlocked', () async {
    final result = await buildExporter([
      entry(DateTime(2026, 4, 1), 'assets/icon/anxious.svg'),
    ]).exportHistory();

    expect((await readPayload(result))['entries'][0]['mood'], 'anxious');
  });

  test('exports an unrecognized mood as stored, not as another mood', () async {
    final result = await buildExporter([
      entry(DateTime(2026, 4, 1), 'assets/icon/retired.svg'),
    ]).exportHistory();

    expect(
      (await readPayload(result))['entries'][0]['mood'],
      'assets/icon/retired.svg',
    );
  });

  test('an empty history exports zero entries', () async {
    final result = await buildExporter([]).exportHistory();

    expect(result.entryCount, 0);
    expect((await readPayload(result))['entries'], isEmpty);
  });

  test('keeps only the latest export in the directory', () async {
    final exports = Directory('${tempDir.path}/exports')..createSync();
    File('${exports.path}/mood-history-20250101-000000.json')
        .writeAsStringSync('{}');
    File('${exports.path}/unrelated.txt').writeAsStringSync('keep me');

    final result = await buildExporter([
      entry(DateTime(2026, 4, 1), 'assets/icon/happy.svg'),
    ]).exportHistory();

    final names = exports
        .listSync()
        .map((entity) => entity.uri.pathSegments.last)
        .toList();
    expect(names, containsAll([result.fileName, 'unrelated.txt']));
    expect(names, isNot(contains('mood-history-20250101-000000.json')));
  });

  test('telemetry reports the count and never the note text', () async {
    await buildExporter([
      entry(
        DateTime(2026, 4, 1),
        'assets/icon/happy.svg',
        note: 'very private note',
      ),
    ]).exportHistory();

    final event = telemetry.events.single;
    expect(event.name, 'mood_history_exported');
    expect(event.properties['entry_count'], 1);
    expect(event.properties.toString(), isNot(contains('private')));
  });

  test('records a traceable error when export fails', () async {
    final exporter = JsonMoodHistoryExporter(
      repository: const _FakeMoodRepository([]),
      logger: const _TestAppLogger(),
      telemetry: telemetry,
      directoryProvider: () async {
        throw const FileSystemException('directory lookup failed');
      },
    );

    await expectLater(
      exporter.exportHistory(),
      throwsA(isA<FileSystemException>()),
    );

    expect(telemetry.errors, hasLength(1));
    expect(telemetry.errors.single.name, 'mood_history_export_failed');
    expect(telemetry.errors.single.reason, 'write_export_file');
  });
}

class _FakeMoodRepository implements MoodRepository {
  const _FakeMoodRepository(this._entries);

  final List<MoodEntry> _entries;

  @override
  Future<List<MoodEntry>> getMoods() async => List<MoodEntry>.from(_entries);

  @override
  Future<List<MoodEntry>> getMoodsForMonth(DateTime month) async {
    return _entries.where((entry) {
      return entry.date.year == month.year && entry.date.month == month.month;
    }).toList();
  }

  @override
  Future<void> saveMood(MoodEntry entry) async {}
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
    errors.add(_CapturedError(name: name, reason: reason));
  }

  @override
  void trackEvent(
    String name, {
    Map<String, Object?> properties = const {},
  }) {
    events.add(_CapturedEvent(name: name, properties: properties));
  }
}

class _CapturedEvent {
  const _CapturedEvent({required this.name, required this.properties});

  final String name;
  final Map<String, Object?> properties;
}

class _CapturedError {
  const _CapturedError({required this.name, required this.reason});

  final String name;
  final String? reason;
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

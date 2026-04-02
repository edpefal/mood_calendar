import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/logging/app_logger.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry.dart';
import 'package:mood_calendar/features/mood/data/services/json_mood_history_exporter.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/mood/domain/repositories/mood_repository.dart';

void main() {
  test('exports mood history as a json file with useful fields', () async {
    final tempDir = await Directory.systemTemp.createTemp('mood_export_test_');
    final telemetry = _FakeAppTelemetry();
    final exporter = JsonMoodHistoryExporter(
      repository: _FakeMoodRepository([
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
      ]),
      logger: const _TestAppLogger(),
      telemetry: telemetry,
      directoryProvider: () async => tempDir,
      now: () => DateTime(2026, 4, 3, 10, 11, 12),
    );

    final result = await exporter.exportHistory();
    final file = File(result.filePath);
    final payload =
        jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final entries = payload['entries'] as List<dynamic>;

    expect(result.fileName, 'mood-history-20260403-101112.json');
    expect(result.entryCount, 2);
    expect(await file.exists(), isTrue);
    expect(payload['entryCount'], 2);
    expect(
      payload['generatedAt'],
      DateTime(2026, 4, 3, 10, 11, 12).toUtc().toIso8601String(),
    );
    expect(entries[0]['date'], '2026-04-01');
    expect(entries[0]['mood'], 'assets/icon/happy.svg');
    expect(entries[0]['note'], isNull);
    expect(entries[1]['date'], '2026-04-02');
    expect(entries[1]['note'], 'Quiet day');
    expect(telemetry.events.single.name, 'mood_history_exported');

    await tempDir.delete(recursive: true);
  });

  test('records a traceable error when export fails', () async {
    final telemetry = _FakeAppTelemetry();
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
    events.add(_CapturedEvent(name: name));
  }
}

class _CapturedEvent {
  const _CapturedEvent({required this.name});

  final String name;
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

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/telemetry/app_telemetry.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/entities/mood_history_export_result.dart';
import '../../domain/repositories/mood_repository.dart';
import '../../domain/services/mood_history_exporter.dart';

typedef ExportDirectoryProvider = Future<Directory> Function();

class JsonMoodHistoryExporter implements MoodHistoryExporter {
  JsonMoodHistoryExporter({
    required MoodRepository repository,
    required AppLogger logger,
    required AppTelemetry telemetry,
    ExportDirectoryProvider? directoryProvider,
    DateTime Function()? now,
  })  : _repository = repository,
        _logger = logger,
        _telemetry = telemetry,
        _directoryProvider =
            directoryProvider ?? getApplicationDocumentsDirectory,
        _now = now ?? DateTime.now;

  final MoodRepository _repository;
  final AppLogger _logger;
  final AppTelemetry _telemetry;
  final ExportDirectoryProvider _directoryProvider;
  final DateTime Function() _now;

  @override
  Future<MoodHistoryExportResult> exportHistory() async {
    try {
      final entries = await _repository.getMoods();
      entries.sort((a, b) => a.date.compareTo(b.date));

      final baseDirectory = await _directoryProvider();
      final exportDirectory = Directory('${baseDirectory.path}/exports');
      await exportDirectory.create(recursive: true);

      final timestamp = _fileSafeTimestamp(_now());
      final fileName = 'mood-history-$timestamp.json';
      final file = File('${exportDirectory.path}/$fileName');

      final payload = <String, Object?>{
        'generatedAt': _isoDateTime(_now().toUtc()),
        'entryCount': entries.length,
        'entries': entries.map(_entryToJson).toList(),
      };

      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(payload),
      );

      _logger.debug(
        'Mood history exported to ${file.path}',
        tag: 'MoodExport',
      );
      _telemetry.trackEvent(
        'mood_history_exported',
        properties: {
          'entry_count': entries.length,
          'file_name': fileName,
        },
      );

      return MoodHistoryExportResult(
        filePath: file.path,
        fileName: fileName,
        entryCount: entries.length,
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Mood history export failed',
        tag: 'MoodExport',
        error: error,
        stackTrace: stackTrace,
      );
      _telemetry.recordError(
        'mood_history_export_failed',
        reason: 'write_export_file',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Map<String, Object?> _entryToJson(MoodEntry entry) {
    return {
      'date': _isoDate(entry.date),
      'mood': entry.mood,
      'note': entry.note,
      'intensity': entry.intensity,
    };
  }

  String _isoDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '${normalized.year}-$month-$day';
  }

  String _isoDateTime(DateTime date) => date.toIso8601String();

  String _fileSafeTimestamp(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    return '${date.year}$month$day-$hour$minute$second';
  }
}

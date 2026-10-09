import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/telemetry/app_telemetry.dart';
import '../../domain/entities/mood_definition.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/entities/mood_history_export_result.dart';
import '../../domain/repositories/mood_repository.dart';
import '../../domain/services/mood_history_exporter.dart';

typedef ExportDirectoryProvider = Future<Directory> Function();

/// Version of the exported file layout; bump it when the format changes.
const moodHistoryExportFormatVersion = 1;

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
            directoryProvider ?? getTemporaryDirectory,
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
      await _deletePreviousExports(exportDirectory);

      final timestamp = _fileSafeTimestamp(_now());
      final fileName = 'mood-history-$timestamp.json';
      final file = File('${exportDirectory.path}/$fileName');

      final payload = <String, Object?>{
        'formatVersion': moodHistoryExportFormatVersion,
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
      'mood': _moodId(entry.mood),
      'note': entry.note,
    };
  }

  /// The stable mood id (e.g. `calm`). Unlike
  /// `MoodDefinitionResolver.byAssetPath` this never falls back to another
  /// mood: an unrecognized value is exported as stored, so the file does not
  /// claim a mood the user never picked.
  String _moodId(String storedMood) {
    for (final definition in allMoodDefinitions) {
      if (definition.assetPath == storedMood) return definition.id;
    }
    return storedMood;
  }

  /// Exports are temporary copies of the user's notes: keep only the latest.
  Future<void> _deletePreviousExports(Directory exportDirectory) async {
    await for (final entity in exportDirectory.list()) {
      final name = entity.uri.pathSegments.last;
      if (entity is File &&
          name.startsWith('mood-history-') &&
          name.endsWith('.json')) {
        await entity.delete();
      }
    }
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

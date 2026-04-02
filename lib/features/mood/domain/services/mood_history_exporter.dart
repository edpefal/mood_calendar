import '../entities/mood_history_export_result.dart';

abstract class MoodHistoryExporter {
  Future<MoodHistoryExportResult> exportHistory();
}

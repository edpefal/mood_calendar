import '../entities/mood_history_export_result.dart';
import '../services/mood_history_exporter.dart';

class ExportMoodHistoryUseCase {
  ExportMoodHistoryUseCase(this._exporter);

  final MoodHistoryExporter _exporter;

  Future<MoodHistoryExportResult> call() => _exporter.exportHistory();
}

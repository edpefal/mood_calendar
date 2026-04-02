class MoodHistoryExportResult {
  const MoodHistoryExportResult({
    required this.filePath,
    required this.fileName,
    required this.entryCount,
  });

  final String filePath;
  final String fileName;
  final int entryCount;
}

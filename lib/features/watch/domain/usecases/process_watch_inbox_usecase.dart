import '../../../mood/domain/entities/mood_definition.dart';
import '../../../mood/domain/entities/mood_entry.dart';
import '../../../mood/domain/repositories/mood_repository.dart';
import '../repositories/watch_channel.dart';

class WatchInboxResult {
  const WatchInboxResult({
    required this.applied,
    required this.ignored,
    this.handledIds = const [],
  });

  /// Mood Entries creadas o cambiadas.
  final int applied;

  /// Elecciones descartadas por no cumplir el contrato o por estar bloqueadas.
  final int ignored;

  /// Ids de todas las elecciones procesadas (aplicadas o descartadas) y ya
  /// confirmadas al canal; se publican al reloj para que quite su marca
  /// "pendiente".
  final List<String> handledIds;
}

/// Aplica en Hive las elecciones que llegaron del Apple Watch.
///
/// Reglas (spec `watch-mood-picker`): el mood se reemplaza y la nota existente
/// se conserva; un id desconocido o bloqueado se ignora sin error; entre varias
/// elecciones del mismo día gana la de mayor `chosenAt`. Solo se confirma al
/// canal lo ya procesado, para no perder nada si la app muere a medias.
class ProcessWatchInboxUseCase {
  ProcessWatchInboxUseCase({
    required this.repository,
    required this.channel,
    required this.isUnlocked,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final MoodRepository repository;
  final WatchChannel channel;

  /// Nota: `MoodEntitlementsRepository.isUnlocked` devuelve true para ids
  /// desconocidos, por eso el id se valida aquí contra el catálogo.
  final bool Function(String moodId) isUnlocked;
  final DateTime Function() _now;

  static final _datePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  Future<WatchInboxResult> call() async {
    final choices = await channel.readInbox();
    if (choices.isEmpty) {
      return const WatchInboxResult(applied: 0, ignored: 0);
    }

    final sorted = [...choices]
      ..sort((a, b) => a.chosenAt.compareTo(b.chosenAt));

    // La última elección válida de cada fecha.
    final latestByDate = <DateTime, MoodDefinition>{};
    var ignored = 0;
    for (final choice in sorted) {
      final date = _parseDate(choice.date);
      final definition = _definitionFor(choice.mood);
      if (date == null || definition == null || !isUnlocked(definition.id)) {
        ignored++;
        continue;
      }
      latestByDate[date] = definition;
    }

    var applied = 0;
    final existingByDate = await _entriesByDate();
    for (final MapEntry(key: date, value: definition) in latestByDate.entries) {
      final existing = existingByDate[date];
      if (existing != null && existing.mood == definition.assetPath) {
        continue;
      }
      await repository.saveMood(
        MoodEntry(
          date: date,
          mood: definition.assetPath,
          note: existing?.note,
          intensity: definition.intensity,
        ),
      );
      applied++;
    }

    final handledIds = [for (final choice in choices) choice.id];
    await channel.ackInbox(handledIds);
    return WatchInboxResult(
      applied: applied,
      ignored: ignored,
      handledIds: handledIds,
    );
  }

  Future<Map<DateTime, MoodEntry>> _entriesByDate() async {
    final entries = await repository.getMoods();
    return {
      for (final entry in entries)
        DateTime(entry.date.year, entry.date.month, entry.date.day): entry,
    };
  }

  MoodDefinition? _definitionFor(String moodId) {
    for (final definition in allMoodDefinitions) {
      if (definition.id == moodId) return definition;
    }
    return null;
  }

  /// `YYYY-MM-DD` válido y no futuro (se tolera un día por la zona horaria).
  DateTime? _parseDate(String raw) {
    final match = _datePattern.firstMatch(raw);
    if (match == null) return null;
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    final now = _now();
    final latestAllowed = DateTime(now.year, now.month, now.day + 1);
    return date.isAfter(latestAllowed) ? null : date;
  }
}

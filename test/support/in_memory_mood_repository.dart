import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/mood/domain/repositories/mood_repository.dart';

/// Repositorio en memoria con una entrada por día, como Hive.
class InMemoryMoodRepository implements MoodRepository {
  InMemoryMoodRepository([List<MoodEntry> entries = const []])
      : entries = [...entries];

  final List<MoodEntry> entries;
  int saves = 0;

  /// Si es mayor que 0, los siguientes `saveMood` fallan y lo decrementan.
  int failNextSaves = 0;

  @override
  Future<void> saveMood(MoodEntry entry) async {
    if (failNextSaves > 0) {
      failNextSaves--;
      throw StateError('save failed');
    }
    saves++;
    entries.removeWhere((e) => _sameDay(e.date, entry.date));
    entries.add(entry);
  }

  @override
  Future<List<MoodEntry>> getMoods() async => [...entries];

  @override
  Future<List<MoodEntry>> getMoodsForMonth(DateTime month) async => entries
      .where((e) => e.date.year == month.year && e.date.month == month.month)
      .toList();

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

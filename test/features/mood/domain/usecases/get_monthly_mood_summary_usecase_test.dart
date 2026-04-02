import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/mood/domain/repositories/mood_repository.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_monthly_mood_summary_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_moods_for_month_usecase.dart';

void main() {
  test('builds a sorted summary with average, best streak and last entry',
      () async {
    final repository = _InMemoryMoodRepository(
      moods: [
        MoodEntry(
          date: DateTime(2026, 4, 12),
          mood: 'assets/icon/sad.svg',
          intensity: 4,
        ),
        MoodEntry(
          date: DateTime(2026, 4, 10),
          mood: 'assets/icon/happy.svg',
          intensity: 1,
        ),
        MoodEntry(
          date: DateTime(2026, 4, 11),
          mood: 'assets/icon/calm.svg',
          intensity: 2,
        ),
        MoodEntry(
          date: DateTime(2026, 4, 15),
          mood: 'assets/icon/neutral.svg',
          intensity: 3,
        ),
      ],
    );
    final useCase = GetMonthlyMoodSummaryUseCase(
      GetMoodsForMonthUseCase(repository),
    );

    final summary = await useCase(DateTime(2026, 4, 30));

    expect(summary.month, DateTime(2026, 4));
    expect(summary.entries.map((entry) => entry.date.day), [10, 11, 12, 15]);
    expect(summary.averageScore, 2.5);
    expect(summary.bestStreak, 3);
    expect(summary.lastEntry?.date.day, 15);
  });

  test('returns zeroed summary when the month has no entries', () async {
    final repository = _InMemoryMoodRepository(moods: const []);
    final useCase = GetMonthlyMoodSummaryUseCase(
      GetMoodsForMonthUseCase(repository),
    );

    final summary = await useCase(DateTime(2026, 4, 1));

    expect(summary.entries, isEmpty);
    expect(summary.averageScore, 0);
    expect(summary.bestStreak, 0);
    expect(summary.lastEntry, isNull);
  });
}

class _InMemoryMoodRepository implements MoodRepository {
  _InMemoryMoodRepository({required List<MoodEntry> moods})
      : _moods = List<MoodEntry>.from(moods);

  final List<MoodEntry> _moods;

  @override
  Future<List<MoodEntry>> getMoods() async => List<MoodEntry>.from(_moods);

  @override
  Future<List<MoodEntry>> getMoodsForMonth(DateTime month) async {
    return _moods.where((entry) {
      return entry.date.year == month.year && entry.date.month == month.month;
    }).toList();
  }

  @override
  Future<void> saveMood(MoodEntry entry) async {
    _moods.add(entry);
  }
}

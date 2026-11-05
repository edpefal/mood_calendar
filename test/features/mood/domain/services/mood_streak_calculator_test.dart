import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/mood/domain/services/mood_streak_calculator.dart';

void main() {
  group('MoodStreakCalculator.bestStreak', () {
    test('returns 0 for an empty list', () {
      expect(MoodStreakCalculator.bestStreak([]), 0);
    });

    test('returns 1 for a single date', () {
      expect(MoodStreakCalculator.bestStreak([DateTime(2026, 4, 10)]), 1);
    });

    test('counts a simple consecutive run', () {
      final dates = [
        DateTime(2026, 4, 10),
        DateTime(2026, 4, 11),
        DateTime(2026, 4, 12),
      ];
      expect(MoodStreakCalculator.bestStreak(dates), 3);
    });

    test('resets the streak when there is a gap', () {
      final dates = [
        DateTime(2026, 4, 10),
        DateTime(2026, 4, 11),
        DateTime(2026, 4, 13),
        DateTime(2026, 4, 14),
        DateTime(2026, 4, 15),
      ];
      expect(MoodStreakCalculator.bestStreak(dates), 3);
    });

    test('counts a streak that crosses a month boundary as consecutive', () {
      final dates = [
        DateTime(2026, 1, 30),
        DateTime(2026, 1, 31),
        DateTime(2026, 2, 1),
        DateTime(2026, 2, 2),
      ];
      expect(MoodStreakCalculator.bestStreak(dates), 4);
    });

    test('counts a streak that crosses a year boundary as consecutive', () {
      final dates = [
        DateTime(2025, 12, 30),
        DateTime(2025, 12, 31),
        DateTime(2026, 1, 1),
      ];
      expect(MoodStreakCalculator.bestStreak(dates), 3);
    });
  });

  group('MoodStreakCalculator.currentStreak', () {
    test('is 0 when the end date has no entry', () {
      expect(
        MoodStreakCalculator.currentStreak(
          [DateTime(2026, 4, 9)],
          DateTime(2026, 4, 10),
        ),
        0,
      );
    });

    test('is 1 for a lone entry on the end date', () {
      expect(
        MoodStreakCalculator.currentStreak(
          [DateTime(2026, 4, 10)],
          DateTime(2026, 4, 10),
        ),
        1,
      );
    });

    test('counts the run that ends on the end date', () {
      final dates = [
        DateTime(2026, 4, 5),
        DateTime(2026, 4, 8),
        DateTime(2026, 4, 9),
        DateTime(2026, 4, 10),
      ];
      expect(
          MoodStreakCalculator.currentStreak(dates, DateTime(2026, 4, 10)), 3);
    });

    test('ignores entries after the end date', () {
      final dates = [
        DateTime(2026, 4, 9),
        DateTime(2026, 4, 10),
        DateTime(2026, 4, 11),
      ];
      expect(
          MoodStreakCalculator.currentStreak(dates, DateTime(2026, 4, 10)), 2);
    });

    test('crosses a month boundary', () {
      final dates = [
        DateTime(2026, 1, 31),
        DateTime(2026, 2, 1),
        DateTime(2026, 2, 2),
      ];
      expect(
          MoodStreakCalculator.currentStreak(dates, DateTime(2026, 2, 2)), 3);
    });

    test('crosses a year boundary', () {
      final dates = [
        DateTime(2025, 12, 31),
        DateTime(2026, 1, 1),
      ];
      expect(
          MoodStreakCalculator.currentStreak(dates, DateTime(2026, 1, 1)), 2);
    });

    test('counts several entries on one day once and ignores the time', () {
      final dates = [
        DateTime(2026, 4, 9, 8),
        DateTime(2026, 4, 10, 7),
        DateTime(2026, 4, 10, 22),
      ];
      expect(
        MoodStreakCalculator.currentStreak(dates, DateTime(2026, 4, 10, 12)),
        2,
      );
    });
  });

  currentStreakAsOfTests();
}

void currentStreakAsOfTests() {
  group('currentStreakAsOf', () {
    final today = DateTime(2026, 11, 4);

    test('counts from today when today has an entry', () {
      final dates = [
        DateTime(2026, 11, 2),
        DateTime(2026, 11, 3),
        DateTime(2026, 11, 4),
      ];
      expect(MoodStreakCalculator.currentStreakAsOf(dates, today), 3);
    });

    test('counts from yesterday while today has no entry yet', () {
      final dates = [DateTime(2026, 11, 2), DateTime(2026, 11, 3)];
      expect(MoodStreakCalculator.currentStreakAsOf(dates, today), 2);
    });

    test('is 0 when neither today nor yesterday has an entry', () {
      final dates = [DateTime(2026, 11, 1), DateTime(2026, 11, 2)];
      expect(MoodStreakCalculator.currentStreakAsOf(dates, today), 0);
    });

    test('crosses a month and a year boundary', () {
      final dates = [
        DateTime(2025, 12, 30),
        DateTime(2025, 12, 31),
        DateTime(2026, 1, 1),
      ];
      expect(
        MoodStreakCalculator.currentStreakAsOf(dates, DateTime(2026, 1, 2)),
        3,
      );
    });
  });
}

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
}

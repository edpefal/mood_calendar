import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/mood/domain/services/logged_time.dart';

void main() {
  MoodEntry entry(DateTime date, DateTime? loggedAt) => MoodEntry(
        date: date,
        mood: 'assets/icon/calm.svg',
        intensity: 2,
        loggedAt: loggedAt,
      );

  test('shows the time when it was logged on the entry day', () {
    final at = DateTime(2026, 11, 2, 21, 2);
    expect(loggedTimeFor(entry(DateTime(2026, 11, 2), at)), at);
  });

  test('hides the time when the entry was logged on another day', () {
    final at = DateTime(2026, 11, 3, 9, 30);
    expect(loggedTimeFor(entry(DateTime(2026, 11, 2), at)), isNull);
  });

  test('hides the time for an entry saved before the field existed', () {
    expect(loggedTimeFor(entry(DateTime(2026, 11, 2), null)), isNull);
  });

  test('treats the same day of another month or year as a different day', () {
    final at = DateTime(2027, 11, 2, 8);
    expect(loggedTimeFor(entry(DateTime(2026, 11, 2), at)), isNull);
  });
}

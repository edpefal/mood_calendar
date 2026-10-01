## 1. Extract and fix the streak calculator

- [x] 1.1 Create `lib/features/mood/domain/services/mood_streak_calculator.dart` with a `MoodStreakCalculator` that computes the best streak from a list of sorted dates, using only `difference(...).inDays == 1` (no month/year equality check)
- [x] 1.2 Update `GetMonthlyMoodSummaryUseCase` to delegate to `MoodStreakCalculator` instead of its private `_calculateBestStreak`, removing the old private method

## 2. Tests

- [x] 2.1 Add `test/features/mood/domain/services/mood_streak_calculator_test.dart` covering: empty list (streak 0), single entry (streak 1), simple consecutive run, a run broken by a gap, and — the actual bug fix — a streak spanning a month boundary (e.g. Jan 31 → Feb 1) and a year boundary (Dec 31 → Jan 1), both counted as consecutive
- [x] 2.2 Run `flutter test test/features/mood/domain/usecases/get_monthly_mood_summary_usecase_test.dart` and confirm all existing assertions (including `bestStreak`) still pass unchanged after the extraction — all 4 tests pass unchanged
- [x] 2.3 Run `flutter test` (full suite) and `flutter analyze` to confirm no regressions — 28/28 tests pass, `flutter analyze` clean

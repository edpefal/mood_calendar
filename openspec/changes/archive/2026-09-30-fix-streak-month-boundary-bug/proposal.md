## Why

`GetMonthlyMoodSummaryUseCase._calculateBestStreak` treats two entries as consecutive only when `currentDate.difference(previousDate).inDays == 1` **and** `currentDate.month == previousDate.month` **and** `currentDate.year == previousDate.year`. The month/year equality checks are wrong: two calendar days can be exactly one day apart while belonging to different months or years (Jan 31 → Feb 1, Dec 31 → Jan 1), and those are genuinely consecutive days. The check should rely purely on the day difference.

This is currently dormant — `GetMoodsForMonthUseCase`/`MoodRepositoryImpl.getMoodsForMonth` only ever return entries from a single calendar month, so the redundant checks never trigger against real cross-month data today. But it's a latent correctness bug in the streak algorithm itself, and it will silently break any future feature that reuses this logic across a date range spanning more than one month (e.g. an all-time "best streak" or "current streak" stat, discussed as a possible growth feature). Fixing it now, while it's cheap and isolated, avoids debugging a confusing off-by-one-month streak count later.

## What Changes

- Extract the streak-counting logic out of `GetMonthlyMoodSummaryUseCase` into its own small, directly testable unit, fixing it to determine consecutiveness solely from the day difference between two sorted dates (`currentDate.difference(previousDate).inDays == 1`), removing the incorrect `month`/`year` equality checks.
- `GetMonthlyMoodSummaryUseCase` keeps its current public behavior (streak for one calendar month's entries), now delegating to the extracted unit.
- Add test coverage for the extracted unit proving a streak spanning a month/year boundary is counted correctly — see design.md for why this requires extraction rather than testing the existing private method in place.

No change to the monthly view's current observable behavior (since `getMoodsForMonth` never supplies cross-month entries), but the fix is required groundwork before any all-time/multi-month streak feature can be built correctly.

## Capabilities

### New Capabilities
_None._

### Modified Capabilities
- `monthly-mood-summary`: clarify that "días consecutivos" for the best-streak calculation means consecutive calendar days, regardless of month or year boundary.

## Impact

- `lib/features/mood/domain/usecases/get_monthly_mood_summary_usecase.dart` — remove inline `_calculateBestStreak`, delegate to the new unit.
- New file for the extracted streak-calculation unit (location decided in design.md).
- New test file for that unit, covering the month/year boundary case. Existing tests in `test/features/mood/domain/usecases/get_monthly_mood_summary_usecase_test.dart` must keep passing unchanged.

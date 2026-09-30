## Context

`GetMonthlyMoodSummaryUseCase._calculateBestStreak` is a private method. It's only ever invoked with entries already filtered to a single calendar month (`GetMoodsForMonthUseCase` → `MoodRepositoryImpl.getMoodsForMonth`, which filters by exact `year`/`month` match). The buggy `month == month && year == year` check is therefore dead code today: within a single month's entries, consecutive-day pairs are always in the same month and year, so the check never evaluates false when the day-difference check wouldn't already have. There is no way to exercise the fix through the use case's public API without also feeding it entries from more than one month — which the use case's own data source never does.

## Goals / Non-Goals

**Goals:**
- Fix the day-consecutiveness logic so it's correct for any date sequence, not just single-month ones.
- Make the fix verifiable with a real test that exercises the month/year-boundary case.
- Keep `GetMonthlyMoodSummaryUseCase`'s public behavior and existing tests unchanged.

**Non-Goals:**
- Building the all-time/current streak feature itself (separate future change).
- Changing how `MonthlyMoodSummaryCard` or the calendar screen display streaks.

## Decisions

**Extract the streak-counting logic into its own small class, `MoodStreakCalculator`, in `lib/features/mood/domain/services/` (alongside `mood_definition_resolver.dart` and `mood_history_exporter.dart`, the existing home for this kind of stateless domain helper). It takes a list of already-sorted `DateTime`s (or `MoodEntry`s) and returns the best streak as an `int`.**

Rationale: this is the only way to add a real, non-contrived test for the boundary fix — a private method fed only single-month data can't demonstrate the fix through the public API. Extracting into its own class makes the unit directly testable with an arbitrary multi-month date sequence, independent of `GetMoodsForMonthUseCase`'s filtering. It also happens to be exactly the reusable piece a future all-time/current-streak feature would need — this change doesn't build that feature, but it stops throwaway duplication of the (now correct) algorithm when that feature does get built.

Alternative considered: keep the method on `GetMonthlyMoodSummaryUseCase` and mark it `@visibleForTesting`. Rejected — it still couples the streak algorithm to this one use case, doesn't help the future all-time-streak feature reuse it, and `@visibleForTesting` on a method that's conceptually independent of "monthly summary" is a weaker fix than giving the algorithm its own home.

`GetMonthlyMoodSummaryUseCase` calls `MoodStreakCalculator` internally; its own public `call()` signature and return type (`MonthlyMoodSummary`) don't change.

## Risks / Trade-offs

- [Risk] Behavior drift between the extracted calculator and what `GetMonthlyMoodSummaryUseCase`'s existing tests expect for `bestStreak` → Mitigation: the existing test file's `bestStreak` assertions (e.g. `summary.bestStreak == 3` for consecutive same-month days) must keep passing unchanged after the extraction, since within-month behavior is identical, just relocated.

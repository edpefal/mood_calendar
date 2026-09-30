## Context

`main()` currently awaits, in order, before calling `runApp()`: Hive setup, repository construction, `notificationService.initialize()` (which internally awaits the native "Allow Notifications?" permission dialog via `requestPermissions()`), `notificationService.scheduleDailyReminder()`, and RevenueCat `configure()`. Only `notificationService.initialize()` actually waits on user interaction with a system dialog — everything else is local/async SDK setup with no UI. See proposal.md for the App Review rejection this caused.

`MoodEntitlementsRepositoryImpl`'s constructor calls `datasource.startListening()`, which calls `Purchases.addCustomerInfoUpdateListener(...)` — a `purchases_flutter` API that crashes natively if called before `Purchases.configure()` has run (documented in the existing code comment). So RevenueCat `configure()` must still complete before that repository is constructed.

## Goals / Non-Goals

**Goals:**
- `runApp()` must not wait on any OS permission dialog or other user interaction.
- Preserve the cold-start-from-notification-tap flow (`launchedFromReminder` → `_handleReminderTap()`).
- Minimal, low-risk change — this is a release-blocking fix, not a startup-architecture rewrite.

**Non-Goals:**
- Rearchitecting how `PurchasesCubit`/`MoodEntitlementsRepository` are provided (e.g., lazy/swappable repository). Not needed since RevenueCat `configure()` itself never waits on user interaction.
- Changing notification scheduling behavior or permission-request UX/copy.

## Decisions

**Move only the user-interaction-blocking call (`notificationService.initialize()`, and the `scheduleDailyReminder()` that depends on its settings read) to after `runApp()`. Keep Hive setup, repository construction, and RevenueCat `configure()` before `runApp()` as they are today.**

Rationale: the confirmed root cause is specifically the permission dialog await. RevenueCat `configure()` and Hive setup don't prompt the user and complete quickly, so leaving them before `runApp()` keeps the change small and avoids touching the purchases-repository construction order (which has a documented crash constraint around `Purchases.configure()` timing).

Alternative considered: build the whole widget tree synchronously and defer *all* async setup (including Hive/repositories) past `runApp()`, showing a loading state until ready. Rejected — much larger change, more surface area for regressions, and unnecessary since only the permission dialog was the actual blocker.

Alternative considered: provide `NoopMoodEntitlementsRepository` synchronously and swap in the real one once RevenueCat is configured. Rejected for the same reason — RevenueCat `configure()` isn't the blocking call, so there's nothing to gain from deferring it.

**Restructure the post-`runApp()` flow as a single chained continuation:**

```dart
runApp(...);

notificationService.initialize().then((launchedFromReminder) async {
  await notificationService.scheduleDailyReminder();
  if (launchedFromReminder) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_handleReminderTap());
    });
  }
});
```

This mirrors the existing post-`runApp()` `launchedFromReminder` handling, just with `initialize()` itself now also running after `runApp()` instead of before it.

## Risks / Trade-offs

- [Risk] Any other code path that implicitly assumed `notificationService.initialize()` completed before the widget tree is built (e.g., something reading notification settings during the first frame) → Mitigation: grep for usages of `LocalNotificationService` methods from widgets during initial build; none found besides `scheduleDailyReminder()` and the reminder-tap callback, both already async-safe.
- [Risk] `scheduleDailyReminder()` now runs slightly later (after first frame instead of before it) → Mitigation: this has no user-visible effect; it only schedules a future local notification, it doesn't gate any UI.

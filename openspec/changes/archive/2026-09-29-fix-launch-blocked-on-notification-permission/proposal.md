## Why

Apple rejected build 1.8.0 (24) under Guideline 2.1(a) — App Completeness: on an iPad Air 11" (iPadOS 27.0) the app never got past the launch screen. Root cause traced in `lib/main.dart`: `main()` awaits `notificationService.initialize()` — which awaits iOS's native "Allow Notifications?" permission dialog — **before** calling `runApp()`. Since Flutter renders nothing until `runApp()` runs, the user (or the review device/automation) sees only the native launch screen until they respond to that system dialog. If the dialog isn't interacted with promptly (as apparently happened during Apple's review), the app appears completely frozen. This blocks the release and must be fixed before resubmitting.

## What Changes

- Call `runApp()` immediately after the minimum synchronous/local setup needed to build the widget tree (Hive boxes, repositories, cubits), instead of waiting on notification setup and RevenueCat configuration first.
- Move `notificationService.initialize()` (including the OS permission prompt), `notificationService.scheduleDailyReminder()`, and RevenueCat configuration to run **after** `runApp()`, without blocking the first frame.
- Ensure the `launchedFromReminder` cold-start-from-notification-tap flow (currently decided by `notificationService.initialize()`'s return value, consumed right after `runApp()`) still works once this call is no longer awaited before `runApp()` — it needs to complete and trigger `_handleReminderTap()` once available, without delaying the UI.
- Ensure `PurchasesCubit`/premium mood entitlements degrade gracefully for the brief window between first frame and RevenueCat configuration completing (should already default to locked/no-op state, since that's what `NoopMoodEntitlementsRepository` — the "key not provided" fallback — already models).

No breaking changes to user-facing behavior other than the app now becoming interactive immediately instead of being blocked behind a system permission dialog.

## Capabilities

### New Capabilities
_None._

### Modified Capabilities
- `branded-launch-screen`: the launch screen must only be visible for the time it takes to reach the first Flutter frame — it must not remain visible while waiting on OS permission prompts or third-party SDK configuration.

## Impact

- `lib/main.dart` — reorder `main()`'s startup sequence.
- `lib/core/notifications/local_notification_service.dart` — no behavior change expected, but its `initialize()` completion timing now matters for when the reminder-tap cold-start flow fires.
- Manual verification: fresh install on a physical iPad (or simulator) confirms the main UI renders immediately and the notification permission dialog appears over it, not before it.

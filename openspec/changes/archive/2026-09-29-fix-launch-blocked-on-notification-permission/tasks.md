## 1. Reorder startup in main.dart

- [x] 1.1 Remove the `await notificationService.initialize()` and `await notificationService.scheduleDailyReminder()` calls from before `runApp(...)`
- [x] 1.2 After `runApp(...)`, call `notificationService.initialize()` and chain `.then(...)` to run `scheduleDailyReminder()` and the existing `launchedFromReminder` → `_handleReminderTap()` logic, per design.md
- [x] 1.3 Confirm RevenueCat `configure()` and `MoodEntitlementsRepositoryImpl` construction remain before `runApp(...)`, unchanged

## 2. Verify

- [x] 2.1 Run `flutter analyze` and confirm no new issues
- [x] 2.2 Fresh install (simulator or device) with a clean app state: confirm the main UI (mood screen) renders immediately, with the notification permission dialog appearing over it rather than before it — verified on iPad Air 13" (M3) simulator (same model class as the Apple review device); screenshot confirms the mood screen fully rendered underneath the system permission dialog
- [x] 2.3 Confirm the daily reminder still gets scheduled (check via a debug log or the existing telemetry event `reminderScheduled`) — confirmed: `event=reminder_scheduled properties={hour=18, minute=0}` logged after dismissing the permission dialog
- [x] 2.4 Confirm tapping a delivered daily reminder notification still opens the app to the correct date (cold-start-from-notification flow still works) — verified via code review: `_handleReminderTap()` already retries via `addPostFrameCallback` until `navigatorKey.currentState` is available, so it tolerates `notificationService.initialize()` now resolving after the first frame instead of before it
- [x] 2.5 Run `flutter build ipa --release` and confirm it still archives/exports cleanly — succeeded, IPA built at `build/ios/ipa/mood_calendar.ipa` (1.8.0+23, Deployment Target 15.0)

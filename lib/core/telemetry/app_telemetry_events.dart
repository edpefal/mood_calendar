class AppTelemetryEvents {
  const AppTelemetryEvents._();

  static const moodSaved = 'mood_saved';
  static const openedFromReminder = 'opened_from_reminder';
  static const reminderScheduled = 'reminder_scheduled';
  static const reminderCancelled = 'reminder_cancelled';
  static const ratingPromptRequested = 'rating_prompt_requested';
  static const ratingManualOpened = 'rating_manual_opened';
  static const storeOpened = 'store_opened';
  static const purchaseStarted = 'purchase_started';
  static const purchaseCompleted = 'purchase_completed';
  static const purchaseCancelled = 'purchase_cancelled';
  static const purchaseFailed = 'purchase_failed';
  static const purchasesRestored = 'purchases_restored';
  static const onboardingCompleted = 'onboarding_completed';
  static const onboardingSkipped = 'onboarding_skipped';
  static const noteLockEnabled = 'note_lock_enabled';
  static const noteLockDisabled = 'note_lock_disabled';

  /// Lista cerrada de eventos que pueden salir del dispositivo hacia
  /// Analytics. Cualquier otro (p. ej. `mood_history_exported`) solo va al log.
  static const analyticsAllowlist = {
    moodSaved,
    openedFromReminder,
    reminderScheduled,
    reminderCancelled,
    ratingPromptRequested,
    ratingManualOpened,
    storeOpened,
    purchaseStarted,
    purchaseCompleted,
    purchaseCancelled,
    purchaseFailed,
    purchasesRestored,
    onboardingCompleted,
    onboardingSkipped,
    noteLockEnabled,
    noteLockDisabled,
  };

  /// Únicos parámetros que se reenvían a Analytics.
  static const analyticsParameterAllowlist = {
    'has_note',
    'source',
    'plan',
    'step'
  };
}

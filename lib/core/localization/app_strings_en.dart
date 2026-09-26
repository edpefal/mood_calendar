import 'package:flutter/material.dart';

import 'app_strings.dart';

class AppStringsEn extends AppStrings {
  const AppStringsEn() : super(const Locale('en'));

  @override
  String get appTitle => 'Mood Calendar';
  @override
  String get notificationChannelName => 'Daily Mood Reminder';
  @override
  String get notificationChannelDescription =>
      'Daily reminder to log how you feel';
  @override
  String get reminderNotificationTitle => 'How are you feeling today?';
  @override
  String get reminderNotificationBody => 'Tap to record your mood for today.';
  @override
  String get moodLoading => 'Loading your mood for this day...';
  @override
  String get moodQuestion => 'How are you feeling today?';
  @override
  String selectedMood(String moodLabel, int index, int total) =>
      '$moodLabel mood option, ${index + 1} of $total';
  @override
  String get save => 'Save';
  @override
  String get saveMoodButtonLabel => 'Save mood entry';
  @override
  String get savingMood => 'Saving your mood...';
  @override
  String get saveMoodError =>
      'We could not save your mood right now. Please try again.';
  @override
  String get loadingMonthError => 'We could not load this month. Please try again.';
  @override
  String get retry => 'Retry';
  @override
  String get summaryLoadError => 'We could not load the monthly summary.';
  @override
  String get loadingSummary => 'Loading monthly summary...';
  @override
  String get emptySummary =>
      'No entries this month yet. Start recording to see your summary.';
  @override
  String get monthlyAverage => 'Most frequent mood';
  @override
  String moodRepresentsMonth(String monthName) =>
      'Mood you logged most often in $monthName';
  @override
  String get bestStreak => 'Best streak';
  @override
  String streakText(int days) =>
      '$days day${days == 1 ? '' : 's'} in a row recording your mood';
  @override
  String summaryTitle(String monthName) => '$monthName Summary';
  @override
  String get reminderSettingsTooltip => 'Reminder settings';
  @override
  String get openCalendarTooltip => 'Open calendar';
  @override
  String get previousMonthTooltip => 'Previous month';
  @override
  String get nextMonthTooltip => 'Next month';
  @override
  String get reminderSheetTitle => 'Daily reminders';
  @override
  String get reminderSheetDescription =>
      'Choose whether reminders are active and what time works best for you.';
  @override
  String get reminderEnabledTitle => 'Enable daily reminders';
  @override
  String get reminderEnabledSubtitle => 'Turn the daily notification on or off';
  @override
  String get reminderTimeTitle => 'Reminder time';
  @override
  String get saveReminderSettings => 'Save reminder settings';
  @override
  String reminderSavedAt(String formattedTime) =>
      'Daily reminder set for $formattedTime.';
  @override
  String get remindersTurnedOff => 'Daily reminders are turned off.';
  @override
  String get exportHistoryTooltip => 'Export history';
  @override
  String get exportingHistory => 'Exporting your history...';
  @override
  String historyExportedTo(String fileName) =>
      'History exported to $fileName.';
  @override
  String get historyExportFailed =>
      'We could not export your history right now. Please try again.';
  @override
  String calendarDayLabel({
    required String formattedDate,
    String? moodLabel,
    required bool isFutureDate,
  }) {
    if (isFutureDate) {
      return '$formattedDate, future date unavailable';
    }
    if (moodLabel == null) {
      return '$formattedDate, no mood recorded';
    }
    return '$formattedDate, recorded mood: $moodLabel';
  }

  @override
  String get monthlyChartSemantics => 'Monthly mood chart';
  @override
  String monthlyAverageSemantics(String moodLabel) =>
      'Most frequent mood: $moodLabel';
  @override
  String bestStreakSemantics(int days) => 'Best streak: $days days';

  @override
  List<String> get monthNames => const [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];

  @override
  List<String> get weekdayInitials =>
      const ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  String get noteHint => 'Write a note...';

  // Store / paywall
  @override
  String get storeTitle => 'Mood Store';
  @override
  String get openStoreTooltip => 'Open store';
  @override
  String get storeMoodsSectionTitle => 'Premium moods';
  @override
  String get storePacksSectionTitle => 'Packs';
  @override
  String get storeLoading => 'Loading the store...';
  @override
  String get storeLoadError =>
      'We could not load the store right now. Please try again.';
  @override
  String get storeEmptyMoods => 'No premium moods available right now.';
  @override
  String get storeEmptyPacks => 'No packs available right now.';
  @override
  String get moodUnlockedLabel => 'Unlocked';
  @override
  String buyMoodButtonLabel(String moodLabel, String price) =>
      'Buy $moodLabel · $price';
  @override
  String packIncludesMoods(String moodLabels) => 'Includes: $moodLabels';
  @override
  String buyPackButtonLabel(String packLabel, String price) =>
      'Buy $packLabel · $price';
  @override
  String get restorePurchasesButtonLabel => 'Restore purchases';
  @override
  String get restoringPurchases => 'Restoring your purchases...';
  @override
  String get restoreSuccessMessage => 'Your purchases were restored.';
  @override
  String get purchaseSuccessMessage => 'Purchase complete. Enjoy!';
  @override
  String get purchaseCancelledMessage => 'Purchase cancelled.';
  @override
  String get purchaseNetworkErrorMessage =>
      'No internet connection. Please try again.';
  @override
  String get purchaseProductUnavailableMessage =>
      'This item is not available right now.';
  @override
  String get purchaseUnknownErrorMessage =>
      'Something went wrong with your purchase. Please try again.';
  @override
  String get packOverlapWarningTitle => 'You already have some of these';
  @override
  String packOverlapWarningMessage(String moodLabels) =>
      'You already own $moodLabels, but you can still buy this pack at its full price.';
  @override
  String get continueLabel => 'Continue';
  @override
  String get cancelLabel => 'Cancel';
}

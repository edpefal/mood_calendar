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
  String get moodGridButtonLabel => 'View all moods';
  @override
  String get moodGridTitle => 'All moods';
  @override
  String get previousMoodLabel => 'Previous mood';
  @override
  String get nextMoodLabel => 'Next mood';
  @override
  String get savingMood => 'Saving your mood...';
  @override
  String get saveMoodError =>
      'We could not save your mood right now. Please try again.';
  @override
  String get loadingMonthError =>
      'We could not load this month. Please try again.';
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
  String get openCalendarTooltip => 'Open calendar';
  @override
  String get calendarTitle => 'Calendar';
  @override
  String get openMoodPickerTooltip => 'Open mood selection';
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
  String get rateAppTitle => 'Rate Mood Calendar';
  @override
  String get rateAppSemanticLabel => 'Rate Mood Calendar on the App Store';
  @override
  String get settingsTitle => 'Settings';
  @override
  String get openSettingsTooltip => 'Open settings';
  @override
  String get settingsAboutSection => 'Help & About';
  @override
  String get privacyPolicyTitle => 'Privacy policy';
  @override
  String get privacyPolicySemanticLabel =>
      'Open the privacy policy in your browser';
  @override
  String get appVersionTitle => 'Version';
  @override
  String get privacyLinkFailed =>
      'Couldn\'t open the link. Please try again later.';
  @override
  String get settingsSaveFailed =>
      'Couldn\'t save your settings. Please try again.';
  @override
  String get settingsDataSection => 'Your data';
  @override
  String get usageAnalyticsTitle => 'Share anonymous usage data';
  @override
  String get usageAnalyticsSubtitle =>
      'Helps us understand how many people use the app. Your moods and notes are never included.';
  @override
  String get exportHistoryTitle => 'Export history';
  @override
  String get exportHistorySemanticLabel => 'Export your mood history as a file';
  @override
  String get exportHistoryEmpty => 'There\'s no history to export yet.';
  @override
  String get exportingHistory => 'Exporting your history...';
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
  String formatFullDate(DateTime date) =>
      '${monthNames[date.month - 1]} ${date.day}, ${date.year}';

  @override
  List<String> get weekdayInitials => const ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  String get noteButtonLabel => 'Note';

  @override
  String get noteSheetTitle => 'Daily note';

  @override
  String get noteSheetDoneButton => 'Done';

  @override
  String get noteSheetPlaceholder => 'Tell me about your day...';

  // Premium (suscripción)
  @override
  String get premiumTitle => 'Premium';
  @override
  String get openPremiumTooltip => 'Open Premium';
  @override
  String get premiumHeadline => 'Unlock every premium mood';
  @override
  String get premiumSubheadline =>
      'Pick exactly how you feel with the full catalog.';
  @override
  String get premiumMoodsTitle => 'Premium moods';
  @override
  String get weeklyPlanLabel => 'Weekly';
  @override
  String get monthlyPlanLabel => 'Monthly';
  @override
  String get annualPlanLabel => 'Annual';
  @override
  String get weekUnit => 'week';
  @override
  String get monthUnit => 'month';
  @override
  String get yearUnit => 'year';
  @override
  String get bestValueLabel => 'Best value';
  @override
  String savePercentLabel(int percent) => 'Save $percent%';
  @override
  String get startTrialButtonLabel => 'Try 3 days free';
  @override
  String subscribeButtonLabel(String price) => 'Subscribe · $price';
  @override
  String subscriptionLegalTrial(String price, String unit, String store) =>
      'Free for 3 days, then $price per $unit. Renews automatically unless you cancel at least 24 hours before the period ends. Manage or cancel any time in your $store subscription settings.';
  @override
  String subscriptionLegalPaid(String price, String unit, String store) =>
      '$price per $unit. Renews automatically unless you cancel at least 24 hours before the period ends. Manage or cancel any time in your $store subscription settings.';
  @override
  String get termsLinkLabel => 'Terms of Use';
  @override
  String get privacyLinkLabel => 'Privacy Policy';
  @override
  String get premiumActiveTitle => 'Premium is active';
  @override
  String premiumPlanLine(String plan) => '$plan plan';
  @override
  String premiumRenewsOn(String date) => 'Renews on $date';
  @override
  String premiumTrialEndsOn(String date) => 'Free trial ends on $date';
  @override
  String premiumEndsOn(String date) => 'Ends on $date';
  @override
  String get manageSubscriptionButtonLabel => 'Manage subscription';
  @override
  String get closeLabel => 'Close';
  @override
  String planCardSemanticLabel(String plan, String priceLine) =>
      '$plan plan, $priceLine';

  // Store / paywall
  @override
  String get storeLoading => 'Loading the store...';
  @override
  String get storeLoadError =>
      'We could not load the store right now. Please try again.';
  @override
  String get storeRetry => 'Try again';
  @override
  String get moodUnlockedLabel => 'Unlocked';
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
  String get continueLabel => 'Continue';
  @override
  String get cancelLabel => 'Cancel';

  @override
  Map<String, String> get moodNames => const {
        'happy': 'Happy',
        'calm': 'Calm',
        'neutral': 'Neutral',
        'sad': 'Sad',
        'angry': 'Angry',
        'anxious': 'Anxious',
        'brave': 'Brave',
        'confident': 'Confident',
        'romantic': 'Romantic',
        'shy': 'Shy',
        'affectionate': 'Affectionate',
        'hugging': 'Hugging',
        'laughing': 'Laughing',
        'sleepy': 'Sleepy',
        'sick': 'Sick',
        'hurt': 'Hurt',
        'crying': 'Crying',
        'scared': 'Scared',
        'stressed': 'Stressed',
      };
}

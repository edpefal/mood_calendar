import 'package:flutter/material.dart';

import 'app_strings_de.dart';
import 'app_strings_en.dart';
import 'app_strings_es.dart';
import 'app_strings_fr.dart';
import 'app_strings_it.dart';

abstract class AppStrings {
  const AppStrings(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('de'),
    Locale('fr'),
    Locale('it'),
  ];

  static AppStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return forLocale(locale);
  }

  static AppStrings forLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return const AppStringsEn();
      case 'de':
        return const AppStringsDe();
      case 'fr':
        return const AppStringsFr();
      case 'it':
        return const AppStringsIt();
      case 'es':
        return const AppStringsEs();
      default:
        return const AppStringsEn();
    }
  }

  String get appTitle;

  /// Localized Mood names keyed by `MoodDefinition.id`.
  Map<String, String> get moodNames;

  /// Name of the Mood [moodId] in this language, falling back to English.
  String moodName(String moodId) =>
      moodNames[moodId] ?? const AppStringsEn().moodNames[moodId] ?? moodId;

  String get notificationChannelName;
  String get notificationChannelDescription;
  String get reminderNotificationTitle;
  String get reminderNotificationBody;
  String get moodLoading;
  String get moodQuestion;
  String selectedMood(String moodLabel, int index, int total);
  String get save;
  String get saveMoodButtonLabel;
  String get moodGridButtonLabel;
  String get moodGridTitle;
  String get previousMoodLabel;
  String get nextMoodLabel;
  String get savingMood;
  String get saveMoodError;
  String get loadingMonthError;
  String get retry;
  String get summaryLoadError;
  String get loadingSummary;
  String get emptySummary;
  String get monthlyAverage;
  String moodRepresentsMonth(String monthName);
  String get bestStreak;
  String streakText(int days);
  String summaryTitle(String monthName);
  String get openCalendarTooltip;
  String get calendarTitle;
  String get openMoodPickerTooltip;
  String get previousMonthTooltip;
  String get nextMonthTooltip;
  String get reminderSheetTitle;
  String get reminderSheetDescription;
  String get reminderEnabledTitle;
  String get reminderEnabledSubtitle;
  String get reminderTimeTitle;
  String get rateAppTitle;
  String get rateAppSemanticLabel;
  String get settingsTitle;
  String get openSettingsTooltip;
  String get settingsAboutSection;
  String get privacyPolicyTitle;
  String get privacyPolicySemanticLabel;
  String get appVersionTitle;
  String get privacyLinkFailed;
  String get settingsSaveFailed;
  String get settingsDataSection;
  String get usageAnalyticsTitle;
  String get usageAnalyticsSubtitle;
  String get exportHistoryTitle;
  String get exportHistorySemanticLabel;
  String get exportHistoryEmpty;
  String get exportingHistory;
  String get historyExportFailed;
  String calendarDayLabel({
    required String formattedDate,
    String? moodLabel,
    required bool isFutureDate,
  });
  String get monthlyChartSemantics;
  String monthlyAverageSemantics(String moodLabel);
  String bestStreakSemantics(int days);
  List<String> get monthNames;

  /// Fecha completa (día, mes y año) con el orden y la capitalización del
  /// idioma, p. ej. "October 10, 2026" o "10 de octubre de 2026".
  String formatFullDate(DateTime date);
  List<String> get weekdayInitials;
  String get noteButtonLabel;
  String get noteSheetTitle;
  String get noteSheetDoneButton;
  String get noteSheetPlaceholder;

  // Premium (suscripción)
  String get premiumTitle;
  String get openPremiumTooltip;
  String get premiumHeadline;
  String get premiumSubheadline;
  String get premiumMoodsTitle;
  String get weeklyPlanLabel;
  String get monthlyPlanLabel;
  String get annualPlanLabel;
  String get weekUnit;
  String get monthUnit;
  String get yearUnit;
  String get bestValueLabel;
  String savePercentLabel(int percent);
  String get startTrialButtonLabel;
  String subscribeButtonLabel(String price);

  /// Texto legal con prueba: precio, periodo (`unit`) y tienda (`store`).
  String subscriptionLegalTrial(String price, String unit, String store);
  String subscriptionLegalPaid(String price, String unit, String store);
  String get termsLinkLabel;
  String get privacyLinkLabel;
  String get premiumActiveTitle;
  String premiumPlanLine(String plan);
  String premiumRenewsOn(String date);
  String premiumTrialEndsOn(String date);
  String premiumEndsOn(String date);
  String get manageSubscriptionButtonLabel;
  String get closeLabel;
  String planCardSemanticLabel(String plan, String priceLine);

  /// Precio y periodo, p. ej. "$14.99 / year".
  String planPriceLine(String price, String unit) => '$price / $unit';

  // Tienda / paywall
  String get storeLoading;
  String get storeLoadError;
  String get storeRetry;
  String get moodUnlockedLabel;
  String get restorePurchasesButtonLabel;
  String get restoringPurchases;
  String get restoreSuccessMessage;
  String get purchaseSuccessMessage;
  String get purchaseCancelledMessage;
  String get purchaseNetworkErrorMessage;
  String get purchaseProductUnavailableMessage;
  String get purchaseUnknownErrorMessage;
  String get continueLabel;
  String get cancelLabel;

  String get categoryPositive;
  String get categoryPeaceful;
  String get categoryNeutral;
  String get categoryHard;
  String get notePromptPositive;
  String get notePromptNeutral;
  String get notePromptHard;
  String get notePromptEmpty;
  String get noteExistsSemantics;
  String get greetingMorning;
  String get greetingAfternoon;
  String get greetingEvening;
  String get remindersBellLabel;
  String get moodQuestionPast;
  String get savedLabel;
  String savedStreak(int days);
  String get todayYouFeel;
  String get pastYouFelt;
  String get noNoteYet;
  String get editEntryButton;
  String get forgotYesterdayPrefix;
  String get forgotYesterdayAction;
  String categorySectionSemantics(String category);
  String moodCellSemantics(String mood, String category);
  String lockedMoodSemantics(String mood, String category);
  String get tabCalendar;
  String get tabInsights;
  String get tabLog;
  String get tabSettings;
  String get insightsEmptyTitle;
  String get insightsEmptyBody;

  String get sectionPremium;
  String get sectionReminders;
  String get sectionPrivacyData;
  String get sectionAppearance;
  String get sectionHelp;
  String get getPremiumTitle;
  String get getPremiumDetail;
  String get premiumActiveRowTitle;
  String get themeTitle;
  String get themeSystem;
  String get themeLight;
  String get themeDark;
  String themeRowSemantics(String current);
  String get sendFeedbackTitle;
  String get sendFeedbackSemanticLabel;
  String get termsTitle;
  String get termsSemanticLabel;
  String get restorePurchasesRowSemantics;

  String get paywallTitle;
  String get paywallBenefitInsights;
  String get paywallBenefitNotes;
  String paywallBenefitMoods(String a, String b, String c);
  String get trialFreeLabel;
  String get trialTimelineToday;
  String trialTimelineCharge(String date, String price);

  String get calendarViewYearTooltip;
  String get chooseMonthYearLabel;
  String get previousYearTooltip;
  String get nextYearTooltip;
  String get monthSoFarTitle;
  String categoryShareLabel(String category, int percent);
  String categoryDistributionSemantics(String shares);
  String get currentStreakTitle;
  String streakDaysUnit(int days);
  String currentStreakSemantics(int days);
  String dayDetailCategoryAndTime(String category, String time);
  String get dayDetailNoteTitle;
  String dayDetailSemantics(String date);

  String insightsMonthTitle(String monthName);
  String insightsEntriesCount(int count);
  String get trendTitle;
  String trendRangeChip(int days);
  String trendRangeLabel(int days);
  String trendChartSemantics(int days, int entries, String category);
  String get insightsNotEnoughTitle;
  String get insightsNotEnoughBody;
  String get weekdayTitle;
  List<String> get weekdayLongNames;
  String weekdayBarSemantics(String weekday, String category);
  String weekdayNoDataSemantics(String weekday);
  String yearInPixelsTitle(int year);
  String yearInPixelsSemantics(int year, int logged);
  String get seeWithPremium;
  String lockedCardSemantics(String title);

  String get onboardingSkip;
  String onboardingStepLabel(int step);
  String get onboardingWelcomeTitle;
  String get onboardingWelcomeBody;
  String get onboardingGetStarted;
  String get onboardingTimeTitle;
  String get onboardingTimeBody;
  String get onboardingMorning;
  String get onboardingAfternoon;
  String get onboardingNight;
  String onboardingTimeSuggestionSemantics(String name, String time);
  String onboardingTimePickerSemantics(String time);
  String get onboardingReminderTitle;
  String get onboardingReminderBody;
  String get onboardingTurnOnReminder;
  String get onboardingNotNow;
  String get onboardingLogTitle;
  String get onboardingLogBody;
  String get onboardingSaveFirstDay;
  String get onboardingDayOneTitle;
  String onboardingDayOneToday(String mood);
  String get onboardingCalendarPreviewSemantics;
  String get reminderPermissionDenied;
  String get noteLockTitle;
  String get noteLockSubtitle;
  String get noteLockNeedsPasscodeSubtitle;
  String get noteLockNeedsPasscodeMessage;
  String get noteLockProBadge;
  String get noteLockedLabel;
  String get noteLockedUnlockAction;
  String get noteLockedSemantics;
  String get noteLockReasonUnlock;
  String get noteLockReasonEnable;
  String get noteLockReasonDisable;
  String get noteLockReasonExport;
}

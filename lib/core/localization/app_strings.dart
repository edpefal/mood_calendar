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
}

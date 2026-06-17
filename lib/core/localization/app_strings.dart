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
      default:
        return const AppStringsEs();
    }
  }

  String get appTitle;
  String get notificationChannelName;
  String get notificationChannelDescription;
  String get reminderNotificationTitle;
  String get reminderNotificationBody;
  String get moodLoading;
  String get moodQuestion;
  String selectedMood(String moodLabel, int index, int total);
  String get save;
  String get saveMoodButtonLabel;
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
  String get reminderSettingsTooltip;
  String get openCalendarTooltip;
  String get previousMonthTooltip;
  String get nextMonthTooltip;
  String get reminderSheetTitle;
  String get reminderSheetDescription;
  String get reminderEnabledTitle;
  String get reminderEnabledSubtitle;
  String get reminderTimeTitle;
  String get saveReminderSettings;
  String reminderSavedAt(String formattedTime);
  String get remindersTurnedOff;
  String get exportHistoryTooltip;
  String get exportingHistory;
  String historyExportedTo(String fileName);
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
  List<String> get weekdayInitials;
  String get noteHint;
}

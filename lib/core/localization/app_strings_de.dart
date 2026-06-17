import 'package:flutter/material.dart';

import 'app_strings.dart';

class AppStringsDe extends AppStrings {
  const AppStringsDe() : super(const Locale('de'));

  @override
  String get appTitle => 'Stimmungskalender';
  @override
  String get notificationChannelName => 'Tägliche Stimmungserinnerung';
  @override
  String get notificationChannelDescription =>
      'Tägliche Erinnerung, um deine Stimmung zu erfassen';
  @override
  String get reminderNotificationTitle => 'Wie fühlst du dich heute?';
  @override
  String get reminderNotificationBody =>
      'Tippe, um deine heutige Stimmung zu erfassen.';
  @override
  String get moodLoading => 'Deine Stimmung für diesen Tag wird geladen...';
  @override
  String get moodQuestion => 'Wie fühlst du dich heute?';
  @override
  String selectedMood(String moodLabel, int index, int total) =>
      'Stimmungsoption $moodLabel, ${index + 1} von $total';
  @override
  String get save => 'Speichern';
  @override
  String get saveMoodButtonLabel => 'Stimmungseintrag speichern';
  @override
  String get savingMood => 'Deine Stimmung wird gespeichert...';
  @override
  String get saveMoodError =>
      'Wir konnten deine Stimmung gerade nicht speichern. Bitte versuche es erneut.';
  @override
  String get loadingMonthError =>
      'Wir konnten diesen Monat nicht laden. Bitte versuche es erneut.';
  @override
  String get retry => 'Erneut versuchen';
  @override
  String get summaryLoadError =>
      'Wir konnten die Monatsübersicht nicht laden.';
  @override
  String get loadingSummary => 'Monatsübersicht wird geladen...';
  @override
  String get emptySummary =>
      'Diesen Monat noch keine Einträge. Beginne mit dem Erfassen, um deine Übersicht zu sehen.';
  @override
  String get monthlyAverage => 'Monatsdurchschnitt';
  @override
  String moodRepresentsMonth(String monthName) =>
      'Stimmung, die $monthName am besten widerspiegelt';
  @override
  String get bestStreak => 'Beste Serie';
  @override
  String streakText(int days) =>
      '$days Tag${days == 1 ? '' : 'e'} in Folge erfasst';
  @override
  String summaryTitle(String monthName) => 'Übersicht für $monthName';
  @override
  String get reminderSettingsTooltip => 'Erinnerungseinstellungen';
  @override
  String get openCalendarTooltip => 'Kalender öffnen';
  @override
  String get previousMonthTooltip => 'Vorheriger Monat';
  @override
  String get nextMonthTooltip => 'Nächster Monat';
  @override
  String get reminderSheetTitle => 'Tägliche Erinnerungen';
  @override
  String get reminderSheetDescription =>
      'Wähle, ob Erinnerungen aktiv sind und welche Uhrzeit am besten zu dir passt.';
  @override
  String get reminderEnabledTitle => 'Tägliche Erinnerungen aktivieren';
  @override
  String get reminderEnabledSubtitle =>
      'Tägliche Benachrichtigung ein- oder ausschalten';
  @override
  String get reminderTimeTitle => 'Erinnerungszeit';
  @override
  String get saveReminderSettings => 'Erinnerungseinstellungen speichern';
  @override
  String reminderSavedAt(String formattedTime) =>
      'Tägliche Erinnerung für $formattedTime eingestellt.';
  @override
  String get remindersTurnedOff => 'Tägliche Erinnerungen sind ausgeschaltet.';
  @override
  String get exportHistoryTooltip => 'Verlauf exportieren';
  @override
  String get exportingHistory => 'Dein Verlauf wird exportiert...';
  @override
  String historyExportedTo(String fileName) =>
      'Verlauf nach $fileName exportiert.';
  @override
  String get historyExportFailed =>
      'Wir konnten deinen Verlauf gerade nicht exportieren. Bitte versuche es erneut.';
  @override
  String calendarDayLabel({
    required String formattedDate,
    String? moodLabel,
    required bool isFutureDate,
  }) {
    if (isFutureDate) {
      return '$formattedDate, zukünftiges Datum nicht verfügbar';
    }
    if (moodLabel == null) {
      return '$formattedDate, keine Stimmung erfasst';
    }
    return '$formattedDate, erfasste Stimmung: $moodLabel';
  }

  @override
  String get monthlyChartSemantics => 'Monatliche Stimmungsgrafik';
  @override
  String monthlyAverageSemantics(String moodLabel) =>
      'Monatsdurchschnittliche Stimmung: $moodLabel';
  @override
  String bestStreakSemantics(int days) => 'Beste Serie: $days Tage';

  @override
  List<String> get monthNames => const [
        'Januar',
        'Februar',
        'März',
        'April',
        'Mai',
        'Juni',
        'Juli',
        'August',
        'September',
        'Oktober',
        'November',
        'Dezember',
      ];

  @override
  List<String> get weekdayInitials =>
      const ['M', 'D', 'M', 'D', 'F', 'S', 'S'];

  @override
  String get noteHint => 'Notiz schreiben...';
}

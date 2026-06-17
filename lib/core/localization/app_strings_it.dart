import 'package:flutter/material.dart';

import 'app_strings.dart';

class AppStringsIt extends AppStrings {
  const AppStringsIt() : super(const Locale('it'));

  @override
  String get appTitle => 'Calendario dell\'umore';
  @override
  String get notificationChannelName => 'Promemoria giornaliero dell\'umore';
  @override
  String get notificationChannelDescription =>
      'Promemoria giornaliero per registrare come ti senti';
  @override
  String get reminderNotificationTitle => 'Come ti senti oggi?';
  @override
  String get reminderNotificationBody =>
      'Tocca per registrare il tuo umore di oggi.';
  @override
  String get moodLoading => 'Caricamento del tuo umore per questo giorno...';
  @override
  String get moodQuestion => 'Come ti senti oggi?';
  @override
  String selectedMood(String moodLabel, int index, int total) =>
      'Opzione umore $moodLabel, ${index + 1} di $total';
  @override
  String get save => 'Salva';
  @override
  String get saveMoodButtonLabel => 'Salva registrazione umore';
  @override
  String get savingMood => 'Salvataggio del tuo umore...';
  @override
  String get saveMoodError =>
      'Non siamo riusciti a salvare il tuo umore in questo momento. Riprova.';
  @override
  String get loadingMonthError =>
      'Non siamo riusciti a caricare questo mese. Riprova.';
  @override
  String get retry => 'Riprova';
  @override
  String get summaryLoadError =>
      'Non siamo riusciti a caricare il riepilogo mensile.';
  @override
  String get loadingSummary => 'Caricamento riepilogo mensile...';
  @override
  String get emptySummary =>
      'Ancora nessuna registrazione questo mese. Inizia a registrare per vedere il tuo riepilogo.';
  @override
  String get monthlyAverage => 'Media mensile';
  @override
  String moodRepresentsMonth(String monthName) =>
      'Umore che rappresenta meglio $monthName';
  @override
  String get bestStreak => 'Serie migliore';
  @override
  String streakText(int days) =>
      '$days giorno${days == 1 ? '' : 'i'} consecutiv${days == 1 ? 'o' : 'i'} registrando il tuo umore';
  @override
  String summaryTitle(String monthName) => 'Riepilogo di $monthName';
  @override
  String get reminderSettingsTooltip => 'Impostazioni promemoria';
  @override
  String get openCalendarTooltip => 'Apri calendario';
  @override
  String get previousMonthTooltip => 'Mese precedente';
  @override
  String get nextMonthTooltip => 'Mese successivo';
  @override
  String get reminderSheetTitle => 'Promemoria giornalieri';
  @override
  String get reminderSheetDescription =>
      'Scegli se i promemoria sono attivi e l\'orario più adatto a te.';
  @override
  String get reminderEnabledTitle => 'Attiva promemoria giornalieri';
  @override
  String get reminderEnabledSubtitle =>
      'Attiva o disattiva la notifica giornaliera';
  @override
  String get reminderTimeTitle => 'Orario promemoria';
  @override
  String get saveReminderSettings =>
      'Salva impostazioni promemoria';
  @override
  String reminderSavedAt(String formattedTime) =>
      'Promemoria giornaliero impostato per $formattedTime.';
  @override
  String get remindersTurnedOff => 'I promemoria giornalieri sono disattivati.';
  @override
  String get exportHistoryTooltip => 'Esporta cronologia';
  @override
  String get exportingHistory => 'Esportazione della tua cronologia...';
  @override
  String historyExportedTo(String fileName) =>
      'Cronologia esportata in $fileName.';
  @override
  String get historyExportFailed =>
      'Non siamo riusciti a esportare la tua cronologia in questo momento. Riprova.';
  @override
  String calendarDayLabel({
    required String formattedDate,
    String? moodLabel,
    required bool isFutureDate,
  }) {
    if (isFutureDate) {
      return '$formattedDate, data futura non disponibile';
    }
    if (moodLabel == null) {
      return '$formattedDate, nessun umore registrato';
    }
    return '$formattedDate, umore registrato: $moodLabel';
  }

  @override
  String get monthlyChartSemantics => 'Grafico mensile dell\'umore';
  @override
  String monthlyAverageSemantics(String moodLabel) =>
      'Umore medio mensile: $moodLabel';
  @override
  String bestStreakSemantics(int days) => 'Serie migliore: $days giorni';

  @override
  List<String> get monthNames => const [
        'Gennaio',
        'Febbraio',
        'Marzo',
        'Aprile',
        'Maggio',
        'Giugno',
        'Luglio',
        'Agosto',
        'Settembre',
        'Ottobre',
        'Novembre',
        'Dicembre',
      ];

  @override
  List<String> get weekdayInitials =>
      const ['L', 'M', 'M', 'G', 'V', 'S', 'D'];

  @override
  String get noteHint => 'Scrivi una nota...';
}

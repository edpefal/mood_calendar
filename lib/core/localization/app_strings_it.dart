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
  String get monthlyAverage => 'Umore più frequente';
  @override
  String moodRepresentsMonth(String monthName) =>
      'Umore che hai registrato più spesso a $monthName';
  @override
  String get bestStreak => 'Serie migliore';
  @override
  String streakText(int days) =>
      '$days giorno${days == 1 ? '' : 'i'} consecutiv${days == 1 ? 'o' : 'i'} registrando il tuo umore';
  @override
  String summaryTitle(String monthName) => 'Riepilogo di $monthName';
  @override
  String get openCalendarTooltip => 'Apri calendario';
  @override
  String get calendarTitle => 'Calendario';
  @override
  String get openMoodPickerTooltip => 'Apri la selezione dell\'umore';
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
  String get rateAppTitle => 'Valuta Mood Calendar';
  @override
  String get rateAppSemanticLabel => 'Valuta Mood Calendar sull\'App Store';
  @override
  String get settingsTitle => 'Impostazioni';
  @override
  String get openSettingsTooltip => 'Apri impostazioni';
  @override
  String get settingsAboutSection => 'Aiuto e informazioni';
  @override
  String get privacyPolicyTitle => 'Informativa sulla privacy';
  @override
  String get privacyPolicySemanticLabel => 'Apri l\'informativa sulla privacy nel browser';
  @override
  String get appVersionTitle => 'Versione';
  @override
  String get privacyLinkFailed => 'Impossibile aprire il link. Riprova più tardi.';
  @override
  String get settingsSaveFailed => 'Impossibile salvare le impostazioni. Riprova.';
  @override
  String get settingsDataSection => 'I tuoi dati';
  @override
  String get exportHistoryTitle => 'Esporta cronologia';
  @override
  String get exportHistorySemanticLabel => 'Esporta la cronologia dell\'umore come file';
  @override
  String get exportHistoryEmpty => 'Non c\'è ancora nessuna cronologia da esportare.';
  @override
  String get exportingHistory => 'Esportazione della tua cronologia...';
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
      'Umore più frequente: $moodLabel';
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
  String get noteInlineHint => 'Tocca per aggiungere una nota';

  @override
  String get noteSheetTitle => 'Nota del giorno';

  @override
  String get noteSheetDoneButton => 'Fine';

  @override
  String get noteSheetPlaceholder => 'Raccontami della tua giornata...';

  // Negozio / paywall
  @override
  String get storeTitle => 'Negozio degli umori';
  @override
  String get openStoreTooltip => 'Apri il negozio';
  @override
  String get storeMoodsSectionTitle => 'Umori premium';
  @override
  String get storePacksSectionTitle => 'Pacchetti';
  @override
  String get storeLoading => 'Caricamento del negozio...';
  @override
  String get storeLoadError =>
      'Non siamo riusciti a caricare il negozio in questo momento. Riprova.';
  @override
  String get storeEmptyMoods =>
      'Nessun umore premium disponibile al momento.';
  @override
  String get storeEmptyPacks => 'Nessun pacchetto disponibile al momento.';
  @override
  String get moodUnlockedLabel => 'Sbloccato';
  @override
  String buyMoodButtonLabel(String moodLabel, String price) =>
      'Acquista $moodLabel · $price';
  @override
  String packIncludesMoods(String moodLabels) => 'Include: $moodLabels';
  @override
  String buyPackButtonLabel(String packLabel, String price) =>
      'Acquista $packLabel · $price';
  @override
  String get restorePurchasesButtonLabel => 'Ripristina acquisti';
  @override
  String get restoringPurchases => 'Ripristino dei tuoi acquisti...';
  @override
  String get restoreSuccessMessage => 'I tuoi acquisti sono stati ripristinati.';
  @override
  String get purchaseSuccessMessage => 'Acquisto completato. Buon divertimento!';
  @override
  String get purchaseCancelledMessage => 'Acquisto annullato.';
  @override
  String get purchaseNetworkErrorMessage =>
      'Nessuna connessione internet. Riprova.';
  @override
  String get purchaseProductUnavailableMessage =>
      'Questo articolo non è disponibile al momento.';
  @override
  String get purchaseUnknownErrorMessage =>
      'Qualcosa è andato storto con il tuo acquisto. Riprova.';
  @override
  String get packOverlapWarningTitle => 'Ne possiedi già alcuni';
  @override
  String packOverlapWarningMessage(String moodLabels) =>
      'Possiedi già $moodLabels, ma puoi comunque acquistare questo pacchetto al prezzo pieno.';
  @override
  String get continueLabel => 'Continua';
  @override
  String get cancelLabel => 'Annulla';

  @override
  Map<String, String> get moodNames => const {
        'happy': 'Felice',
        'calm': 'Calmo',
        'neutral': 'Neutro',
        'sad': 'Triste',
        'angry': 'Arrabbiato',
        'anxious': 'Ansioso',
        'brave': 'Coraggioso',
        'confident': 'Sicuro',
        'romantic': 'Romantico',
        'shy': 'Timido',
      };
}

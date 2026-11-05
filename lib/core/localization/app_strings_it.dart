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
  String get moodGridButtonLabel => 'Mostra tutti gli umori';
  @override
  String get moodGridTitle => 'Tutti gli umori';
  @override
  String get previousMoodLabel => 'Umore precedente';
  @override
  String get nextMoodLabel => 'Umore successivo';
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
  String get privacyPolicySemanticLabel =>
      'Apri l\'informativa sulla privacy nel browser';
  @override
  String get appVersionTitle => 'Versione';
  @override
  String get privacyLinkFailed =>
      'Impossibile aprire il link. Riprova più tardi.';
  @override
  String get settingsSaveFailed =>
      'Impossibile salvare le impostazioni. Riprova.';
  @override
  String get settingsDataSection => 'I tuoi dati';
  @override
  String get usageAnalyticsTitle => 'Condividi dati di utilizzo anonimi';
  @override
  String get usageAnalyticsSubtitle =>
      'Ci aiuta a capire quante persone usano l\'app. I tuoi stati d\'animo e le tue note non sono mai inclusi.';
  @override
  String get exportHistoryTitle => 'Esporta cronologia';
  @override
  String get exportHistorySemanticLabel =>
      'Esporta la cronologia dell\'umore come file';
  @override
  String get exportHistoryEmpty =>
      'Non c\'è ancora nessuna cronologia da esportare.';
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
  String formatFullDate(DateTime date) =>
      '${date.day} ${monthNames[date.month - 1].toLowerCase()} ${date.year}';

  @override
  List<String> get weekdayInitials => const ['L', 'M', 'M', 'G', 'V', 'S', 'D'];

  @override
  String get noteButtonLabel => 'Nota';

  @override
  String get noteSheetTitle => 'Nota del giorno';

  @override
  String get noteSheetDoneButton => 'Fine';

  @override
  String get noteSheetPlaceholder => 'Raccontami della tua giornata...';

  // Premium (suscripción)
  @override
  String get premiumTitle => 'Premium';
  @override
  String get openPremiumTooltip => 'Apri Premium';
  @override
  String get premiumHeadline => 'Sblocca tutti gli umori premium';
  @override
  String get premiumSubheadline =>
      'Scegli esattamente come ti senti con tutto il catalogo.';
  @override
  String get premiumMoodsTitle => 'Umori premium';
  @override
  String get weeklyPlanLabel => 'Settimanale';
  @override
  String get monthlyPlanLabel => 'Mensile';
  @override
  String get annualPlanLabel => 'Annuale';
  @override
  String get weekUnit => 'settimana';
  @override
  String get monthUnit => 'mese';
  @override
  String get yearUnit => 'anno';
  @override
  String get bestValueLabel => 'Migliore offerta';
  @override
  String savePercentLabel(int percent) => 'Risparmia il $percent%';
  @override
  String get startTrialButtonLabel => 'Prova 3 giorni gratis';
  @override
  String subscribeButtonLabel(String price) => 'Abbonati · $price';
  @override
  String subscriptionLegalTrial(String price, String unit, String store) =>
      'Gratis per 3 giorni, poi $price a $unit. Si rinnova automaticamente a meno che tu non annulli almeno 24 ore prima della fine del periodo. Gestisci o annulla quando vuoi nelle impostazioni degli abbonamenti di $store.';
  @override
  String subscriptionLegalPaid(String price, String unit, String store) =>
      '$price a $unit. Si rinnova automaticamente a meno che tu non annulli almeno 24 ore prima della fine del periodo. Gestisci o annulla quando vuoi nelle impostazioni degli abbonamenti di $store.';
  @override
  String get termsLinkLabel => 'Termini di utilizzo';
  @override
  String get privacyLinkLabel => 'Informativa sulla privacy';
  @override
  String get premiumActiveTitle => 'Premium è attivo';
  @override
  String premiumPlanLine(String plan) => 'Piano $plan';
  @override
  String premiumRenewsOn(String date) => 'Si rinnova il $date';
  @override
  String premiumTrialEndsOn(String date) =>
      'La prova gratuita termina il $date';
  @override
  String premiumEndsOn(String date) => 'Termina il $date';
  @override
  String get manageSubscriptionButtonLabel => 'Gestisci abbonamento';
  @override
  String get closeLabel => 'Chiudi';
  @override
  String planCardSemanticLabel(String plan, String priceLine) =>
      'Piano $plan, $priceLine';

  // Negozio / paywall
  @override
  String get storeLoading => 'Caricamento del negozio...';
  @override
  String get storeLoadError =>
      'Non siamo riusciti a caricare il negozio in questo momento. Riprova.';
  @override
  String get storeRetry => 'Riprova';
  @override
  String get moodUnlockedLabel => 'Sbloccato';
  @override
  String get restorePurchasesButtonLabel => 'Ripristina acquisti';
  @override
  String get restoringPurchases => 'Ripristino dei tuoi acquisti...';
  @override
  String get restoreSuccessMessage =>
      'I tuoi acquisti sono stati ripristinati.';
  @override
  String get purchaseSuccessMessage =>
      'Acquisto completato. Buon divertimento!';
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
        'affectionate': 'Affettuoso',
        'hugging': 'Abbracciando',
        'laughing': 'Ridendo',
        'sleepy': 'Assonnato',
        'sick': 'Malato',
        'hurt': 'Ferito',
        'crying': 'Piangendo',
        'scared': 'Spaventato',
        'stressed': 'Stressato',
      };

  @override
  String get categoryPositive => 'Positivo';
  @override
  String get categoryPeaceful => 'Sereno';
  @override
  String get categoryNeutral => 'Neutro';
  @override
  String get categoryHard => 'Difficile';
  @override
  String get notePromptPositive => 'Cosa ha reso bella la tua giornata?';
  @override
  String get notePromptNeutral => 'Qualcosa da ricordare';
  @override
  String get notePromptHard => 'Cosa ti preoccupa?';
  @override
  String get notePromptEmpty => 'Aggiungi una nota (facoltativo)';
  @override
  String get noteExistsSemantics => 'Nota aggiunta';
  @override
  String get greetingMorning => 'Buongiorno';
  @override
  String get greetingAfternoon => 'Buon pomeriggio';
  @override
  String get greetingEvening => 'Buonasera';
  @override
  String get remindersBellLabel => 'Promemoria';
  @override
  String get moodQuestionPast => 'Come ti sentivi quel giorno?';
  @override
  String get savedLabel => 'Salvato';
  @override
  String savedStreak(int days) =>
      days == 1 ? '1 giorno di fila' : '$days giorni di fila';
  @override
  String get todayYouFeel => 'Oggi ti senti';
  @override
  String get pastYouFelt => 'Quel giorno ti sentivi';
  @override
  String get noNoteYet => 'Ancora nessuna nota.';
  @override
  String get editEntryButton => 'Modifica';
  @override
  String get forgotYesterdayPrefix => 'Hai dimenticato ieri?';
  @override
  String get forgotYesterdayAction => 'Registralo';
  @override
  String categorySectionSemantics(String category) =>
      'Stati d’animo: $category';
  @override
  String moodCellSemantics(String mood, String category) => '$mood, $category';
  @override
  String lockedMoodSemantics(String mood, String category) =>
      '$mood, $category, bloccato, Premium';
  @override
  String get tabCalendar => 'Calendario';
  @override
  String get tabInsights => 'Insights';
  @override
  String get tabLog => 'Diario';
  @override
  String get tabSettings => 'Impostazioni';
  @override
  String get insightsEmptyTitle => 'Qui troverai i tuoi insights';
  @override
  String get insightsEmptyBody =>
      'Registra qualche giorno e ti mostreremo come ti sei sentito.';

  @override
  String get sectionPremium => 'Premium';
  @override
  String get sectionReminders => 'Promemoria';
  @override
  String get sectionPrivacyData => 'Privacy e dati';
  @override
  String get sectionAppearance => 'Aspetto';
  @override
  String get sectionHelp => 'Aiuto';
  @override
  String get getPremiumTitle => 'Passa a Premium';
  @override
  String get getPremiumDetail =>
      'Insights, note protette e stati d’animo espressivi';
  @override
  String get premiumActiveRowTitle => 'Premium · Attivo';
  @override
  String get themeTitle => 'Tema';
  @override
  String get themeSystem => 'Sistema';
  @override
  String get themeLight => 'Chiaro';
  @override
  String get themeDark => 'Scuro';
  @override
  String themeRowSemantics(String current) => 'Tema, $current';
  @override
  String get sendFeedbackTitle => 'Invia feedback';
  @override
  String get sendFeedbackSemanticLabel => 'Invia feedback via email';
  @override
  String get termsTitle => 'Termini';
  @override
  String get termsSemanticLabel => 'Apri i termini di utilizzo nel browser';
  @override
  String get restorePurchasesRowSemantics => 'Ripristina acquisti';

  @override
  String get paywallTitle => 'Capisci come ti senti';
  @override
  String get paywallBenefitInsights =>
      'Insights e Year in Pixels, con tendenze a 90 e 365 giorni';
  @override
  String get paywallBenefitNotes => 'Note protette dalla biometria';
  @override
  String paywallBenefitMoods(String a, String b, String c) =>
      'Stati d’animo espressivi: $a, $b, $c e altri';
  @override
  String get trialFreeLabel => '3 giorni gratis';
  @override
  String get trialTimelineToday => 'Oggi · Accesso completo a Premium';
  @override
  String trialTimelineCharge(String date, String price) =>
      '$date · Primo addebito di $price';
}

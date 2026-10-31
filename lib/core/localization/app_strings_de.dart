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
  String get moodGridButtonLabel => 'Alle Stimmungen anzeigen';
  @override
  String get moodGridTitle => 'Alle Stimmungen';
  @override
  String get previousMoodLabel => 'Vorherige Stimmung';
  @override
  String get nextMoodLabel => 'Nächste Stimmung';
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
  String get summaryLoadError => 'Wir konnten die Monatsübersicht nicht laden.';
  @override
  String get loadingSummary => 'Monatsübersicht wird geladen...';
  @override
  String get emptySummary =>
      'Diesen Monat noch keine Einträge. Beginne mit dem Erfassen, um deine Übersicht zu sehen.';
  @override
  String get monthlyAverage => 'Häufigste Stimmung';
  @override
  String moodRepresentsMonth(String monthName) =>
      'Stimmung, die du im $monthName am häufigsten erfasst hast';
  @override
  String get bestStreak => 'Beste Serie';
  @override
  String streakText(int days) =>
      '$days Tag${days == 1 ? '' : 'e'} in Folge erfasst';
  @override
  String summaryTitle(String monthName) => 'Übersicht für $monthName';
  @override
  String get openCalendarTooltip => 'Kalender öffnen';
  @override
  String get calendarTitle => 'Kalender';
  @override
  String get openMoodPickerTooltip => 'Stimmungsauswahl öffnen';
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
  String get rateAppTitle => 'Mood Calendar bewerten';
  @override
  String get rateAppSemanticLabel => 'Mood Calendar im App Store bewerten';
  @override
  String get settingsTitle => 'Einstellungen';
  @override
  String get openSettingsTooltip => 'Einstellungen öffnen';
  @override
  String get settingsAboutSection => 'Hilfe & Info';
  @override
  String get privacyPolicyTitle => 'Datenschutzerklärung';
  @override
  String get privacyPolicySemanticLabel =>
      'Datenschutzerklärung im Browser öffnen';
  @override
  String get appVersionTitle => 'Version';
  @override
  String get privacyLinkFailed =>
      'Der Link konnte nicht geöffnet werden. Bitte versuche es später erneut.';
  @override
  String get settingsSaveFailed =>
      'Die Einstellungen konnten nicht gespeichert werden. Bitte versuche es erneut.';
  @override
  String get settingsDataSection => 'Deine Daten';
  @override
  String get usageAnalyticsTitle => 'Anonyme Nutzungsdaten teilen';
  @override
  String get usageAnalyticsSubtitle =>
      'Hilft uns zu verstehen, wie viele Menschen die App nutzen. Deine Stimmungen und Notizen sind nie enthalten.';
  @override
  String get exportHistoryTitle => 'Verlauf exportieren';
  @override
  String get exportHistorySemanticLabel =>
      'Exportiere deinen Stimmungsverlauf als Datei';
  @override
  String get exportHistoryEmpty =>
      'Es gibt noch keinen Verlauf zum Exportieren.';
  @override
  String get exportingHistory => 'Dein Verlauf wird exportiert...';
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
      'Häufigste Stimmung: $moodLabel';
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
  String formatFullDate(DateTime date) =>
      '${date.day}. ${monthNames[date.month - 1]} ${date.year}';

  @override
  List<String> get weekdayInitials => const ['M', 'D', 'M', 'D', 'F', 'S', 'S'];

  @override
  String get noteButtonLabel => 'Notiz';

  @override
  String get noteSheetTitle => 'Tagesnotiz';

  @override
  String get noteSheetDoneButton => 'Fertig';

  @override
  String get noteSheetPlaceholder => 'Erzähl mir von deinem Tag...';

  // Premium (suscripción)
  @override
  String get premiumTitle => 'Premium';
  @override
  String get openPremiumTooltip => 'Premium öffnen';
  @override
  String get premiumHeadline => 'Alle Premium-Stimmungen freischalten';
  @override
  String get premiumSubheadline =>
      'Wähle mit dem ganzen Katalog genau, wie du dich fühlst.';
  @override
  String get premiumMoodsTitle => 'Premium-Stimmungen';
  @override
  String get weeklyPlanLabel => 'Wöchentlich';
  @override
  String get monthlyPlanLabel => 'Monatlich';
  @override
  String get annualPlanLabel => 'Jährlich';
  @override
  String get weekUnit => 'Woche';
  @override
  String get monthUnit => 'Monat';
  @override
  String get yearUnit => 'Jahr';
  @override
  String get bestValueLabel => 'Bestes Angebot';
  @override
  String savePercentLabel(int percent) => 'Spare $percent %';
  @override
  String get startTrialButtonLabel => '3 Tage kostenlos testen';
  @override
  String subscribeButtonLabel(String price) => 'Abonnieren · $price';
  @override
  String subscriptionLegalTrial(String price, String unit, String store) =>
      '3 Tage kostenlos, danach $price pro $unit. Verlängert sich automatisch, wenn du nicht mindestens 24 Stunden vor Ende des Zeitraums kündigst. Verwalte oder kündige jederzeit in den Abo-Einstellungen von $store.';
  @override
  String subscriptionLegalPaid(String price, String unit, String store) =>
      '$price pro $unit. Verlängert sich automatisch, wenn du nicht mindestens 24 Stunden vor Ende des Zeitraums kündigst. Verwalte oder kündige jederzeit in den Abo-Einstellungen von $store.';
  @override
  String get termsLinkLabel => 'Nutzungsbedingungen';
  @override
  String get privacyLinkLabel => 'Datenschutzerklärung';
  @override
  String get premiumActiveTitle => 'Premium ist aktiv';
  @override
  String premiumPlanLine(String plan) => 'Abo: $plan';
  @override
  String premiumRenewsOn(String date) => 'Verlängert sich am $date';
  @override
  String premiumTrialEndsOn(String date) =>
      'Die kostenlose Testphase endet am $date';
  @override
  String premiumEndsOn(String date) => 'Endet am $date';
  @override
  String get manageSubscriptionButtonLabel => 'Abo verwalten';
  @override
  String get closeLabel => 'Schließen';
  @override
  String planCardSemanticLabel(String plan, String priceLine) =>
      'Abo $plan, $priceLine';

  // Shop / Paywall
  @override
  String get storeLoading => 'Shop wird geladen...';
  @override
  String get storeLoadError =>
      'Wir konnten den Shop gerade nicht laden. Bitte versuche es erneut.';
  @override
  String get storeRetry => 'Erneut versuchen';
  @override
  String get moodUnlockedLabel => 'Freigeschaltet';
  @override
  String get restorePurchasesButtonLabel => 'Käufe wiederherstellen';
  @override
  String get restoringPurchases => 'Deine Käufe werden wiederhergestellt...';
  @override
  String get restoreSuccessMessage => 'Deine Käufe wurden wiederhergestellt.';
  @override
  String get purchaseSuccessMessage => 'Kauf abgeschlossen. Viel Spaß!';
  @override
  String get purchaseCancelledMessage => 'Kauf abgebrochen.';
  @override
  String get purchaseNetworkErrorMessage =>
      'Keine Internetverbindung. Bitte versuche es erneut.';
  @override
  String get purchaseProductUnavailableMessage =>
      'Dieser Artikel ist gerade nicht verfügbar.';
  @override
  String get purchaseUnknownErrorMessage =>
      'Bei deinem Kauf ist etwas schiefgelaufen. Bitte versuche es erneut.';
  @override
  String get continueLabel => 'Weiter';
  @override
  String get cancelLabel => 'Abbrechen';

  @override
  Map<String, String> get moodNames => const {
        'happy': 'Glücklich',
        'calm': 'Ruhig',
        'neutral': 'Neutral',
        'sad': 'Traurig',
        'angry': 'Wütend',
        'anxious': 'Ängstlich',
        'brave': 'Mutig',
        'confident': 'Selbstbewusst',
        'romantic': 'Romantisch',
        'shy': 'Schüchtern',
        'affectionate': 'Zärtlich',
        'hugging': 'Umarmend',
        'laughing': 'Lachend',
        'sleepy': 'Schläfrig',
        'sick': 'Krank',
        'hurt': 'Verletzt',
        'crying': 'Weinend',
        'scared': 'Verängstigt',
        'stressed': 'Gestresst',
      };
}

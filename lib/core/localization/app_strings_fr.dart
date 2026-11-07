import 'package:flutter/material.dart';

import 'app_strings.dart';

class AppStringsFr extends AppStrings {
  const AppStringsFr() : super(const Locale('fr'));

  @override
  String get appTitle => 'Calendrier d\'humeur';
  @override
  String get notificationChannelName => 'Rappel quotidien d\'humeur';
  @override
  String get notificationChannelDescription =>
      'Rappel quotidien pour noter comment tu te sens';
  @override
  String get reminderNotificationTitle => 'Comment te sens-tu aujourd\'hui ?';
  @override
  String get reminderNotificationBody =>
      'Touche pour enregistrer ton humeur du jour.';
  @override
  String get moodLoading => 'Chargement de ton humeur pour ce jour...';
  @override
  String get moodQuestion => 'Comment te sens-tu aujourd\'hui ?';
  @override
  String selectedMood(String moodLabel, int index, int total) =>
      'Option d\'humeur $moodLabel, ${index + 1} sur $total';
  @override
  String get save => 'Enregistrer';
  @override
  String get saveMoodButtonLabel => 'Enregistrer l\'humeur';
  @override
  String get moodGridButtonLabel => 'Voir toutes les humeurs';
  @override
  String get moodGridTitle => 'Toutes les humeurs';
  @override
  String get previousMoodLabel => 'Humeur précédente';
  @override
  String get nextMoodLabel => 'Humeur suivante';
  @override
  String get savingMood => 'Enregistrement de ton humeur...';
  @override
  String get saveMoodError =>
      'Nous n\'avons pas pu enregistrer ton humeur pour le moment. Réessaie.';
  @override
  String get loadingMonthError =>
      'Nous n\'avons pas pu charger ce mois. Réessaie.';
  @override
  String get retry => 'Réessayer';
  @override
  String get summaryLoadError =>
      'Nous n\'avons pas pu charger le résumé mensuel.';
  @override
  String get loadingSummary => 'Chargement du résumé mensuel...';
  @override
  String get emptySummary =>
      'Pas encore d\'entrées ce mois-ci. Commence à enregistrer pour voir ton résumé.';
  @override
  String get monthlyAverage => 'Humeur la plus fréquente';
  @override
  String moodRepresentsMonth(String monthName) =>
      'Humeur que tu as le plus enregistrée en $monthName';
  @override
  String get bestStreak => 'Meilleure série';
  @override
  String streakText(int days) =>
      '$days jour${days == 1 ? '' : 's'} consécutif${days == 1 ? '' : 's'} à enregistrer ton humeur';
  @override
  String summaryTitle(String monthName) => 'Résumé de $monthName';
  @override
  String get openCalendarTooltip => 'Ouvrir le calendrier';
  @override
  String get calendarTitle => 'Calendrier';
  @override
  String get openMoodPickerTooltip => 'Ouvrir la sélection de l\'humeur';
  @override
  String get previousMonthTooltip => 'Mois précédent';
  @override
  String get nextMonthTooltip => 'Mois suivant';
  @override
  String get reminderSheetTitle => 'Rappels quotidiens';
  @override
  String get reminderSheetDescription =>
      'Choisis si les rappels sont actifs et l\'heure qui te convient le mieux.';
  @override
  String get reminderEnabledTitle => 'Activer les rappels quotidiens';
  @override
  String get reminderEnabledSubtitle =>
      'Active ou désactive la notification quotidienne';
  @override
  String get reminderTimeTitle => 'Heure du rappel';
  @override
  String get rateAppTitle => 'Noter Mood Calendar';
  @override
  String get rateAppSemanticLabel => 'Noter Mood Calendar sur l\'App Store';
  @override
  String get settingsTitle => 'Réglages';
  @override
  String get openSettingsTooltip => 'Ouvrir les réglages';
  @override
  String get settingsAboutSection => 'Aide et à propos';
  @override
  String get privacyPolicyTitle => 'Politique de confidentialité';
  @override
  String get privacyPolicySemanticLabel =>
      'Ouvrir la politique de confidentialité dans le navigateur';
  @override
  String get appVersionTitle => 'Version';
  @override
  String get privacyLinkFailed =>
      'Impossible d\'ouvrir le lien. Réessaie plus tard.';
  @override
  String get settingsSaveFailed =>
      'Impossible d\'enregistrer les réglages. Réessaie.';
  @override
  String get settingsDataSection => 'Tes données';
  @override
  String get usageAnalyticsTitle =>
      'Partager des données d\'utilisation anonymes';
  @override
  String get usageAnalyticsSubtitle =>
      'Nous aide à savoir combien de personnes utilisent l\'app. Tes humeurs et tes notes ne sont jamais incluses.';
  @override
  String get exportHistoryTitle => 'Exporter l\'historique';
  @override
  String get exportHistorySemanticLabel =>
      'Exporter ton historique d\'humeur dans un fichier';
  @override
  String get exportHistoryEmpty =>
      'Il n\'y a pas encore d\'historique à exporter.';
  @override
  String get exportingHistory => 'Exportation de ton historique...';
  @override
  String get historyExportFailed =>
      'Nous n\'avons pas pu exporter ton historique pour le moment. Réessaie.';
  @override
  String calendarDayLabel({
    required String formattedDate,
    String? moodLabel,
    required bool isFutureDate,
  }) {
    if (isFutureDate) {
      return '$formattedDate, date future non disponible';
    }
    if (moodLabel == null) {
      return '$formattedDate, aucune humeur enregistrée';
    }
    return '$formattedDate, humeur enregistrée : $moodLabel';
  }

  @override
  String get monthlyChartSemantics => 'Graphique mensuel de l\'humeur';
  @override
  String monthlyAverageSemantics(String moodLabel) =>
      'Humeur la plus fréquente : $moodLabel';
  @override
  String bestStreakSemantics(int days) => 'Meilleure série : $days jours';

  @override
  List<String> get monthNames => const [
        'Janvier',
        'Février',
        'Mars',
        'Avril',
        'Mai',
        'Juin',
        'Juillet',
        'Août',
        'Septembre',
        'Octobre',
        'Novembre',
        'Décembre',
      ];

  @override
  String formatFullDate(DateTime date) =>
      '${date.day} ${monthNames[date.month - 1].toLowerCase()} ${date.year}';

  @override
  List<String> get weekdayInitials => const ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  String get noteButtonLabel => 'Note';

  @override
  String get noteSheetTitle => 'Note du jour';

  @override
  String get noteSheetDoneButton => 'Terminé';

  @override
  String get noteSheetPlaceholder => 'Raconte-moi ta journée...';

  // Premium (suscripción)
  @override
  String get premiumTitle => 'Premium';
  @override
  String get openPremiumTooltip => 'Ouvrir Premium';
  @override
  String get premiumHeadline => 'Débloque toutes les humeurs premium';
  @override
  String get premiumSubheadline =>
      'Choisis exactement comment tu te sens grâce à tout le catalogue.';
  @override
  String get premiumMoodsTitle => 'Humeurs premium';
  @override
  String get weeklyPlanLabel => 'Hebdomadaire';
  @override
  String get monthlyPlanLabel => 'Mensuel';
  @override
  String get annualPlanLabel => 'Annuel';
  @override
  String get weekUnit => 'semaine';
  @override
  String get monthUnit => 'mois';
  @override
  String get yearUnit => 'an';
  @override
  String get bestValueLabel => 'Meilleure offre';
  @override
  String savePercentLabel(int percent) => 'Économise $percent %';
  @override
  String get startTrialButtonLabel => 'Essayer 3 jours gratuits';
  @override
  String subscribeButtonLabel(String price) => 'S\'abonner · $price';
  @override
  String subscriptionLegalTrial(String price, String unit, String store) =>
      'Gratuit pendant 3 jours, puis $price par $unit. Se renouvelle automatiquement sauf si tu annules au moins 24 heures avant la fin de la période. Gère ou annule à tout moment dans les réglages d\'abonnement de $store.';
  @override
  String subscriptionLegalPaid(String price, String unit, String store) =>
      '$price par $unit. Se renouvelle automatiquement sauf si tu annules au moins 24 heures avant la fin de la période. Gère ou annule à tout moment dans les réglages d\'abonnement de $store.';
  @override
  String get termsLinkLabel => 'Conditions d\'utilisation';
  @override
  String get privacyLinkLabel => 'Politique de confidentialité';
  @override
  String get premiumActiveTitle => 'Premium est actif';
  @override
  String premiumPlanLine(String plan) => 'Formule $plan';
  @override
  String premiumRenewsOn(String date) => 'Se renouvelle le $date';
  @override
  String premiumTrialEndsOn(String date) =>
      'L\'essai gratuit se termine le $date';
  @override
  String premiumEndsOn(String date) => 'Se termine le $date';
  @override
  String get manageSubscriptionButtonLabel => 'Gérer l\'abonnement';
  @override
  String get closeLabel => 'Fermer';
  @override
  String planCardSemanticLabel(String plan, String priceLine) =>
      'Formule $plan, $priceLine';

  // Boutique / paywall
  @override
  String get storeLoading => 'Chargement de la boutique...';
  @override
  String get storeLoadError =>
      'Nous n\'avons pas pu charger la boutique pour le moment. Réessaie.';
  @override
  String get storeRetry => 'Réessayer';
  @override
  String get moodUnlockedLabel => 'Débloquée';
  @override
  String get restorePurchasesButtonLabel => 'Restaurer les achats';
  @override
  String get restoringPurchases => 'Restauration de tes achats...';
  @override
  String get restoreSuccessMessage => 'Tes achats ont été restaurés.';
  @override
  String get purchaseSuccessMessage => 'Achat terminé. Profite-en bien !';
  @override
  String get purchaseCancelledMessage => 'Achat annulé.';
  @override
  String get purchaseNetworkErrorMessage =>
      'Pas de connexion internet. Réessaie.';
  @override
  String get purchaseProductUnavailableMessage =>
      'Cet article n\'est pas disponible pour le moment.';
  @override
  String get purchaseUnknownErrorMessage =>
      'Un problème est survenu avec ton achat. Réessaie.';
  @override
  String get continueLabel => 'Continuer';
  @override
  String get cancelLabel => 'Annuler';

  @override
  Map<String, String> get moodNames => const {
        'happy': 'Heureux',
        'calm': 'Calme',
        'neutral': 'Neutre',
        'sad': 'Triste',
        'angry': 'En colère',
        'anxious': 'Anxieux',
        'brave': 'Courageux',
        'confident': 'Confiant',
        'romantic': 'Romantique',
        'shy': 'Timide',
        'affectionate': 'Affectueux',
        'hugging': 'Câlin',
        'laughing': 'Hilare',
        'sleepy': 'Somnolent',
        'sick': 'Malade',
        'hurt': 'Blessé',
        'crying': 'En pleurs',
        'scared': 'Effrayé',
        'stressed': 'Stressé',
      };

  @override
  String get categoryPositive => 'Positif';
  @override
  String get categoryPeaceful => 'Paisible';
  @override
  String get categoryNeutral => 'Neutre';
  @override
  String get categoryHard => 'Difficile';
  @override
  String get notePromptPositive =>
      'Qu’est-ce qui a rendu ta journée agréable ?';
  @override
  String get notePromptNeutral => 'Quelque chose à retenir';
  @override
  String get notePromptHard => 'Qu’est-ce qui te préoccupe ?';
  @override
  String get notePromptEmpty => 'Ajouter une note (facultatif)';
  @override
  String get noteExistsSemantics => 'Note ajoutée';
  @override
  String get greetingMorning => 'Bonjour';
  @override
  String get greetingAfternoon => 'Bon après-midi';
  @override
  String get greetingEvening => 'Bonsoir';
  @override
  String get remindersBellLabel => 'Rappels';
  @override
  String get moodQuestionPast => 'Comment te sentais-tu ce jour-là ?';
  @override
  String get savedLabel => 'Enregistré';
  @override
  String savedStreak(int days) =>
      days == 1 ? '1 jour d’affilée' : '$days jours d’affilée';
  @override
  String get todayYouFeel => 'Aujourd’hui, tu te sens';
  @override
  String get pastYouFelt => 'Ce jour-là, tu te sentais';
  @override
  String get noNoteYet => 'Pas encore de note.';
  @override
  String get editEntryButton => 'Modifier';
  @override
  String get forgotYesterdayPrefix => 'Tu as oublié hier ?';
  @override
  String get forgotYesterdayAction => 'Enregistre-le';
  @override
  String categorySectionSemantics(String category) => 'Humeurs : $category';
  @override
  String moodCellSemantics(String mood, String category) => '$mood, $category';
  @override
  String lockedMoodSemantics(String mood, String category) =>
      '$mood, $category, verrouillé, Premium';
  @override
  String get tabCalendar => 'Calendrier';
  @override
  String get tabInsights => 'Insights';
  @override
  String get tabLog => 'Journal';
  @override
  String get tabSettings => 'Réglages';
  @override
  String get insightsEmptyTitle => 'Tes insights apparaîtront ici';
  @override
  String get insightsEmptyBody =>
      'Enregistre quelques jours et nous te montrerons comment tu te sens.';

  @override
  String get sectionPremium => 'Premium';
  @override
  String get sectionReminders => 'Rappels';
  @override
  String get sectionPrivacyData => 'Confidentialité et données';
  @override
  String get sectionAppearance => 'Apparence';
  @override
  String get sectionHelp => 'Aide';
  @override
  String get getPremiumTitle => 'Passer à Premium';
  @override
  String get getPremiumDetail =>
      'Insights, notes protégées et humeurs expressives';
  @override
  String get premiumActiveRowTitle => 'Premium · Actif';
  @override
  String get themeTitle => 'Thème';
  @override
  String get themeSystem => 'Système';
  @override
  String get themeLight => 'Clair';
  @override
  String get themeDark => 'Sombre';
  @override
  String themeRowSemantics(String current) => 'Thème, $current';
  @override
  String get sendFeedbackTitle => 'Envoyer un avis';
  @override
  String get sendFeedbackSemanticLabel => 'Envoyer un avis par e-mail';
  @override
  String get termsTitle => 'Conditions';
  @override
  String get termsSemanticLabel =>
      'Ouvrir les conditions d’utilisation dans le navigateur';
  @override
  String get restorePurchasesRowSemantics => 'Restaurer les achats';

  @override
  String get paywallTitle => 'Comprends ce que tu ressens';
  @override
  String get paywallBenefitInsights =>
      'Insights et Year in Pixels, avec des tendances sur 90 et 365 jours';
  @override
  String get paywallBenefitNotes => 'Notes protégées par biométrie';
  @override
  String paywallBenefitMoods(String a, String b, String c) =>
      'Humeurs expressives : $a, $b, $c et plus';
  @override
  String get trialFreeLabel => '3 jours offerts';
  @override
  String get trialTimelineToday => 'Aujourd’hui · Accès complet à Premium';
  @override
  String trialTimelineCharge(String date, String price) =>
      '$date · Premier prélèvement de $price';

  @override
  String get calendarViewYearTooltip => "Voir l'année";
  @override
  String get chooseMonthYearLabel => "Choisir le mois et l'année";
  @override
  String get previousYearTooltip => 'Année précédente';
  @override
  String get nextYearTooltip => 'Année suivante';
  @override
  String get monthSoFarTitle => "Ton mois jusqu'ici";
  @override
  String categoryShareLabel(String category, int percent) =>
      '$category $percent %';
  @override
  String categoryDistributionSemantics(String shares) =>
      'Catégories d’humeur ce mois-ci : $shares';
  @override
  String get currentStreakTitle => 'Série en cours';
  @override
  String streakDaysUnit(int days) => days == 1 ? 'jour' : 'jours';
  @override
  String currentStreakSemantics(int days) =>
      "Série en cours : $days ${days == 1 ? 'jour' : 'jours'}";
  @override
  String dayDetailCategoryAndTime(String category, String time) =>
      '$category · enregistré à $time';
  @override
  String get dayDetailNoteTitle => 'Note';
  @override
  String dayDetailSemantics(String date) => 'Détails du $date';

  @override
  String insightsMonthTitle(String monthName) =>
      'Résumé de ${monthName.toLowerCase()}';
  @override
  String insightsEntriesCount(int count) =>
      "$count ${count == 1 ? 'entrée' : 'entrées'}";
  @override
  String get trendTitle => 'Tendance';
  @override
  String trendRangeChip(int days) => '$days j';
  @override
  String trendRangeLabel(int days) => '$days derniers jours';
  @override
  String trendChartSemantics(int days, int entries, String category) =>
      'Tendance de l’humeur, $days derniers jours, $entries entrées, surtout $category';
  @override
  String get insightsNotEnoughTitle => 'Pas encore assez de données';
  @override
  String get insightsNotEnoughBody =>
      'Enregistre encore quelques jours pour le voir.';
  @override
  String get weekdayTitle => 'Humeur selon le jour de la semaine';
  @override
  List<String> get weekdayLongNames => const [
        'lundi',
        'mardi',
        'mercredi',
        'jeudi',
        'vendredi',
        'samedi',
        'dimanche'
      ];
  @override
  String weekdayBarSemantics(String weekday, String category) =>
      '$weekday : surtout $category';
  @override
  String weekdayNoDataSemantics(String weekday) =>
      '$weekday : pas assez d’entrées';
  @override
  String yearInPixelsTitle(int year) => 'L’année en pixels · $year';
  @override
  String yearInPixelsSemantics(int year, int logged) =>
      "L’année en pixels $year : $logged ${logged == 1 ? 'jour enregistré' : 'jours enregistrés'}";
  @override
  String get seeWithPremium => 'Voir avec Premium';
  @override
  String lockedCardSemantics(String title) =>
      '$title. Verrouillé. Voir avec Premium';

  @override
  String get onboardingSkip => 'Passer';
  @override
  String onboardingStepLabel(int step) => "Étape $step sur 4";
  @override
  String get onboardingWelcomeTitle => 'Note ton humeur en 5 secondes par jour';
  @override
  String get onboardingWelcomeBody =>
      'Un geste par jour, et avec le temps tu verras ce qui te fait du bien.';
  @override
  String get onboardingGetStarted => 'Commencer';
  @override
  String get onboardingTimeTitle => 'Quand veux-tu faire ton point ?';
  @override
  String get onboardingTimeBody =>
      'La plupart le font le soir, quand la journée se termine.';
  @override
  String get onboardingMorning => 'Matin';
  @override
  String get onboardingAfternoon => 'Après-midi';
  @override
  String get onboardingNight => 'Soir';
  @override
  String onboardingTimeSuggestionSemantics(String name, String time) =>
      "$name, $time";
  @override
  String onboardingTimePickerSemantics(String time) =>
      "Heure du rappel : $time";
  @override
  String get onboardingReminderTitle => 'Un seul rappel par jour, c’est tout';
  @override
  String get onboardingReminderBody =>
      'Touche la notification pour noter ton humeur en quelques secondes.';
  @override
  String get onboardingTurnOnReminder => 'Activer le rappel';
  @override
  String get onboardingNotNow => 'Pas maintenant';
  @override
  String get onboardingLogTitle => 'Comment te sens-tu en ce moment ?';
  @override
  String get onboardingLogBody =>
      'Choisis le plus proche. Tu pourras le changer plus tard.';
  @override
  String get onboardingSaveFirstDay => 'Enregistrer mon premier jour';
  @override
  String get onboardingDayOneTitle => 'Jour 1 de ton calendrier';
  @override
  String onboardingDayOneToday(String mood) => "Aujourd’hui : $mood";
  @override
  String get onboardingCalendarPreviewSemantics =>
      'Aperçu d’un calendrier rempli d’humeurs';
  @override
  String get reminderPermissionDenied =>
      'Les notifications sont désactivées pour Mood Calendar. Active-les dans les réglages de l’appareil pour recevoir le rappel.';
  @override
  String get noteLockTitle => 'Verrouiller les notes';
  @override
  String get noteLockSubtitle => 'Biométrie ou code de l’appareil';
  @override
  String get noteLockNeedsPasscodeSubtitle =>
      'Configure un code sur ton appareil pour utiliser le verrouillage';
  @override
  String get noteLockNeedsPasscodeMessage =>
      'Configure d’abord un code ou la biométrie sur ton appareil pour verrouiller tes notes.';
  @override
  String get noteLockProBadge => 'Pro';
  @override
  String get noteLockedLabel => 'Note verrouillée';
  @override
  String get noteLockedUnlockAction => 'Déverrouiller';
  @override
  String get noteLockedSemantics =>
      'Note verrouillée. Appuie deux fois pour déverrouiller';
  @override
  String get noteLockReasonUnlock => 'Déverrouille tes notes';
  @override
  String get noteLockReasonEnable => 'Active le verrouillage des notes';
  @override
  String get noteLockReasonDisable => 'Désactive le verrouillage des notes';
  @override
  String get noteLockReasonExport =>
      'Déverrouille tes notes pour exporter ton historique';
}

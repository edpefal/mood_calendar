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
  String get reminderSettingsTooltip => 'Paramètres de rappel';
  @override
  String get openCalendarTooltip => 'Ouvrir le calendrier';
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
  String get saveReminderSettings =>
      'Enregistrer les paramètres de rappel';
  @override
  String reminderSavedAt(String formattedTime) =>
      'Rappel quotidien programmé pour $formattedTime.';
  @override
  String get remindersTurnedOff => 'Les rappels quotidiens sont désactivés.';
  @override
  String get exportHistoryTooltip => 'Exporter l\'historique';
  @override
  String get exportingHistory => 'Exportation de ton historique...';
  @override
  String historyExportedTo(String fileName) =>
      'Historique exporté vers $fileName.';
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
  List<String> get weekdayInitials =>
      const ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  String get noteHint => 'Écrire une note...';

  // Boutique / paywall
  @override
  String get storeTitle => 'Boutique d\'humeurs';
  @override
  String get openStoreTooltip => 'Ouvrir la boutique';
  @override
  String get storeMoodsSectionTitle => 'Humeurs premium';
  @override
  String get storePacksSectionTitle => 'Packs';
  @override
  String get storeLoading => 'Chargement de la boutique...';
  @override
  String get storeLoadError =>
      'Nous n\'avons pas pu charger la boutique pour le moment. Réessaie.';
  @override
  String get storeEmptyMoods =>
      'Aucune humeur premium disponible pour le moment.';
  @override
  String get storeEmptyPacks => 'Aucun pack disponible pour le moment.';
  @override
  String get moodUnlockedLabel => 'Débloquée';
  @override
  String buyMoodButtonLabel(String moodLabel, String price) =>
      'Acheter $moodLabel · $price';
  @override
  String packIncludesMoods(String moodLabels) => 'Comprend : $moodLabels';
  @override
  String buyPackButtonLabel(String packLabel, String price) =>
      'Acheter $packLabel · $price';
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
  String get packOverlapWarningTitle => 'Tu as déjà certaines de ces humeurs';
  @override
  String packOverlapWarningMessage(String moodLabels) =>
      'Tu possèdes déjà $moodLabels, mais tu peux quand même acheter ce pack à son prix plein.';
  @override
  String get continueLabel => 'Continuer';
  @override
  String get cancelLabel => 'Annuler';
}

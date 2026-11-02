import 'package:flutter/material.dart';

import 'app_strings.dart';

class AppStringsEs extends AppStrings {
  const AppStringsEs() : super(const Locale('es'));

  @override
  String get appTitle => 'Calendario de ánimo';
  @override
  String get notificationChannelName => 'Recordatorio diario de ánimo';
  @override
  String get notificationChannelDescription =>
      'Recordatorio diario para registrar cómo te sientes';
  @override
  String get reminderNotificationTitle => '¿Cómo te sientes hoy?';
  @override
  String get reminderNotificationBody => 'Toca para registrar tu ánimo de hoy.';
  @override
  String get moodLoading => 'Cargando tu ánimo para este día...';
  @override
  String get moodQuestion => '¿Cómo te sientes hoy?';
  @override
  String selectedMood(String moodLabel, int index, int total) =>
      'Opción de ánimo $moodLabel, ${index + 1} de $total';
  @override
  String get save => 'Guardar';
  @override
  String get saveMoodButtonLabel => 'Guardar registro de ánimo';
  @override
  String get moodGridButtonLabel => 'Ver todos los moods';
  @override
  String get moodGridTitle => 'Todos los moods';
  @override
  String get previousMoodLabel => 'Mood anterior';
  @override
  String get nextMoodLabel => 'Mood siguiente';
  @override
  String get savingMood => 'Guardando tu ánimo...';
  @override
  String get saveMoodError =>
      'No pudimos guardar tu ánimo en este momento. Inténtalo de nuevo.';
  @override
  String get loadingMonthError =>
      'No pudimos cargar este mes. Inténtalo de nuevo.';
  @override
  String get retry => 'Reintentar';
  @override
  String get summaryLoadError => 'No pudimos cargar el resumen mensual.';
  @override
  String get loadingSummary => 'Cargando resumen mensual...';
  @override
  String get emptySummary =>
      'Todavía no hay registros este mes. Empieza a registrar para ver tu resumen.';
  @override
  String get monthlyAverage => 'Ánimo más frecuente';
  @override
  String moodRepresentsMonth(String monthName) =>
      'Ánimo que más registraste en $monthName';
  @override
  String get bestStreak => 'Mejor racha';
  @override
  String streakText(int days) =>
      '$days día${days == 1 ? '' : 's'} seguidos registrando tu ánimo';
  @override
  String summaryTitle(String monthName) => 'Resumen de $monthName';
  @override
  String get openCalendarTooltip => 'Abrir calendario';
  @override
  String get calendarTitle => 'Calendario';
  @override
  String get openMoodPickerTooltip => 'Abrir selección de ánimo';
  @override
  String get previousMonthTooltip => 'Mes anterior';
  @override
  String get nextMonthTooltip => 'Mes siguiente';
  @override
  String get reminderSheetTitle => 'Recordatorios diarios';
  @override
  String get reminderSheetDescription =>
      'Elige si los recordatorios están activos y la hora que mejor se adapta a tu rutina.';
  @override
  String get reminderEnabledTitle => 'Activar recordatorios diarios';
  @override
  String get reminderEnabledSubtitle =>
      'Activa o desactiva la notificación diaria';
  @override
  String get reminderTimeTitle => 'Hora del recordatorio';
  @override
  String get rateAppTitle => 'Calificar Mood Calendar';
  @override
  String get rateAppSemanticLabel => 'Calificar Mood Calendar en el App Store';
  @override
  String get settingsTitle => 'Ajustes';
  @override
  String get openSettingsTooltip => 'Abrir ajustes';
  @override
  String get settingsAboutSection => 'Ayuda y acerca de';
  @override
  String get privacyPolicyTitle => 'Política de privacidad';
  @override
  String get privacyPolicySemanticLabel =>
      'Abrir la política de privacidad en el navegador';
  @override
  String get appVersionTitle => 'Versión';
  @override
  String get privacyLinkFailed =>
      'No se pudo abrir el enlace. Inténtalo de nuevo más tarde.';
  @override
  String get settingsSaveFailed =>
      'No se pudieron guardar los ajustes. Inténtalo de nuevo.';
  @override
  String get settingsDataSection => 'Tus datos';
  @override
  String get usageAnalyticsTitle => 'Compartir datos de uso anónimos';
  @override
  String get usageAnalyticsSubtitle =>
      'Nos ayuda a saber cuántas personas usan la app. Nunca se incluyen tus estados de ánimo ni tus notas.';
  @override
  String get exportHistoryTitle => 'Exportar historial';
  @override
  String get exportHistorySemanticLabel =>
      'Exportar tu historial de ánimo como archivo';
  @override
  String get exportHistoryEmpty => 'Aún no hay historial para exportar.';
  @override
  String get exportingHistory => 'Exportando tu historial...';
  @override
  String get historyExportFailed =>
      'No pudimos exportar tu historial en este momento. Inténtalo de nuevo.';
  @override
  String calendarDayLabel({
    required String formattedDate,
    String? moodLabel,
    required bool isFutureDate,
  }) {
    if (isFutureDate) {
      return '$formattedDate, fecha futura no disponible';
    }
    if (moodLabel == null) {
      return '$formattedDate, sin ánimo registrado';
    }
    return '$formattedDate, ánimo registrado: $moodLabel';
  }

  @override
  String get monthlyChartSemantics => 'Gráfica mensual de estados de ánimo';
  @override
  String monthlyAverageSemantics(String moodLabel) =>
      'Ánimo más frecuente: $moodLabel';
  @override
  String bestStreakSemantics(int days) => 'Mejor racha: $days días';

  @override
  List<String> get monthNames => const [
        'Enero',
        'Febrero',
        'Marzo',
        'Abril',
        'Mayo',
        'Junio',
        'Julio',
        'Agosto',
        'Septiembre',
        'Octubre',
        'Noviembre',
        'Diciembre',
      ];

  @override
  String formatFullDate(DateTime date) =>
      '${date.day} de ${monthNames[date.month - 1].toLowerCase()} de ${date.year}';

  @override
  List<String> get weekdayInitials => const ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  String get noteButtonLabel => 'Nota';

  @override
  String get noteSheetTitle => 'Nota del día';

  @override
  String get noteSheetDoneButton => 'Listo';

  @override
  String get noteSheetPlaceholder => 'Cuéntame sobre tu día...';

  // Premium (suscripción)
  @override
  String get premiumTitle => 'Premium';
  @override
  String get openPremiumTooltip => 'Abrir Premium';
  @override
  String get premiumHeadline => 'Desbloquea todos los moods premium';
  @override
  String get premiumSubheadline =>
      'Elige justo cómo te sientes con todo el catálogo.';
  @override
  String get premiumMoodsTitle => 'Moods premium';
  @override
  String get weeklyPlanLabel => 'Semanal';
  @override
  String get monthlyPlanLabel => 'Mensual';
  @override
  String get annualPlanLabel => 'Anual';
  @override
  String get weekUnit => 'semana';
  @override
  String get monthUnit => 'mes';
  @override
  String get yearUnit => 'año';
  @override
  String get bestValueLabel => 'Mejor valor';
  @override
  String savePercentLabel(int percent) => 'Ahorra $percent%';
  @override
  String get startTrialButtonLabel => 'Probar 3 días gratis';
  @override
  String subscribeButtonLabel(String price) => 'Suscribirme · $price';
  @override
  String subscriptionLegalTrial(String price, String unit, String store) =>
      'Gratis durante 3 días y después $price por $unit. Se renueva automáticamente salvo que canceles al menos 24 horas antes de que termine el periodo. Gestiona o cancela cuando quieras en los ajustes de suscripciones de $store.';
  @override
  String subscriptionLegalPaid(String price, String unit, String store) =>
      '$price por $unit. Se renueva automáticamente salvo que canceles al menos 24 horas antes de que termine el periodo. Gestiona o cancela cuando quieras en los ajustes de suscripciones de $store.';
  @override
  String get termsLinkLabel => 'Términos de uso';
  @override
  String get privacyLinkLabel => 'Política de privacidad';
  @override
  String get premiumActiveTitle => 'Premium está activo';
  @override
  String premiumPlanLine(String plan) => 'Plan $plan';
  @override
  String premiumRenewsOn(String date) => 'Se renueva el $date';
  @override
  String premiumTrialEndsOn(String date) => 'La prueba gratis termina el $date';
  @override
  String premiumEndsOn(String date) => 'Termina el $date';
  @override
  String get manageSubscriptionButtonLabel => 'Gestionar suscripción';
  @override
  String get closeLabel => 'Cerrar';
  @override
  String planCardSemanticLabel(String plan, String priceLine) =>
      'Plan $plan, $priceLine';

  // Tienda / paywall
  @override
  String get storeLoading => 'Cargando la tienda...';
  @override
  String get storeLoadError =>
      'No pudimos cargar la tienda en este momento. Inténtalo de nuevo.';
  @override
  String get storeRetry => 'Reintentar';
  @override
  String get moodUnlockedLabel => 'Desbloqueado';
  @override
  String get restorePurchasesButtonLabel => 'Restaurar compras';
  @override
  String get restoringPurchases => 'Restaurando tus compras...';
  @override
  String get restoreSuccessMessage => 'Tus compras fueron restauradas.';
  @override
  String get purchaseSuccessMessage => 'Compra completada. ¡Disfrútalo!';
  @override
  String get purchaseCancelledMessage => 'Compra cancelada.';
  @override
  String get purchaseNetworkErrorMessage =>
      'Sin conexión a internet. Inténtalo de nuevo.';
  @override
  String get purchaseProductUnavailableMessage =>
      'Este producto no está disponible en este momento.';
  @override
  String get purchaseUnknownErrorMessage =>
      'Algo salió mal con tu compra. Inténtalo de nuevo.';
  @override
  String get continueLabel => 'Continuar';
  @override
  String get cancelLabel => 'Cancelar';

  @override
  Map<String, String> get moodNames => const {
        'happy': 'Feliz',
        'calm': 'Tranquilo',
        'neutral': 'Neutral',
        'sad': 'Triste',
        'angry': 'Enojado',
        'anxious': 'Ansioso',
        'brave': 'Valiente',
        'confident': 'Seguro',
        'romantic': 'Romántico',
        'shy': 'Tímido',
        'affectionate': 'Cariñoso',
        'hugging': 'Abrazando',
        'laughing': 'Riendo',
        'sleepy': 'Con sueño',
        'sick': 'Enfermo',
        'hurt': 'Lastimado',
        'crying': 'Llorando',
        'scared': 'Asustado',
        'stressed': 'Estresado',
      };
}

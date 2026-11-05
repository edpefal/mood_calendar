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

  @override
  String get categoryPositive => 'Positivo';
  @override
  String get categoryPeaceful => 'Tranquilo';
  @override
  String get categoryNeutral => 'Neutral';
  @override
  String get categoryHard => 'Difícil';
  @override
  String get notePromptPositive => '¿Qué hizo bueno tu día?';
  @override
  String get notePromptNeutral => 'Algo que quieras recordar';
  @override
  String get notePromptHard => '¿Qué te preocupa?';
  @override
  String get notePromptEmpty => 'Añade una nota (opcional)';
  @override
  String get noteExistsSemantics => 'Nota añadida';
  @override
  String get greetingMorning => 'Buenos días';
  @override
  String get greetingAfternoon => 'Buenas tardes';
  @override
  String get greetingEvening => 'Buenas noches';
  @override
  String get remindersBellLabel => 'Recordatorios';
  @override
  String get moodQuestionPast => '¿Cómo te sentiste ese día?';
  @override
  String get savedLabel => 'Guardado';
  @override
  String savedStreak(int days) =>
      days == 1 ? '1 día seguido' : '$days días seguidos';
  @override
  String get todayYouFeel => 'Hoy te sientes';
  @override
  String get pastYouFelt => 'Ese día te sentiste';
  @override
  String get noNoteYet => 'Aún no hay nota.';
  @override
  String get editEntryButton => 'Editar';
  @override
  String get forgotYesterdayPrefix => '¿Olvidaste ayer?';
  @override
  String get forgotYesterdayAction => 'Regístralo';
  @override
  String categorySectionSemantics(String category) =>
      'Estados de ánimo: $category';
  @override
  String moodCellSemantics(String mood, String category) => '$mood, $category';
  @override
  String lockedMoodSemantics(String mood, String category) =>
      '$mood, $category, bloqueado, Premium';
  @override
  String get tabCalendar => 'Calendario';
  @override
  String get tabInsights => 'Insights';
  @override
  String get tabLog => 'Registro';
  @override
  String get tabSettings => 'Ajustes';
  @override
  String get insightsEmptyTitle => 'Aquí vivirán tus insights';
  @override
  String get insightsEmptyBody =>
      'Registra unos días y te mostraremos cómo te has sentido.';

  @override
  String get sectionPremium => 'Premium';
  @override
  String get sectionReminders => 'Recordatorios';
  @override
  String get sectionPrivacyData => 'Privacidad y datos';
  @override
  String get sectionAppearance => 'Apariencia';
  @override
  String get sectionHelp => 'Ayuda';
  @override
  String get getPremiumTitle => 'Obtener Premium';
  @override
  String get getPremiumDetail =>
      'Insights, notas protegidas y moods expresivos';
  @override
  String get premiumActiveRowTitle => 'Premium · Activo';
  @override
  String get themeTitle => 'Tema';
  @override
  String get themeSystem => 'Sistema';
  @override
  String get themeLight => 'Claro';
  @override
  String get themeDark => 'Oscuro';
  @override
  String themeRowSemantics(String current) => 'Tema, $current';
  @override
  String get sendFeedbackTitle => 'Enviar comentarios';
  @override
  String get sendFeedbackSemanticLabel => 'Enviar comentarios por correo';
  @override
  String get termsTitle => 'Términos';
  @override
  String get termsSemanticLabel => 'Abrir los términos de uso en el navegador';
  @override
  String get restorePurchasesRowSemantics => 'Restaurar compras';

  @override
  String get paywallTitle => 'Entiende cómo te sientes';
  @override
  String get paywallBenefitInsights =>
      'Insights y Year in Pixels, con tendencias de 90 y 365 días';
  @override
  String get paywallBenefitNotes => 'Notas protegidas con biometría';
  @override
  String paywallBenefitMoods(String a, String b, String c) =>
      'Moods expresivos: $a, $b, $c y más';
  @override
  String get trialFreeLabel => '3 días gratis';
  @override
  String get trialTimelineToday => 'Hoy · Acceso completo a Premium';
  @override
  String trialTimelineCharge(String date, String price) =>
      '$date · Primer cobro de $price';

  @override
  String get calendarViewYearTooltip => 'Ver año';
  @override
  String get chooseMonthYearLabel => 'Elegir mes y año';
  @override
  String get previousYearTooltip => 'Año anterior';
  @override
  String get nextYearTooltip => 'Año siguiente';
  @override
  String get monthSoFarTitle => 'Tu mes hasta ahora';
  @override
  String categoryShareLabel(String category, int percent) =>
      '$category $percent%';
  @override
  String categoryDistributionSemantics(String shares) =>
      'Categorías de ánimo este mes: $shares';
  @override
  String get currentStreakTitle => 'Racha actual';
  @override
  String streakDaysUnit(int days) => days == 1 ? 'día' : 'días';
  @override
  String currentStreakSemantics(int days) =>
      "Racha actual: $days ${days == 1 ? 'día' : 'días'}";
  @override
  String dayDetailCategoryAndTime(String category, String time) =>
      '$category · hora de registro $time';
  @override
  String get dayDetailNoteTitle => 'Nota';
  @override
  String dayDetailSemantics(String date) => 'Detalle del $date';

  @override
  String insightsMonthTitle(String monthName) =>
      'Resumen de ${monthName.toLowerCase()}';
  @override
  String insightsEntriesCount(int count) =>
      "$count ${count == 1 ? 'entrada' : 'entradas'}";
  @override
  String get trendTitle => 'Tendencia';
  @override
  String trendRangeChip(int days) => '$days d';
  @override
  String trendRangeLabel(int days) => 'Últimos $days días';
  @override
  String trendChartSemantics(int days, int entries, String category) =>
      'Tendencia del ánimo, últimos $days días, $entries entradas, sobre todo $category';
  @override
  String get insightsNotEnoughTitle => 'Aún no hay suficientes datos';
  @override
  String get insightsNotEnoughBody => 'Registra unos días más para verlo.';
  @override
  String get weekdayTitle => 'Ánimo por día de la semana';
  @override
  List<String> get weekdayLongNames => const [
        'lunes',
        'martes',
        'miércoles',
        'jueves',
        'viernes',
        'sábado',
        'domingo'
      ];
  @override
  String weekdayBarSemantics(String weekday, String category) =>
      '$weekday: sobre todo $category';
  @override
  String weekdayNoDataSemantics(String weekday) => '$weekday: pocas entradas';
  @override
  String yearInPixelsTitle(int year) => 'Año en píxeles · $year';
  @override
  String yearInPixelsSemantics(int year, int logged) =>
      "Año en píxeles $year: $logged ${logged == 1 ? 'día registrado' : 'días registrados'}";
  @override
  String get seeWithPremium => 'Ver con Premium';
  @override
  String lockedCardSemantics(String title) =>
      '$title. Bloqueado. Ver con Premium';
}

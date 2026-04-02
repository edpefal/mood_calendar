import 'package:flutter/material.dart';

class AppStrings {
  const AppStrings._(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('es'),
    Locale('en'),
  ];

  static const spanish = AppStrings._(Locale('es'));
  static const english = AppStrings._(Locale('en'));

  static AppStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return forLocale(locale);
  }

  static AppStrings forLocale(Locale locale) {
    return locale.languageCode == 'en' ? english : spanish;
  }

  bool get isEnglish => locale.languageCode == 'en';

  String get appTitle => isEnglish ? 'Mood Calendar' : 'Calendario de animo';
  String get notificationChannelName =>
      isEnglish ? 'Daily Mood Reminder' : 'Recordatorio diario de animo';
  String get notificationChannelDescription => isEnglish
      ? 'Daily reminder to log how you feel'
      : 'Recordatorio diario para registrar como te sientes';
  String get reminderNotificationTitle =>
      isEnglish ? 'How are you feeling today?' : 'Como te sientes hoy?';
  String get reminderNotificationBody => isEnglish
      ? 'Tap to record your mood for today.'
      : 'Toca para registrar tu animo de hoy.';
  String get moodLoading => isEnglish
      ? 'Loading your mood for this day...'
      : 'Cargando tu animo para este dia...';
  String get moodQuestion =>
      isEnglish ? 'How are you feeling today?' : 'Como te sientes hoy?';
  String selectedMood(String moodLabel, int index, int total) => isEnglish
      ? '$moodLabel mood option, ${index + 1} of $total'
      : 'Opcion de animo $moodLabel, ${index + 1} de $total';
  String get save => isEnglish ? 'Save' : 'Guardar';
  String get saveMoodButtonLabel =>
      isEnglish ? 'Save mood entry' : 'Guardar registro de animo';
  String get savingMood =>
      isEnglish ? 'Saving your mood...' : 'Guardando tu animo...';
  String get saveMoodError => isEnglish
      ? 'We could not save your mood right now. Please try again.'
      : 'No pudimos guardar tu animo en este momento. Intentalo de nuevo.';
  String get loadingMonthError => isEnglish
      ? 'We could not load this month. Please try again.'
      : 'No pudimos cargar este mes. Intentalo de nuevo.';
  String get retry => isEnglish ? 'Retry' : 'Reintentar';
  String get summaryLoadError => isEnglish
      ? 'We could not load the monthly summary.'
      : 'No pudimos cargar el resumen mensual.';
  String get loadingSummary =>
      isEnglish ? 'Loading monthly summary...' : 'Cargando resumen mensual...';
  String get emptySummary => isEnglish
      ? 'No entries this month yet. Start recording to see your summary.'
      : 'Todavia no hay registros este mes. Empieza a registrar para ver tu resumen.';
  String get monthlyAverage =>
      isEnglish ? 'Monthly average' : 'Promedio mensual';
  String moodRepresentsMonth(String monthName) => isEnglish
      ? 'Mood that best represents $monthName'
      : 'Animo que mejor representa $monthName';
  String get bestStreak => isEnglish ? 'Best streak' : 'Mejor racha';
  String streakText(int days) => isEnglish
      ? '$days day${days == 1 ? '' : 's'} in a row recording your mood'
      : '$days dia${days == 1 ? '' : 's'} seguidos registrando tu animo';
  String summaryTitle(String monthName) =>
      isEnglish ? '$monthName Summary' : 'Resumen de $monthName';
  String get reminderSettingsTooltip =>
      isEnglish ? 'Reminder settings' : 'Configuracion de recordatorios';
  String get openCalendarTooltip =>
      isEnglish ? 'Open calendar' : 'Abrir calendario';
  String get previousMonthTooltip =>
      isEnglish ? 'Previous month' : 'Mes anterior';
  String get nextMonthTooltip => isEnglish ? 'Next month' : 'Mes siguiente';
  String get reminderSheetTitle =>
      isEnglish ? 'Daily reminders' : 'Recordatorios diarios';
  String get reminderSheetDescription => isEnglish
      ? 'Choose whether reminders are active and what time works best for you.'
      : 'Elige si los recordatorios estan activos y la hora que mejor se adapta a tu rutina.';
  String get reminderEnabledTitle =>
      isEnglish ? 'Enable daily reminders' : 'Activar recordatorios diarios';
  String get reminderEnabledSubtitle => isEnglish
      ? 'Turn the daily notification on or off'
      : 'Activa o desactiva la notificacion diaria';
  String get reminderTimeTitle =>
      isEnglish ? 'Reminder time' : 'Hora del recordatorio';
  String get saveReminderSettings => isEnglish
      ? 'Save reminder settings'
      : 'Guardar configuracion de recordatorios';
  String reminderSavedAt(String formattedTime) => isEnglish
      ? 'Daily reminder set for $formattedTime.'
      : 'Recordatorio diario configurado para las $formattedTime.';
  String get remindersTurnedOff => isEnglish
      ? 'Daily reminders are turned off.'
      : 'Los recordatorios diarios estan desactivados.';
  String get exportHistoryTooltip =>
      isEnglish ? 'Export history' : 'Exportar historial';
  String get exportingHistory =>
      isEnglish ? 'Exporting your history...' : 'Exportando tu historial...';
  String historyExportedTo(String fileName) => isEnglish
      ? 'History exported to $fileName.'
      : 'Historial exportado en $fileName.';
  String get historyExportFailed => isEnglish
      ? 'We could not export your history right now. Please try again.'
      : 'No pudimos exportar tu historial en este momento. Intentalo de nuevo.';
  String calendarDayLabel({
    required String formattedDate,
    String? moodLabel,
    required bool isFutureDate,
  }) {
    if (isEnglish) {
      if (isFutureDate) {
        return '$formattedDate, future date unavailable';
      }
      if (moodLabel == null) {
        return '$formattedDate, no mood recorded';
      }
      return '$formattedDate, recorded mood: $moodLabel';
    }

    if (isFutureDate) {
      return '$formattedDate, fecha futura no disponible';
    }
    if (moodLabel == null) {
      return '$formattedDate, sin animo registrado';
    }
    return '$formattedDate, animo registrado: $moodLabel';
  }

  String get monthlyChartSemantics =>
      isEnglish ? 'Monthly mood chart' : 'Grafica mensual de estados de animo';
  String monthlyAverageSemantics(String moodLabel) => isEnglish
      ? 'Monthly average mood: $moodLabel'
      : 'Promedio mensual del animo: $moodLabel';
  String bestStreakSemantics(int days) =>
      isEnglish ? 'Best streak: $days days' : 'Mejor racha: $days dias';

  List<String> get monthNames => isEnglish
      ? const [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ]
      : const [
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

  List<String> get weekdayInitials => isEnglish
      ? const ['S', 'M', 'T', 'W', 'T', 'F', 'S']
      : const ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
}

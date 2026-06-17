import 'package:flutter/material.dart';

import 'app_strings.dart';

class AppStringsEs extends AppStrings {
  const AppStringsEs() : super(const Locale('es'));

  @override
  String get appTitle => 'Calendario de animo';
  @override
  String get notificationChannelName => 'Recordatorio diario de animo';
  @override
  String get notificationChannelDescription =>
      'Recordatorio diario para registrar como te sientes';
  @override
  String get reminderNotificationTitle => 'Como te sientes hoy?';
  @override
  String get reminderNotificationBody => 'Toca para registrar tu animo de hoy.';
  @override
  String get moodLoading => 'Cargando tu animo para este dia...';
  @override
  String get moodQuestion => 'Como te sientes hoy?';
  @override
  String selectedMood(String moodLabel, int index, int total) =>
      'Opcion de animo $moodLabel, ${index + 1} de $total';
  @override
  String get save => 'Guardar';
  @override
  String get saveMoodButtonLabel => 'Guardar registro de animo';
  @override
  String get savingMood => 'Guardando tu animo...';
  @override
  String get saveMoodError =>
      'No pudimos guardar tu animo en este momento. Intentalo de nuevo.';
  @override
  String get loadingMonthError =>
      'No pudimos cargar este mes. Intentalo de nuevo.';
  @override
  String get retry => 'Reintentar';
  @override
  String get summaryLoadError => 'No pudimos cargar el resumen mensual.';
  @override
  String get loadingSummary => 'Cargando resumen mensual...';
  @override
  String get emptySummary =>
      'Todavia no hay registros este mes. Empieza a registrar para ver tu resumen.';
  @override
  String get monthlyAverage => 'Promedio mensual';
  @override
  String moodRepresentsMonth(String monthName) =>
      'Animo que mejor representa $monthName';
  @override
  String get bestStreak => 'Mejor racha';
  @override
  String streakText(int days) =>
      '$days dia${days == 1 ? '' : 's'} seguidos registrando tu animo';
  @override
  String summaryTitle(String monthName) => 'Resumen de $monthName';
  @override
  String get reminderSettingsTooltip => 'Configuracion de recordatorios';
  @override
  String get openCalendarTooltip => 'Abrir calendario';
  @override
  String get previousMonthTooltip => 'Mes anterior';
  @override
  String get nextMonthTooltip => 'Mes siguiente';
  @override
  String get reminderSheetTitle => 'Recordatorios diarios';
  @override
  String get reminderSheetDescription =>
      'Elige si los recordatorios estan activos y la hora que mejor se adapta a tu rutina.';
  @override
  String get reminderEnabledTitle => 'Activar recordatorios diarios';
  @override
  String get reminderEnabledSubtitle =>
      'Activa o desactiva la notificacion diaria';
  @override
  String get reminderTimeTitle => 'Hora del recordatorio';
  @override
  String get saveReminderSettings => 'Guardar configuracion de recordatorios';
  @override
  String reminderSavedAt(String formattedTime) =>
      'Recordatorio diario configurado para las $formattedTime.';
  @override
  String get remindersTurnedOff =>
      'Los recordatorios diarios estan desactivados.';
  @override
  String get exportHistoryTooltip => 'Exportar historial';
  @override
  String get exportingHistory => 'Exportando tu historial...';
  @override
  String historyExportedTo(String fileName) =>
      'Historial exportado en $fileName.';
  @override
  String get historyExportFailed =>
      'No pudimos exportar tu historial en este momento. Intentalo de nuevo.';
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
      return '$formattedDate, sin animo registrado';
    }
    return '$formattedDate, animo registrado: $moodLabel';
  }

  @override
  String get monthlyChartSemantics => 'Grafica mensual de estados de animo';
  @override
  String monthlyAverageSemantics(String moodLabel) =>
      'Promedio mensual del animo: $moodLabel';
  @override
  String bestStreakSemantics(int days) => 'Mejor racha: $days dias';

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
  List<String> get weekdayInitials =>
      const ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  String get noteHint => 'Escribe una nota...';
}

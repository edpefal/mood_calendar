import 'app_theme_preference.dart';

class AppSettings {
  const AppSettings({
    required this.dailyReminderEnabled,
    required this.dailyReminderHour,
    required this.dailyReminderMinute,
    this.usageAnalyticsEnabled = true,
    this.themePreference = AppThemePreference.system,
    this.noteLockEnabled = false,
  });

  final bool dailyReminderEnabled;
  final int dailyReminderHour;
  final int dailyReminderMinute;

  /// Si la medición anónima de uso está permitida (opt-out, activa por defecto).
  final bool usageAnalyticsEnabled;

  /// Tema elegido en Settings (Sistema por defecto).
  final AppThemePreference themePreference;

  /// Si el texto de las notas pide autenticación del dispositivo (Premium).
  /// Sobrevive a un vencimiento de la suscripción: ver `note-lock`.
  final bool noteLockEnabled;

  static const defaults = AppSettings(
    dailyReminderEnabled: true,
    dailyReminderHour: 18,
    dailyReminderMinute: 0,
  );

  AppSettings copyWith({
    bool? dailyReminderEnabled,
    int? dailyReminderHour,
    int? dailyReminderMinute,
    bool? usageAnalyticsEnabled,
    AppThemePreference? themePreference,
    bool? noteLockEnabled,
  }) {
    return AppSettings(
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
      dailyReminderMinute: dailyReminderMinute ?? this.dailyReminderMinute,
      usageAnalyticsEnabled:
          usageAnalyticsEnabled ?? this.usageAnalyticsEnabled,
      themePreference: themePreference ?? this.themePreference,
      noteLockEnabled: noteLockEnabled ?? this.noteLockEnabled,
    );
  }
}

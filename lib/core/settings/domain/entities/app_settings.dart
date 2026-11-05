import 'app_theme_preference.dart';

class AppSettings {
  const AppSettings({
    required this.dailyReminderEnabled,
    required this.dailyReminderHour,
    required this.dailyReminderMinute,
    this.usageAnalyticsEnabled = true,
    this.themePreference = AppThemePreference.system,
  });

  final bool dailyReminderEnabled;
  final int dailyReminderHour;
  final int dailyReminderMinute;

  /// Si la medición anónima de uso está permitida (opt-out, activa por defecto).
  final bool usageAnalyticsEnabled;

  /// Tema elegido en Settings (Sistema por defecto).
  final AppThemePreference themePreference;

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
  }) {
    return AppSettings(
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
      dailyReminderMinute: dailyReminderMinute ?? this.dailyReminderMinute,
      usageAnalyticsEnabled:
          usageAnalyticsEnabled ?? this.usageAnalyticsEnabled,
      themePreference: themePreference ?? this.themePreference,
    );
  }
}

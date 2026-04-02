class AppSettings {
  const AppSettings({
    required this.dailyReminderEnabled,
    required this.dailyReminderHour,
    required this.dailyReminderMinute,
  });

  final bool dailyReminderEnabled;
  final int dailyReminderHour;
  final int dailyReminderMinute;

  static const defaults = AppSettings(
    dailyReminderEnabled: true,
    dailyReminderHour: 18,
    dailyReminderMinute: 0,
  );

  AppSettings copyWith({
    bool? dailyReminderEnabled,
    int? dailyReminderHour,
    int? dailyReminderMinute,
  }) {
    return AppSettings(
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
      dailyReminderMinute: dailyReminderMinute ?? this.dailyReminderMinute,
    );
  }
}

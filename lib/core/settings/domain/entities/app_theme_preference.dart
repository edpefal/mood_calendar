/// Which theme the user picked in Settings. [system] follows the device.
enum AppThemePreference {
  system,
  light,
  dark;

  /// Parses a stored name; anything unknown (or missing) falls back to
  /// [system] so a corrupted value never leaves the app unthemed.
  static AppThemePreference fromName(Object? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return AppThemePreference.system;
  }
}

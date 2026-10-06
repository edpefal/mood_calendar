class RatingPromptPolicy {
  const RatingPromptPolicy._();

  static const int firstAttemptMinEntryDays = 3;
  static const int secondAttemptMinEntryDays = 7;
  static const int maxAttempts = 2;
  static const Duration minAttemptSpacing = Duration(days: 30);

  /// Whether the app should ask the system to show its rating prompt now.
  ///
  /// [totalEntryDays] is the number of distinct days with a saved Mood Entry,
  /// [attempts] how many automatic requests were already made and
  /// [lastAttemptAt] when the latest one happened.
  static bool shouldRequest({
    required int totalEntryDays,
    required int attempts,
    required DateTime? lastAttemptAt,
    required DateTime now,
  }) {
    if (attempts >= maxAttempts) return false;
    if (attempts == 0) return totalEntryDays >= firstAttemptMinEntryDays;

    if (totalEntryDays < secondAttemptMinEntryDays) return false;
    final last = lastAttemptAt;
    if (last == null) return false;
    return now.difference(last) >= minAttemptSpacing;
  }
}

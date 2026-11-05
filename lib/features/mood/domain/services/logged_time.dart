import '../entities/mood_entry.dart';

/// The time an entry was recorded, or null when it must not be shown: the
/// entry has no time (saved before the field existed) or it was recorded on a
/// different calendar day than the entry's date (e.g. yesterday logged today).
DateTime? loggedTimeFor(MoodEntry entry) {
  final loggedAt = entry.loggedAt;
  if (loggedAt == null) return null;
  final sameDay = loggedAt.year == entry.date.year &&
      loggedAt.month == entry.date.month &&
      loggedAt.day == entry.date.day;
  return sameDay ? loggedAt : null;
}

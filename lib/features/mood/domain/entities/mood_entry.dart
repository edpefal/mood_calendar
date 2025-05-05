import 'package:freezed_annotation/freezed_annotation.dart';

part 'mood_entry.freezed.dart';
part 'mood_entry.g.dart';

@freezed
class MoodEntry with _$MoodEntry {
  const factory MoodEntry({
    required DateTime date,
    required String mood,
    String? note,
    required int intensity,
  }) = _MoodEntry;

  factory MoodEntry.fromJson(Map<String, dynamic> json) =>
      _$MoodEntryFromJson(json);
}

import 'package:hive/hive.dart';

part 'mood_model.g.dart';

@HiveType(typeId: 0)
class MoodModel extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final String mood;

  @HiveField(2)
  final String? note;

  @HiveField(3)
  final int intensity;

  /// Null for entries saved before the field existed.
  @HiveField(4)
  final DateTime? loggedAt;

  MoodModel({
    required this.date,
    required this.mood,
    this.note,
    required this.intensity,
    this.loggedAt,
  });
}

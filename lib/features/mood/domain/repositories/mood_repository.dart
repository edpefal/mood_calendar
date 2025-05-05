import '../entities/mood_entry.dart';

abstract class MoodRepository {
  Future<void> saveMood(MoodEntry entry);
  Future<List<MoodEntry>> getMoods();
}

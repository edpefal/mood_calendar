import 'package:hive/hive.dart';
import '../models/mood_model.dart';

abstract class MoodLocalDataSource {
  Future<List<MoodModel>> getMoods();
  Future<void> saveMood(MoodModel mood);
  Future<void> updateMood(MoodModel mood);
  Future<void> deleteMood(DateTime date);
  Future<MoodModel?> getMoodForDate(DateTime date);
}

class MoodLocalDataSourceImpl implements MoodLocalDataSource {
  final Box<MoodModel> moodBox;

  MoodLocalDataSourceImpl({required this.moodBox});

  @override
  Future<List<MoodModel>> getMoods() async {
    return moodBox.values.toList();
  }

  @override
  Future<void> saveMood(MoodModel mood) async {
    await moodBox.put(mood.date.toIso8601String(), mood);
  }

  @override
  Future<void> updateMood(MoodModel mood) async {
    await moodBox.put(mood.date.toIso8601String(), mood);
  }

  @override
  Future<void> deleteMood(DateTime date) async {
    await moodBox.delete(date.toIso8601String());
  }

  @override
  Future<MoodModel?> getMoodForDate(DateTime date) async {
    return moodBox.get(date.toIso8601String());
  }
}

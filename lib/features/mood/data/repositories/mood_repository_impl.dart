import 'package:hive/hive.dart';

import '../../domain/entities/mood_entry.dart';
import '../../domain/repositories/mood_repository.dart';
import '../models/mood_model.dart';

class MoodRepositoryImpl implements MoodRepository {
  final Box<MoodModel> moodBox;

  MoodRepositoryImpl(this.moodBox);

  @override
  Future<void> saveMood(MoodEntry entry) async {
    print('Saving mood for date: ${entry.date}');
    print('Mood path: ${entry.mood}');
    print('Note: ${entry.note}');
    print('Intensity: ${entry.intensity}');

    final model = MoodModel(
      date: entry.date,
      mood: entry.mood,
      note: entry.note,
      intensity: entry.intensity,
    );
    await moodBox.put(model.date.toIso8601String(), model);
    print('Mood saved successfully');

    // Print all moods after saving
    print('All moods after saving:');
    for (var mood in moodBox.values) {
      print('Date: ${mood.date}, Mood: ${mood.mood}');
    }
  }

  @override
  Future<List<MoodEntry>> getMoods() async {
    print('Getting all moods from box');
    final moods = moodBox.values.map(_mapModelToEntity).toList();
    print('Found ${moods.length} moods in box');
    print('Moods in box:');
    for (var mood in moods) {
      print('Date: ${mood.date}, Mood: ${mood.mood}');
    }
    return moods;
  }

  @override
  Future<List<MoodEntry>> getMoodsForMonth(DateTime month) async {
    final normalized = DateTime(month.year, month.month);
    final moods = moodBox.values
        .where((mood) =>
            mood.date.year == normalized.year &&
            mood.date.month == normalized.month)
        .map(_mapModelToEntity)
        .toList();
    return moods;
  }

  MoodEntry _mapModelToEntity(MoodModel model) {
    return MoodEntry(
      date: model.date,
      mood: model.mood,
      note: model.note,
      intensity: model.intensity,
    );
  }
}

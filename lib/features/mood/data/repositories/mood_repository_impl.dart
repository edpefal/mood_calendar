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
    // Legacy: entries saved before we stored real intensity had intensity 3.
    // Derive correct intensity from mood path so graph and average are correct.
    final intensity = model.intensity == 3
        ? (_intensityFromMoodPath(model.mood) ?? model.intensity)
        : model.intensity;
    return MoodEntry(
      date: model.date,
      mood: model.mood,
      note: model.note,
      intensity: intensity,
    );
  }

  /// Maps mood asset path to intensity 1–5 (same order as MoodScreen: Happy→1,
  /// Calm→2, Neutral→3, Sad→4, Angry→5). Used for legacy data that had 3.
  static int? _intensityFromMoodPath(String moodPath) {
    const pathToIntensity = {
      'assets/icon/happy.svg': 1,
      'assets/icon/calm.svg': 2,
      'assets/icon/neutral.svg': 3,
      'assets/icon/sad.svg': 4,
      'assets/icon/angry.svg': 5,
    };
    return pathToIntensity[moodPath];
  }
}

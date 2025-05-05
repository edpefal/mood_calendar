import '../../domain/entities/mood_entry.dart';
import '../../domain/repositories/mood_repository.dart';
import '../models/mood_model.dart';
import 'package:hive/hive.dart';

class MoodRepositoryImpl implements MoodRepository {
  final Box<MoodModel> moodBox;

  MoodRepositoryImpl(this.moodBox);

  @override
  Future<void> saveMood(MoodEntry entry) async {
    final model = MoodModel(
      date: entry.date,
      mood: entry.mood,
      note: entry.note,
      intensity: entry.intensity,
    );
    await moodBox.put(model.date.toIso8601String(), model);
  }

  @override
  Future<List<MoodEntry>> getMoods() async {
    return moodBox.values
        .map((m) => MoodEntry(
              date: m.date,
              mood: m.mood,
              note: m.note,
              intensity: m.intensity,
            ))
        .toList();
  }
}

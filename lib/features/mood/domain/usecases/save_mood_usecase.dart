import '../entities/mood_entry.dart';
import '../repositories/mood_repository.dart';

class SaveMoodUseCase {
  final MoodRepository repository;
  SaveMoodUseCase(this.repository);

  Future<void> call(MoodEntry entry) => repository.saveMood(entry);
}

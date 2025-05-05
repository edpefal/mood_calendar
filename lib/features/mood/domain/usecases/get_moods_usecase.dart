import '../entities/mood_entry.dart';
import '../repositories/mood_repository.dart';

class GetMoodsUseCase {
  final MoodRepository repository;
  GetMoodsUseCase(this.repository);

  Future<List<MoodEntry>> call() => repository.getMoods();
}

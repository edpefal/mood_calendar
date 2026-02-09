import '../entities/mood_entry.dart';
import '../repositories/mood_repository.dart';

class GetMoodsForMonthUseCase {
  final MoodRepository repository;

  GetMoodsForMonthUseCase(this.repository);

  Future<List<MoodEntry>> call(DateTime month) {
    final normalized = DateTime(month.year, month.month);
    return repository.getMoodsForMonth(normalized);
  }
}

import '../entities/monthly_mood_summary.dart';
import 'get_moods_for_month_usecase.dart';

class GetMonthlyMoodSummaryUseCase {
  final GetMoodsForMonthUseCase getMoodsForMonth;

  GetMonthlyMoodSummaryUseCase(this.getMoodsForMonth);

  Future<MonthlyMoodSummary> call(DateTime month) async {
    final normalizedMonth = DateTime(month.year, month.month);
    final entries = await getMoodsForMonth(normalizedMonth);
    return MonthlyMoodSummary.fromEntries(normalizedMonth, entries);
  }
}

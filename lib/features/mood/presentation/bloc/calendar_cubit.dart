import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/monthly_mood_summary.dart';
import '../../domain/usecases/get_monthly_mood_summary_usecase.dart';

class CalendarState extends Equatable {
  final DateTime visibleMonth;
  final MonthlyMoodSummary? summary;
  final bool isLoading;
  final Object? error;

  const CalendarState({
    required this.visibleMonth,
    this.summary,
    this.isLoading = false,
    this.error,
  });

  CalendarState copyWith({
    DateTime? visibleMonth,
    MonthlyMoodSummary? summary,
    bool? isLoading,
    Object? error,
  }) {
    return CalendarState(
      visibleMonth: visibleMonth ?? this.visibleMonth,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [visibleMonth, summary, isLoading, error];
}

class CalendarCubit extends Cubit<CalendarState> {
  final GetMonthlyMoodSummaryUseCase getMonthlyMoodSummary;

  CalendarCubit({
    required DateTime initialMonth,
    required this.getMonthlyMoodSummary,
  }) : super(CalendarState(
            visibleMonth: DateTime(initialMonth.year, initialMonth.month))) {
    loadMonth(initialMonth);
  }

  Future<void> loadMonth(DateTime month) async {
    final normalized = DateTime(month.year, month.month);
    emit(
        state.copyWith(visibleMonth: normalized, isLoading: true, error: null));
    try {
      final summary = await getMonthlyMoodSummary(normalized);
      emit(state.copyWith(summary: summary, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e));
    }
  }

  Future<void> refresh() => loadMonth(state.visibleMonth);

  Future<void> refreshForDate(DateTime date) =>
      loadMonth(DateTime(date.year, date.month));
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/telemetry/app_telemetry.dart';
import '../../../../core/telemetry/app_telemetry_events.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/usecases/save_mood_usecase.dart';
import '../../domain/usecases/get_moods_usecase.dart';

part 'mood_state.dart';
part 'mood_cubit.freezed.dart';

class MoodCubit extends Cubit<MoodState> {
  final SaveMoodUseCase saveMood;
  final GetMoodsUseCase getMoods;
  final AppLogger logger;
  final AppTelemetry telemetry;

  MoodCubit({
    required this.saveMood,
    required this.getMoods,
    required this.logger,
    required this.telemetry,
  }) : super(const MoodState.initial()) {
    // Cargar los estados de ánimo inmediatamente al crear el cubit
    fetchAll();
  }

  Future<void> save(MoodEntry entry) async {
    emit(const MoodState.loading());
    try {
      await saveMood(entry);
      telemetry.trackEvent(
        AppTelemetryEvents.moodSaved,
        properties: {
          'date': _dateKey(entry.date),
          'intensity': entry.intensity,
          'mood': _moodId(entry.mood),
          'has_note': (entry.note?.trim().isNotEmpty ?? false).toString(),
        },
      );
      emit(const MoodState.saved());
      // Recargar los estados de ánimo después de guardar
      await fetchAll();
    } catch (e, stackTrace) {
      logger.error(
        'Error saving mood',
        tag: 'MoodCubit',
        error: e,
        stackTrace: stackTrace,
      );
      telemetry.recordError(
        'save_mood_failed',
        reason: 'save_use_case',
        context: {
          'date': _dateKey(entry.date),
          'mood': _moodId(entry.mood),
          'intensity': entry.intensity,
        },
        error: e,
        stackTrace: stackTrace,
      );
      emit(MoodState.error(e.toString()));
    }
  }

  Future<void> fetchAll() async {
    emit(const MoodState.loading());
    try {
      final moods = await getMoods();
      logger.debug(
        'Fetched ${moods.length} moods for presentation state',
        tag: 'MoodCubit',
      );
      emit(MoodState.loaded(moods));
    } catch (e, stackTrace) {
      logger.error(
        'Error fetching moods',
        tag: 'MoodCubit',
        error: e,
        stackTrace: stackTrace,
      );
      telemetry.recordError(
        'fetch_moods_failed',
        reason: 'get_moods_use_case',
        error: e,
        stackTrace: stackTrace,
      );
      emit(MoodState.error(e.toString()));
    }
  }

  String _dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '${normalized.year}-$month-$day';
  }

  String _moodId(String moodPath) => moodPath.split('/').last;
}

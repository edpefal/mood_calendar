import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/usecases/save_mood_usecase.dart';
import '../../domain/usecases/get_moods_usecase.dart';

part 'mood_state.dart';
part 'mood_cubit.freezed.dart';

class MoodCubit extends Cubit<MoodState> {
  final SaveMoodUseCase saveMood;
  final GetMoodsUseCase getMoods;

  MoodCubit({
    required this.saveMood,
    required this.getMoods,
  }) : super(const MoodState.initial()) {
    // Cargar los estados de ánimo inmediatamente al crear el cubit
    fetchAll();
  }

  Future<void> save(MoodEntry entry) async {
    emit(const MoodState.loading());
    try {
      await saveMood(entry);
      emit(const MoodState.saved());
      // Recargar los estados de ánimo después de guardar
      await fetchAll();
    } catch (e) {
      emit(MoodState.error(e.toString()));
    }
  }

  Future<void> fetchAll() async {
    emit(const MoodState.loading());
    try {
      final moods = await getMoods();
      print('Fetched ${moods.length} moods');
      emit(MoodState.loaded(moods));
    } catch (e) {
      print('Error fetching moods: $e');
      emit(MoodState.error(e.toString()));
    }
  }
}

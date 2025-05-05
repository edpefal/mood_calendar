part of 'mood_cubit.dart';

@freezed
class MoodState with _$MoodState {
  const factory MoodState.initial() = _Initial;
  const factory MoodState.loading() = _Loading;
  const factory MoodState.saved() = _Saved;
  const factory MoodState.loaded(List<MoodEntry> moods) = _Loaded;
  const factory MoodState.error(String message) = _Error;
}

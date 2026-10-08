import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_definition.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/mood/domain/services/mood_picker_order.dart';

MoodEntry _entry(String moodId, {int day = 1, int intensity = 1}) => MoodEntry(
      date: DateTime(2026, 1, day),
      mood: 'assets/icon/$moodId.svg',
      intensity: intensity,
    );

List<String> _ids(List<MoodDefinition> moods) =>
    moods.map((mood) => mood.id).toList();

bool _onlyBase(String moodId) =>
    baseMoodDefinitions.any((mood) => mood.id == moodId);

void main() {
  final catalogIds = _ids(allMoodDefinitions);

  test('sin historial devuelve el orden del catálogo', () {
    final result = MoodPickerOrder.sort(const [], isUnlocked: (_) => true);
    expect(_ids(result), catalogIds);
  });

  test('sin historial y con premium bloqueados, estos van al final', () {
    final result = MoodPickerOrder.sort(const [], isUnlocked: _onlyBase);
    expect(_ids(result), catalogIds);
  });

  test('ordena los desbloqueados por frecuencia descendente', () {
    final entries = [
      _entry('calm', day: 1),
      _entry('calm', day: 2),
      _entry('calm', day: 3),
      _entry('happy', day: 4),
    ];
    final result = MoodPickerOrder.sort(entries, isUnlocked: _onlyBase);
    expect(_ids(result).take(5), ['calm', 'happy', 'neutral', 'sad', 'angry']);
  });

  test('el empate conserva el orden del catálogo', () {
    final entries = [_entry('sad', day: 1), _entry('calm', day: 2)];
    final result = MoodPickerOrder.sort(entries, isUnlocked: _onlyBase);
    expect(_ids(result).take(3), ['calm', 'sad', 'happy']);
  });

  test('un premium comprado se ordena junto con los desbloqueados', () {
    final entries = [_entry('brave', day: 1), _entry('brave', day: 2)];
    final result = MoodPickerOrder.sort(
      entries,
      isUnlocked: (id) => _onlyBase(id) || id == 'brave',
    );
    expect(
      _ids(result),
      ['brave', 'happy', 'calm', 'neutral', 'sad', 'angry', 'anxious', 'confident', 'romantic', 'shy'],
    );
  });

  test('un premium comprado sin uso va tras los desbloqueados ya usados', () {
    final entries = [_entry('angry')];
    final result = MoodPickerOrder.sort(
      entries,
      isUnlocked: (id) => _onlyBase(id) || id == 'anxious',
    );
    expect(
      _ids(result).take(7),
      ['angry', 'happy', 'calm', 'neutral', 'sad', 'anxious', 'brave'],
    );
  });

  test('los bloqueados van al final aunque tengan historial', () {
    final entries = [_entry('shy', day: 1), _entry('shy', day: 2)];
    final result = MoodPickerOrder.sort(entries, isUnlocked: _onlyBase);
    expect(_ids(result), catalogIds);
  });

  test('no usa intensity para ordenar', () {
    final entries = [
      _entry('happy', day: 1, intensity: 99),
      _entry('angry', day: 2, intensity: 1),
      _entry('angry', day: 3, intensity: 1),
    ];
    final result = MoodPickerOrder.sort(entries, isUnlocked: _onlyBase);
    expect(_ids(result).take(2), ['angry', 'happy']);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/localization/app_strings_en.dart';
import 'package:mood_calendar/core/localization/app_strings_es.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_definition.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/watch/domain/usecases/publish_watch_state_usecase.dart';

import '../../../support/fake_watch_channel.dart';
import '../../../support/in_memory_mood_repository.dart';

MoodEntry _entry(DateTime date, String id, int intensity) => MoodEntry(
      date: date,
      mood: 'assets/icon/$id.svg',
      intensity: intensity,
    );

void main() {
  final now = DateTime(2026, 11, 2, 9);
  final base = baseMoodDefinitions.map((mood) => mood.id).toSet();

  PublishWatchStateUseCase build(
    List<MoodEntry> entries,
    FakeWatchChannel channel, {
    Set<String> premium = const {},
    bool spanish = false,
  }) =>
      PublishWatchStateUseCase(
        repository: InMemoryMoodRepository(entries),
        channel: channel,
        isUnlocked: (id) => base.contains(id) || premium.contains(id),
        strings: () => spanish ? const AppStringsEs() : const AppStringsEn(),
        now: () => now,
      );

  test('publica los 11 moods gratis en el orden fijo por categoría', () async {
    final channel = FakeWatchChannel();

    await build([], channel)();

    final ids = channel.published.single.moods.map((m) => m.id).toList();
    expect(ids, [
      'happy',
      'calm',
      'neutral',
      'sleepy',
      'sad',
      'angry',
      'anxious',
      'stressed',
      'scared',
      'crying',
      'sick',
    ]);
  });

  test(
      'añade los premium desbloqueados en su lugar de la categoría, sin los '
      'bloqueados', () async {
    final channel = FakeWatchChannel();

    await build([], channel, premium: {'brave', 'shy'})();

    final ids = channel.published.single.moods.map((m) => m.id).toList();
    expect(ids, [
      'happy',
      'brave',
      'calm',
      'neutral',
      'sleepy',
      'shy',
      'sad',
      'angry',
      'anxious',
      'stressed',
      'scared',
      'crying',
      'sick',
    ]);
    expect(ids, isNot(contains('laughing')));
  });

  test('el orden no sigue la frecuencia de uso', () async {
    final channel = FakeWatchChannel();
    final entries = [
      _entry(DateTime(2026, 10, 30), 'sad', 4),
      _entry(DateTime(2026, 10, 31), 'sad', 4),
      _entry(DateTime(2026, 11, 1), 'angry', 5),
    ];

    await build(entries, channel)();

    final ids = channel.published.single.moods.map((m) => m.id).toList();
    expect(ids.first, 'happy');
    expect(ids.indexOf('sad'), lessThan(ids.indexOf('angry')));
    expect(ids.indexOf('calm'), lessThan(ids.indexOf('sad')));
  });

  test('los nombres salen en el idioma de la app', () async {
    final channel = FakeWatchChannel();

    await build([], channel, spanish: true)();

    final state = channel.published.single;
    expect(state.locale, 'es');
    expect(state.moods.first.name, 'Feliz');
  });

  test('today es el id del mood de hoy, o null', () async {
    final withToday = FakeWatchChannel();
    await build([_entry(now, 'calm', 2)], withToday)();
    expect(withToday.published.single.today, 'calm');

    final without = FakeWatchChannel();
    await build([_entry(DateTime(2026, 11, 1), 'calm', 2)], without)();
    expect(without.published.single.today, isNull);
  });

  test('el mapa publicado sigue el contrato', () async {
    final channel = FakeWatchChannel();
    await build([_entry(now, 'calm', 2)], channel)();

    final map = channel.published.single.toMap();
    expect(map['version'], 1);
    expect(map.keys, containsAll(['version', 'locale', 'today', 'moods']));
    expect((map['moods']! as List).first, {'id': 'happy', 'name': 'Happy'});
  });

  test('publica los ids de las elecciones procesadas y, por defecto, ninguno',
      () async {
    final channel = FakeWatchChannel();
    final publish = build([_entry(now, 'calm', 2)], channel);

    await publish();
    await publish(handledChoiceIds: ['a', 'b']);

    expect(channel.published.first.toMap()['handledChoiceIds'], isEmpty);
    expect(channel.published.last.toMap()['handledChoiceIds'], ['a', 'b']);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/localization/app_strings_en.dart';
import 'package:mood_calendar/core/localization/app_strings_es.dart';
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
  const base = {'happy', 'calm', 'neutral', 'sad', 'angry'};

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

  test('publica solo los moods desbloqueados, sin los premium bloqueados',
      () async {
    final channel = FakeWatchChannel();

    await build([], channel, premium: {'anxious'})();

    final ids = channel.published.single.moods.map((m) => m.id).toList();
    expect(ids, ['happy', 'calm', 'neutral', 'sad', 'angry', 'anxious']);
  });

  test('sigue el orden de uso del selector del iPhone', () async {
    final channel = FakeWatchChannel();
    final entries = [
      _entry(DateTime(2026, 10, 30), 'sad', 4),
      _entry(DateTime(2026, 10, 31), 'sad', 4),
      _entry(DateTime(2026, 11, 1), 'angry', 5),
    ];

    await build(entries, channel)();

    final ids = channel.published.single.moods.map((m) => m.id).toList();
    expect(ids.take(2), ['sad', 'angry']);
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
    expect((map['moods']! as List).first, {'id': 'calm', 'name': 'Calm'});
  });
}

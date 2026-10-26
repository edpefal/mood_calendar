import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/watch/domain/entities/watch_mood_choice.dart';
import 'package:mood_calendar/features/watch/domain/usecases/process_watch_inbox_usecase.dart';

import '../../../support/fake_watch_channel.dart';
import '../../../support/in_memory_mood_repository.dart';

WatchMoodChoice _choice(
  String id,
  String mood, {
  String date = '2026-11-02',
  int at = 1,
}) =>
    WatchMoodChoice(id: id, date: date, mood: mood, chosenAt: at);

void main() {
  final now = DateTime(2026, 11, 2, 9);
  const calm = 'assets/icon/calm.svg';
  const happy = 'assets/icon/happy.svg';

  ProcessWatchInboxUseCase build(
    InMemoryMoodRepository repository,
    FakeWatchChannel channel, {
    Set<String> unlockedPremium = const {},
  }) =>
      ProcessWatchInboxUseCase(
        repository: repository,
        channel: channel,
        isUnlocked: (id) {
          // Igual que MoodEntitlementsRepository: un id desconocido cuenta
          // como desbloqueado, por eso el caso de uso valida el catálogo.
          const base = {'happy', 'calm', 'neutral', 'sad', 'angry'};
          return base.contains(id) ||
              unlockedPremium.contains(id) ||
              !_catalog.contains(id);
        },
        now: () => now,
      );

  test('crea la entrada de hoy sin nota', () async {
    final repository = InMemoryMoodRepository();
    final channel = FakeWatchChannel(inbox: [_choice('a', 'calm')]);

    final result = await build(repository, channel)();

    expect(result.applied, 1);
    final saved = repository.entries.single;
    expect(saved.mood, calm);
    expect(saved.note, isNull);
    expect(saved.date, DateTime(2026, 11, 2));
    expect(saved.intensity, 2);
    expect(channel.acks.single, ['a']);
  });

  test('reemplaza el mood y conserva la nota existente', () async {
    final repository = InMemoryMoodRepository([
      MoodEntry(
        date: DateTime(2026, 11, 2),
        mood: happy,
        note: 'buen día',
        intensity: 1,
      ),
    ]);
    final channel = FakeWatchChannel(inbox: [_choice('a', 'sad')]);

    await build(repository, channel)();

    final saved = repository.entries.single;
    expect(saved.mood, 'assets/icon/sad.svg');
    expect(saved.note, 'buen día');
  });

  test('no guarda ni cuenta como aplicada una elección igual a la actual',
      () async {
    final repository = InMemoryMoodRepository([
      MoodEntry(date: DateTime(2026, 11, 2), mood: calm, intensity: 2),
    ]);
    final channel = FakeWatchChannel(inbox: [_choice('a', 'calm')]);

    final result = await build(repository, channel)();

    expect(result.applied, 0);
    expect(repository.saves, 0);
    expect(channel.acks.single, ['a']);
  });

  test('entre varias elecciones del mismo día gana la de mayor chosenAt',
      () async {
    final repository = InMemoryMoodRepository();
    final channel = FakeWatchChannel(inbox: [
      _choice('late', 'sad', at: 20),
      _choice('early', 'happy', at: 10),
    ]);

    await build(repository, channel)();

    expect(repository.entries.single.mood, 'assets/icon/sad.svg');
    expect(repository.saves, 1);
    expect(channel.acks.single, containsAll(['late', 'early']));
  });

  test('ignora ids desconocidos sin tocar datos y los confirma', () async {
    final repository = InMemoryMoodRepository();
    final channel = FakeWatchChannel(inbox: [_choice('a', 'nope')]);

    final result = await build(repository, channel)();

    expect(result.applied, 0);
    expect(result.ignored, 1);
    expect(repository.entries, isEmpty);
    expect(channel.acks.single, ['a']);
  });

  test('ignora un mood premium bloqueado', () async {
    final repository = InMemoryMoodRepository();
    final channel = FakeWatchChannel(inbox: [_choice('a', 'anxious')]);

    final result = await build(repository, channel)();

    expect(result.ignored, 1);
    expect(repository.entries, isEmpty);
  });

  test('acepta un mood premium comprado', () async {
    final repository = InMemoryMoodRepository();
    final channel = FakeWatchChannel(inbox: [_choice('a', 'anxious')]);

    await build(repository, channel, unlockedPremium: {'anxious'})();

    expect(repository.entries.single.mood, 'assets/icon/anxious.svg');
  });

  test('descarta fechas mal formadas, imposibles o futuras', () async {
    final repository = InMemoryMoodRepository();
    final channel = FakeWatchChannel(inbox: [
      _choice('bad', 'calm', date: '02/11/2026'),
      _choice('impossible', 'calm', date: '2026-02-31'),
      _choice('future', 'calm', date: '2026-11-09'),
    ]);

    final result = await build(repository, channel)();

    expect(result.applied, 0);
    expect(result.ignored, 3);
    expect(repository.entries, isEmpty);
  });

  test('una elección de las 23:50 se guarda en su fecha local', () async {
    final repository = InMemoryMoodRepository();
    final channel =
        FakeWatchChannel(inbox: [_choice('a', 'calm', date: '2026-11-01')]);

    await build(repository, channel)();

    expect(repository.entries.single.date, DateTime(2026, 11, 1));
  });

  test('con el buzón vacío no hace nada ni confirma', () async {
    final repository = InMemoryMoodRepository();
    final channel = FakeWatchChannel();

    final result = await build(repository, channel)();

    expect(result.applied, 0);
    expect(channel.acks, isEmpty);
  });
}

const _catalog = {
  'happy', 'calm', 'neutral', 'sad', 'angry', 'anxious', 'brave', 'confident',
  'romantic', 'shy', 'affectionate', 'hugging', 'laughing', 'sleepy', 'sick',
  'hurt', 'crying', 'scared', 'stressed', //
};

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/localization/app_strings_en.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/watch/domain/entities/watch_mood_choice.dart';
import 'package:mood_calendar/features/watch/domain/services/watch_sync_coordinator.dart';
import 'package:mood_calendar/features/watch/domain/usecases/process_watch_inbox_usecase.dart';
import 'package:mood_calendar/features/watch/domain/usecases/publish_watch_state_usecase.dart';

import '../../../support/fake_crash_reporter.dart';
import '../../../support/fake_watch_channel.dart';
import '../../../support/in_memory_mood_repository.dart';

WatchMoodChoice _choice(String id, String mood) => WatchMoodChoice(
      id: id,
      date: '${DateTime.now().year.toString().padLeft(4, '0')}-'
          '${DateTime.now().month.toString().padLeft(2, '0')}-'
          '${DateTime.now().day.toString().padLeft(2, '0')}',
      mood: mood,
      chosenAt: DateTime.now().millisecondsSinceEpoch,
    );

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  const base = {'happy', 'calm', 'neutral', 'sad', 'angry'};

  late InMemoryMoodRepository repository;
  late FakeWatchChannel channel;
  late StreamController<Set<String>> unlocked;
  late RecordingLogger logger;
  late WatchSyncCoordinator coordinator;

  setUp(() {
    repository = InMemoryMoodRepository();
    unlocked = StreamController<Set<String>>.broadcast();
    logger = RecordingLogger();
  });

  WatchSyncCoordinator build({List<WatchMoodChoice> inbox = const []}) {
    channel = FakeWatchChannel(inbox: inbox);
    bool isUnlocked(String id) => base.contains(id);
    coordinator = WatchSyncCoordinator(
      processInbox: ProcessWatchInboxUseCase(
        repository: repository,
        channel: channel,
        isUnlocked: isUnlocked,
      ),
      publishState: PublishWatchStateUseCase(
        repository: repository,
        channel: channel,
        isUnlocked: isUnlocked,
        strings: () => const AppStringsEn(),
      ),
      channel: channel,
      unlockedMoodIds: unlocked.stream,
      logger: logger,
      publishDebounce: const Duration(milliseconds: 10),
    );
    return coordinator;
  }

  tearDown(() async {
    await coordinator.dispose();
    await unlocked.close();
  });

  test('al arrancar aplica el buzón pendiente y publica el estado', () async {
    build(inbox: [_choice('a', 'calm')]);
    final applied = <int>[];
    coordinator.applied.listen(applied.add);

    coordinator.start();
    await _settle();

    expect(repository.entries.single.mood, 'assets/icon/calm.svg');
    expect(applied, [1]);
    expect(channel.published, isNotEmpty);
    expect(channel.published.last.today, 'calm');
  });

  test('una elección que llega con la app abierta se aplica y se republica',
      () async {
    build();
    coordinator.start();
    await _settle();
    final before = channel.published.length;

    channel.deliver(_choice('a', 'sad'));
    await _settle();

    expect(repository.entries.single.mood, 'assets/icon/sad.svg');
    expect(channel.published.length, greaterThan(before));
    expect(channel.published.last.today, 'sad');
  });

  test('cambios seguidos de desbloqueos se agrupan en una publicación',
      () async {
    build();
    coordinator.start();
    await _settle();
    final before = channel.published.length;

    unlocked
      ..add({'anxious'})
      ..add({'anxious', 'brave'})
      ..add({'anxious', 'brave', 'shy'});
    await _settle();

    expect(channel.published.length, before + 1);
  });

  test('un error al guardar se registra, no se confirma y no rompe lo demás',
      () async {
    repository.failNextSaves = 1;
    build(inbox: [_choice('a', 'calm')]);

    coordinator.start();
    await _settle();

    expect(logger.errors, isNotEmpty);
    expect(channel.acks, isEmpty);
    expect(channel.inbox, hasLength(1));

    // El siguiente aviso reintenta y esta vez se aplica.
    channel.deliver(_choice('b', 'sad'));
    await _settle();

    expect(repository.entries.single.mood, 'assets/icon/sad.svg');
    expect(channel.acks, isNotEmpty);
  });

  test('tras dispose ya no reacciona', () async {
    build();
    coordinator.start();
    await _settle();
    await coordinator.dispose();

    channel.deliver(_choice('a', 'calm'));
    await _settle();

    expect(repository.entries, isEmpty);
  });

  test('sync() procesa y publica sin esperar al debounce', () async {
    build(inbox: [_choice('a', 'calm')]);

    await coordinator.sync();

    expect(repository.entries, hasLength(1));
    expect(channel.published, isNotEmpty);
    expect(
      repository.entries.single,
      isA<MoodEntry>().having((e) => e.note, 'note', isNull),
    );
  });

  test(
      'una elección de un mood bloqueado se descarta y el reloj recibe un '
      'estado que la da por procesada', () async {
    build();
    coordinator.start();
    await _settle();
    final before = channel.published.length;

    channel.deliver(_choice('locked-1', 'anxious'));
    await _settle();

    expect(repository.entries, isEmpty);
    expect(channel.acks.last, ['locked-1']);
    expect(channel.published.length, greaterThan(before));
    expect(channel.published.last.handledChoiceIds, ['locked-1']);
    expect(
      channel.published.last.moods.map((mood) => mood.id),
      isNot(contains('anxious')),
    );
  });

  test('los ids procesados se acumulan y solo se conservan los 20 últimos',
      () async {
    build();
    coordinator.start();
    await _settle();

    for (var i = 0; i < 25; i++) {
      channel.deliver(_choice('c$i', 'anxious'));
      await _settle();
    }

    final handled = channel.published.last.handledChoiceIds;
    expect(handled, hasLength(20));
    expect(handled.first, 'c5');
    expect(handled.last, 'c24');
  });

  test('una elección que no se pudo guardar no se da por procesada', () async {
    repository.failNextSaves = 1;
    build(inbox: [_choice('a', 'calm')]);

    coordinator.start();
    await _settle();

    expect(channel.published.last.handledChoiceIds, isEmpty);
  });
}

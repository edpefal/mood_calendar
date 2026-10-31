import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/watch/data/method_channel_watch_channel.dart';
import 'package:mood_calendar/features/watch/domain/entities/watch_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const name = MethodChannelWatchChannel.channelName;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];
  Object? Function(MethodCall call) handler = (_) => null;

  setUp(() {
    calls.clear();
    handler = (_) => null;
    messenger.setMockMethodCallHandler(const MethodChannel(name), (call) async {
      calls.add(call);
      return handler(call);
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(const MethodChannel(name), null);
  });

  test('readInbox devuelve las elecciones válidas y salta las mal formadas',
      () async {
    handler = (_) => [
          {'id': 'a', 'date': '2026-11-02', 'mood': 'calm', 'chosenAt': 5},
          {'id': 'b', 'date': '2026-11-02', 'mood': '', 'chosenAt': 5},
          {'id': 'c', 'date': '2026-11-02', 'mood': 'sad', 'chosenAt': 6.0},
          'basura',
        ];

    final inbox = await MethodChannelWatchChannel().readInbox();

    expect(inbox.map((c) => c.id), ['a', 'c']);
    expect(inbox.last.chosenAt, 6);
  });

  test('readInbox devuelve vacío si la plataforma falla', () async {
    handler = (_) => throw PlatformException(code: 'boom');

    expect(await MethodChannelWatchChannel().readInbox(), isEmpty);
  });

  test('ackInbox manda los ids y no llama con una lista vacía', () async {
    final channel = MethodChannelWatchChannel();

    await channel.ackInbox([]);
    await channel.ackInbox(['a', 'b']);

    expect(calls.single.method, 'ackInbox');
    expect(calls.single.arguments, {
      'ids': ['a', 'b'],
    });
  });

  test('publishState manda el contrato y traga fallos de plataforma', () async {
    final channel = MethodChannelWatchChannel();
    const state = WatchState(
      locale: 'es',
      today: 'calm',
      moods: [WatchMoodOption(id: 'calm', name: 'Tranquilo')],
    );

    await channel.publishState(state);
    expect(calls.single.method, 'publishState');
    expect((calls.single.arguments as Map)['version'], 1);

    handler = (_) => throw PlatformException(code: 'no-watch');
    await channel.publishState(state);
  });

  test('inboxChanged desde el lado nativo emite en el stream', () async {
    final channel = MethodChannelWatchChannel();
    final events = <void>[];
    final subscription = channel.inboxChanged.listen(events.add);

    await messenger.handlePlatformMessage(
      name,
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('inboxChanged'),
      ),
      (_) {},
    );
    await Future<void>.delayed(Duration.zero);

    expect(events, hasLength(1));
    await subscription.cancel();
  });
}

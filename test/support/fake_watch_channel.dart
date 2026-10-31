import 'dart:async';

import 'package:mood_calendar/features/watch/domain/entities/watch_mood_choice.dart';
import 'package:mood_calendar/features/watch/domain/entities/watch_state.dart';
import 'package:mood_calendar/features/watch/domain/repositories/watch_channel.dart';

/// Canal de prueba: un buzón en memoria que imita al lado nativo.
class FakeWatchChannel implements WatchChannel {
  FakeWatchChannel({List<WatchMoodChoice> inbox = const []})
      : inbox = [...inbox];

  final List<WatchMoodChoice> inbox;
  final List<List<String>> acks = [];
  final List<WatchState> published = [];
  final _changed = StreamController<void>.broadcast();

  /// Simula que llega una elección con la app abierta.
  void deliver(WatchMoodChoice choice) {
    inbox.add(choice);
    _changed.add(null);
  }

  @override
  Future<List<WatchMoodChoice>> readInbox() async => [...inbox];

  @override
  Future<void> ackInbox(List<String> ids) async {
    acks.add(ids);
    inbox.removeWhere((choice) => ids.contains(choice.id));
  }

  @override
  Future<void> publishState(WatchState state) async => published.add(state);

  @override
  Stream<void> get inboxChanged => _changed.stream;
}

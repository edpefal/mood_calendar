import '../domain/entities/watch_mood_choice.dart';
import '../domain/entities/watch_state.dart';
import '../domain/repositories/watch_channel.dart';

/// Canal sin efecto: Android, tests y cualquier plataforma sin Apple Watch.
class NoopWatchChannel implements WatchChannel {
  const NoopWatchChannel();

  @override
  Future<List<WatchMoodChoice>> readInbox() async => const [];

  @override
  Future<void> ackInbox(List<String> ids) async {}

  @override
  Future<void> publishState(WatchState state) async {}

  @override
  Stream<void> get inboxChanged => const Stream.empty();
}

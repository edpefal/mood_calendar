import '../entities/watch_mood_choice.dart';
import '../entities/watch_state.dart';

/// Puente con el lado nativo de WatchConnectivity.
///
/// Swift guarda las elecciones del reloj en un buzón y Dart es el único que
/// escribe en Hive: lee el buzón, aplica y solo después confirma (`ackInbox`).
abstract class WatchChannel {
  Future<List<WatchMoodChoice>> readInbox();

  /// Quita del buzón solo las elecciones con estos ids.
  Future<void> ackInbox(List<String> ids);

  Future<void> publishState(WatchState state);

  /// Avisa de que llegó una elección nueva con la app en ejecución.
  Stream<void> get inboxChanged;
}

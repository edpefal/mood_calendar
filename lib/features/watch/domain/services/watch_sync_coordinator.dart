import 'dart:async';

import '../../../../core/logging/app_logger.dart';
import '../repositories/watch_channel.dart';
import '../usecases/process_watch_inbox_usecase.dart';
import '../usecases/publish_watch_state_usecase.dart';

/// Mantiene sincronizados el iPhone y el Apple Watch.
///
/// Procesa el buzón al arrancar, al reanudar y cuando el lado nativo avisa de
/// una elección nueva, y publica el estado al arrancar y cuando cambian los
/// moods desbloqueados, el mood de hoy o el idioma. Las operaciones se
/// serializan para que dos lecturas del buzón nunca se pisen.
class WatchSyncCoordinator {
  WatchSyncCoordinator({
    required this.processInbox,
    required this.publishState,
    required this.channel,
    required this.unlockedMoodIds,
    required this.logger,
    this.publishDebounce = const Duration(milliseconds: 400),
  });

  final ProcessWatchInboxUseCase processInbox;
  final PublishWatchStateUseCase publishState;
  final WatchChannel channel;

  /// Cambia cuando una compra o restauración altera los moods desbloqueados.
  final Stream<Set<String>> unlockedMoodIds;
  final AppLogger logger;
  final Duration publishDebounce;

  final _applied = StreamController<int>.broadcast();
  final _subscriptions = <StreamSubscription<Object?>>[];
  Future<void> _queue = Future<void>.value();
  Timer? _publishTimer;

  /// Ids de las últimas elecciones procesadas, que cada estado publicado lleva
  /// al reloj (acotado: el reloj solo necesita las recientes).
  final _recentHandledIds = <String>[];
  static const _maxHandledIds = 20;
  bool _started = false;
  bool _disposed = false;

  /// Cuántas Mood Entries cambió cada procesamiento del buzón (solo si > 0).
  Stream<int> get applied => _applied.stream;

  void start() {
    if (_started || _disposed) return;
    _started = true;
    _subscriptions
      ..add(channel.inboxChanged.listen((_) => _enqueue(_process)))
      ..add(unlockedMoodIds.listen((_) => schedulePublish()));
    unawaited(sync());
  }

  /// Procesa el buzón y publica el estado ahora.
  Future<void> sync() async {
    _enqueue(_process);
    _enqueue(_publish);
    await _queue;
  }

  /// Publica el estado tras una pausa corta, agrupando cambios seguidos.
  void schedulePublish() {
    if (_disposed) return;
    _publishTimer?.cancel();
    _publishTimer = Timer(publishDebounce, () => _enqueue(_publish));
  }

  void _enqueue(Future<void> Function() task) {
    if (_disposed) return;
    _queue = _queue.then((_) => task());
  }

  Future<void> _process() async {
    try {
      final result = await processInbox();
      if (result.handledIds.isNotEmpty) {
        _recentHandledIds.addAll(result.handledIds);
        if (_recentHandledIds.length > _maxHandledIds) {
          _recentHandledIds.removeRange(
            0,
            _recentHandledIds.length - _maxHandledIds,
          );
        }
        // También si todas se descartaron: el reloj debe enterarse de que su
        // elección ya no está pendiente y de los moods que hoy ofrece.
        schedulePublish();
      }
      if (result.applied > 0 && !_applied.isClosed) {
        _applied.add(result.applied);
      }
    } catch (error, stackTrace) {
      logger.error(
        'Error applying Apple Watch choices',
        tag: 'WatchSync',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _publish() async {
    try {
      await publishState(handledChoiceIds: List.of(_recentHandledIds));
    } catch (error, stackTrace) {
      logger.error(
        'Error publishing state to Apple Watch',
        tag: 'WatchSync',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    _publishTimer?.cancel();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _applied.close();
  }
}

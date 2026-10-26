import 'dart:async';

import 'package:flutter/services.dart';

import '../domain/entities/watch_mood_choice.dart';
import '../domain/entities/watch_state.dart';
import '../domain/repositories/watch_channel.dart';

/// Implementación sobre el `MethodChannel` que registra `WatchBridge.swift`.
///
/// El reloj nunca debe romper la app: cualquier fallo de plataforma se traga
/// y se trata como "sin elecciones" o "nada que publicar".
class MethodChannelWatchChannel implements WatchChannel {
  MethodChannelWatchChannel({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(channelName) {
    _channel.setMethodCallHandler(_onCall);
  }

  static const channelName = 'com.artlab.moodcalendar/watch';

  final MethodChannel _channel;
  final _inboxChanged = StreamController<void>.broadcast();

  Future<Object?> _onCall(MethodCall call) async {
    if (call.method == 'inboxChanged') {
      _inboxChanged.add(null);
    }
    return null;
  }

  @override
  Stream<void> get inboxChanged => _inboxChanged.stream;

  @override
  Future<List<WatchMoodChoice>> readInbox() async {
    try {
      final raw = await _channel.invokeListMethod<Object?>('readInbox');
      return [
        for (final item in raw ?? const <Object?>[])
          if (item is Map)
            if (WatchMoodChoice.tryParse(item.cast<Object?, Object?>())
                case final choice?)
              choice,
      ];
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }

  @override
  Future<void> ackInbox(List<String> ids) async {
    if (ids.isEmpty) return;
    await _channel.invokeMethod<void>('ackInbox', {'ids': ids});
  }

  @override
  Future<void> publishState(WatchState state) async {
    try {
      await _channel.invokeMethod<void>('publishState', state.toMap());
    } on PlatformException {
      // Sin reloj emparejado o sesión no activa: se reenvía en el siguiente cambio.
    } on MissingPluginException {
      // Plataforma sin puente (tests, Android).
    }
  }
}

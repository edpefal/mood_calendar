import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/telemetry/app_telemetry.dart';
import '../../../../core/telemetry/app_telemetry_events.dart';
import '../../domain/note_lock_authenticator.dart';
import 'note_lock_state.dart';

/// What happened when the user tried to turn the lock on or off.
enum NoteLockChange {
  /// The lock is now on.
  enabled,

  /// The lock is now off.
  disabled,

  /// Turning it on needs Premium (the caller opens the subscription sheet).
  needsPremium,

  /// The device has no biometrics or passcode, so the lock cannot be used.
  unavailable,

  /// The authentication was cancelled or failed; nothing changed.
  cancelled,
}

/// Single source of truth for whether note text may be shown (see the
/// `note-lock` spec). Screens never read `unlocked` themselves: they go
/// through `NoteText`, which asks this cubit.
class NoteLockCubit extends Cubit<NoteLockState> {
  NoteLockCubit({
    required NoteLockAuthenticator authenticator,
    required AppTelemetry telemetry,
    required bool Function() isSubscribed,
    bool enabled = false,
  })  : _authenticator = authenticator,
        _telemetry = telemetry,
        _isSubscribed = isSubscribed,
        super(NoteLockState(enabled: enabled));

  final NoteLockAuthenticator _authenticator;
  final AppTelemetry _telemetry;
  final bool Function() _isSubscribed;

  /// Bumped every time the session locks, so an authentication that finishes
  /// after the app went to the background cannot unlock it.
  int _epoch = 0;
  Future<bool>? _unlocking;

  /// Re-checks whether the device can still authenticate.
  Future<void> refreshAvailability() async {
    final available = await _authenticator.isAvailable();
    if (isClosed || available == state.available) return;
    emit(state.copyWith(available: available));
  }

  /// Makes the session unlocked, asking the system to authenticate when it is
  /// locked. Returns whether note text may be shown afterwards. Concurrent
  /// calls share one system prompt.
  Future<bool> unlock(String reason) {
    if (!state.conceals) return Future.value(true);
    return _unlocking ??= _authenticate(reason).whenComplete(() {
      _unlocking = null;
    });
  }

  Future<bool> _authenticate(String reason) async {
    final epoch = _epoch;
    final ok = await _authenticator.authenticate(reason);
    if (isClosed || !ok || epoch != _epoch) return false;
    emit(state.copyWith(unlocked: true));
    return true;
  }

  /// Goes back to locked (the app moved to the background).
  void lock() {
    _epoch++;
    if (state.unlocked) emit(state.copyWith(unlocked: false));
  }

  /// Turns the lock on ([enable]) or off, asking for Premium (only to turn it
  /// on) and for authentication. The caller persists the new value.
  Future<NoteLockChange> requestChange({
    required bool enable,
    required String reason,
  }) async {
    if (enable) {
      if (!_isSubscribed()) return NoteLockChange.needsPremium;
      if (!await _authenticator.isAvailable()) {
        await refreshAvailability();
        return NoteLockChange.unavailable;
      }
    } else if (await _authenticator.isAvailable()) {
      // Turning it off needs proof, unless the device can no longer ask.
      if (!state.unlocked && !await _authenticator.authenticate(reason)) {
        return NoteLockChange.cancelled;
      }
    }
    if (enable && !await _authenticator.authenticate(reason)) {
      return NoteLockChange.cancelled;
    }
    if (isClosed) return NoteLockChange.cancelled;
    emit(state.copyWith(
      enabled: enable,
      unlocked: enable,
      available: true,
    ));
    _telemetry.trackEvent(
      enable
          ? AppTelemetryEvents.noteLockEnabled
          : AppTelemetryEvents.noteLockDisabled,
    );
    return enable ? NoteLockChange.enabled : NoteLockChange.disabled;
  }

  /// Follows the saved value (a failed save puts the old one back).
  void setEnabled(bool enabled) {
    if (enabled == state.enabled) return;
    emit(state.copyWith(enabled: enabled, unlocked: enabled));
  }
}

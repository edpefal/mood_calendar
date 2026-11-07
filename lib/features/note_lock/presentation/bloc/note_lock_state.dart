import 'package:equatable/equatable.dart';

class NoteLockState extends Equatable {
  const NoteLockState({
    this.enabled = false,
    this.unlocked = false,
    this.available = true,
  });

  /// The user turned the lock on in Settings (saved across launches).
  final bool enabled;

  /// This session already passed authentication. Never saved: it is lost when
  /// the app goes to the background.
  final bool unlocked;

  /// The device can still authenticate (biometrics or passcode). Without it
  /// the lock cannot be enforced and notes are shown instead of lost.
  final bool available;

  /// Whether note text must be hidden right now.
  bool get conceals => enabled && available && !unlocked;

  /// The lock is on but the device cannot enforce it.
  bool get enabledButUnenforceable => enabled && !available;

  NoteLockState copyWith({bool? enabled, bool? unlocked, bool? available}) {
    return NoteLockState(
      enabled: enabled ?? this.enabled,
      unlocked: unlocked ?? this.unlocked,
      available: available ?? this.available,
    );
  }

  @override
  List<Object?> get props => [enabled, unlocked, available];
}
